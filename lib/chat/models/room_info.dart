import 'dart:io';

class RoomInfo {
  RoomInfo({
    required this.hostAddress,
    required this.hostName,
    required this.roomName,
    required this.port,
    required this.lastSeen,
  });

  final InternetAddress hostAddress;
  final String hostName;
  final String roomName;
  final int port;
  DateTime lastSeen;

  String get key => '${hostAddress.address}:$port';
}
