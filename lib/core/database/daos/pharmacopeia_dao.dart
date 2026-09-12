import 'package:drift/drift.dart';
import 'dart:convert';

import '../local_database.dart';

part 'pharmacopeia_dao.g.dart';

@DriftAccessor(tables: [Drugs])
class PharmacopeiaDao extends DatabaseAccessor<AppDatabase>
    with _$PharmacopeiaDaoMixin {
  PharmacopeiaDao(super.db);

  Stream<List<Drug>> searchDrugsPaged({
    required String query,
    int limit = 50,
    int offset = 0,
  }) {
    final safeLimit = limit.clamp(1, 200);
    final safeOffset = offset < 0 ? 0 : offset;
    final statement = select(drugs)
      ..where((row) => row.isActive.equals(true) & row.genericName.isNotNull())
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.isTrusted, mode: OrderingMode.desc),
        (row) => OrderingTerm(
          expression: row.usageFrequency,
          mode: OrderingMode.desc,
        ),
      ]);

    final term = query.trim();
    if (term.isNotEmpty) {
      final pattern = '%${term.replaceAll('%', '\\%')}%';
      statement.where(
        (row) =>
            row.brandName.like(pattern) |
            row.genericName.like(pattern) |
            row.uses.like(pattern) |
            row.category.like(pattern) |
            row.chemicalClass.like(pattern),
      );
    }
    statement.limit(safeLimit, offset: safeOffset);
    return statement.watch();
  }

  Future<void> insertDrug(DrugsCompanion values) =>
      attachedDatabase.into(drugs).insert(values);

  // Expose the update mechanism seamlessly
  Future<void> updateDrug(Drug value) => update(drugs).replace(value);

  Future<void> deleteDrug(Drug value) => delete(drugs).delete(value);

  Future<void> markTrusted(String id, bool trusted) async {
    await (update(drugs)..where((row) => row.id.equals(id))).write(
      DrugsCompanion(
        isTrusted: Value(trusted),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> upsertLearnedDrug({
    required String? brand,
    required String? generic,
    required String? dose,
    required List<String> problemNames,
    required String ownerId,
  }) async {
    final name = (brand?.trim().isNotEmpty == true ? brand : generic)?.trim();
    if (name == null || name.isEmpty) return;

    final existing = await (select(
      drugs,
    )..where((row) => row.brandName.equals(name))).getSingleOrNull();
    final problems = problemNames.toSet().toList(growable: false);

    if (existing == null) {
      await insertDrug(
        DrugsCompanion.insert(
          ownerId: ownerId,
          genericName: generic?.trim().isNotEmpty == true
              ? generic!.trim()
              : name,
          brandName: Value(
            brand?.trim().isNotEmpty == true ? brand!.trim() : null,
          ),
          strength: Value(
            dose?.trim().isNotEmpty == true ? dose!.trim() : null,
          ),
          usageFrequency: const Value(1),
          associatedProblems: Value(jsonEncode(problems)),
        ),
      );
      return;
    }

    final oldProblems = jsonDecode(existing.associatedProblems);
    final merged = <String>{
      if (oldProblems is List) ...oldProblems.map((value) => value.toString()),
      ...problems,
    }.toList(growable: false);

    await updateDrug(
      existing.copyWith(
        usageFrequency: existing.usageFrequency + 1,
        associatedProblems: jsonEncode(merged),
        customNotes: Value('Mentioned for: ${merged.join(', ')}'),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
