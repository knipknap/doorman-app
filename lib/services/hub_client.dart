import 'dart:developer' as developer;
import 'dart:async'; 
import 'dart:convert'; 
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; 

class HubClient {
  late final Uri baseUrl;
  String? sid;
  DateTime sidExpires = DateTime.now();
  final Duration timeout = Duration(seconds: 10);

  final Map<String,String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  HubClient(String baseUrl) {
    this.baseUrl = Uri.parse(baseUrl);
  }

  void setSid(String sid, DateTime sidExpires) {
		this.sid = sid;
		this.sidExpires = sidExpires;
	}

  bool isLoggedIn() {
	  if (sidExpires.isBefore(DateTime.now())) {
		  sid = null;
    }
		return sid != null;
	}

  void _updateSidFromLoginResponse(String responseBody) {
    // Extract session ID and session validity from response.
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>(); 
    sid = parsed['sid'];
    sidExpires = DateTime.fromMillisecondsSinceEpoch(parsed['sid_expires']);
  }

  Future<void> passwordLogin(String username,
                     String password,
                     VoidCallback onSuccess,
                     Function onError) async {
    Uri url = baseUrl.replace(path: "/auth/1.0/session/start");
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
    Uri url = baseUrl.replace(path: "/auth/1.0/session/start_google");
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
    if (sid == null) {
      return;
    }

    Uri url = baseUrl.replace(path: "/auth/1.0/session/check");
    Map<String, String> params = {"sid": sid!};
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

  Future<void> logout(VoidCallback onSuccess, Function onError) async {
    if (sid == null) {
      return;
    }

    Uri url = baseUrl.replace(path: "/auth/1.0/session/end");
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
    onSuccess();
	}

  Future<void> trigger(int actionId, VoidCallback onSuccess, Function onError) async {
    Uri url = baseUrl.replace(path: "/action/1.0/action/start");
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