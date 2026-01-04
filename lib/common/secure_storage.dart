import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage(
  aOptions: Platform.isAndroid
      ? const AndroidOptions(encryptedSharedPreferences: true)
      : AndroidOptions.defaultOptions,
);

