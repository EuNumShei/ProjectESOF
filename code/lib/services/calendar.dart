import 'dart:core';

// Função para obter o número do dia da semana
int getDayOfWeekNumber(String dayOfWeek) {
  switch (dayOfWeek) {
    case 'Monday':
      return 1;
    case 'Tuesday':
      return 2;
    case 'Wednesday':
      return 3;
    case 'Thursday':
      return 4;
    case 'Friday':
      return 5;
    case 'Saturday':
      return 6;
    default:
      return 7;
  }
}

String get_weekday() {
  // Create a DateTime object representing the current date
  DateTime now = DateTime.now();

  // Get the weekday from the DateTime object
  int weekday = now.weekday;
  // Convert the numeric representation of the weekday to a string
  String weekdayString = '';

  switch (weekday) {
    case 1:
      weekdayString = 'Monday';
      break;
    case 2:
      weekdayString = 'Tuesday';
      break;
    case 3:
      weekdayString = 'Wednesday';
      break;
    case 4:
      weekdayString = 'Thursday';
      break;
    case 5:
      weekdayString = 'Friday';
      break;
    case 6:
      weekdayString = 'Saturday'; //'Saturday';
      break;
    case 7:
      weekdayString = 'Sunday'; //'Sunday';
      break;
    default:
      weekdayString = 'Unknown';
  }

  // Print the weekday
  //print('Today is $weekdayString');

  return weekdayString;
}

class MonthWeek {
  final String month;
  final WeekRange weekNumber;

  MonthWeek(this.month, this.weekNumber);
}

class Semester {
  final int year;
  final int semester;
  final int school_year;

  Semester(this.year, this.semester, this.school_year);
}

Semester getSchoolYear() {
  final now = DateTime.now();
  final currentYear = now.year;
  final currentMonth = now.month;

  if (currentMonth == 1 || currentMonth == 2) {
    return Semester(currentYear, 1, currentYear - 1);
  } else if (currentMonth > 2 && currentMonth <= 8) {
    return Semester(currentYear, 2, currentYear - 1);
  } else {
    return Semester(currentYear, 1, currentYear);
  }
}

class WeekRange {
  final DateTime firstDay;
  final DateTime lastDay;

  WeekRange(this.firstDay, this.lastDay);
}

WeekRange getWeekRange(int weekNumber, int month, int year) {
  // Encontrar o primeiro dia do mês
  DateTime firstDayOfMonth = DateTime(year, month, 1);
  
  // Encontrar o primeiro dia da semana
  DateTime firstDayOfWeek = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
  
  // Adicionar os dias necessários para chegar à semana desejada
  firstDayOfWeek = firstDayOfWeek.add(Duration(days: (weekNumber - 1) * 7));
  
  // Encontrar o último dia da semana (seis dias após o primeiro dia da semana)
  DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));
  
  // Verificar se o último dia da semana está dentro do mês fornecido
  if (lastDayOfWeek.month != month) {
    // Se não estiver, definir o último dia da semana como o último dia do mês
    lastDayOfWeek = DateTime(year, month + 1, 0);
  }
  
  return WeekRange(firstDayOfWeek, lastDayOfWeek);
}

MonthWeek getCurrentMonthWeek() {
  final now = DateTime.now();
  final currentYear = now.year;
  final startOfMonth = DateTime(currentYear, now.month, 1);
  final weekNumber = ((now.day + (startOfMonth.weekday - 1)) / 7).ceil();
  final currentMonth = now.month;
  WeekRange weekRange = getWeekRange(weekNumber, currentMonth, currentYear);

  final month = _getMonthName(currentMonth);
  return MonthWeek(month, weekRange);
}

String _getMonthName(int monthNumber) {
  final monthNames = [
    "January", "February", "March", "April", "May", "June", 
    "July", "August", "September", "October", "November", "December"
  ];
  return monthNames[monthNumber - 1];
}
