import 'dart:convert'; // Để mã hóa email làm docId
import 'dart:math'; // Random cho mã giảm giá
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _token = "";
  String? _email;
  String _fullName = "";
  String _phoneNumber = "";
  String _address = "";

  double _walletBalance = 0.0;

  String? get userId => _auth.currentUser?.uid;
  bool get isAuthenticated => _token.isNotEmpty;
  String? get email => _email;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;
  double get walletBalance => _walletBalance;

  bool get hasUserInfo {
    return _email != null &&
        _fullName.isNotEmpty &&
        _phoneNumber.isNotEmpty &&
        _address.isNotEmpty;
  }

  set walletBalance(double value) {
    _walletBalance = value;
    notifyListeners();
  }

  String generateDiscountCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rand = Random();
    return List.generate(8, (index) => characters[rand.nextInt(characters.length)]).join();
  }

  String encodeEmail(String email) => base64Url.encode(utf8.encode(email));

  Future<void> createDiscountCodes(String email) async {
    final docId = encodeEmail(email);

    await _firestore.collection('users').doc(docId).update({
      'discountCodes': FieldValue.delete(),
    });

    await Future.delayed(Duration(seconds: 1));

    List<Map<String, dynamic>> discountCodes = List.generate(5, (_) {
      return {
        'code': generateDiscountCode(),
        'amount': 5000,
        'isUsed': false,
        'expiryDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      };
    });

    await _firestore.collection('users').doc(docId).update({
      'discountCodes': discountCodes,
    });
  }

  Future<void> createBirthdayDiscount(String email) async {
    final docId = encodeEmail(email);
    final today = DateTime.now();
    final userDoc = await _firestore.collection('users').doc(docId).get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data == null || !data.containsKey('birthDate')) return;

      final birthDateRaw = data['birthDate'];
      final birthDate = birthDateRaw is Timestamp
          ? birthDateRaw.toDate()
          : DateTime.tryParse(birthDateRaw.toString());

      if (birthDate == null) return;

      if (birthDate.month == today.month && birthDate.day == today.day) {
        final code = generateDiscountCode();
        final newDiscount = {
          'code': code,
          'amount': 0.5,
          'isUsed': false,
          'expiryDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
        };

        final existingCodes = List<Map<String, dynamic>>.from(data['discountCodes'] ?? []);
        existingCodes.add(newDiscount);

        await _firestore.collection('users').doc(docId).update({
          'discountCodes': existingCodes,
        });
      }
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? "";
    _email = prefs.getString('email');
    _fullName = prefs.getString('full_name') ?? "";
    _phoneNumber = prefs.getString('phone_number') ?? "";
    _address = prefs.getString('address') ?? "";

    if (_email != null) {
      final docId = encodeEmail(_email!);
      final doc = await _firestore.collection('users').doc(docId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _walletBalance = (data['walletBalance'] ?? 0).toDouble();
      }
    }

    notifyListeners();
  }

  Future<void> loadToken() async {
    await _loadToken();
  }

  Future<void> logout() async {
    _token = "";
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<void> updateUserInfo({
    required String email,
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _email = email;
    _fullName = fullName;
    _phoneNumber = phoneNumber;
    _address = address;

    final docId = encodeEmail(email);

    await _firestore.collection('users').doc(docId).set({
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('full_name', fullName);
    await prefs.setString('phone_number', phoneNumber);
    await prefs.setString('address', address);

    notifyListeners();
  }

  Future<String> register(String email, String password, BuildContext context) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        return "Email đã tồn tại. Vui lòng chọn email khác!";
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final token = await userCredential.user?.getIdToken() ?? "";
      _token = token;

      final docId = encodeEmail(email);

      await _firestore.collection('users').doc(docId).set({
        'email': email,
        'fullName': '',
        'phoneNumber': '',
        'address': '',
        'discountCodes': [],
        'walletBalance': 0.0,  // Khởi tạo số dư ví = 0
      });

      await createDiscountCodes(email);
      await _saveToken(token);
      notifyListeners();

      Navigator.pushReplacementNamed(context, '/login');
      return "Đăng ký thành công!";
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        return 'Email này đã được sử dụng. Vui lòng thử email khác!';
      }
      return "Lỗi đăng ký: ${e.toString()}";
    }
  }

  Future<String?> login(String email, String password, BuildContext context) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return "Đăng nhập thất bại!";

      _token = await user.getIdToken() ?? "";
      _email = email;
      final docId = encodeEmail(email);
      final userDoc = await _firestore.collection('users').doc(docId).get();

      if (!userDoc.exists) return "Sai email hoặc mật khẩu!";
      final data = userDoc.data() as Map<String, dynamic>;

      _fullName = data['fullName'] ?? "";
      _phoneNumber = data['phoneNumber'] ?? "";
      _address = data['address'] ?? "";
      _walletBalance = (data['walletBalance'] ?? 0).toDouble();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('full_name', _fullName);
      await prefs.setString('phone_number', _phoneNumber);
      await prefs.setString('address', _address);

      await _saveToken(_token);
      notifyListeners();

      await createDiscountCodes(email);

      if (hasUserInfo) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/user_info');
      }

      return null;
    } catch (e) {
      return "Sai email hoặc mật khẩu!";
    }
  }

  // Hàm cập nhật số dư ví khi trừ tiền
  Future<void> updateWalletBalance(double newBalance) async {
    if (_email == null) return;
    final docId = encodeEmail(_email!);

    await _firestore.collection('users').doc(docId).update({
      'walletBalance': newBalance,
    });

    walletBalance = newBalance;
  }
}
