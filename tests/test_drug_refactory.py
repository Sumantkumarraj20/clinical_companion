"""Comprehensive unit and integration tests for Drug Refactory."""

import unittest
import os
import sys
import tempfile
import sqlite3

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

scripts_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../scripts"))
if scripts_dir not in sys.path:
    sys.path.insert(0, scripts_dir)

try:
    from scripts.drug_refactory.models import DrugRecord, RawDrugRow
    from scripts.drug_refactory.knowledge import load_knowledge, KnowledgeBase
    from scripts.drug_refactory.normalizer import (
        normalize_raw_name,
        extract_strengths,
        extract_dosage_form,
        extract_route,
        remove_brand_noise,
        normalize_spelling,
        normalize_salt,
        normalize_ingredient_names
    )
    from scripts.drug_refactory.combinations import resolve_combination, format_combination_canonical_name
    from scripts.drug_refactory.resolver import resolve_drug_record
    from scripts.drug_refactory.rules import ClinicalRuleEngine, build_clinical_rules
    from scripts.drug_refactory.validator import DataValidator
    from scripts.drug_refactory.compiler import (
        generate_deterministic_drug_id,
        DrugCompiler,
        stream_source_rows
    )
except ModuleNotFoundError:
    from drug_refactory.models import DrugRecord, RawDrugRow
    from drug_refactory.knowledge import load_knowledge, KnowledgeBase
    from drug_refactory.normalizer import (
        normalize_raw_name,
        extract_strengths,
        extract_dosage_form,
        extract_route,
        remove_brand_noise,
        normalize_spelling,
        normalize_salt,
        normalize_ingredient_names
    )
    from drug_refactory.combinations import resolve_combination, format_combination_canonical_name
    from drug_refactory.resolver import resolve_drug_record
    from drug_refactory.rules import ClinicalRuleEngine, build_clinical_rules
    from drug_refactory.validator import DataValidator
    from drug_refactory.compiler import (
        generate_deterministic_drug_id,
        DrugCompiler,
        stream_source_rows
    )


