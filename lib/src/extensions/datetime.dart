// Defines the
extension Datetime on DateTime {
  // Returns the day of the week in text instead of a int
  String weekdayToString() {
    switch (this.weekday) {
      case 1:
        return 'Maandag';
      case 2:
        return 'Dinsdag';
      case 3:
        return 'Woensdag';
      case 4:
        return 'Donderdag';
      case 5:
        return 'Vrijdag';
      case 6:
        return 'Zaterdag';
      case 7:
        return 'Zondag';
      default:
        return '';
    }
  }

  // Returns the month in text instead of a int
  String monthToString() {
    switch (this.month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maart';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Augustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  // PadLeft is used because otherwise if the time is fe 14:00 it displays 14:0
  String formatHourAndMinutes(){
    return "$hour:${minute.toString().padLeft(2, '0')}";
  }

  // Formats the given date to a readable date, fe monday or 19 augustus
  String formatDate() {
    final DateTime now = DateTime.now();
    final DateTime nextWeek = now.add(Duration(days: 7));

    // Check if the date is within the next 7 days
    if (isAfter(now) && isBefore(nextWeek) || isAtSameMomentAs(now)) {
      // Get the day of the week fe Monday
      return weekdayToString();
    } else {
      // Get the day + month fe 19 augustus
      return '$day ${monthToString()}';
    }
  }
}