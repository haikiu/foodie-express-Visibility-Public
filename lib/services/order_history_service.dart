
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class OrderHistoryService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://foodie-express-592a8-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  Stream<List<Map<String, dynamic>>> getOrders() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _database
        .ref('orders/${user.uid}')
        .onValue
        .map((event) {
      final value = event.snapshot.value;

      if (value == null || value is! Map) {
        return <Map<String, dynamic>>[];
      }

      final orders = value.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['id'] = entry.key.toString();
        return data;
      }).toList();

      orders.sort((a, b) {
        final timeA = a['createdAt'] is num
            ? (a['createdAt'] as num).toInt()
            : 0;
        final timeB = b['createdAt'] is num
            ? (b['createdAt'] as num).toInt()
            : 0;
        return timeB.compareTo(timeA);
      });

      return orders;
    });
  }

  Stream<Map<String, dynamic>?> watchOrder(String orderId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(null);
    }

    return _database
        .ref('orders/${user.uid}/$orderId')
        .onValue
        .map((event) {
      final value = event.snapshot.value;

      if (value == null || value is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(value);
    });
  }
}
