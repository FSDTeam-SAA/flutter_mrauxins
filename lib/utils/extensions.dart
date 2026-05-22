import 'package:two_one_two_messenger/generated/l10n.dart';

extension Validator on String {
  bool isValidEmail(void Function(String message) onError) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (isEmpty) {
      onError(S.current.pleaseEnterYourEmailAddress);
      return false;
    } else if (!regex.hasMatch(this)) {
      onError(S.current.emailAddressIsInvalid);
      return false;
    }
    return true;
  }

  bool isValidPassword(void Function(String message) showError) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (isEmpty) {
      showError("Please enter your password");
      return false;
    } else if (length < 6) {
      showError("Password length must be at least 6 character long");
      return false;
    } else if (!regex.hasMatch(this)) {
      showError("Password is invalid");
      return false;
    }
    return true;
  }

  bool isValidPin(void Function(String message) showError) {
    // String pattern =
    //     r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    // RegExp regex = RegExp(pattern);
    if (isEmpty) {
      showError(S.current.pleaseEnterYourOTP);
      return false;
    } else if (length < 6) {
      showError(S.current.otpIsInvalid);
      return false;
    }
    return true;
  }

  // bool isValidMobile(void Function(String message) showError) {
  //   String universalMobilePattern = r'^\+?[1-9]\d{1,14}$';
  //   RegExp regex = RegExp(universalMobilePattern);
  //   if (isEmpty) {
  //     showError(S.current.pleaseEnterYourmobileNumber);
  //     return false;
  //   } else if (!(length > 7 && length < 14)) {
  //     showError(S.current.invalidMobileNumber);
  //     return false;
  //   } else if (!regex.hasMatch(this)) {
  //     showError(S.current.invalidMobileNumber);
  //     return false;
  //   }
  //   return true;
  // }
}
