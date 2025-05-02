import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfo(this.connectionChecker);

  /// Check if the device is connected to the internet
  Future<bool> get isConnected => connectionChecker.hasConnection;

  /// Stream of connectivity status changes
  Stream<InternetConnectionStatus> get onStatusChange => connectionChecker.onStatusChange;

  /// Listen to connectivity changes and execute callbacks
  void listenToConnectivity({
    required Function() onConnected,
    required Function() onDisconnected,
  }) {
    connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        onConnected();
      } else {
        onDisconnected();
      }
    });
  }
}
