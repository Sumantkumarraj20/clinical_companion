"""Deterministic clinical rules engine and clinical safety flags."""

from __future__ import annotations
from typing import Callable
from .models import DrugRecord, Rule
from .knowledge import KnowledgeBase

# Curated sets of molecules known to carry specific clinical risks
QT_PROLONGING_DRUGS = {
    "amiodarone", "sotalol", "haloperidol", "quetiapine", "ondansetron",
    "erythromycin", "clarithromycin", "azithromycin", "ciprofloxacin",
    "levofloxacin", "moxifloxacin", "fluconazole", "methadone", "hydroxychloroquine"
}

HYPERKALEMIA_DRUGS = {
    "spironolactone", "eplerenone", "lisinopril", "ramipril", "enalapril",
    "losartan", "telmisartan", "valsartan", "trimethoprim", "heparin"
}

HYPOKALEMIA_DRUGS = {
    "furosemide", "torsemide", "hydrochlorothiazide", "chlorthalidone",
    "indapamide", "amphotericin b", "insulin", "albuterol", "salbutamol"
}

HEPATOTOXIC_DRUGS = {
    "paracetamol", "methotrexate", "isoniazid", "rifampicin", "pyrazinamide",
    "valproate", "amiodarone", "ketoconazole", "statins", "atorvastatin"
}

NEPHROTOXIC_DRUGS = {
    "gentamicin", "amikacin", "tobramycin", "vancomycin", "cisplatin",
    "amphotericin b", "ibuprofen", "diclofenac", "naproxen", "tenofovir"
}

BLEEDING_RISK_DRUGS = {
    "aspirin", "clopidogrel", "prasugrel", "ticagrelor", "warfarin",
    "heparin", "enoxaparin", "dabigatran", "rivaroxaban", "apixaban"
}

SEDATION_DRUGS = {
    "alprazolam", "clonazepam", "diazepam", "lorazepam", "zolpidem",
    "diphenhydramine", "promethazine", "chlorpheniramine", "olanzapine", "chlorpromazine"
}

SEROTONERGIC_DRUGS = {
    "fluoxetine", "sertraline", "paroxetine", "citalopram", "escitalopram",
    "venlafaxine", "duloxetine", "tramadol", "linezolid", "trazodone"
}

BRADYCARDIA_DRUGS = {
    "metoprolol", "atenolol", "bisoprolol", "carvedilol", "verapamil",
    "diltiazem", "digoxin", "amiodarone", "clonidine"
}

HYPOTENSION_DRUGS = {
    "amlodipine", "nifedipine", "doxazosin", "prazosin", "tamsulosin",
    "nitroglycerin", "isosorbide mononitrate", "hydralazine"
}

HYPOGLYCEMIA_DRUGS = {
    "glimepiride", "gliclazide", "glipizide", "glibenclamide", "insulin", "repaglinide"
}


