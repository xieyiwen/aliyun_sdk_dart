import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// The New Method of aliyunOcr
class AliyunSigner {
  /// Use UTC(0) time to generate Signature
  String timeStamp = "";

  /// aliyun_ocr_serve
  String baseUrl = "";

  /// init the Class
  AliyunSigner(String url) {
    baseUrl = url;
  }

  /// Signature Algorithm
  Map<String, String> generateSignature({
    required String accessKeySecret,
    required Map<String, String> queries,
    String method = 'POST',
  }) {
    var now = DateTime.now().toUtc();
    timeStamp =
        '${DateFormat("yyyy-MM-dd").format(now)}T${DateFormat.Hms().format(now)}Z';
    String uuidCode = Uuid().v4().toString().replaceAll('-', '');
    queries['Timestamp'] = timeStamp;
    queries['SignatureNonce'] = uuidCode;

    final Map<String, String> encodedQueries = {};
    queries.forEach((key, value) {
      encodedQueries[encode(key)] = encode(value);
    });

    List<String> sortedKeys = encodedQueries.keys.toList()..sort();

    final List<String> formalizedStringPair = <String>[
      for (final String k in sortedKeys) '$k=${encodedQueries[k]}',
    ];
    final String formalizedString = formalizedStringPair.join('&');
    final String signString = '$method'
        '&${encode('/')}'
        '&${encode(formalizedString)}';

    final String signature = encode(
      base64Encode(
        Hmac(
          sha1,
          utf8.encode('$accessKeySecret&'),
        ).convert(utf8.encode(signString)).bytes,
      ),
    );

    queries['Signature'] = signature;
    return queries;
  }

  String getRequestUrl({
    required String accessKeySecret,
    required Map<String, String> queries,
    String method = 'POST',
  }) {
    final signQueries = generateSignature(
        accessKeySecret: accessKeySecret, queries: queries, method: method);

    final url =
        "$baseUrl?${signQueries.entries.map((e) => '${e.key}=${e.value}').join('&')}";

    return url;
  }

  static String encode(String value) {
    return Uri.encodeComponent(value)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }
}
