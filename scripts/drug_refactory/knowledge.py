"""Knowledge Base loader and indexed clinical lookup tables."""

from __future__ import annotations
import json
import os
from dataclasses import dataclass, field
from typing import Any


@dataclass
class KnowledgeBase:
    """Holds indexed clinical and pharmacological dictionaries for O(1) lookup."""
    manifest: dict[str, str] = field(default_factory=dict)
    generic_aliases: dict[str, str] = field(default_factory=dict)
    ingredient_aliases: dict[str, str] = field(default_factory=dict)
    combination_aliases: dict[str, list[str]] = field(default_factory=dict)
    dosage_forms: dict[str, list[str]] = field(default_factory=dict)
    brand_aliases: dict[str, str] = field(default_factory=dict)
    indications: dict[str, list[str]] = field(default_factory=dict)
    side_effects: dict[str, list[Any]] = field(default_factory=dict)
    drug_classes: dict[str, list[str]] = field(default_factory=dict)
    contraindications: dict[str, list[str]] = field(default_factory=dict)
    interactions: dict[str, list[str]] = field(default_factory=dict)
    prescribing_rules: dict[str, list[str]] = field(default_factory=dict)
    indication_aliases: dict[str, str] = field(default_factory=dict)
    validation_rules: dict[str, Any] = field(default_factory=dict)
    manual_overrides: dict[str, dict[str, Any]] = field(default_factory=dict)
    canonical_molecules: set[str] = field(default_factory=set)
    display_names: dict[str, str] = field(default_factory=dict)
    salts: dict[str, dict[str, str]] = field(default_factory=dict)

    @property
    def version(self) -> str:
        return self.manifest.get("knowledge_version", "1.0.0")

    def is_canonical(self, name: str) -> bool:
        return name.lower() in self.canonical_molecules

    def get_display_name(self, canonical_name: str) -> str:
        key = canonical_name.lower().strip()
        if key in self.display_names:
            return self.display_names[key]
        # Preserve N-acetylcysteine-style hyphenated prefixes while
        # title-casing each space-separated word (e.g. "clavulanic acid"
        # -> "Clavulanic Acid"). Never use blind .title() on the whole
        # string for scientific names; handle hyphenated tokens carefully.
        def _smart_cap(token: str) -> str:
            if "-" in token:
                head, _, tail = token.partition("-")
                if len(head) <= 2:
                    # Keep prefix like N-, D-, L-, S- upper, rest lower
                    # e.g. n-acetylcysteine -> N-acetylcysteine
                    return head.upper() + "-" + tail[:1].upper() + tail[1:].lower() if tail else head.upper() + "-"
                return token[:1].upper() + token[1:].lower()
            if any(c.isupper() for c in token) and token not in (token.lower(), token.upper(), token.capitalize()):
                return token
            return token[:1].upper() + token[1:].lower() if token else token
        return " ".join(_smart_cap(w) for w in key.split(" "))

    def get_indications(self, molecule: str) -> list[str]:
        raw = self.indications.get(molecule.lower().strip(), [])
        # Canonicalize every term through indication_aliases so legacy
        # variants (CAP, GERD, AOM, ...) collapse to one display term.
        canonical: list[str] = []
        for term in raw:
            key = str(term).lower().strip()
            mapped = self.indication_aliases.get(key, str(term).strip())
            if mapped not in canonical:
                canonical.append(mapped)
        return canonical

    def get_side_effects(self, molecule: str) -> list[str]:
        """Return prioritized list of side effect terms."""
        raw_effects = self.side_effects.get(molecule.lower().strip(), [])
        if not raw_effects:
            return []
        # If stored as structured objects, prioritize by severity
        if isinstance(raw_effects[0], dict):
            # Prioritization: life-threatening -> organ-threatening -> clinically important -> common -> minor
            severity_order = {
                "life_threatening": 1,
                "organ_threatening": 2,
                "potentially_serious": 3,
                "clinically_important": 4,
                "common": 5,
                "usually_mild": 6,
                "minor": 7
            }
            sorted_effects = sorted(
                raw_effects,
                key=lambda x: severity_order.get(x.get("severity", "minor"), 99)
            )
            return [x["term"] for x in sorted_effects if "term" in x]
        return list(raw_effects)

    def get_drug_classes(self, molecule: str) -> list[str]:
        return self.drug_classes.get(molecule.lower().strip(), [])

    def get_contraindications(self, molecule: str) -> list[str]:
        return self.contraindications.get(molecule.lower().strip(), [])

    def get_interactions(self, molecule: str) -> list[str]:
        return self.interactions.get(molecule.lower().strip(), [])

    def get_prescribing_pearls(self, molecule: str) -> list[str]:
        return self.prescribing_rules.get(molecule.lower().strip(), [])


def _load_json(file_path: str, default: Any) -> Any:
    if not os.path.exists(file_path):
        return default
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"[WARN] Failed to load {file_path}: {e}")
        return default