class TestDrugRefactory(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.assets_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../assets/drug_refactory"))
        cls.kb = load_knowledge(base_dir=cls.assets_dir)
        cls.rule_engine = ClinicalRuleEngine()

    def test_case_normalization(self):
        """AMOXICILLIN -> amoxicillin"""
        raw = "AMOXICILLIN"
        norm = normalize_raw_name(raw)
        self.assertEqual(norm, "amoxicillin")

    def test_strength_extraction(self):
        """Amoxicillin 125mg/5ml -> amoxicillin, extracts 125mg/5ml"""
        text = "amoxicillin 125mg/5ml"
        clean, strengths = extract_strengths(text)
        self.assertEqual(clean, "amoxicillin")
        self.assertIn("125mg/5ml", strengths)

    def test_dosage_form_extraction(self):
        """Amoxicillin Capsule -> amoxicillin, extracts capsule"""
        text = "amoxicillin capsule"
        clean, forms = extract_dosage_form(text, self.kb.dosage_forms)
        self.assertEqual(clean, "amoxicillin")
        self.assertIn("capsule", forms)

    def test_basic_normalization(self):
        """Amoxicillin 500 mg Tablet -> amoxicillin"""
        record = resolve_drug_record("Amoxicillin 500 mg Tablet", self.kb)
        self.assertEqual(record.canonical_name, "amoxicillin")
        self.assertEqual(record.display_name, "Amoxicillin")
        self.assertEqual(record.ingredients, ["amoxicillin"])
        self.assertIn("500 mg", record.strengths)
        self.assertIn("tablet", record.dosage_forms)
        self.assertEqual(record.data_status, "RESOLVED")

    def test_combination_detection(self):
        """Amoxicillin + Clavulanic Acid -> two canonical ingredients in alphabetical order"""
        record = resolve_drug_record("Amoxicillin + Clavulanic Acid 625mg Tablet", self.kb)
        self.assertEqual(record.ingredients, ["amoxicillin", "clavulanic acid"])
        self.assertEqual(record.canonical_name, "amoxicillin + clavulanic acid")
        self.assertEqual(record.display_name, "Amoxicillin + Clavulanic Acid")
        self.assertEqual(record.data_status, "RESOLVED")

    def test_combination_alias(self):
        """Co-Amoxiclav or Augmentin resolves to combination amoxicillin + clavulanic acid"""
        record = resolve_drug_record("Co-amoxiclav 625mg", self.kb)
        self.assertEqual(record.ingredients, ["amoxicillin", "clavulanic acid"])
        self.assertEqual(record.canonical_name, "amoxicillin + clavulanic acid")

    def test_spelling_and_generic_alias(self):
        """Acetaminophen -> paracetamol (explicit alias only)"""
        record = resolve_drug_record("Acetaminophen 500mg Tablet", self.kb)
        self.assertEqual(record.canonical_name, "paracetamol")
        self.assertEqual(record.display_name, "Paracetamol")
        self.assertEqual(record.data_status, "RESOLVED")

    def test_unknown_molecule(self):
        """XYZ-FOO-123 -> UNRESOLVED with low confidence, no hallucinated indications"""
        record = resolve_drug_record("XYZ-FOO-123 50mg", self.kb)
        self.assertIsNone(record.canonical_name)
        self.assertEqual(record.data_status, "UNRESOLVED")
        self.assertEqual(record.confidence, "LOW")
        self.assertEqual(record.indications, [])
        self.assertEqual(record.side_effects, [])

    def test_deterministic_id(self):
        """The same molecule must always produce the identical deterministic hash ID."""
        id1 = generate_deterministic_drug_id("Amoxicillin")
        id2 = generate_deterministic_drug_id("amoxicillin")
        id3 = generate_deterministic_drug_id("AMOXICILLIN")
        self.assertEqual(id1, id2)
        self.assertEqual(id2, id3)
        self.assertTrue(id1.startswith("drug_"))

    def test_salt_handling(self):
        """Diclofenac sodium should recognize parent molecule diclofenac"""
        parent, salt = normalize_salt("diclofenac sodium", self.kb.salts)
        self.assertEqual(parent, "diclofenac")
        self.assertEqual(salt, "sodium")

    def test_manual_override(self):
        """Manual override has highest precedence"""
        record = resolve_drug_record("abc forte", self.kb)
        self.assertEqual(record.canonical_name, "paracetamol")
        self.assertEqual(record.display_name, "Paracetamol")
        self.assertEqual(record.data_source, "MANUAL_OVERRIDE")

    def test_scientific_name_preservation(self):
        """N-acetylcysteine display name preserves lowercase hyphenation, not naive title case"""
        disp = self.kb.get_display_name("n-acetylcysteine")
        self.assertEqual(disp, "N-acetylcysteine")

    def test_clinical_rules_flags(self):
        """QT prolongation and Hyperkalemia flags assigned deterministically"""
        record_qt = resolve_drug_record("Azithromycin 500mg", self.kb)
        self.rule_engine.apply(record_qt)
        self.assertIn("QT_PROLONGATION", record_qt.clinical_flags)

        record_k = resolve_drug_record("Spironolactone 25mg", self.kb)
        self.rule_engine.apply(record_k)
        self.assertIn("HYPERKALEMIA_RISK", record_k.clinical_flags)

    def test_side_effect_prioritization(self):
        """Life-threatening side effects precede minor/common adverse reactions"""
        effects = self.kb.get_side_effects("amoxicillin")
        self.assertTrue(len(effects) > 0)
        # Anaphylaxis is life-threatening and must appear before Nausea
        self.assertIn("Anaphylaxis", effects)
        self.assertIn("Nausea", effects)
        anaph_idx = effects.index("Anaphylaxis")
        nausea_idx = effects.index("Nausea")
        self.assertLess(anaph_idx, nausea_idx)

    def test_data_quality_scoring(self):
        """Quality score calculates deterministically up to 100"""
        record = resolve_drug_record("Amoxicillin 500mg", self.kb)
        record.indications = ["Acute Otitis Media"]
        record.side_effects = ["Diarrhea"]
        record.drug_classes = ["Beta-Lactam Antibiotic"]
        record.contraindications = ["Penicillin Allergy"]
        record.interactions = ["Methotrexate"]
        record.prescribing_pearls = ["Complete course"]
        score = record.calculate_quality_score()
        self.assertGreaterEqual(score, 90)
        self.assertEqual(record.confidence, "HIGH")

    def test_end_to_end_compiler_pipeline(self):
        """Verify complete compiler run on a temporary SQLite database."""
        with tempfile.NamedTemporaryFile(suffix=".sqlite", delete=False) as tf:
            db_path = tf.name

        try:
            conn = sqlite3.connect(db_path)
            cur = conn.cursor()
            cur.execute("""
                CREATE TABLE drug_master (
                    id INTEGER PRIMARY KEY,
                    brand_name TEXT,
                    generic_name TEXT,
                    dosage_form TEXT,
                    strength TEXT,
                    price REAL
                )
            """)
            sample_data = [
                (1, "Augmentin 625", "Amoxicillin and Clavulanic Acid", "Tablet", "625mg", 120.5),
                (2, "Clavam 625", "Amoxycillin and Potassium Clavulanate", "Tablet", "625mg", 115.0),
                (3, "Dolo 650", "Paracetamol", "Tablet", "650mg", 30.0),
                (4, "Calpol 500", "Acetaminophen", "Tablet", "500mg", 20.0),
                (5, "Atorva 20", "Atorvastatin Calcium", "Tablet", "20mg", 150.0),
                (6, "Lasix 40", "Frusemide", "Tablet", "40mg", 12.0),
                (7, "Aldactone 25", "Spironolactone", "Tablet", "25mg", 45.0),
                (8, "UnknownFakeDrug", "XYZ-SUPER-123", "Capsule", "100mg", 99.0)
            ]
            cur.executemany(
                "INSERT INTO drug_master VALUES (?, ?, ?, ?, ?, ?)",
                sample_data
            )
            conn.commit()
            conn.close()

            compiler = DrugCompiler(kb=self.kb)
            report = compiler.compile(
                db_path=db_path,
                top_n=10,
                validate_only=False,
                dry_run=False
            )

            self.assertEqual(report["source_rows"], 8)
            self.assertGreater(report["canonical_molecules"], 0)

            # Check resulting clinical_drugs table
            conn = sqlite3.connect(db_path)
            cur = conn.cursor()
            cur.execute("SELECT generic_molecule, clinical_flags, data_status FROM clinical_drugs")
            rows = cur.fetchall()
            conn.close()

            molecules = [r[0] for r in rows]
            self.assertIn("Amoxicillin + Clavulanic Acid", molecules)
            self.assertIn("Paracetamol", molecules)
            self.assertIn("Atorvastatin", molecules)
            self.assertIn("Furosemide", molecules)

        finally:
            if os.path.exists(db_path):
                os.remove(db_path)


if __name__ == "__main__":
    unittest.main()
