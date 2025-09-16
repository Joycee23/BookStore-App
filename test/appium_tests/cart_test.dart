    test('Thêm sách vào giỏ hàng', () async {
  await driver.tap(find.byValueKey('bookItem_1')); // Chọn sách
  await driver.tap(find.byValueKey('addToCartButton')); // Nhấn thêm vào giỏ hàng

  // Kiểm tra giỏ hàng
  await driver.tap(find.byValueKey('cartIcon'));
  expect(await driver.getText(find.byValueKey('cartItem_1')), isNotNull);
});
