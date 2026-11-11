
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseOrderService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://foodie-express-592a8-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  Future<void> saveOrder({
    required String orderId,
    required Map<String, dynamic> order,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập Firebase.');
    }

    if (orderId.isEmpty) {
      throw Exception('Mã đơn hàng không hợp lệ.');
    }

    await _database.ref('orders/${user.uid}/$orderId').set({
      ...order,
      'userId': user.uid,
      'userEmail': user.email,
      'createdAt': ServerValue.timestamp,
    });
  }
}