def load_knowledge(base_dir: str = "assets/drug_refactory") -> KnowledgeBase:
    """Loads all knowledge base files into memory."""
    kb = KnowledgeBase()
    kb.manifest = _load_json(os.path.join(base_dir, "manifest.json"), {
        "schema_version": "1.0.0",
        "knowledge_version": "2026.09.01",
        "compiler_version": "1.0.0"
    })
    kb.generic_aliases = {
        k.lower().strip(): v.lower().strip()
        for k, v in _load_json(os.path.join(base_dir, "generic_aliases.json"), {}).items()
    }
    kb.ingredient_aliases = {
        k.lower().strip(): v.lower().strip()
        for k, v in _load_json(os.path.join(base_dir, "ingredient_aliases.json"), {}).items()
    }
    kb.combination_aliases = {
        k.lower().strip(): [ing.lower().strip() for ing in v]
        for k, v in _load_json(os.path.join(base_dir, "combination_aliases.json"), {}).items()
    }
    kb.dosage_forms = _load_json(os.path.join(base_dir, "dosage_forms.json"), {})
    kb.brand_aliases = {
        k.lower().strip(): v.lower().strip()
        for k, v in _load_json(os.path.join(base_dir, "brand_aliases.json"), {}).items()
    }
    kb.indications = {
        k.lower().strip(): v
        for k, v in _load_json(os.path.join(base_dir, "indications.json"), {}).items()
    }
    kb.side_effects = {
        k.lower().strip(): v
        for k, v in _load_json(os.path.join(base_dir, "side_effects.json"), {}).items()
    }
    kb.drug_classes = {
        k.lower().strip(): v
        for k, v in _load_json(os.path.join(base_dir, "drug_classes.json"), {}).items()
    }
    kb.contraindications = {
        k.lower().strip(): v
        for k, v in _load_json(os.path.join(base_dir, "contraindications.json"), {}).items()
    }
    kb.interactions = {
        k.lower().strip(): v
        for k, v in _load_json(os.path.join(base_dir, "interactions.json"), {}).items()
    }
    kb.prescribing_rules = {
        k.lower().strip(): v
        for k, v in _load_json(os.path.join(base_dir, "prescribing_rules.json"), {}).items()
    }
    kb.indication_aliases = {
        k.lower().strip(): v.strip()
        for k, v in _load_json(os.path.join(base_dir, "indication_aliases.json"), {}).items()
    }
    kb.validation_rules = _load_json(os.path.join(base_dir, "validation_rules.json"), {})
    raw_overrides = _load_json(os.path.join(base_dir, "manual_overrides.json"), {})
    kb.manual_overrides = {}
    for k, v in raw_overrides.items():
        canon = str(v.get("canonical_name", "") or "")
        # Normalize canonical ingredient keys to lowercase for resolver/dedup
        canon_key = canon.lower().strip()
        ings = [str(i).lower().strip() for i in v.get("ingredients", []) if str(i).strip()]
        kb.manual_overrides[k.lower().strip()] = {
            "canonical_name": canon_key or canon,
            "display_name": canon,  # preserve curated display casing
            "ingredients": ings,
            "confidence": v.get("confidence", "HIGH"),
        }
    raw_salts = _load_json(os.path.join(base_dir, "salts.json"), {})
    kb.salts = {
        k.lower().strip(): v for k, v in raw_salts.items()
    }

    # Populate canonical molecules set from all curated clinical tables
    canonical = set()
    canonical.update(kb.indications.keys())
    canonical.update(kb.side_effects.keys())
    canonical.update(kb.drug_classes.keys())
    canonical.update(kb.contraindications.keys())
    canonical.update(kb.interactions.keys())
    canonical.update(kb.prescribing_rules.keys())
    # Add values of aliases
    canonical.update(kb.generic_aliases.values())
    canonical.update(kb.ingredient_aliases.values())
    kb.canonical_molecules = canonical

    # Build display name cache
    display_file = os.path.join(base_dir, "display_names.json")
    if os.path.exists(display_file):
        kb.display_names = _load_json(display_file, {})
    else:
        # Default smart display names: title-case each word while
        # preserving hyphenated scientific prefixes (N-acetylcysteine).
        def _default_display(m: str) -> str:
            parts = []
            for w in m.split(" "):
                if "-" in w:
                    head, _, tail = w.partition("-")
                    if len(head) <= 2 and head:
                        parts.append(head.upper() + "-" + (tail[:1].upper() + tail[1:].lower() if tail else ""))
                    else:
                        parts.append(w[:1].upper() + w[1:].lower() if w else w)
                else:
                    parts.append(w[:1].upper() + w[1:].lower() if w else w)
            return " ".join(parts)
        kb.display_names = {
            m: _default_display(m) for m in canonical
        }
        # Special scientific / biological capitalization overrides
        special_names = {
            "n-acetylcysteine": "N-acetylcysteine",
            "co-amoxiclav": "Co-amoxiclav",
            "peg-interferon": "PEG-interferon",
            "d-penicillamine": "D-penicillamine",
            "l-thyroxine": "L-thyroxine",
            "s-amlodipine": "S-amlodipine",
            "esomeprazole": "Esomeprazole",
            "levocetirizine": "Levocetirizine"
        }
        kb.display_names.update(special_names)

    return kb
