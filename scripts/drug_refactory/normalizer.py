"""Multi-stage text normalization and feature extraction pipeline."""

from __future__ import annotations
import re
import unicodedata

# Regex for strengths: 500mg, 125mg/5ml, 1.2g, 2.5mcg, 10%, 100iu, 5000 iu, etc.
STRENGTH_PATTERN = re.compile(
    r'\b(?:\d+(?:\.\d+)?\s*(?:mg|g|mcg|µg|ug|ml|l|iu|u|meq|%|w/v|w/w|v/v)'
    r'(?:\s*/\s*(?:\d+(?:\.\d+)?\s*)?(?:ml|g|l|puff|dose|actuation))?)\b',
    re.IGNORECASE
)

# Brand noise tokens commonly seen in Indian and global SKU names
BRAND_NOISE_TOKENS = [
    r'\bforte\b', r'\bplus\b', r'\bpro\b', r'\bmax\b', r'\bd-?\d+\b',
    r'\bsr\b', r'\ber\b', r'\bxr\b', r'\bcr\b', r'\bdt\b', r'\bds\b',
    r'\bmr\b', r'\bla\b', r'\btr\b', r'\bpr\b', r'\bxl\b', r'\biv\b',
    r'\bim\b', r'\bod\b', r'\bbid\b', r'\btid\b', r'\bqid\b', r'\bhs\b',
    r'\bkid\b', r'\bjunior\b', r'\bpaediatric\b', r'\bpediatric\b',
    r'\bdrop\b', r'\bdrops\b', r'\bstrip\b', r'\btab\b', r'\bcaps\b',
    r'\btablets?\b', r'\bcapsules?\b', r'\bsyrups?\b', r'\bsuspensions?\b',
    r'\binjections?\b', r'\bampoule\b', r'\bvial\b', r'\bointment\b',
    r'\bgel\b', r'\bcream\b', r'\blotion\b', r'\bshampoo\b', r'\bwash\b',
    r'\bsoap\b', r'\bpowder\b', r'\bsachet\b', r'\brespules?\b',
    r'\brotacaps?\b', r'\binhaler\b', r'\btranscaps?\b', r'\beye\b',
    r'\bear\b', r'\bnasal\b', r'\bspray\b', r'\bgargle\b', r'\bmouthwash\b',
    r'\bpaste\b', r'\bpaints?\b', r'\bemulsion\b', r'\bliniment\b'
]
BRAND_NOISE_PATTERN = re.compile(r'|'.join(BRAND_NOISE_TOKENS), re.IGNORECASE)

DEFAULT_DOSAGE_FORMS = {
    "tablet": ["tablet", "tab", "tabs", "caplet", "dispersible tablet", "dt", "chewable tablet", "effervescent"],
    "capsule": ["capsule", "cap", "caps", "softgel"],
    "injection": ["injection", "inj", "vial", "ampoule", "infusion", "iv", "im"],
    "syrup": ["syrup", "syr", "suspension", "susp", "elixir", "liquid", "oral solution"],
    "cream": ["cream", "cr", "ointment", "oint", "gel", "lotion", "emulgel", "liniment"],
    "drops": ["drops", "drop", "eye drops", "ear drops", "nasal drops", "eye/ear drops"],
    "inhaler": ["inhaler", "mdi", "respule", "respules", "rotacap", "rotacaps", "rotahaler", "dry powder inhaler"],
    "spray": ["spray", "nasal spray", "metered dose spray"],
    "powder": ["powder", "sachet", "granules"],
    "suppository": ["suppository", "suppositories", "pessary", "pessaries"],
    "patch": ["patch", "transdermal patch"]
}

DOSAGE_TO_ROUTES = {
    "tablet": ["Oral"],
    "capsule": ["Oral"],
    "syrup": ["Oral"],
    "powder": ["Oral"],
    "injection": ["Intravenous", "Intramuscular", "Subcutaneous"],
    "cream": ["Topical"],
    "drops": ["Ophthalmic", "Otic", "Nasal"],
    "inhaler": ["Inhalation"],
    "spray": ["Nasal", "Topical"],
    "suppository": ["Rectal", "Vaginal"],
    "patch": ["Transdermal"]
}


def normalize_raw_name(text: str) -> str:
    """Normalize unicode, strip brackets, collapse whitespace, and convert to lower case."""
    if not text:
        return ""
    # Normalize unicode (e.g. accented characters, special dashes)
    normalized = unicodedata.normalize("NFKD", text)
    # Replace non-breaking spaces and hyphens
    normalized = normalized.replace("\xa0", " ").replace("–", "-").replace("—", "-")
    # Remove content in brackets if it only contains SKU packaging info
    normalized = re.sub(r'\[.*?\]', ' ', normalized)
    normalized = re.sub(r'\(.*?\)', ' ', normalized)
    # Replace punctuation except + and - (needed for combinations like 'amoxicillin + clavulanic acid' and 'N-acetylcysteine')
    normalized = re.sub(r'[,;/\\|&]', ' + ', normalized)
    # Lowercase internally
    normalized = normalized.lower().strip()
    # Collapse multiple whitespaces
    normalized = re.sub(r'\s+', ' ', normalized)
    return normalized


