import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MicrophonePermissionRuntime {
  MicrophonePermissionRuntime._();

  static final MicrophonePermissionRuntime instance = MicrophonePermissionRuntime._();

  static const MethodChannel _methodChannel = MethodChannel('elaro.microphone.permission');
  static const EventChannel _eventChannel = EventChannel('elaro.microphone.permission.stream');

  final StreamController<bool> _permissionStateController = StreamController<bool>.broadcast();
  StreamSubscription<dynamic>? _platformPermissionSubscription;

  bool _hasMicrophone = true;
  bool _isTestOverride = false;
  bool _hasBoundPermissionStream = false;

  Stream<bool> get permissionStateStream => _permissionStateController.stream;

  bool get hasMicrophone => _hasMicrophone;

  Future<bool> preflight() async {
    if (_isTestOverride) {
      return _hasMicrophone;
    }

    final permissionState = await _queryPlatformPermissionState();
    _setPermissionState(permissionState);

    _bindPermissionStream();
    return permissionState;
  }

  Future<bool> _queryPlatformPermissionState() async {
    try {
      final Object? result = await _methodChannel.invokeMethod<Object?>(
        'permissionState',
      ).timeout(const Duration(milliseconds: 120));
      if (result is bool) {
        return result;
      }
      return true;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    } catch (_) {
      return true;
    }
  }

  void _bindPermissionStream() {
    if (_hasBoundPermissionStream) {
      return;
    }

    _hasBoundPermissionStream = true;
    try {
      _platformPermissionSubscription = _eventChannel
          .receiveBroadcastStream()
          .listen((dynamic value) {
            if (value is bool) {
              _setPermissionState(value);
            }
          }, onError: (_) {});
    } catch (_) {
      // Production platforms without event-channel support are intentionally treated as no-op.
    }
  }

  void _setPermissionState(bool hasMicrophone) {
    if (_hasMicrophone == hasMicrophone) {
      return;
    }

    _hasMicrophone = hasMicrophone;
    _permissionStateController.add(hasMicrophone);
  }

  @visibleForTesting
  void setPermissionForTests(bool hasMicrophone) {
    _isTestOverride = true;
    _setPermissionState(hasMicrophone);
  }

  @visibleForTesting
  void resetForTests() {
    _isTestOverride = false;
    _setPermissionState(true);
    _platformPermissionSubscription?.cancel();
    _platformPermissionSubscription = null;
    _hasBoundPermissionStream = false;
  }
}
