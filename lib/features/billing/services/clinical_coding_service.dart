import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';

// ==========================================
// ICD-11 EXTERNAL API SERVICE
// ==========================================
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

    return _parse(jsonDecode(response.body));
  }

  List<Icd11Code> _parse(Object? decoded) {
    if (decoded is! List || decoded.length < 2) return const [];
    final rows = decoded[1];
    if (rows is! List) return const [];

    final results = <Icd11Code>[];
    for (final row in rows) {
      if (row is List && row.length >= 2) {
        results.add(
          Icd11Code(code: row.first.toString(), title: row[1].toString()),
        );
      } else if (row is Map && row['code'] != null && row['title'] != null) {
        results.add(
          Icd11Code(
            code: row['code'].toString(),
            title: row['title'].toString(),
          ),
        );
      }
    }
    return results;
  }

  void dispose() => _client.close();
}

// ==========================================
// OFFLINE PM-JAY / HBP SERVICE
// ==========================================
class HbpProcedureDetails {
  const HbpProcedureDetails({
    required this.procedure,
    this.implants = const [],
    this.stratifications = const [],
  });

  final HbpProcedure procedure;
  final List<HbpImplant> implants;
  final List<HbpStratification> stratifications;
}

class ClinicalCodingService {
  ClinicalCodingService(this._dao, {http.Client? client})
    : icd11 = Icd11SearchService(client: client);

  final ClinicalDao _dao;
  final Icd11SearchService icd11;

  /// Fetches a PM-JAY package and automatically joins its related implants
  /// and stratification rules from the local offline database.
  Future<HbpProcedureDetails?> getFullProcedureDetails(
    String procedureCode,
  ) async {
    // Fetch the base procedure
    final proc =
        await (_dao.select(_dao.hbpProcedures)
              ..where((tbl) => tbl.procedureCode.equals(procedureCode)))
            .getSingleOrNull();

    if (proc == null) return null;

    // Fetch associated implants
    final implants = await (_dao.select(
      _dao.hbpImplants,
    )..where((tbl) => tbl.procedureCode.equals(procedureCode))).get();

    // Fetch associated stratification rules
    final stratifications = await (_dao.select(
      _dao.hbpStratifications,
    )..where((tbl) => tbl.procedureCode.equals(procedureCode))).get();

    return HbpProcedureDetails(
      procedure: proc,
      implants: implants,
      stratifications: stratifications,
    );
  }

  void dispose() {
    icd11.dispose();
  }
}
