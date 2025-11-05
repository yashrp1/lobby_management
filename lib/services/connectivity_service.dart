import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Stream<ConnectivityResult> get onConnectivityChanged;
  Future<ConnectivityResult> check();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  // Normalize API differences across connectivity_plus versions
  // Some platforms/versions emit Stream<List<ConnectivityResult>>
  // while others emit Stream<ConnectivityResult>. We map both to a
  // single ConnectivityResult stream.
  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    final stream = _connectivity.onConnectivityChanged;
    // Type check at runtime to adapt without version pinning
    if (stream is Stream<List<ConnectivityResult>>) {
      return stream.map((list) =>
          list.isNotEmpty ? list.first : ConnectivityResult.none);
    }
    return stream as Stream<ConnectivityResult>;
  }

  @override
  Future<ConnectivityResult> check() async {
    final dynamic result = await _connectivity.checkConnectivity();
    if (result is List<ConnectivityResult>) {
      return result.isNotEmpty ? result.first : ConnectivityResult.none;
    }
    return result as ConnectivityResult;
  }
}


