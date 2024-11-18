import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'dart:async';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity;
  final SharedPreferences _prefs;
  final Logger _logger;

  bool _isOnline = true;
  bool _isInitialized = false;
  ConnectivityResult _connectionType = ConnectivityResult.none;
  DateTime? _lastOnline;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _pingTimer;
  final Duration _pingInterval = const Duration(minutes: 1);
  final String _lastOnlineKey = 'last_online_timestamp';

  ConnectivityProvider({
    Connectivity? connectivity,
    SharedPreferences? prefs,
    Logger? logger,
  }) : 
    _connectivity = connectivity ?? Connectivity(),
    _prefs = prefs ?? SharedPreferences.getInstance() as SharedPreferences,
    _logger = logger ?? Logger() {
    _initialize();
  }

  // Getters
  bool get isOnline => _isOnline;
  bool get isInitialized => _isInitialized;
  ConnectivityResult get connectionType => _connectionType;
  DateTime? get lastOnline => _lastOnline;
  bool get isWifi => _connectionType == ConnectivityResult.wifi;
  bool get isMobile => _connectionType == ConnectivityResult.mobile;
  bool get isEthernet => _connectionType == ConnectivityResult.ethernet;

  Future<void> _initialize() async {
    try {
      // Restore last online timestamp
      final lastOnlineStr = _prefs.getString(_lastOnlineKey);
      if (lastOnlineStr != null) {
        _lastOnline = DateTime.parse(lastOnlineStr);
      }

      // Check initial connection status
      _connectionType = await _connectivity.checkConnectivity();
      _isOnline = _connectionType != ConnectivityResult.none;

      // Setup connectivity stream listener
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      // Setup periodic connection check
      _setupPingTimer();

      _isInitialized = true;
      notifyListeners();

    } catch (e, stackTrace) {
      _logger.error('Failed to initialize connectivity', e, stackTrace);
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    try {
      final wasOnline = _isOnline;
      _connectionType = result;
      _isOnline = result != ConnectivityResult.none;

      if (_isOnline) {
        _lastOnline = DateTime.now();
        await _prefs.setString(_lastOnlineKey, _lastOnline!.toIso8601String());
      }

      // Log connectivity changes
      if (wasOnline != _isOnline) {
        _logger.info('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
        if (!_isOnline) {
          _logger.warning('Device went offline');
        }
      }

      notifyListeners();

    } catch (e, stackTrace) {
      _logger.error('Failed to update connection status', e, stackTrace);
    }
  }

  void _setupPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) => checkConnectivity());
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
      return _isOnline;
    } catch (e, stackTrace) {
      _logger.error('Failed to check connectivity', e, stackTrace);
      return false;
    }
  }

  Future<bool> hasStableConnection() async {
    if (!_isOnline) return false;

    try {
      bool isStable = false;
      int successfulPings = 0;
      
      for (var i = 0; i < 3; i++) {
        if (await _pingServer()) {
          successfulPings++;
        }
        await Future.delayed(const Duration(seconds: 1));
      }

      isStable = successfulPings >= 2;
      return isStable;

    } catch (e, stackTrace) {
      _logger.error('Failed to check connection stability', e, stackTrace);
      return false;
    }
  }

  Future<bool> _pingServer() async {
    try {
      // Implement actual ping logic here
      // This could be a lightweight API call or actual ping
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getConnectionInfo() async {
    try {
      final wifiInfo = await _getWifiInfo();
      final cellularInfo = await _getCellularInfo();

      return {
        'isOnline': _isOnline,
        'connectionType': _connectionType.toString(),
        'lastOnline': _lastOnline?.toIso8601String(),
        'wifi': wifiInfo,
        'cellular': cellularInfo,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _logger.error('Failed to get connection info', e, stackTrace);
      return {};
    }
  }

  Future<Map<String, dynamic>> _getWifiInfo() async {
    if (_connectionType != ConnectivityResult.wifi) {
      return {};
    }

    // Implement WiFi info gathering
    return {
      'strength': 'strong', // Example
      'secured': true,      // Example
    };
  }

  Future<Map<String, dynamic>> _getCellularInfo() async {
    if (_connectionType != ConnectivityResult.mobile) {
      return {};
    }

    // Implement cellular info gathering
    return {
      'networkType': '4G', // Example
      'strength': 'good',  // Example
    };
  }

  Future<void> enableOfflineMode() async {
    try {
      // Implement offline mode logic
      _logger.info('Enabling offline mode');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Failed to enable offline mode', e, stackTrace);
    }
  }

  Future<void> disableOfflineMode() async {
    try {
      // Implement online mode logic
      _logger.info('Disabling offline mode');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Failed to disable offline mode', e, stackTrace);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _pingTimer?.cancel();
    super.dispose();
  }
}
