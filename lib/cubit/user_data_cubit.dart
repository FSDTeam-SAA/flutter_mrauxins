import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../database/local_db.dart';
import '../models/otp_verify.dart';

class UserDataCubit extends Cubit<UserData?> {
  final DatabaseHelper dbHelper;

  UserDataCubit(this.dbHelper) : super(null);

  // Method to fetch user data and store it in the Cubit
  Future<void> loadUserData() async {
    try {
      final user = await dbHelper.getLoginData();
      showMessage("user ==> ${user!.toDbJson()}");
      emit(user); // Emit the fetched user or null
    } catch (error) {
      emit(null); // Emit null on error
      showMessage('Error loading user data: $error');
    }
  }

  // Method to clear user data if needed
  void clearUserData() {
    emit(null);
  }
}
