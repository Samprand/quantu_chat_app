import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../config/websocket_config.dart';
import '../constants/websocket_events.dart';
import '../enums/connection_status.dart';

class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  factory WebSocketClient() => _instance;
  WebSocketClient._internal();

  socket_io.Socket? _socket;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  
  final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();
  
  // Getters
  ConnectionStatus get connectionStatus => _connectionStatus;
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;
  socket_io.Socket? get socket => _socket;

  Future<void> connect({
    Map<String, dynamic>? authData,
    String? sellerName,
    String? companyDescription,
    String? focusArea,
  }) async {
    if (_socket != null && _connectionStatus == ConnectionStatus.connected) {
      log('🔗 WebSocket already connected');
      print('🔗 WebSocket already connected');
      return;
    }

    try {
      log('🚀 Starting WebSocket connection to: ${WebSocketConfig.socketUrl}');
      print('🚀 Starting WebSocket connection to: ${WebSocketConfig.socketUrl}');
      
      // Merge auth data with agent configuration
      final Map<String, dynamic> connectionData = {
        ...authData ?? {},
        ...WebSocketConfig.getAgentConfig(
          sellerName: sellerName,
          companyDescription: companyDescription,
          focusArea: focusArea,
        ),
      };
      
      log('🔐 Connection data: $connectionData');
      print('🔐 Connection data: $connectionData');
      
      _updateConnectionStatus(ConnectionStatus.connecting);
      
      _socket = socket_io.io(
        WebSocketConfig.socketUrl,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth(connectionData)
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(WebSocketConfig.maxReconnectAttempts)
            .setReconnectionDelay(WebSocketConfig.reconnectDelay.inMilliseconds)
            .setTimeout(WebSocketConfig.connectionTimeout.inMilliseconds)
            .build(),
      );

      log('📡 Socket.IO client created, setting up event listeners...');
      print('📡 Socket.IO client created, setting up event listeners...');
      
      _setupEventListeners();
      
      log('⏳ Waiting for connection...');
      print('⏳ Waiting for connection...');
      
      // Wait for connection with timeout
      await _waitForConnection();
      
    } catch (e) {
      log('💥 WebSocket connection error: $e');
      print('💥 WebSocket connection error: $e');
      _updateConnectionStatus(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // Add catch-all event listener for debugging
    _socket!.onAny((event, data) {
      log('🔍 RECEIVED EVENT: $event');
      log('📦 EVENT DATA: $data');
      print('🔍 RECEIVED EVENT: $event'); // Also use print to ensure visibility
      print('📦 EVENT DATA: $data');
    });

    // Test direct event listeners to verify they work
    _socket!.on('message_start', (data) {
      log('🧪 DIRECT TEST: message_start received!');
      print('🧪 DIRECT TEST: message_start received!');
    });
    
    _socket!.on('message_chunk', (data) {
      log('🧪 DIRECT TEST: message_chunk received!');
      print('🧪 DIRECT TEST: message_chunk received!');
    });
    
    _socket!.on('receive_message', (data) {
      log('🧪 DIRECT TEST: receive_message received!');
      print('🧪 DIRECT TEST: receive_message received!');
    });

    _socket!.onConnect((_) {
      log('✅ WebSocket connected successfully!');
      print('✅ WebSocket connected successfully!');
      _updateConnectionStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;
      _cancelReconnectTimer();
    });

    _socket!.onDisconnect((_) {
      log('❌ WebSocket disconnected');
      print('❌ WebSocket disconnected');
      _updateConnectionStatus(ConnectionStatus.disconnected);
      _scheduleReconnect();
    });

    _socket!.onConnectError((error) {
      log('🚫 WebSocket connection error: $error');
      print('🚫 WebSocket connection error: $error');
      _updateConnectionStatus(ConnectionStatus.error);
      _scheduleReconnect();
    });

    _socket!.onError((error) {
      log('⚠️ WebSocket error: $error');
      print('⚠️ WebSocket error: $error');
    });

    _socket!.onReconnect((_) {
      log('WebSocket reconnected');
      _updateConnectionStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;
    });

    _socket!.onReconnectError((error) {
      log('WebSocket reconnection error: $error');
      _updateConnectionStatus(ConnectionStatus.error);
    });
  }

  Future<void> _waitForConnection() async {
    log('⌛ Starting connection wait...');
    print('⌛ Starting connection wait...');
    
    final completer = Completer<void>();
    Timer? timeoutTimer;

    void onConnect(_) {
      log('🎯 Connection callback triggered!');
      print('🎯 Connection callback triggered!');
      if (!completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.complete();
      }
    }

    void onError(dynamic error) {
      log('💔 Connection error callback: $error');
      print('💔 Connection error callback: $error');
      if (!completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.completeError(error);
      }
    }

    _socket!.onConnect(onConnect);
    _socket!.onConnectError(onError);

    timeoutTimer = Timer(WebSocketConfig.connectionTimeout, () {
      log('⏰ Connection timeout reached!');
      print('⏰ Connection timeout reached!');
      if (!completer.isCompleted) {
        completer.completeError('Connection timeout');
      }
    });

    try {
      log('🔄 Awaiting connection...');
      print('🔄 Awaiting connection...');
      await completer.future;
      log('🏆 Connection established successfully!');
      print('🏆 Connection established successfully!');
    } catch (e) {
      log('💀 Connection failed: $e');
      print('💀 Connection failed: $e');
      rethrow;
    } finally {
      _socket!.off(WebSocketEvents.connect, onConnect);
      _socket!.off(WebSocketEvents.connectError, onError);
      timeoutTimer?.cancel();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= WebSocketConfig.maxReconnectAttempts) {
      log('Max reconnection attempts reached');
      _updateConnectionStatus(ConnectionStatus.error);
      return;
    }

    _cancelReconnectTimer();
    _updateConnectionStatus(ConnectionStatus.reconnecting);
    
    _reconnectTimer = Timer(WebSocketConfig.reconnectDelay, () {
      _reconnectAttempts++;
      log('Attempting reconnection ($_reconnectAttempts/${WebSocketConfig.maxReconnectAttempts})');
      connect();
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    if (_connectionStatus != status) {
      _connectionStatus = status;
      _connectionStatusController.add(status);
    }
  }

  void emit<T>(String event, [T? data]) {
    log('📤 Attempting to emit event: $event');
    print('📤 Attempting to emit event: $event');
    log('📦 Event data: $data');
    print('📦 Event data: $data');
    
    if (_socket != null && isConnected) {
      log('✅ Emitting event to server');
      print('✅ Emitting event to server');
      _socket!.emit(event, data);
    } else {
      log('❌ Cannot emit event: WebSocket not connected (connected: $isConnected, socket: ${_socket != null})');
      print('❌ Cannot emit event: WebSocket not connected (connected: $isConnected, socket: ${_socket != null})');
    }
  }

  void on<T>(String event, Function(T) callback) {
    _socket?.on(event, (data) => callback(data as T));
  }

  void off(String event, [Function? callback]) {
    if (callback != null) {
      _socket?.off(event, (data) => callback(data));
    } else {
      _socket?.off(event);
    }
  }

  void once<T>(String event, Function(T) callback) {
    _socket?.once(event, (data) => callback(data as T));
  }

  void disconnect() {
    _cancelReconnectTimer();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _updateConnectionStatus(ConnectionStatus.disconnected);
    _reconnectAttempts = 0;
  }

  void dispose() {
    disconnect();
    _connectionStatusController.close();
  }
} 