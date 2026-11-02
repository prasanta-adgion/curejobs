import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class SessionCookieParser {
  SessionCookieParser._();

  static Cookie? parse(Headers headers) {
    final values = headers[ApiConstants.setCookieHeader];

    if (values == null || values.isEmpty) {
      return null;
    }

    for (final value in values) {
      late final Cookie cookie;

      try {
        cookie = Cookie.fromSetCookieValue(value);
      } on FormatException {
        continue;
      }

      if (cookie.name == ApiConstants.cookieName) {
        return cookie;
      }
    }

    return null;
  }

  static bool isExpired(Cookie cookie) {
    if (cookie.value.isEmpty) {
      return true;
    }

    if (cookie.maxAge != null && cookie.maxAge! <= 0) {
      return true;
    }

    final expiry = cookie.expires;

    if (expiry != null && !expiry.isAfter(DateTime.now().toUtc())) {
      return true;
    }

    return false;
  }
}
