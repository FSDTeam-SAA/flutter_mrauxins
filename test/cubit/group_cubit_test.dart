import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:two_one_two_messenger/cubit/group_cubit.dart';
import 'package:two_one_two_messenger/cubit/group_state.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/repository/group_repository.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class _FakeBuildContext extends Fake implements BuildContext {}

/// Pumps a widget tree mirroring the app's real `MyApp` setup (ScreenUtilInit
/// + localizations + EasyLoading) so cubit methods that take a real
/// `BuildContext` — and call `Utils.showLoader`/`showSnackBar` (which reach
/// into `.sp` sizing and `S.current` localized strings) under the hood —
/// have somewhere real to run against instead of a bare Fake.
Future<BuildContext> pumpRealContext(WidgetTester tester) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, child) => MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: EasyLoading.init(),
      home: Builder(builder: (context) {
        capturedContext = context;
        return const Scaffold();
      }),
    ),
  ));
  await tester.pumpAndSettle();
  return capturedContext;
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
  });

  late MockGroupRepository repository;

  setUp(() {
    repository = MockGroupRepository();
  });

  group('GroupCubit local toggles (no network)', () {
    blocTest<GroupCubit, GroupState>(
      'togglePrivateGroup flips privateGroup',
      build: () => GroupCubit(repository),
      act: (cubit) => cubit.togglePrivateGroup(true),
      expect: () => [
        isA<GroupState>().having((s) => s.privateGroup, 'privateGroup', true),
      ],
    );

    blocTest<GroupCubit, GroupState>(
      'toggleRestrictContentSharing flips restrictContentSharing',
      build: () => GroupCubit(repository),
      act: (cubit) => cubit.toggleRestrictContentSharing(true),
      expect: () => [
        isA<GroupState>().having(
            (s) => s.restrictContentSharing, 'restrictContentSharing', true),
      ],
    );

    blocTest<GroupCubit, GroupState>(
      'addToGroup adds a participant to selectedUserForGroup',
      build: () => GroupCubit(repository),
      act: (cubit) =>
          cubit.addToGroup(UserData(sId: 'u1', name: 'Alice'), false, 0),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.selectedUserForGroup.map((p) => p.id),
          'selectedUserForGroup ids',
          contains('u1'),
        ),
      ],
    );

    blocTest<GroupCubit, GroupState>(
      'addToGroup refuses to add once the member cap is reached',
      build: () => GroupCubit(repository),
      act: (cubit) {
        final added =
            cubit.addToGroup(UserData(sId: 'u1', name: 'Alice'), false, 20000);
        expect(added, isFalse);
      },
      expect: () => [],
    );

    blocTest<GroupCubit, GroupState>(
      'removeSelectedGroupUser removes a previously-added participant',
      build: () => GroupCubit(repository),
      seed: () => GroupState(
        selectedUserForGroup: {Participant(id: 'u1', name: 'Alice')},
      ),
      act: (cubit) => cubit.removeSelectedGroupUser('u1'),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.selectedUserForGroup, 'selectedUserForGroup', isEmpty),
      ],
    );

    blocTest<GroupCubit, GroupState>(
      'cleanGroupData resets settings toggles and clears selection',
      build: () => GroupCubit(repository),
      seed: () => GroupState(
        privateGroup: true,
        restrictContentSharing: true,
        selectedUserForGroup: {Participant(id: 'u1')},
      ),
      act: (cubit) => cubit.cleanGroupData(),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.privateGroup, 'privateGroup', false)
            .having((s) => s.restrictContentSharing, 'restrictContentSharing',
                false)
            .having((s) => s.selectedUserForGroup, 'selectedUserForGroup',
                isEmpty),
      ],
    );
  });

  group('GroupCubit.getGroupInfobyId', () {
    testWidgets('populates groupData and derived toggles on success',
        (tester) async {
      final context = await pumpRealContext(tester);
      final cubit = GroupCubit(repository);
      addTearDown(cubit.close);

      when(() => repository.getGroupInfobyId(
            context: any(named: 'context'),
            groupId: 'g1',
          )).thenAnswer((_) async => GroupResponseModel(
            status: Utils.APISUCCESS,
            groupData: const GroupData(
              groupId: 'g1',
              groupName: 'Test Group',
              privacy: 'private',
              inviteLink: 'messenger212://join/g1/abc',
              isAdmin: true,
            ),
          ));

      await cubit.getGroupInfobyId(context, 'g1');

      expect(cubit.state.groupLoadingState, LoadingState.success);
      expect(cubit.state.groupData?.groupName, 'Test Group');
      expect(cubit.state.privateGroup, isTrue);
      expect(cubit.state.groupNameController.text, 'Test Group');
    });

    testWidgets('sets an error state when the repository call throws',
        (tester) async {
      final context = await pumpRealContext(tester);
      final cubit = GroupCubit(repository);
      addTearDown(cubit.close);

      when(() => repository.getGroupInfobyId(
            context: any(named: 'context'),
            groupId: 'g1',
          )).thenThrow(Exception('network down'));

      await cubit.getGroupInfobyId(context, 'g1');

      expect(cubit.state.groupLoadingState, LoadingState.error);
    });
  });

  group('GroupCubit.revokeGroupInviteLink', () {
    // Note: revokeGroupInviteLink's success path ends with a call to the
    // real `homeCubit` singleton (to refresh the conversation list), which
    // can't resolve outside the full app's provider tree and throws — caught
    // by the method's own try/catch, so it doesn't fail the test, but it
    // does print a stack trace after the assertions-relevant work
    // (revoke + refetch) has already completed. Harmless console noise, not
    // a real failure.
    testWidgets(
        'revokes then refreshes group info so the UI drops the stale link',
        (tester) async {
      final context = await pumpRealContext(tester);
      final cubit = GroupCubit(repository);
      addTearDown(cubit.close);

      when(() => repository.revokeGroupInviteLink(groupId: 'g1')).thenAnswer(
          (_) async =>
              CommonResponseModel(status: Utils.APISUCCESS, message: 'Revoked'));
      when(() => repository.getGroupInfobyId(
            context: any(named: 'context'),
            groupId: 'g1',
          )).thenAnswer((_) async => GroupResponseModel(
            status: Utils.APISUCCESS,
            groupData: const GroupData(groupId: 'g1', inviteLink: null),
          ));

      await cubit.revokeGroupInviteLink(context, 'g1');

      verify(() => repository.revokeGroupInviteLink(groupId: 'g1')).called(1);
      verify(() => repository.getGroupInfobyId(
          context: any(named: 'context'), groupId: 'g1')).called(1);
      expect(cubit.state.groupData?.inviteLink, isNull);
    });

    testWidgets('does not refresh group info when the revoke call fails',
        (tester) async {
      final context = await pumpRealContext(tester);
      final cubit = GroupCubit(repository);
      addTearDown(cubit.close);

      when(() => repository.revokeGroupInviteLink(groupId: 'g1')).thenAnswer(
          (_) async => CommonResponseModel(status: 0, message: 'Failed'));

      await cubit.revokeGroupInviteLink(context, 'g1');

      verify(() => repository.revokeGroupInviteLink(groupId: 'g1')).called(1);
      verifyNever(() => repository.getGroupInfobyId(
          context: any(named: 'context'), groupId: any(named: 'groupId')));
    });
  });
}
