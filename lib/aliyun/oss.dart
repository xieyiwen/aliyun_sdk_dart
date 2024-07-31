import './sts.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class OssClient {
  static Future<Auth> _authGetter() async {
    final result = await StsClient.getSecurityToken();
    return Auth.fromJson(result);
  }

  static final OssClient _instance = OssClient._internal();

  factory OssClient() {
    return _instance;
  }

  OssClient._internal() {
    Client.init(
      ossEndpoint: Platform.environment['oss_enpoint']!,
      bucketName: Platform.environment['oss_bucket']!,
      authGetter: _authGetter,
      dio: Dio(BaseOptions(connectTimeout: Duration(seconds: 30))),
    );
  }

  Client get instance => Client();
}