def build_clinical_rules() -> list[Rule]:
    """Constructs the deterministic clinical safety rules."""
    rules: list[Rule] = []

    def _has_any_ingredient(record: DrugRecord, target_set: set[str]) -> bool:
        molecules = set(ing.lower().strip() for ing in record.ingredients)
        if record.canonical_name:
            molecules.add(record.canonical_name.lower().strip())
        return bool(molecules.intersection(target_set))

    # 1. QT Prolongation
    rules.append(Rule(
        name="QT_PROLONGATION_FLAG",
        condition=lambda d: _has_any_ingredient(d, QT_PROLONGING_DRUGS),
        effect=lambda d: d.clinical_flags.append("QT_PROLONGATION"),
        description="Surfaces risk of cardiac repolarization delay / Torsades de Pointes."
    ))

    # 2. Hyperkalemia
    rules.append(Rule(
        name="HYPERKALEMIA_RISK_FLAG",
        condition=lambda d: _has_any_ingredient(d, HYPERKALEMIA_DRUGS),
        effect=lambda d: d.clinical_flags.append("HYPERKALEMIA_RISK"),
        description="Surfaces risk of serum potassium elevation."
    ))

    # 3. Hypokalemia
    rules.append(Rule(
        name="HYPOKALEMIA_RISK_FLAG",
        condition=lambda d: _has_any_ingredient(d, HYPOKALEMIA_DRUGS),
        effect=lambda d: d.clinical_flags.append("HYPOKALEMIA_RISK"),
        description="Surfaces risk of serum potassium depletion."
    ))

    # 4. Hepatotoxicity
    rules.append(Rule(
        name="HEPATOTOXICITY_FLAG",
        condition=lambda d: _has_any_ingredient(d, HEPATOTOXIC_DRUGS),
        effect=lambda d: d.clinical_flags.append("HEPATOTOXICITY"),
        description="Surfaces drug-induced liver injury / transaminitis risk."
    ))

    # 5. Nephrotoxicity
    rules.append(Rule(
        name="NEPHROTOXICITY_FLAG",
        condition=lambda d: _has_any_ingredient(d, NEPHROTOXIC_DRUGS),
        effect=lambda d: d.clinical_flags.append("NEPHROTOXICITY"),
        description="Surfaces acute tubular necrosis / renal impairment risk."
    ))

    # 6. Bleeding Risk
    rules.append(Rule(
        name="BLEEDING_RISK_FLAG",
        condition=lambda d: _has_any_ingredient(d, BLEEDING_RISK_DRUGS),
        effect=lambda d: d.clinical_flags.append("BLEEDING_RISK"),
        description="Surfaces antiplatelet / anticoagulant hemorrhagic risk."
    ))

    # 7. Sedation
    rules.append(Rule(
        name="SEDATION_FLAG",
        condition=lambda d: _has_any_ingredient(d, SEDATION_DRUGS),
        effect=lambda d: d.clinical_flags.append("SEDATION"),
        description="Surfaces CNS depression and psychomotor slowing risk."
    ))

    # 8. Serotonergic Risk
    rules.append(Rule(
        name="SEROTONERGIC_RISK_FLAG",
        condition=lambda d: _has_any_ingredient(d, SEROTONERGIC_DRUGS),
        effect=lambda d: d.clinical_flags.append("SEROTONERGIC_RISK"),
        description="Surfaces Serotonin Syndrome risk."
    ))

    # 9. Bradycardia
    rules.append(Rule(
        name="BRADYCARDIA_FLAG",
        condition=lambda d: _has_any_ingredient(d, BRADYCARDIA_DRUGS),
        effect=lambda d: d.clinical_flags.append("BRADYCARDIA"),
        description="Surfaces AV nodal slowing and negative chronotropic risk."
    ))

    # 10. Hypotension
    rules.append(Rule(
        name="HYPOTENSION_FLAG",
        condition=lambda d: _has_any_ingredient(d, HYPOTENSION_DRUGS),
        effect=lambda d: d.clinical_flags.append("HYPOTENSION"),
        description="Surfaces systemic vasodilation / orthostatic hypotension risk."
    ))

    # 11. Hypoglycemia
    rules.append(Rule(
        name="HYPOGLYCEMIA_FLAG",
        condition=lambda d: _has_any_ingredient(d, HYPOGLYCEMIA_DRUGS),
        effect=lambda d: d.clinical_flags.append("HYPOGLYCEMIA"),
        description="Surfaces acute hypoglycemic risk."
    ))

    return rules


class ClinicalRuleEngine:
    """Executes deterministic rules over DrugRecord objects."""

    def __init__(self, custom_rules: list[Rule] | None = None):
        self.rules = custom_rules if custom_rules is not None else build_clinical_rules()

    def apply(self, record: DrugRecord) -> None:
        """Apply all active rules to enrich the record."""
        for rule in self.rules:
            if rule.condition(record):
                rule.effect(record)
        # Deduplicate flags
        record.clinical_flags = sorted(list(set(record.clinical_flags)))
