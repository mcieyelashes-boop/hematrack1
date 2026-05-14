import 'dart:convert';

class JsonStorageService {
  String encode(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  Map<String, dynamic> decode(String source) {
    return jsonDecode(source) as Map<String, dynamic>;
  }
}
