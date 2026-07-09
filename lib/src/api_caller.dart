import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sz_core/src/core.dart';
import 'package:sz_core/src/show.dart';
import 'package:sz_core/src/widget.dart';

class SZApiSetting {
  static final http.Client client = http.Client();
  static String networkError =
      "Network is not available in your mobile at this location. Please go to network or try again when network is available.";
  static String baseURL = "http://localhost/";
  static String keyStatus = "status";
  static String keyMessage = "message";
  static String keyData = "data";
  static String keyInternet = "internet";
  static Map<String, String> defaultHeader = {};

  /// Initializes SZ Core and configures global API settings.
  ///
  /// This method should be called once during application startup,
  /// typically before `runApp()`.
  ///
  /// Parameters:
  /// - [baseURL] : Base URL used for all API requests.
  /// - [keyStatus] : JSON response key representing request status.
  /// - [keyMessage] : JSON response key representing response message.
  /// - [keyData] : JSON response key containing response data.
  /// - [keyInternet] : Custom message used when internet connectivity is unavailable.
  /// - [defaultHeader] : Default HTTP headers included with every request.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   SZCore.init(
  ///     'https://api.example.com',
  ///     keyStatus: 'success',
  ///     keyMessage: 'message',
  ///     keyData: 'data',
  ///     defaultHeader: {
  ///       'Accept': 'application/json',
  ///       'Content-Type': 'application/json',
  ///     },
  ///   );
  ///
  ///   runApp(const MyApp());
  /// }
  /// ```
  static void init(
    String baseURL, {
    String? keyStatus,
    String? keyMessage,
    String? keyData,
    String? keyInternet,
    Map<String, String>? defaultHeader,
  }) async {
    SZApiSetting.baseURL = baseURL;
    if (keyStatus != null) {
      SZApiSetting.keyStatus = keyStatus;
    }
    if (keyMessage != null) {
      SZApiSetting.keyMessage = keyMessage;
    }
    if (keyData != null) {
      SZApiSetting.keyData = keyData;
    }
    if (keyInternet != null) {
      SZApiSetting.keyInternet = keyInternet;
    }
    if (defaultHeader != null) {
      SZApiSetting.defaultHeader = defaultHeader;
    }
  }
}

/// Supported HTTP request methods used by SZ Core.
///
/// These methods are used when making API requests through the networking
/// utilities provided by the package.
///
/// Example:
/// ```dart
/// await SZCore.request(
///   method: SZMethod.post,
///   url: '/login',
///   body: {
///     'email': email,
///     'password': password,
///   },
/// );
/// ```
enum SZMethod {
  /// Retrieves data from the server.
  get,

  /// Sends new data to the server.
  post,

  /// Removes existing data from the server.
  delete,

  /// Updates existing data by replacing it completely.
  put,

  /// Updates existing data partially.
  patch,
}

/// A generic API caller used by SZ Core for performing HTTP requests.
///
/// Supports all common HTTP methods including GET, POST, PUT, PATCH,
/// and DELETE.
///
/// The caller automatically handles:
/// - Loading dialogs
/// - Request logging
/// - Session expiration detection
/// - Keyboard dismissal
/// - Network error handling
/// - UTF-8 response decoding
///
/// Example:
/// ```dart
/// SZApiCaller(
///   context,
///   this,
///   1,
///   jsonEncode(data),
///   'Please wait...',
///   '/login',
/// ).then((response, key) {
///   // Handle response
/// });
/// ```
class SZApiCaller<T extends SZBase> {
  /// UTF-8 decoder used for decoding API responses.
  static final utf8 = const Utf8Decoder();

  /// Current build context.
  final BuildContext? _context;

  /// Request identifier returned in callbacks.
  final int _key;

  /// API endpoint URL.
  final String _api;

  /// Request body data.
  final String? _data;

  /// Loading dialog message.
  final String? _dialogMsg;

  /// Prevents keyboard hiding after request completion.
  final bool skipFocus;

  /// Current activity instance.
  final T? activity;

  /// Custom headers for this request.
  final Map<String, String>? customHeader;

  /// HTTP request method.
  final SZMethod _szMethod;

