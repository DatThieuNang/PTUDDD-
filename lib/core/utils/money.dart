import 'package:intl/intl.dart';

String formatVnd(int value) =>
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);
