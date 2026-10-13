import 'dart:typed_data';

import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/ingestion/clinical_ingestion_mapper.dart';
import 'package:clinical_companion/core/ingestion/image_optimizer.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('lab results and document date persist against the encounter', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final result = await ClinicalIngestionMapper(db).persist({
      'patient_name': 'Asha Rao',
      'age': 40,
      'document_date': '2024-03-05',
      'document_time': '14:30',
      'lab_results': [
        {
          'test_name': 'Hemoglobin',
          'value': '8.2',
          'unit': 'g/dL',
          'reference_range': '12-16',
          'is_abnormal': true,
        },
        {'value': 'orphan'},
      ],
    });
    expect(result.labCount, 1);
    final enc = await db.select(db.clinicalEncounters).getSingle();
    expect(enc.occurredAt, DateTime(2024, 3, 5, 14, 30));
    final res = await db.select(db.investigationResults).getSingle();
    expect(res.numericValue, 8.2);
    expect(res.isAbnormal, isTrue);
    expect(res.resultDate, DateTime(2024, 3, 5, 14, 30));
    final order = await db.select(db.investigationOrders).getSingle();
    expect(order.encounterId, enc.id);
    expect(res.orderId, order.id);
  });

  test('missing document date is never fabricated', () {
    expect(ClinicalIngestionMapper.parseDocumentMoment(null, '10:00'), isNull);
    expect(ClinicalIngestionMapper.parseDocumentMoment('null', null), isNull);
    expect(
      ClinicalIngestionMapper.parseDocumentMoment('05/03/2024', null),
      DateTime(2024, 3, 5),
    );
  });

  test('prompt demands exact document date/time', () {
    expect(kFlatIngestionSystemPrompt, contains('Do not hallucinate'));
    expect(kFlatIngestionSystemPrompt, contains('lab_results'));
  });

  test('image optimizer caps at 1536 px and encodes JPEG', () {
    final big = img.Image(width: 3000, height: 2000);
    final out = optimizeImageBytes(Uint8List.fromList(img.encodePng(big)));
    final decoded = img.decodeJpg(out)!;
    expect(decoded.width, 1536);
    expect(decoded.height, 1024);
    final small = img.Image(width: 400, height: 300);
    final kept = img.decodeJpg(
      optimizeImageBytes(Uint8List.fromList(img.encodePng(small))),
    )!;
    expect(kept.width, 400);
  });
}