  /// Creates a new API request.
  ///
  /// Relative URLs are automatically prefixed with
  /// `SZApiSetting.baseURL`.
  ///
  /// If [method] is not provided:
  /// - `GET` is used when [_data] is `null`
  /// - `POST` is used otherwise
  SZApiCaller(
    this._context,
    this.activity,
    this._key,
    this._data,
    this._dialogMsg,
    _api, {
    this.skipFocus = false,
    this.customHeader,
    SZMethod? method,
  }) : _api = (_api.startsWith("http")) ? _api : "${SZApiSetting.baseURL}$_api",
       _szMethod = (method ?? (_data == null ? SZMethod.get : SZMethod.post)) {
    // init();
  }

  /// Executes the API request and returns the response and request key.
  ///
  /// Returns `null` when the session has expired and logout processing
  /// has been triggered.
  Future<({String response, int key})?> call() async {
    if (_dialogMsg != null) {
      if (activity != null) {
        activity!.showDialog(_dialogMsg);
      }
    }

    SZCore.printLog("API : $_api");
    SZCore.printLog("HED : ${customHeader ?? SZApiSetting.defaultHeader}");
    SZCore.printLog("DAT : $_data");

    String response = await getRes();
    if (_context?.mounted ?? false) {
      if (response.toLowerCase().contains("session expire")) {
        //!(_api.endsWith(API.login)) &&
        // Navigator.pop(_context);
        SZCore.logoutCallback?.call();
        SZShow.toast("Session expired.\nLogout Successfully ", bg: Colors.red);
        return null;
      }
    }
    SZCore.printLog("RES : $response");
    if (_dialogMsg != null) {
      if (activity != null) {
        activity!.hideDialog();
      }
    }
    if (!skipFocus && (_context?.mounted ?? false)) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    return (response: response, key: _key);
  }

  /// Executes the request and delivers the result to [apiListener].
  ///
  /// This is a convenience wrapper around [call].
  void then(Function(String response, int key) apiListener) async {
    final d = await call();
    if (d != null) {
      apiListener(d.response, d.key);
    }
  }

  /// Sends the HTTP request and returns the raw response body.
  ///
  /// Network and timeout exceptions are automatically converted into
  /// a standardized JSON error response.
  Future<String> getRes() async {
    try {
      http.Response response;
      if (_szMethod == SZMethod.post) {
        response = await SZApiSetting.client
            .post(
              Uri.parse(_api),
              headers: customHeader ?? SZApiSetting.defaultHeader,
              body: _data,
            )
            .timeout(const Duration(seconds: 20));
      } else if (_szMethod == SZMethod.put) {
        response = await SZApiSetting.client
            .put(
              Uri.parse(_api),
              headers: customHeader ?? SZApiSetting.defaultHeader,
              body: _data,
            )
            .timeout(const Duration(seconds: 20));
      } else if (_szMethod == SZMethod.patch) {
        response = await SZApiSetting.client
            .patch(
              Uri.parse(_api),
              headers: customHeader ?? SZApiSetting.defaultHeader,
              body: _data,
            )
            .timeout(const Duration(seconds: 20));
      } else if (_szMethod == SZMethod.delete) {
        response = await SZApiSetting.client
            .delete(
              Uri.parse(_api),
              headers: customHeader ?? SZApiSetting.defaultHeader,
              body: _data,
            )
            .timeout(const Duration(seconds: 20));
      } else {
        response = await SZApiSetting.client
            .get(
              Uri.parse(_api),
              headers: customHeader ?? SZApiSetting.defaultHeader,
            )
            .timeout(const Duration(seconds: 20));
      }

      return utf8.convert(response.bodyBytes);
    } catch (e) {
      String msg = "";
      if (e is TimeoutException ||
          e is SocketException ||
          e is ArgumentError ||
          e is http.ClientException) {
        msg = SZApiSetting.networkError;
      } else {
        msg = e.toString();
      }
      return '{"${SZApiSetting.keyStatus}":false,"${SZApiSetting.keyMessage}":"$msg","${SZApiSetting.keyInternet}":true}';
    }
  }
}
