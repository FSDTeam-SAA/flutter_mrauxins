import 'package:intl/intl.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

extension DateFormatExtension on DateTime {
  String get formattedDateTime {
    try {
      String formatted = '${day.toString().padLeft(2, '0')}/'
          '${month.toString().padLeft(2, '0')}/'
          '${year.toString()} '
          '$formatTime';
      return formatted;
    } catch (e) {
      showMessage('Error formatting date: $e');
      return toString();
    }
  }

  String get formattedDate {
    try {
      String formatted = '${day.toString().padLeft(2, '0')}/'
          '${month.toString().padLeft(2, '0')}/'
          '${year.toString()}';
      return formatted;
    } catch (e) {
      showMessage('Error formatting date: $e');
      return toString();
    }
  }

  String get formatTime {
    try {
      int hour = this.hour;
      int minute = this.minute;
      String period = hour >= 12 ? 'PM' : 'AM';

      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      showMessage('Error formatting time: $e');
      return toString();
    }
  }

  String get formattedDate2 {
    try {
      int day = this.day;
      String suffix;

      if (day >= 11 && day <= 13) {
        suffix = 'th';
      } else if (day % 10 == 1) {
        suffix = 'st';
      } else if (day % 10 == 2) {
        suffix = 'nd';
      } else if (day % 10 == 3) {
        suffix = 'rd';
      } else {
        suffix = 'th';
      }

      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      return '$day$suffix ${months[month - 1]} $year';
    } catch (e) {
      showMessage('Error formatting date: $e');
      return toString();
    }
  }

  String get formattedDateWithDay {
    try {
      return DateFormat('E, dd MMM yyyy').format(this);
    } catch (e) {
      showMessage('Error formatting date: $e');
      return toString();
    }
  }

  String get formattedDateWithDayMonthAtTime {
    try {
      String formattedDate = DateFormat("MMM dd").format(this); // Sep 15
      String formattedTime = DateFormat("HH : mm").format(this); // 22 : 53
      return "$formattedDate at $formattedTime";
    } catch (e) {
      showMessage('Error formatting date: $e');
      return toString();
    }
  }

  String get formattedDateWithDayMonthYearAtTime {
    try {
      String formattedDate = DateFormat("MMM dd, yyyy").format(this); // Sep 15
      String formattedTime = DateFormat("HH : mm").format(this); // 22 : 53
      return "$formattedDate at $formattedTime";
    } catch (e) {
      showMessage('Error formatting date: $e');
      return toString();
    }
  }

  String get differenceDaysFromNow {
    final now = DateTime.now();
    final difference = this.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return '1 day';
    } else if (difference > 1) {
      return '$difference days';
    } else {
      return '${-difference} days ago';
    }
  }

  String get toWhatsAppDateFormat {
    DateTime now = DateTime.now();

    if (year == now.year && month == now.month && day == now.day) {
      return 'Today';
    } else if (year == now.year && month == now.month && day == now.day - 1) {
      return 'Yesterday';
    } else {
      return formattedDateWithDay;
    }
  }

  String get formattedDateMonthYear {
    try {
      return DateFormat('MMMM yyyy').format(this);
    } catch (e) {
      showMessage('Error formatting date: $e');
      return toString();
    }
  }

  String get formatTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds < 1 ? 1 : difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return formatTime;
    } else if (difference.inHours < 48) {
      return 'Yesterday';
    } else {
      return formattedDate2;
    }
  }

  String get storyTime {
    final date = this;

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 1) {
      return "Just now";
    } else if (diff.inSeconds < 60) {
      return '${diff.inSeconds < 1 ? 1 : diff.inSeconds} seconds ago';
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return diff.inHours == 1 ? "1 hour ago" : "${diff.inHours} hours ago";
    } else {
      return "";
    }
  }
}
