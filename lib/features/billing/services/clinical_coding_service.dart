import 'dart:convert';

import 'package:http/http.dart' as http;

class Icd11Code {
  const Icd11Code({required this.code, required this.title});

  final String code;
  final String title;
}

class Icd11SearchService {
  Icd11SearchService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _endpoint =
      'https://clinicaltables.nlm.nih.gov/api/icd11_codes/v3/search';

  Future<List<Icd11Code>> search(String query) async {
    final term = query.trim();
    if (term.isEmpty) return const [];
    final response = await _client.get(
      Uri.parse(_endpoint).replace(queryParameters: {'terms': term}),
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('ICD-11 search failed (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body);
    return _parse(decoded);
  }

  List<Icd11Code> _parse(Object? decoded) {
    if (decoded is! List || decoded.length < 2) return const [];
    final rows = decoded[1];
    if (rows is! List) return const [];
    final results = <Icd11Code>[];
    for (final row in rows) {
      if (row is List && row.length >= 2) {
        results.add(Icd11Code(code: row.first.toString(), title: row[1].toString()));
      } else if (row is Map && row['code'] != null && row['title'] != null) {
        results.add(Icd11Code(code: row['code'].toString(), title: row['title'].toString()));
      }
    }
    return results;
  }

  void dispose() => _client.close();
}

class HbpImplantDetail {
  const HbpImplantDetail({
    required this.code,
    required this.name,
    this.maximumPrice,
  });

  final String code;
  final String name;
  final double? maximumPrice;
}

class HbpStratificationDetail {
  const HbpStratificationDetail({
    required this.code,
    required this.name,
    required this.rule,
  });

  final String code;
  final String name;
  final String rule;
}

class HbpProcedureDetails {
  const HbpProcedureDetails({
    required this.procedureCode,
    required this.packageName,
    required this.procedureName,
    required this.specialty,
    this.rate,
    this.implants = const [],
    this.stratifications = const [],
  });

  final String procedureCode;
  final String packageName;
  final String procedureName;
  final String specialty;
  final double? rate;
  final List<HbpImplantDetail> implants;
  final List<HbpStratificationDetail> stratifications;
}