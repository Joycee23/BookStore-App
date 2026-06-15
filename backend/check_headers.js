const http = require('http');

http.get('http://localhost:3000/api/books', (res) => {
  console.log('Headers:', res.headers);
});
