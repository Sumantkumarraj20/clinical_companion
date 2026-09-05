import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local_database.dart';

part 'cdss_dao.g.dart';

@DriftAccessor(tables: [CdssRules])
class CdssDao extends DatabaseAccessor<AppDatabase> with _$CdssDaoMixin {
  CdssDao(super.db);

    Stream<List<CdssRule>> watchRules() =>
      (select(cdssRules)..orderBy([(row) => OrderingTerm(expression: row.targetProblem)])).watch();

  Future<List<CdssRule>> rulesForProblem(String problem) =>
      (select(cdssRules)..where((row) => row.targetProblem.equals(problem))).get();

  Future<CdssRule> saveRule(CdssRulesCompanion values) async {
    final id = values.id.present ? values.id.value : _uuid.v4();
    await into(cdssRules).insertOnConflictUpdate(values.copyWith(id: Value(id)));
    return (select(cdssRules)..where((row) => row.id.equals(id))).getSingle();
  }

  Future<void> deleteRule(String id) =>
      (delete(cdssRules)..where((row) => row.id.equals(id))).go();
}

const _uuid = Uuid();
