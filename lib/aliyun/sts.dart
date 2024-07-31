import 'dart:convert';
import 'dart:io';
import 'aliyun.dart';
import 'package:http/http.dart' as http;

class StsClient {
  static final String _endpoint = Platform.environment['sts_endpoint'] ??
      'https://sts.cn-shanghai.aliyuncs.com';
  static final AliyunSigner aliyunSigner = AliyunSigner(_endpoint);

  static Future<Map<String, String>> getSecurityToken() async {
    final url = aliyunSigner.getRequestUrl(
        accessKeySecret: Platform.environment['access_secret']!,
        queries: _getCommonParameters(),
        method: 'GET');
    final response =
        await http.get(Uri.parse(url)).timeout(Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception(
          'StsClient getSecurityToken error:${response.statusCode} message:${response.body}');
    }
    final result = jsonDecode(response.body);
    if (result['Code'] != null && result['Code'] != 200) {
      throw Exception(
          'StsClient getSecurityToken failed, code: ${result['Code']} message: ${result['Message']}');
    }
    return {
      'AccessKeyId': result['Credentials']['AccessKeyId'],
      'AccessKeySecret': result['Credentials']['AccessKeySecret'],
      'Expiration': result['Credentials']['Expiration'],
      'SecurityToken': result['Credentials']['SecurityToken'],
    };
  }

  static Map<String, String> _getCommonParameters() {
    return {
      "AccessKeyId": Platform.environment['access_key']!,
      "Action": "AssumeRole",
      'RoleArn': Platform.environment['role_arn']!,
      'RoleSessionName': 'clinic',
      'Version': '2015-04-01',
      'DurationSeconds': '3600',
      'SignatureMethod': 'HMAC-SHA1',
      'SignatureVersion': '1.0',
      'Format': 'JSON',
    };
  }
}
