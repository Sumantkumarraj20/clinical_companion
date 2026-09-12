import 'package:flutter/material.dart';

import '../database/daos/clinical_dao.dart';
import '../database/daos/cdss_dao.dart';

class DecisionRule {
  const DecisionRule({
    required this.ifProblemIs,
    required this.labName,
    required this.operator,
    required this.threshold,
    required this.thenSuggestAction,
    required this.evidenceLevel,
  });

  final String ifProblemIs;
  final String labName;
  final String operator;
  final double threshold;
  final String thenSuggestAction;
  final String evidenceLevel;
}

class DecisionSuggestion {
  const DecisionSuggestion(this.action, this.evidenceLevel);
  final String action;
  final String evidenceLevel;
}

/// A medication/lab order proposed by the deterministic CDSS engine.
/// Tapping a banner stages these into [stagedOrdersProvider].
class OrderProposal {
  const OrderProposal({
    required this.label,
    this.kind = OrderProposalKind.lab,
    this.details,
  });

  final String label;
  final OrderProposalKind kind;
  final String? details;
}

enum OrderProposalKind { medication, lab, procedure, oxygen, fluids }

/// Actionable banner surfaced by [DecisionSupportEngine.evaluateVitals].
class CdssAlert {
  const CdssAlert({
    required this.title,
    required this.description,
    required this.severityColor,
    this.suggestedOrders = const [],
  });

  final String title;
  final String description;
  final Color severityColor;
  final List<OrderProposal> suggestedOrders;
}

class DecisionSupportEngine {
  DecisionSupportEngine(this.dao, this.rulesDao);
  final ClinicalDao dao;
  final CdssDao rulesDao;

  static const baselineRules = [
    DecisionRule(
      ifProblemIs: 'Sepsis',
      labName: 'Lactate',
      operator: '>',
      threshold: 2,
      thenSuggestAction:
          'Consider IV fluid bolus and broad-spectrum antibiotics.',
      evidenceLevel: 'Baseline guidance; clinician verification required',
    ),
  ];

  /// Deterministic vitals evaluation — pure function, no I/O.
  ///
  /// * Shock Index: `pulse / sbp > 1.0` → "High Shock Index (>1.0)".
  /// * Hypoxia: `spo2 < 92` → "Hypoxia detected".
  /// * Hypotension (qSOFA proxy): `sbp < 100`.
  static List<CdssAlert> evaluateVitals(int? sbp, int? pulse, int? spo2) {
    final alerts = <CdssAlert>[];

    if (pulse != null && sbp != null && sbp > 0) {
      final shockIndex = pulse / sbp;
      if (shockIndex > 1.0) {
        alerts.add(
          CdssAlert(
            title: 'High Shock Index (>1.0)',
            description:
                'Shock index ${shockIndex.toStringAsFixed(2)} (HR $pulse / SBP $sbp). Consider occult shock — assess perfusion, lactate, and fluid responsiveness.',
            severityColor: Colors.red,
            suggestedOrders: const [
              OrderProposal(
                label: 'IV Fluid Bolus',
                kind: OrderProposalKind.fluids,
                details: 'e.g. 500 mL NS/RL stat, reassess',
              ),
              OrderProposal(
                label: 'Serum Lactate',
                kind: OrderProposalKind.lab,
              ),
            ],
          ),
        );
      }
    }

    if (spo2 != null && spo2 < 92) {
      alerts.add(
        CdssAlert(
          title: 'Hypoxia detected',
          description:
              'SpO2 $spo2% is below 92%. Evaluate airway, breathing, and circulation; confirm probe placement.',
          severityColor: Colors.deepOrange,
          suggestedOrders: const [
            OrderProposal(
              label: 'Start O2 therapy',
              kind: OrderProposalKind.oxygen,
              details: 'Titrate to SpO2 ≥ 94%',
            ),
          ],
        ),
      );
    }

    if (sbp != null && sbp < 100) {
      alerts.add(
        const CdssAlert(
          title: 'Hypotension (qSOFA criteria)',
          description:
              'SBP < 100 mmHg meets the hypotension arm of qSOFA. Screen for infection + organ dysfunction (GCS, RR) and trend vitals.',
          severityColor: Colors.amber,
          suggestedOrders: [
            OrderProposal(label: 'Repeat BP in 15 min', kind: OrderProposalKind.lab),
            OrderProposal(label: 'Serum Lactate', kind: OrderProposalKind.lab),
          ],
        ),
      );
    }

    return alerts;
  }

  Future<List<DecisionSuggestion>> generateSuggestions(String problemId) async {
    final problem = await dao.getPatientProblem(problemId);
    if (problem == null) return const [];
    final encounters = await dao.getEncountersForPatient(problem.patientId);
    final lactate = encounters
        .expand((row) => [row.dynamicData['lactate']])
        .whereType<num>()
        .firstOrNull
        ?.toDouble();
    final rules = await rulesDao.rulesForProblem(problem.problemName);
    return [
      for (final rule in rules)
        if (lactate != null && rule.triggerCondition.contains('Lactate') &&
            lactate > (double.tryParse(rule.triggerCondition.split('>').last.trim()) ?? double.infinity))
          DecisionSuggestion(rule.suggestedAction, rule.evidenceSource),
    ];
  }
}
