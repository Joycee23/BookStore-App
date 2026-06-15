const http = require('http');

http.get('http://localhost:3000/api/books', (res) => {
  let data = '';
  res.on('data', (chunk) => data += chunk);
  res.on('end', () => {
    const books = JSON.parse(data);
    console.log(books[0].title);
  });
});
