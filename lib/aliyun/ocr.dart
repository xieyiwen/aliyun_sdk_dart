import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import "aliyun.dart";

class OcrClient {
  static final String _endpoint = Platform.environment['ocr_endpoint'] ??
      'https://ocr-api.cn-hangzhou.aliyuncs.com';
  static final AliyunSigner aliyunSigner = AliyunSigner(_endpoint);
  static Future<String> recognizeGeneral(
      String filePath, Map<String, String> queries) async {
    // 获取请求URL
    String requestUrl = aliyunSigner.getRequestUrl(
        queries: queries,
        accessKeySecret: Platform.environment['access_secret']!);

    // 读取文件内容
    List<int> fileBytes = await File(filePath).readAsBytes();

    // 创建请求
    final response = await http
        .post(Uri.parse(requestUrl),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/octet-stream',
            },
            body: fileBytes)
        .timeout(Duration(seconds: 30));

    // 检查响应状态码
    if (response.statusCode == 200) {
      return _parseResult(response.body);
    } else {
      throw Exception(
          'Failed to upload file: ${response.statusCode} ${response.body}');
    }
  }

  static Map<String, String> _getCommonParameters() {
    return {
      "AccessKeyId": Platform.environment['access_key']!, // 您的AccessKeyId
      "Action": "RecognizeAdvanced", // 调用的接口名称，此处以 RecognizeGeneral 为例
      'Version': '2021-07-07',
      'NeedSortPage': 'true',
      'NeedRotate': 'true',
      'NoStamp': 'true',
      'Paragraph': 'true',
      'SignatureMethod': 'HMAC-SHA1',
      'SignatureVersion': '1.0',
      'Format': 'JSON',
    };
  }

  // Parse reponse for RecognizeAdvanced with Paragraph
  static String _parseResult(String responseBody) {
    var result = jsonDecode(responseBody);

    if (result['Code'] != null && result['Code'] != 200) {
      throw FlutterError(
          'OCR invoke failed, status: ${result['Code']} message: ${result['Message']}');
    }

    var data = jsonDecode(result['Data']);
    final paragraphs = data['prism_paragraphsInfo'];
    String formatResult = '';
    for (var item in paragraphs) {
      formatResult = '$formatResult${item['word']}\n';
    }

    return formatResult;
  }
}
