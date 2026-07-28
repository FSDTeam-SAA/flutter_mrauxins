
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';

import '../cubit/create_stories_cubit.dart';
import '../cubit/create_stories_state.dart';
import '../widgets/appbar.dart';

class CreateStoriesScreen extends StatefulWidget {
  const CreateStoriesScreen({super.key});

  @override
  State<CreateStoriesScreen> createState() => _CreateStoriesScreenState();
}

class _CreateStoriesScreenState extends State<CreateStoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        isActionsShow: false,
        title: S.of(context).yourStories,
      ),
      body: BlocBuilder<CreateStoriesCubit, CreateStoriesState>(
          builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: ListView(
              children: [],
            ),
          ),
        );
      }),
    );
  }
}
