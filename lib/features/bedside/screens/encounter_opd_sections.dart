import 'package:flutter/material.dart';

/// OPD Consult mode: collapsible ExpansionTile history sections.
class OpdHistorySections extends StatelessWidget {
  const OpdHistorySections({
    required this.complaint,
    required this.hpi,
    required this.pastMedical,
    required this.pastSurgical,
    required this.personalHistory,
    required this.socialHistory,
    required this.birthHistory,
    required this.milestones,
    required this.vaccination,
    required this.gplaa,
    required this.lmp,
    required this.menstrualHistory,
    required this.examination,
    super.key,
  });

  final TextEditingController complaint;
  final TextEditingController hpi;
  final TextEditingController pastMedical;
  final TextEditingController pastSurgical;
  final TextEditingController personalHistory;
  final TextEditingController socialHistory;
  final TextEditingController birthHistory;
  final TextEditingController milestones;
  final TextEditingController vaccination;
  final TextEditingController gplaa;
  final TextEditingController lmp;
  final TextEditingController menstrualHistory;
  final TextEditingController examination;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tile(
          title: 'Chief Complaints & HPI',
          icon: Icons.chat_bubble_outline,
          initiallyExpanded: true,
          children: [
            _field(complaint, 'Chief Complaints (e.g. Fever x 3 days)'),
            _field(hpi, 'HPI (onset, duration, progression, associates)'),
          ],
        ),
        _tile(
          title: 'Past Medical & Surgical History',
          icon: Icons.history_outlined,
          children: [
            _field(pastMedical, 'Past Medical (DM, HTN, TB, asthma...)'),
            _field(pastSurgical, 'Past Surgical (appendectomy 2019, LSCS...)'),
          ],
        ),
        _tile(
          title: 'Personal & Social History',
          icon: Icons.person_outline,
          children: [
            _field(personalHistory, 'Personal (diet, sleep, job, addictions)'),
            _field(socialHistory, 'Social (housing, water, contacts, travel)'),
          ],
        ),
        _tile(
          title: 'Pediatric History',
          icon: Icons.child_care_outlined,
          children: [
            _field(birthHistory, 'Birth history (term, weight, NICU, cry)'),
            _field(milestones, 'Developmental Milestones'),
            _field(vaccination, 'Vaccination (BCG, OPV, DPT, measles)'),
          ],
        ),
        _tile(
          title: 'OB/GYN History',
          icon: Icons.pregnant_woman_outlined,
          children: [
            _field(gplaa, 'GPLAA (e.g. G2 P1 L1 A0)'),
            _field(lmp, 'LMP (date)'),
            _field(menstrualHistory, 'Menstrual history'),
          ],
        ),
        _tile(
          title: 'Physical Examination',
          icon: Icons.medical_services_outlined,
          initiallyExpanded: true,
          children: [
            _field(examination, 'Examination (general + systemic)'),
          ],
        ),
      ],
    );
  }

  Widget _tile({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon, size: 20),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: children,
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(
            labelText: label, alignLabelWithHint: true, isDense: true),
      ),
    );
  }
}
