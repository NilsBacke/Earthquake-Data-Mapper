import 'package:intl/intl.dart';

class Earthquake {
  final mag;
  final place;
  var time;
  final url;

  Earthquake({this.mag, this.place, this.time, this.url}) {
    time = _getTime(this.time);
  }

  String _getTime(var time) {
    int milliseconds = int.parse(time.toString());
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(milliseconds);
    var format = new DateFormat.yMd().add_jm();
    return format.format(date);
  }
}
