import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/flutter_driver.dart';

void main() {
  group('Đăng ký tài khoản', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
      }
    });

    test('dang_ky_tai_khoan_moi', () async {
      await driver!.tap(find.byValueKey('nameField'));
      await driver!.enterText('Nguyen Van A');

      await driver!.tap(find.byValueKey('emailField'));
      await driver!.enterText('newuser@example.com');

      await driver!.tap(find.byValueKey('passwordField'));
      await driver!.enterText('123456');

      await driver!.tap(find.byValueKey('confirmPasswordField'));
      await driver!.enterText('123456');

      await driver!.tap(find.byValueKey('registerButton'));

      expect(await driver!.getText(find.byValueKey('successMessage')), 'Đăng ký thành công!');
    });
  });
}
