import 'dart:convert';

import 'package:clinical_companion/core/ingestion/clinical_ingestion_mapper.dart';
import 'package:clinical_companion/core/ingestion/json_schema_tool.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('schema template is valid JSON and persists through the mapper', () async {
    final template = jsonDecode(buildIngestionSchemaTemplate()) as Map;
    expect(template.keys, containsAll(['lab_results', 'document_type', 'vitals']));

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final result = await ClinicalIngestionMapper(db).persist({
      'patient_name': 'Test Patient',
      'age': 40,
      'lab_results': [
        {'test_name': 'Hb', 'value': '9.1', 'unit': null, 'is_abnormal': true},
      ],
    });
    expect(result.labCount, 1);
  });

  test('invalid JSON surfaces the raw parser error', () {
    expect(() => jsonDecode('{bad'), throwsFormatException);
  });
}
