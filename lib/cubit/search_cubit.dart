import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/local_db.dart';
import '../models/all_user.dart';
import '../models/otp_verify.dart';
import '../services/api_client.dart';
import '../utils/utils.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  List<UserData> allUsers = [];
  int totalPage = 0;

  SearchCubit(this.apiClient, this.dbHelper) : super(SearchInitial());

  Future<void> getAllUserData(
      String name, int page, int limit, BuildContext context,
      {Function()? callback}) async {
    emit(SearchLoading());
    try {
      AllUserResponse response =
          await apiClient.getAllUser(name, page, limit, context, []);
      if (response.status == Utils.APISUCCESS) {
        log("getAllUser==> ${response.data?.users?.length}");
        allUsers = response.data?.users ?? [];
        totalPage = response.data?.totalPages ?? 0;
        callback?.call();
      }
      emit(SearchSuccess());
      emit(SearchLoaded(response, allUsers, totalPage));
    } catch (e, st) {
      showMessage("Error all Users== $e, $st");
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      emit(SearchError(e.toString()));
    }
  }

  Future<void> fetchMoreData(
      String name, int page, int limit, BuildContext context) async {
    try {
      if (page > totalPage) {
        return;
      }
      AllUserResponse response =
          await apiClient.getAllUser(name, page, limit, context, []);
      if (response.status == Utils.APISUCCESS) {
        allUsers.addAll(response.data!.users!);
        totalPage = response.data!.totalPages!;
        emit(SearchLoaded(response, allUsers, totalPage));
      }
    } catch (e, st) {
      showMessage("fetchMoreData== $e, $st");
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      emit(SearchError(e.toString()));
    }
  }
}
