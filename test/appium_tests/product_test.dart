test('Thêm sách mới', () async {
  await driver.tap(find.byValueKey('addBookButton'));
  await driver.sendKeys(find.byValueKey('bookTitleField'), 'Sách mới');
  await driver.sendKeys(find.byValueKey('bookPriceField'), '150000');
  await driver.tap(find.byValueKey('saveBookButton'));

  expect(await driver.getText(find.byValueKey('bookList')), contains('Sách mới'));
});
