import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/repository/group_repository.dart';
import 'package:two_one_two_messenger/services/group_client.dart';

class MockGroupClient extends Mock implements GroupClient {}

void main() {
  late MockGroupClient client;
  late GroupRepository repository;

  setUp(() {
    client = MockGroupClient();
    repository = GroupRepository(client);
  });

  group('GroupRepository invite-link delegation', () {
    test('checkGroupInviteName forwards name/chatId and returns availability',
        () async {
      when(() => client.checkGroupInviteName('my-name', 'chat1'))
          .thenAnswer((_) async => true);

      final result = await repository.checkGroupInviteName('my-name', 'chat1');

      expect(result, isTrue);
      verify(() => client.checkGroupInviteName('my-name', 'chat1')).called(1);
    });

    test('checkGroupInviteName surfaces a taken name as unavailable',
        () async {
      when(() => client.checkGroupInviteName('taken-name', 'chat1'))
          .thenAnswer((_) async => false);

      final result =
          await repository.checkGroupInviteName('taken-name', 'chat1');

      expect(result, isFalse);
    });

    test('revokeGroupInviteLink forwards groupId and returns the response',
        () async {
      final response = CommonResponseModel(status: 1, message: 'Link revoked');
      when(() => client.revokeGroupInviteLink(groupId: 'g1'))
          .thenAnswer((_) async => response);

      final result = await repository.revokeGroupInviteLink(groupId: 'g1');

      expect(result, same(response));
      verify(() => client.revokeGroupInviteLink(groupId: 'g1')).called(1);
    });

    test(
        'joinGroupByInvite forwards chatId and the full invite link string',
        () async {
      final response = CommonResponseModel(status: 1, message: 'Joined!');
      when(() => client.joinGroupByInvite(
            chatId: 'chat1',
            inviteLink: 'messenger212://join/chat1/my-name',
          )).thenAnswer((_) async => response);

      final result = await repository.joinGroupByInvite(
        chatId: 'chat1',
        inviteLink: 'messenger212://join/chat1/my-name',
      );

      expect(result.status, 1);
      verify(() => client.joinGroupByInvite(
            chatId: 'chat1',
            inviteLink: 'messenger212://join/chat1/my-name',
          )).called(1);
    });
  });

  group('GroupRepository membership delegation', () {
    test('addMemberToGroup/removeMemberToGroup/assignAdminToGroup forward data',
        () async {
      final response = CommonResponseModel(status: 1);
      when(() => client.addMemberToGroup(data: any(named: 'data')))
          .thenAnswer((_) async => response);
      when(() => client.removeMemberToGroup(data: any(named: 'data')))
          .thenAnswer((_) async => response);
      when(() => client.assignAdminToGroup(data: any(named: 'data')))
          .thenAnswer((_) async => response);

      await repository.addMemberToGroup(data: {'groupId': 'g1'});
      await repository.removeMemberToGroup(data: {'chatId': 'g1'});
      await repository.assignAdminToGroup(data: {'chatId': 'g1'});

      verify(() => client.addMemberToGroup(
          data: {'groupId': 'g1'})).called(1);
      verify(() => client.removeMemberToGroup(
          data: {'chatId': 'g1'})).called(1);
      verify(() => client.assignAdminToGroup(
          data: {'chatId': 'g1'})).called(1);
    });

    test('deleteGroup and leaveGroup forward groupId', () async {
      final response = CommonResponseModel(status: 1);
      when(() => client.deleteGroup(groupId: 'g1'))
          .thenAnswer((_) async => response);
      when(() => client.leaveGroup(groupId: 'g1'))
          .thenAnswer((_) async => response);

      await repository.deleteGroup(groupId: 'g1');
      await repository.leaveGroup(groupId: 'g1');

      verify(() => client.deleteGroup(groupId: 'g1')).called(1);
      verify(() => client.leaveGroup(groupId: 'g1')).called(1);
    });
  });

  group('GroupRepository search delegation', () {
    test('searchDatabase forwards search/page/limit and returns the raw list',
        () async {
      when(() => client.searchDatabase(search: 'ab', page: 2, limit: 10))
          .thenAnswer((_) async => [
                {'id': '1'}
              ]);

      final result =
          await repository.searchDatabase(search: 'ab', page: 2, limit: 10);

      expect(result, [
        {'id': '1'}
      ]);
    });

    test('searchPublicGroups forwards search/page/limit', () async {
      when(() => client.searchPublicGroups(search: 'ab', page: 1, limit: 20))
          .thenAnswer((_) async => []);

      final result = await repository.searchPublicGroups(search: 'ab');

      expect(result, isEmpty);
      verify(() => client.searchPublicGroups(search: 'ab', page: 1, limit: 20))
          .called(1);
    });
  });
}
