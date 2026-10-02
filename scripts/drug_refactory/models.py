"""Data models for the Offline Drug Data Refactory."""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any, Callable


@dataclass
class RawDrugRow:
    """Represents a single raw row streamed from drug_master."""
    row_id: str | int
    raw_name: str
    brand_name: str | None = None
    dosage_form: str | None = None
    strength: str | None = None
    price: float | None = None
    manufacturer: str | None = None


@dataclass
class NormalizedDrug:
    """Intermediate representation after string cleaning and extraction."""
    raw_name: str
    cleaned_name: str
    extracted_strengths: list[str] = field(default_factory=list)
    extracted_dosage_forms: list[str] = field(default_factory=list)
    extracted_routes: list[str] = field(default_factory=list)
    detected_salts: list[str] = field(default_factory=list)
    is_combination: bool = False
    candidate_ingredients: list[str] = field(default_factory=list)


@dataclass
class DrugRecord:
    """Canonical representation of an aggregated and clinically enriched drug."""
    source_name: str
    canonical_name: str | None
    display_name: str
    ingredients: list[str] = field(default_factory=list)
    strengths: list[str] = field(default_factory=list)
    dosage_forms: list[str] = field(default_factory=list)
    routes: list[str] = field(default_factory=list)
    drug_classes: list[str] = field(default_factory=list)
    indications: list[str] = field(default_factory=list)
    side_effects: list[str] = field(default_factory=list)
    contraindications: list[str] = field(default_factory=list)
    interactions: list[str] = field(default_factory=list)
    prescribing_pearls: list[str] = field(default_factory=list)
    clinical_flags: list[str] = field(default_factory=list)
    top_brands: list[dict[str, Any]] = field(default_factory=list)
    usage_frequency: int = 0
    confidence: str = "LOW"  # HIGH, MEDIUM, LOW
    data_status: str = "UNRESOLVED"  # RESOLVED, PARTIALLY_RESOLVED, UNRESOLVED
    data_source: str = "LOCAL_CURATED"  # LOCAL_CURATED, MANUAL_OVERRIDE, RAW_FALLBACK
    knowledge_version: str = "1.0.0"
    data_quality_score: int = 0
    stable_id: str = ""
    # Fuzzy candidate matches for review queue only (never auto-resolved).
    _candidate_matches: list[str] = field(default_factory=list, repr=False)

    def calculate_quality_score(self) -> int:
        score = 0
        if self.canonical_name and self.data_status in ("RESOLVED", "PARTIALLY_RESOLVED"):
            score += 40
        if self.ingredients:
            score += 15
        if self.drug_classes:
            score += 10
        if self.indications:
            score += 10
        if self.side_effects:
            score += 10
        if self.contraindications:
            score += 5
        if self.interactions:
            score += 5
        if self.prescribing_pearls:
            score += 5
        self.data_quality_score = score

        if score >= 90:
            self.confidence = "HIGH"
        elif score >= 70:
            self.confidence = "MEDIUM"
        else:
            self.confidence = "LOW"

        return score


@dataclass
class Rule:
    """Explicit clinical rule definition."""
    name: str
    condition: Callable[[DrugRecord], bool]
    effect: Callable[[DrugRecord], None]
    description: str = ""


@dataclass
class ReviewQueueItem:
    """Item queued for human pharmacist / clinical developer review."""
    source_name: str
    normalized_name: str
    candidate_matches: list[str] = field(default_factory=list)
    reason: str = "NO_CANONICAL_MATCH"
    status: str = "REVIEW_REQUIRED"
    frequency: int = 0
