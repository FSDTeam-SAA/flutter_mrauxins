

import '../models/all_user.dart';
import '../models/otp_verify.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {

}

class SearchSuccess extends SearchState {
  SearchSuccess();
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchLoaded extends SearchState {
  final AllUserResponse allUserResponse;
  final List<UserData> allUser;
  final int totalPage;
  SearchLoaded(this.allUserResponse, this.allUser, this.totalPage);
}

class SearchEmpty extends SearchState {}
