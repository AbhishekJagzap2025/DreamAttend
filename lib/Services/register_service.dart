import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/register_model.dart';
import '/controller/app_constants.dart';

class RegisterService {
  final http.Client client;

  RegisterService({required this.client});

  Future<RegisterResponse> registerUser(RegisterRequest request) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.registerEndpoint}',
      );
      print('Request URL: $url');
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return RegisterResponse.fromJson(responseData);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Registration failed');
        } catch (e) {
          throw Exception(
            'Server error: ${response.statusCode} ${response.reasonPhrase}',
          );
        }
      }
    } catch (e) {
      print("Exception: $e");
      throw Exception('Registration error: $e');
    }
  }
}