def extract_strengths(text: str) -> tuple[str, list[str]]:
    """Extract and remove dosage strengths from drug name string."""
    strengths: list[str] = []
    def _repl(match: re.Match) -> str:
        s = match.group(0).strip()
        strengths.append(s.lower())
        return " "

    cleaned = STRENGTH_PATTERN.sub(_repl, text)
    cleaned = re.sub(r'\s+', ' ', cleaned).strip()
    return cleaned, strengths


def extract_dosage_form(text: str, forms_dict: dict[str, list[str]] | None = None) -> tuple[str, list[str]]:
    """Extract standard dosage forms and strip them from the candidate generic string."""
    if forms_dict is None:
        forms_dict = DEFAULT_DOSAGE_FORMS

    detected_forms: list[str] = []
    cleaned = text

    # Sort forms by length descending to match multi-word forms first
    for canonical_form, variants in forms_dict.items():
        sorted_variants = sorted(variants, key=len, reverse=True)
        for variant in sorted_variants:
            pattern = re.compile(r'\b' + re.escape(variant) + r'\b', re.IGNORECASE)
            if pattern.search(cleaned):
                if canonical_form not in detected_forms:
                    detected_forms.append(canonical_form)
                cleaned = pattern.sub(" ", cleaned)

    cleaned = re.sub(r'\s+', ' ', cleaned).strip()
    return cleaned, detected_forms


def extract_route(dosage_forms: list[str]) -> list[str]:
    """Map extracted dosage forms to clinical routes of administration."""
    routes: list[str] = []
    for form in dosage_forms:
        for r in DOSAGE_TO_ROUTES.get(form, []):
            if r not in routes:
                routes.append(r)
    if not routes:
        routes = ["Oral"]  # Most common default fallback if unclassified
    return routes


def remove_brand_noise(text: str) -> str:
    """Strip extraneous packaging, release tokens, and noise words."""
    cleaned = BRAND_NOISE_PATTERN.sub(" ", text)
    cleaned = re.sub(r'\s+', ' ', cleaned).strip()
    return cleaned


def normalize_salt(ingredient: str, salt_dict: dict[str, dict[str, str]]) -> tuple[str, str | None]:
    """Check explicit salt dictionary to split molecule into parent and salt."""
    clean_ing = ingredient.lower().strip()
    if clean_ing in salt_dict:
        data = salt_dict[clean_ing]
        return data.get("parent", clean_ing), data.get("salt")

    # Conservative salt heuristic fallback: only strip a trailing salt token
    # when the remaining parent is non-empty and not a single letter (avoids
    # mangling names like "vitamin c"). Explicit salts.json remains primary.
    common_salts = [
        "hydrochloride", "hcl", "sodium", "potassium", "sulfate", "sulphate",
        "mesylate", "maleate", "tartrate", "citrate", "succinate", "acetate",
        "phosphate", "calcium", "bromide", "iodide", "fumarate", "gluconate",
        "propionate", "dipropionate", "valerate", "monohydrate", "dihydrate",
        "trihydrate", "besylate", "tosylate", "palmitate", "oxalate"
    ]
    words = clean_ing.split()
    if len(words) > 1 and words[-1] in common_salts:
        return " ".join(words[:-1]), words[-1]

    return clean_ing, None


def normalize_spelling(ingredient: str, aliases: dict[str, str]) -> str:
    """Map spelling variant to canonical ingredient using explicit alias dictionary."""
    clean_ing = ingredient.lower().strip()
    return aliases.get(clean_ing, clean_ing)


def normalize_ingredient_names(
    ingredients: list[str],
    aliases: dict[str, str],
    salts: dict[str, dict[str, str]]
) -> tuple[list[str], list[str]]:
    """Normalize a list of ingredients through spelling aliases and salt separation."""
    normalized_ingredients: list[str] = []
    detected_salts: list[str] = []

    for ing in ingredients:
        clean_ing = ing.strip()
        if not clean_ing:
            continue
        # First check explicit alias
        aliased = normalize_spelling(clean_ing, aliases)
        # Check salt
        parent, salt = normalize_salt(aliased, salts)
        # Re-check alias of parent (e.g. diclofenac -> diclofenac)
        final_parent = normalize_spelling(parent, aliases)

        if final_parent and final_parent not in normalized_ingredients:
            normalized_ingredients.append(final_parent)
        if salt and salt not in detected_salts:
            detected_salts.append(salt)

    return normalized_ingredients, detected_salts
