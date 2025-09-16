import 'package:flutter_test/flutter_test.dart';
import 'package:appium_flutter_driver/appium_flutter_driver.dart';

void main() {
  late AppiumFlutterDriver driver;

  setUpAll(() async {
    driver = await AppiumFlutterDriver.createDriver();
  });

  tearDownAll(() async {
    await driver.quit();
  });

  test('Đăng nhập thành công', () async {
    // Nhập email
    await driver.sendKeys(find.byValueKey('emailField'), 'test@example.com');

    // Nhập mật khẩu
    await driver.sendKeys(find.byValueKey('passwordField'), '123456');

    // Nhấn nút đăng nhập
    await driver.tap(find.byValueKey('loginButton'));

    // Kiểm tra xem màn hình Home đã load chưa
    expect(await driver.getText(find.byValueKey('homeScreenTitle')), 'Trang chủ');
  });
}
