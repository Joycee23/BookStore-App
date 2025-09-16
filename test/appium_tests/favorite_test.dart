test('Thêm sách vào yêu thích', () async {
  await driver.tap(find.byValueKey('bookItem_1'));
  await driver.tap(find.byValueKey('favoriteButton'));

  // Kiểm tra danh sách yêu thích
  await driver.tap(find.byValueKey('favoriteTab'));
  expect(await driver.getText(find.byValueKey('favoriteItem_1')), isNotNull);
});
