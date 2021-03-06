import 'dart:developer' as developer;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HubClient {
  Uri? baseUrl;
  String? sid;
  DateTime sidExpires = DateTime.now();
  final Duration timeout = Duration(seconds: 10);

  final Map<String,String> headers = {
    'Content-type' : 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Access-Control-Allow-Origin, Accept',
  };

  void init(String baseUrl, VoidCallback onInitialized, Function onError) async {
    developer.log("HubClient.init()");

    Uri? url;
    try {
      url = Uri.parse(baseUrl);
    }
    on FormatException {
      onError(http.Response("Invalid server URL; check your hostname", 418));
      return;
    }

    _isReachable(url, () async {
      this.baseUrl = url;

      // If we don't have a SID, initialization is complete and we are
      // ready to log in.
      await loadSid();
      developer.log("HubClient.init(): sid is $sid");
      if (sid == null) {
        onInitialized();
        return;
      }

      // Otherwise, we have yet to check if the SID is still valid.
      checkSid(onInitialized, onError);
      developer.log("HubClient.init(): end: sid is $sid");

    }, onError);
  }

  Future<void> loadSid() async {
    developer.log("HubClient.loadSid()");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sid = prefs.getString("sid");
    int sidExpiresMs = prefs.getInt("sid-expires") ?? 0;
    sidExpires = DateTime.fromMillisecondsSinceEpoch(sidExpiresMs);
    developer.log("HubClient.loadSid(): $sid");
  }

  Future<void> saveSid() async {
    developer.log("HubClient.saveSid()");
    final prefs = await SharedPreferences.getInstance();
    if (sid == null) {
      prefs.remove("sid");
      prefs.remove("sidExpires");
      loadSid(); // Cause re-initialization; needed to make sure onInitialized() signal is sent.
    }
    else {
      prefs.setString("sid", sid!);
    }
    prefs.setInt("sid-expires", sidExpires.millisecondsSinceEpoch);
	}

  bool isLoggedIn() {
	  if (sidExpires.isBefore(DateTime.now())) {
		  sid = null;
    }
		return sid != null;
	}

  void _updateSidFromLoginResponse(String responseBody) {
    developer.log("HubClient._updateSidFromLoginResponse()");
    // Extract session ID and session validity from response.
    final Map<String, dynamic> parsed = json.decode(responseBody);
    developer.log("HubClient._updateSidFromLoginResponse() $parsed");
    sid = parsed['sid'];
    sidExpires = DateTime.parse(parsed['sid_expires']);
    saveSid();
  }

  Future<void> _isReachable(url, VoidCallback onSuccess, Function onError) async {
    url = url.replace(path: "/api/info/1.0/hello");
    try {
      final response = await http.get(url).timeout(timeout);

      if (response.statusCode != 200) {
        onError(response);
        return;
      }
    }
    on TimeoutException catch (e) {
      onError(http.Response(e.toString(), 408));
      return;
    }
    on Exception catch(e) {
      developer.log(e.toString());
      onError(http.Response(e.toString(), 418));
      return;
    }

    onSuccess();
	}

  Future<void> passwordLogin(String username,
                     String password,
                     VoidCallback onSuccess,
                     Function onError) async {
    Uri url = baseUrl!.replace(path: "/api/auth/1.0/session/start");
    Map<String, String> params = {"username": username, "password": password};
    var body = json.encode(params);

    try {
      final response = await http.post(url, body: body, headers: headers).timeout(timeout);

      if (response.statusCode != 200) {
        onError(response);
        return;
      }

      _updateSidFromLoginResponse(response.body);
    }
    on TimeoutException catch (e) {
      onError(http.Response(e.toString(), 408));
      return;
    }
    on Exception catch(e) {
      developer.log(e.toString());
      onError(http.Response(e.toString(), 418));
      return;
    }

    onSuccess();
	}

  Future<void> googleLogin(String authToken,
                           Function onSuccess,
                           Function onError) async {
    Uri url = baseUrl!.replace(path: "/api/auth/1.0/session/start_google");
    Map<String, String> params = {"id_token": authToken};
    var body = json.encode(params);

    try {
      final response = await http.post(url, body: body, headers: headers).timeout(timeout);

      if (response.statusCode != 200) {
        onError(response);
        return;
      }

      _updateSidFromLoginResponse(response.body);
    }
    on TimeoutException catch (e) {
      onError(http.Response(e.toString(), 408));
      return;
    }
    on Exception catch(e) {
      developer.log(e.toString());
      onError(http.Response(e.toString(), 418));
      return;
    }

    onSuccess();
	}

  Future<void> checkSid(VoidCallback onSuccess, Function onError) async {
    developer.log("HubClient.checkSid()");
    if (sid == null) {
      return;
    }

    Uri url = baseUrl!.replace(path: "/api/auth/1.0/session/check");
    Map<String, String> params = {"sid": sid!};
    var body = json.encode(params);

    try {
      final response = await http.post(url, body: body, headers: headers).timeout(timeout);

      if (response.statusCode != 200) {
        onError(response);
        return;
      }
    }
    on TimeoutException catch (e) {
      onError(http.Response(e.toString(), 408));
      return;
    }
    on Exception catch(e) {
      developer.log(e.toString());
      onError(http.Response(e.toString(), 418));
      return;
    }

    onSuccess();
	}

  Future<void> logout(VoidCallback onSuccess, Function onError) async {
    if (sid == null) {
      return;
    }

    Uri url = baseUrl!.replace(path: "/api/auth/1.0/session/end");
    Map<String, String> params = {"sid": sid!};
    var body = json.encode(params);

    try {
      final response = await http.post(url, body: body, headers: headers).timeout(timeout);

      if (response.statusCode != 200) {
        onError(response);
        return;
      }
    }
    on TimeoutException catch (e) {
      onError(http.Response(e.toString(), 408));
      return;
    }
    on Exception catch(e) {
      developer.log(e.toString());
      onError(http.Response(e.toString(), 418));
      return;
    }

    sid = null;
    saveSid();
    onSuccess();
	}

  Future<void> trigger(int actionId, VoidCallback onSuccess, Function onError) async {
    Uri url = baseUrl!.replace(path: "/api/action/1.0/action/start");
    Map<String, String> params = {"sid": sid!, "id": actionId.toString()};
    var body = json.encode(params);

    try {
      final response = await http.post(url, body: body, headers: headers).timeout(timeout);
      if (response.statusCode != 200) {
        onError(response);
        return;
      }
    }
    on TimeoutException catch (e) {
      onError(http.Response(e.toString(), 408));
      return;
    }
    on Exception catch(e) {
      developer.log(e.toString());
      onError(http.Response(e.toString(), 418));
      return;
    }

    onSuccess();
	}
}