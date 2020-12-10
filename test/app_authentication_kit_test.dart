import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_authentication_kit/app_authentication_kit.dart';

void main() {
  const MethodChannel channel = MethodChannel('app_authentication_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
