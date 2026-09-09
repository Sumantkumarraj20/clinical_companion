import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/database/daos/clinical_dao.dart';

class ComparativeAnalysisScreen extends ConsumerStatefulWidget {
  const ComparativeAnalysisScreen({super.key});

  @override
  ConsumerState<ComparativeAnalysisScreen> createState() =>
      _ComparativeAnalysisScreenState();
}

class _ComparativeAnalysisScreenState
    extends ConsumerState<ComparativeAnalysisScreen> {
  String? _selectedProblemName;
  String _selectedMetric = 'Length of Stay (Days)';

  final List<String> _availableMetrics = [
    'Length of Stay (Days)',
    'Drain Output (mL)',
    'Pain Score / VAS',
    'Time to Resolution (Days)',
  ];

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);
    final theme = Theme.of(context);

    // Watch distinct problems recorded across the cohort
    final problemsStream = dao.select(dao.patientProblems).watch();

    return Scaffold(
      appBar: AppBar(title: const Text('Comparative Efficacy & Audit')),
      body: StreamBuilder<List<PatientProblem>>(
        stream: problemsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Failed to load problems: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final allProblems = snapshot.data ?? [];
          // Deduplicate problem names
          final distinctProblemNames =
              allProblems.map((p) => p.problemName.trim()).toSet().toList()
                ..sort();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. SELECTOR BANNER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Problem & Objective Parameter',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Target Diagnosis/Problem Selector
                        Expanded(
                          flex: 5,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedProblemName,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Target Clinical Problem',
                              prefixIcon: Icon(Icons.psychology_outlined),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('— Select Problem for Audit —'),
                              ),
                              for (final name in distinctProblemNames)
                                DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedProblemName = val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Objective Endpoint Selector
                        Expanded(
                          flex: 4,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedMetric,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Target Endpoint Metric',
                              prefixIcon: Icon(Icons.analytics_outlined),
                              isDense: true,
                            ),
                            items: [
                              for (final m in _availableMetrics)
                                DropdownMenuItem(value: m, child: Text(m)),
                            ],
                            onChanged: (val) => setState(
                              () => _selectedMetric = val ?? _selectedMetric,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. OUTCOME COMPARISON RESULTS
              Expanded(
                child: _selectedProblemName == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.compare_arrows_rounded,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Select a Clinical Problem',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Compares outcome trajectories across surgical & medical interventions.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : FutureBuilder<_ComparisonReport>(
                        future: _computeComparativeReport(
                          dao,
                          _selectedProblemName!,
                          _selectedMetric,
                        ),
                        builder: (context, reportSnap) {
                          if (reportSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final report = reportSnap.data;
                          if (report == null || report.cohorts.isEmpty) {
                            return Center(
                              child: Text(
                                'No longitudinal outcome metrics found for "$_selectedProblemName"',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Summary Metric Banner
                              Row(
                                children: [
                                  _metricSummaryCard(
                                    title: 'Total Analyzed Cases',
                                    value: '${report.totalPatients}',
                                    icon: Icons.people_alt_outlined,
                                    theme: theme,
                                  ),
                                  const SizedBox(width: 10),
                                  _metricSummaryCard(
                                    title: 'Overall Resolution Rate',
                                    value:
                                        '${report.overallResolutionRate.toStringAsFixed(1)}%',
                                    icon: Icons.task_alt,
                                    theme: theme,
                                    isGreen: report.overallResolutionRate >= 75,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Text(
                                'Intervention Arm Comparison for $_selectedMetric',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Comparative Arm Cards
                              for (final arm in report.cohorts)
                                _InterventionArmCard(
                                  arm: arm,
                                  maxMean: report.highestMean,
                                  unit: _getUnitForMetric(_selectedMetric),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required ThemeData theme,
    bool isGreen = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isGreen
              ? Colors.green.shade50
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isGreen
                ? Colors.green.shade300
                : theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isGreen
                  ? Colors.green.shade800
                  : theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isGreen
                        ? Colors.green.shade900
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isGreen ? Colors.green.shade900 : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getUnitForMetric(String metric) {
    if (metric.contains('Days')) return 'days';
    if (metric.contains('mL')) return 'mL';
    if (metric.contains('Score')) return 'pts';
    return '';
  }

  Future<_ComparisonReport> _computeComparativeReport(
    ClinicalDao dao,
    String problemName,
    String metricType,
  ) async {
    // 1. Fetch all problems matching this name
    final matchingProblems = await (dao.select(
      dao.patientProblems,
    )..where((p) => p.problemName.equals(problemName))).get();

    final problemIds = matchingProblems.map((p) => p.id).toSet();
    final patientIds = matchingProblems.map((p) => p.patientId).toSet();

    // 2. Fetch associated interventions (procedures)
    final interventions = await (dao.select(
      dao.clinicalInterventions,
    )..where((i) => i.problemId.isIn(problemIds))).get();

    // Group patients by intervention approach
    final Map<String, List<double>> valuesByArm = {};
    final Map<String, int> resolvedCountByArm = {};
    final Map<String, Set<String>> patientsByArm = {};

    for (final prob in matchingProblems) {
      // Find matching intervention for this problem
      final patientInterventions = interventions.where(
        (i) => i.patientId == prob.patientId,
      );
      final armName = patientInterventions.isNotEmpty
          ? patientInterventions.first.procedureName
          : 'Conservative / Medical Management';

      patientsByArm.putIfAbsent(armName, () => <String>{}).add(prob.patientId);

      // Determine metric value
      double metricValue = 0.0;
      if (metricType.contains('Length of Stay')) {
        final encounters = await dao.getEncountersForPatient(prob.patientId);
        if (encounters.length >= 2) {
          final first = encounters.last.occurredAt;
          final last = encounters.first.occurredAt;
          metricValue = max(1.0, last.difference(first).inDays.toDouble());
        } else {
          metricValue = 2.0; // Default baseline stay
        }
      } else if (metricType.contains('Resolution')) {
        if (prob.onsetDate != null && prob.resolvedDate != null) {
          metricValue = max(
            1.0,
            prob.resolvedDate!.difference(prob.onsetDate!).inDays.toDouble(),
          );
        } else {
          metricValue = 5.0;
        }
      } else {
        // Query ClinicalOutcomeMetrics table directly
        final metrics = await (dao.select(
          dao.clinicalOutcomeMetrics,
        )..where((m) => m.problemId.equals(prob.id))).get();
        if (metrics.isNotEmpty) {
          metricValue =
              metrics.map((m) => m.metricValue).reduce((a, b) => a + b) /
              metrics.length;
        }
      }

      valuesByArm.putIfAbsent(armName, () => []).add(metricValue);

      if (prob.currentStatus == 'Resolved' ||
          prob.currentStatus == 'Improving') {
        resolvedCountByArm[armName] = (resolvedCountByArm[armName] ?? 0) + 1;
      }
    }

    final cohorts = <_ArmCohort>[];
    double highestMean = 1.0;

    valuesByArm.forEach((armName, vals) {
      if (vals.isEmpty) return;
      final count = vals.length;
      final mean = vals.reduce((a, b) => a + b) / count;
      if (mean > highestMean) highestMean = mean;

      // Compute standard deviation
      final variance =
          vals.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / count;
      final sd = sqrt(variance);

      final resolved = resolvedCountByArm[armName] ?? 0;
      final rate = (resolved / count) * 100;

      cohorts.add(
        _ArmCohort(
          armName: armName,
          sampleSize: count,
          mean: mean,
          standardDeviation: sd,
          min: vals.reduce(min),
          max: vals.reduce(max),
          resolutionRate: rate,
        ),
      );
    });

    final totalResolved = resolvedCountByArm.values.fold(0, (a, b) => a + b);
    final totalPatients = patientIds.length;
    final overallRate = totalPatients > 0
        ? (totalResolved / totalPatients) * 100
        : 0.0;

    return _ComparisonReport(
      totalPatients: totalPatients,
      overallResolutionRate: overallRate,
      highestMean: highestMean,
      cohorts: cohorts,
    );
  }
}

class _ComparisonReport {
  _ComparisonReport({
    required this.totalPatients,
    required this.overallResolutionRate,
    required this.highestMean,
    required this.cohorts,
  });

  final int totalPatients;
  final double overallResolutionRate;
  final double highestMean;
  final List<_ArmCohort> cohorts;
}

class _ArmCohort {
  _ArmCohort({
    required this.armName,
    required this.sampleSize,
    required this.mean,
    required this.standardDeviation,
    required this.min,
    required this.max,
    required this.resolutionRate,
  });

  final String armName;
  final int sampleSize;
  final double mean;
  final double standardDeviation;
  final double min;
  final double max;
  final double resolutionRate;
}

class _InterventionArmCard extends StatelessWidget {
  const _InterventionArmCard({
    required this.arm,
    required this.maxMean,
    required this.unit,
  });

  final _ArmCohort arm;
  final double maxMean;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (arm.mean / (maxMean > 0 ? maxMean : 1)).clamp(0.05, 1.0);

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    arm.armName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'n = ${arm.sampleSize}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Visual Comparison Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Statistics Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statBlock(
                  'Mean ± SD',
                  '${arm.mean.toStringAsFixed(1)} ± ${arm.standardDeviation.toStringAsFixed(1)} $unit',
                ),
                _statBlock(
                  'Range',
                  '${arm.min.toStringAsFixed(1)} - ${arm.max.toStringAsFixed(1)} $unit',
                ),
                _statBlock(
                  'Success / Improvement',
                  '${arm.resolutionRate.toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
