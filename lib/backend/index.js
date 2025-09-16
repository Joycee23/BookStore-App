const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();
const { db } = require('./firebaseAdmin'); // Import Firestore
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(express.json());
app.use(cors());

const FIREBASE_API_KEY = process.env.FIREBASE_API_KEY;

// ✅ Đăng ký tài khoản
app.post('/auth/register', async (req, res) => {
  const { email, password, fullName, phoneNumber, address } = req.body;

  try {
    const response = await axios.post(
      `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_API_KEY}`,
      {
        email,
        password,
        returnSecureToken: true
      }
    );

    const { localId } = response.data;

    await db.collection("users").doc(email).set({
      email,
      fullName: fullName || '',
      phoneNumber: phoneNumber || '',
      address: address || '',
    });

    res.json({
      message: '✅ Đăng ký thành công và đã lưu vào Firestore!',
      data: response.data
    });
  } catch (error) {
    console.error("❌ Lỗi khi đăng ký:", error.message);
    res.status(400).json(error.response?.data || { error: 'Lỗi không xác định' });
  }
});

// ✅ Đăng nhập tài khoản
app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const response = await axios.post(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`,
      {
        email,
        password,
        returnSecureToken: true
      }
    );

    res.json({
      message: '✅ Đăng nhập thành công!',
      data: response.data
    });
  } catch (error) {
    console.error("❌ Lỗi đăng nhập:", error.message);
    res.status(401).json({
      error: error.response?.data?.error?.message || "Đăng nhập thất bại"
    });
  }
});

// ✅ Cập nhật thông tin người dùng
app.put('/auth/update', async (req, res) => {
  const { email, fullName, phoneNumber, address } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'Thiếu email để xác định người dùng.' });
  }

  try {
    await db.collection("users").doc(email).update({
      ...(fullName && { fullName }),
      ...(phoneNumber && { phoneNumber }),
      ...(address && { address }),
    });

    res.json({ message: "✅ Cập nhật thông tin người dùng thành công!" });
  } catch (error) {
    console.error("❌ Lỗi cập nhật user:", error.message);
    res.status(500).json({ error: "Không thể cập nhật thông tin người dùng" });
  }
});

// ✅ Xoá người dùng khỏi Firestore
app.delete('/auth/delete', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'Thiếu email để xoá người dùng.' });
  }

  try {
    await db.collection("users").doc(email).delete();
    res.json({ message: "✅ Đã xoá người dùng khỏi Firestore." });
  } catch (error) {
    console.error("❌ Lỗi xoá user:", error.message);
    res.status(500).json({ error: "Không thể xoá người dùng" });
  }
});

// ✅ Tìm kiếm sách theo trường (title, author, category)
app.get('/books/search', async (req, res) => {
  const { field, value } = req.query;

  const allowedFields = ['title', 'author', 'category'];
  if (!allowedFields.includes(field)) {
    return res.status(400).json({
      error: "Trường tìm kiếm không hợp lệ. Chỉ chấp nhận: title, author, category"
    });
  }

  try {
    const snapshot = await db.collection("books")
      .where(field, '==', value)
      .get();

    const results = [];
    snapshot.forEach(doc => {
      results.push({ id: doc.id, ...doc.data() });
    });

    res.json({ results });
  } catch (error) {
    console.error("❌ Lỗi khi tìm sách:", error.message);
    res.status(500).json({ error: "Không thể tìm kiếm sách" });
  }
});

// ✅ Khởi động server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
  console.log(`📡 API đăng ký:       POST    http://localhost:${PORT}/auth/register`);
  console.log(`📡 API đăng nhập:     POST    http://localhost:${PORT}/auth/login`);
  console.log(`📡 API cập nhật user: PUT     http://localhost:${PORT}/auth/update`);
  console.log(`📡 API xoá user:      DELETE  http://localhost:${PORT}/auth/delete`);
  console.log(`📡 API tìm sách:      GET     http://localhost:${PORT}/books/search?field=title&value=Số đỏ`);
});
