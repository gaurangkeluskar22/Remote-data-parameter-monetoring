import 'package:intl/intl.dart';


class Data {
  final dynamic humidity;
  final dynamic temp;
  final dynamic timestamp;

  Data(this.humidity, this.temp, this.timestamp);

  Data.fromMap(Map<String, dynamic> map)
      : assert(map['humidity'] != null),
        assert(map['temp'] != null),
        assert(map['timestamp'] != null),
        humidity = map['humidity'],
        temp = (map['temp']/50)*100,
        timestamp = DateFormat('dd/MM/yy hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(map['timestamp']*1000));
}
