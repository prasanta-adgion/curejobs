import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

abstract interface class SessionStorageInterface {
  Future<String?> getSession();

  Future<void> saveSession({required String sessionId});

  Future<void> clearSession();

  Future<bool> hasSession();
}

class SecureSessionStorageImpl implements SessionStorageInterface {
  final FlutterSecureStorage _storage;

  const SecureSessionStorageImpl(this._storage);

  @override
  Future<String?> getSession() {
    return _storage.read(key: StorageKeys.sessionCookie);
  }

  @override
  Future<void> saveSession({required String sessionId}) async {
    if (sessionId.isEmpty) {
      throw ArgumentError('Session cannot be empty');
    }

    await _storage.write(key: StorageKeys.sessionCookie, value: sessionId); //For aware about sessionCookie go to => lib\core\constants\storage_keys.dart
  }

  @override
  Future<void> clearSession() {
    return _storage.delete(key: StorageKeys.sessionCookie);
  }

  @override
  Future<bool> hasSession() async {
    final session = await getSession();
    return session != null && session.isNotEmpty;
  }
}
