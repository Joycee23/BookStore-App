const admin = require('firebase-admin');
const serviceAccount = require('./firebase/bookstore-f41cb-firebase-adminsdk-fbsvc-14e45ca04d.json'); // hoặc ../firebase nếu file khác cấp

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
module.exports = { admin, db };
