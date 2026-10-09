import '../ai/document_ai_service.dart';
import '../database/daos/clinical_dao.dart';
import '../models/clinical_insight.dart';

/// Collects a concise longitudinal POMR snapshot and asks ClinCom to audit it.
///
/// This is deliberately an on-demand operation, not a reactive stream: chart
/// reviews can be expensive and must never run on every UI edit.
class ClinComAuditService {
  const ClinComAuditService({
    required ClinicalDao clinicalDao,
    required DocumentAiService aiService,
  }) : _clinicalDao = clinicalDao,
       _aiService = aiService;

  final ClinicalDao _clinicalDao;
  final DocumentAiService _aiService;

  Future<List<ClinicalInsight>> auditPatient(String patientId) async {
    final summary = await _clinicalDao.buildClinicalAuditSummary(patientId);
    return _aiService.generateClinicalInsights(
      summary,
      // Sprint 27 (adaptive compute): standard POMR/chart linkage — `medium`.
      thinkingLevel: ThinkingLevel.medium,
    );
  }
}
