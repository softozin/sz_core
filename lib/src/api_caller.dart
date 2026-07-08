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

enum SZMethod { get, post, delete, put, patch }

class SZApiCaller<T extends SZBase> {
  static final utf8 = const Utf8Decoder();
  final BuildContext? _context;
  final int _key;
  final String _api;
  final String? _data;
  final String? _dialogMsg;
  final bool skipFocus;
  final T? activity;
  final Map<String, String>? customHeader;
  final SZMethod _szMethod;

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

  void then(Function(String response, int key) apiListener) async {
    final d = await call();
    if (d != null) {
      apiListener(d.response, d.key);
    }
  }

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
