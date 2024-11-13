// lib/providers/connectivity_provider.dart

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final List<String> _testUrls = [
    'https://www.google.com',
    'https://www.apple.com',
    'https://www.amazon.com',
  ];
  
  bool _isConnected = true;
  ConnectivityResult _connectionType = ConnectivityResult.none;
  DateTime? _lastConnected;
  DateTime? _lastDisconnected;
  bool _isInitialized = false;
  Timer? _connectivityTimer;
  Timer? _internetCheckTimer;
  Map<String, int> _connectionHistory = {};
  bool _isCheckingConnection = false;
  String? _error;

  // Getters
  bool get isConnected => _isConnected;
  ConnectivityResult get connectionType => _connectionType;
  DateTime? get lastConnected => _lastConnected;
  DateTime? get lastDisconnected => _lastDisconnected;
  bool get isInitialized => _isInitialized;
  Map<String, int> get connectionHistory => _connectionHistory;
  bool get isCheckingConnection => _isCheckingConnection;
  String? get error => _error;

  ConnectivityProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _initConnectivity();
      _setupTimers();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _handleError('Initialization failed', e);
    }
  }

  void _setupTimers() {
    // Check connectivity status every 30 seconds
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );

    // Check actual internet connection every 2 minutes
    _internetCheckTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _checkInternetConnection(),
    );

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(result);
    } catch (e) {
      _handleError('Initial connectivity check failed', e);
    }
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    _connectionType = result;
    final hasConnection = result != ConnectivityResult.none;
    
    if (hasConnection != _isConnected) {
      _isConnected = hasConnection;
      _updateConnectionHistory(hasConnection);
      
      if (hasConnection) {
        _lastConnected = DateTime.now();
        await _checkInternetConnection(); // Verify actual internet connection
      } else {
        _lastDisconnected = DateTime.now();
      }
      
      notifyListeners();
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(result);
    } catch (e) {
      _handleError('Connectivity check failed', e);
    }
  }

  Future<void> _checkInternetConnection() async {
    if (_isCheckingConnection) return;
    
    try {
      _isCheckingConnection = true;
      notifyListeners();

      bool hasInternet = false;
      
      // Try each test URL until we get a response or exhaust all options
      for (final url in _testUrls) {
        try {
          final response = await http.get(Uri.parse(url))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            hasInternet = true;
            break;
          }
        } catch (_) {
          continue;
        }
      }

      if (_isConnected != hasInternet) {
        _isConnected = hasInternet;
        _updateConnectionHistory(hasInternet);
        if (hasInternet) {
          _lastConnected = DateTime.now();
        } else {
          _lastDisconnected = DateTime.now();
        }
        notifyListeners();
      }

    } catch (e) {
      _handleError('Internet connection check failed', e);
    } finally {
      _isCheckingConnection = false;
      notifyListeners();
    }
  }

  void _updateConnectionHistory(bool connected) {
    final now = DateTime.now();
    final dateKey = _formatDate(now);
    
    if (connected) {
      _connectionHistory[dateKey] = (_connectionHistory[dateKey] ?? 0) + 1;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> getConnectionStats() {
    if (!_isInitialized) return {};

    final now = DateTime.now();
    final uptime = _calculateUptime();
    
    return {
      'currentStatus': {
        'isConnected': _isConnected,
        'connectionType': _connectionType.toString(),
        'lastChecked': now.toIso8601String(),
      },
      'history': {
        'lastConnected': _lastConnected?.toIso8601String(),
        'lastDisconnected': _lastDisconnected?.toIso8601String(),
        'disconnectionCount': _connectionHistory[_formatDate(now)] ?? 0,
      },
      'performance': {
        'uptime': uptime,
        'reliability': _calculateReliability(),
        'stabilityScore': _calculateStabilityScore(),
      },
    };
  }

  double _calculateUptime() {
    if (_lastConnected == null) return 0.0;
    
    final totalDuration = DateTime.now().difference(_lastConnected!);
    final disconnectedDuration = _lastDisconnected != null && 
                               _lastDisconnected!.isAfter(_lastConnected!)
        ? DateTime.now().difference(_lastDisconnected!)
        : Duration.zero;

    return ((totalDuration.inMinutes - disconnectedDuration.inMinutes) / 
            totalDuration.inMinutes * 100)
        .clamp(0.0, 100.0);
  }

  double _calculateReliability() {
    final totalChecks = _connectionHistory.values.fold<int>(0, (a, b) => a + b);
    if (totalChecks == 0) return 100.0;
    
    final disconnections = _connectionHistory.values.fold<int>(0, (a, b) => a + b);
    return ((totalChecks - disconnections) / totalChecks * 100).clamp(0.0, 100.0);
  }

  double _calculateStabilityScore() {
    final uptime = _calculateUptime();
    final reliability = _calculateReliability();
    return ((uptime + reliability) / 2).clamp(0.0, 100.0);
  }

  void _handleError(String message, dynamic error) {
    _error = '$message: ${error.toString()}';
    debugPrint('ConnectivityProvider Error: $_error');
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    _internetCheckTimer?.cancel();
    super.dispose();
  }
}