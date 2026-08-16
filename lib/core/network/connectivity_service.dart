import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> _isConnected = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Whether the device is currently connected to the internet
  bool get isConnected => _isConnected.value;

  /// Listen to connectivity changes
  ValueNotifier<bool> get connectivityNotifier => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);

      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
      );
    } catch (e) {
      debugPrint('ConnectivityService initialization error: $e');
      _isConnected.value = true; // Default to true to not block features
    }
  }

  /// Update connection status from connectivity results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _isConnected.value = false;
      return;
    }

    _isConnected.value = results.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isConnected.value;
    } catch (e) {
      debugPrint('ConnectivityService check error: $e');
      return true;
    }
  }

  /// Dispose the subscription
  void dispose() {
    _subscription?.cancel();
    _isConnected.dispose();
  }
}

