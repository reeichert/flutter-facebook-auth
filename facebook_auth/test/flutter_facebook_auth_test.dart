import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_facebook_auth_platform_interface/flutter_facebook_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'src/data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('authentication', () {
    const MethodChannel channel = MethodChannel(
      'app.meedu/flutter_facebook_auth',
    );
    late FacebookAuth facebookAuth;
    late bool isLogged;

    setUp(() {
      isLogged = false;
      facebookAuth = FacebookAuth.getInstance();
      channel.setMockMethodCallHandler((MethodCall call) async {
        switch (call.method) {
          case "login":
            isLogged = true;
            return MockData.accessToken;
          case "expressLogin":
            isLogged = true;
            return MockData.accessToken;
          case "getAccessToken":
            return isLogged ? MockData.accessToken : null;
          case "logOut":
            isLogged = false;
            return null;

          case "getUserData":
            final String fields = call.arguments['fields'];
            return await MockData.getUserData(fields);
        }
      });
    });

    test('login request', () async {
      expect(facebookAuth.isWebSdkInitialized, true);
      expect(await facebookAuth.accessToken, null);
      facebookAuth.webInitialize(appId: "1233443", cookie: true, xfbml: true, version: "v9.0");
      final result = await facebookAuth.login();
      expect(result.status, LoginStatus.success);
      expect(result.accessToken, isNotNull);
      expect(await facebookAuth.accessToken, isA<AccessToken>());
      final Map<String, dynamic> userData = await facebookAuth.getUserData();
      expect(userData.containsKey("email"), true);
      final FacebookPermissions? permissions = await facebookAuth.permissions;
      expect(permissions, isNotNull);
      expect(permissions!.granted.length > 0, true);
      expect(permissions.declined.length == 0, true);
      await facebookAuth.logOut();
      expect(await facebookAuth.accessToken, null);
    });

    test('express login', () async {
      expect(await facebookAuth.accessToken, null);
      final result = await facebookAuth.expressLogin();
      expect(result.status, LoginStatus.success);
    });
  });
}
