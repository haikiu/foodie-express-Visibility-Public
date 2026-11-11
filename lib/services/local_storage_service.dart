import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _nameKey = 'delivery_name';
  static const String _phoneKey = 'delivery_phone';
  static const String _addressKey = 'delivery_address';

  Future<void> saveDeliveryInfo({
    required String name,
    required String phone,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_addressKey, address);
  }

  Future<Map<String, String>> getDeliveryInfo() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString(_nameKey) ?? '',
      'phone': prefs.getString(_phoneKey) ?? '',
      'address': prefs.getString(_addressKey) ?? '',
    };
  }

  Future<void> clearDeliveryInfo() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_addressKey);
  }
}