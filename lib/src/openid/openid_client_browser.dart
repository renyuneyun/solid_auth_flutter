// ignore_for_file: avoid_web_libraries_in_flutter

import 'openid_client.dart';
import 'package:web/web.dart' show window;
import 'dart:async';
import 'dart:convert';
export 'openid_client.dart';

class Authenticator {
  final Flow flow;

  final Future<Credential?> credential;

  Authenticator._(this.flow) : credential = _credentialFromUri(flow);

  // With PKCE flow
  Authenticator(
    Client client, {
    Iterable<String> scopes = const [],
    popToken = '',
  }) : this._(Flow.authorizationCodeWithPKCE(client,
            state: window.localStorage.getItem('openid_client:state'))
          ..scopes.addAll(scopes)
          ..redirectUri = Uri.parse(window.location.href.contains('#/')
                  ? window.location.href.replaceAll('#/', 'callback.html')
                  : window.location.href + 'callback.html')
              .removeFragment()
          ..dPoPToken = popToken);

  void authorize() {
    _forgetCredentials();
    window.localStorage.setItem('openid_client:state', flow.state);
    window.location.href = flow.authenticationUri.toString();
  }

  // ignore: unused_field
  static final Map<String, Completer<Map<String, String>>> _requestsByState =
      {};

  void logout() async {
    _forgetCredentials();
    var c = await credential;
    if (c == null) return;
    var uri = c.generateLogoutUrl(
        redirectUri: Uri.parse(window.location.href).removeFragment());
    if (uri != null) {
      window.location.href = uri.toString();
    }
  }

  void _forgetCredentials() {
    window.localStorage.removeItem('openid_client:state');
    window.localStorage.removeItem('openid_client:auth');
  }

  static Future<Credential?> _credentialFromUri(Flow flow) async {
    Map? q;
    if (window.localStorage.getItem('openid_client:auth') != null) {
      q = json.decode(window.localStorage.getItem('openid_client:auth')!);
    } else {
      var uri = Uri(query: Uri.parse(window.location.href).fragment);
      q = uri.queryParameters;
      if (q.containsKey('access_token') ||
          q.containsKey('code') ||
          q.containsKey('id_token')) {
        window.localStorage.setItem('openid_client:auth', json.encode(q));
        window.location.href =
            Uri.parse(window.location.href).removeFragment().toString();
      }
    }
    if (q!.containsKey('access_token') ||
        q.containsKey('code') ||
        q.containsKey('id_token')) {
      return await flow.callback(q.cast());
    }
    return null;
  }
}
