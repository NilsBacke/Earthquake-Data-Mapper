import 'package:intl/intl.dart';

class Earthquake {
  final mag;
  var place;
  var time;
  final url;
  final lat;
  final long;

  Earthquake({this.mag, this.place, this.time, this.url, this.lat, this.long}) {
    time = _getTime(this.time);
    place = this.place.toString();
    place = this.place.substring(this.place.indexOf("of ") + 3);
  }

  String _getTime(var time) {
    int milliseconds = int.parse(time.toString());
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(milliseconds);
    var format = new DateFormat.yMd().add_jm();
    return format.format(date);
  }
}
