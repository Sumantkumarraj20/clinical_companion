"""Drug Refactory package for offline, deterministic compilation of clinical drug data."""

from .models import DrugRecord, RawDrugRow, ReviewQueueItem, Rule
from .knowledge import KnowledgeBase, load_knowledge
from .normalizer import (
    normalize_raw_name,
    extract_strengths,
    extract_dosage_form,
    extract_route,
    remove_brand_noise,
    normalize_spelling,
    normalize_salt,
    normalize_ingredient_names
)
from .combinations import resolve_combination, format_combination_canonical_name
from .resolver import resolve_drug_record
from .rules import ClinicalRuleEngine, build_clinical_rules
from .validator import DataValidator
from .compiler import DrugCompiler, generate_deterministic_drug_id

__all__ = [
    "DrugRecord",
    "RawDrugRow",
    "ReviewQueueItem",
    "Rule",
    "KnowledgeBase",
    "load_knowledge",
    "normalize_raw_name",
    "extract_strengths",
    "extract_dosage_form",
    "extract_route",
    "remove_brand_noise",
    "normalize_spelling",
    "normalize_salt",
    "normalize_ingredient_names",
    "resolve_combination",
    "format_combination_canonical_name",
    "resolve_drug_record",
    "ClinicalRuleEngine",
    "build_clinical_rules",
    "DataValidator",
    "DrugCompiler",
    "generate_deterministic_drug_id"
]
