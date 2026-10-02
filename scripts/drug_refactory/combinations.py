"""Combination drug detection, splitting, and deterministic sorting."""

from __future__ import annotations
import re


def detect_combination_delimiter(text: str) -> list[str]:
    """Split string on combination markers (+, with, and, /)."""
    # Protect N-acetylcysteine or hyphenated names
    # First replace explicit combination phrases like 'with' and 'and' surrounded by spaces
    s = re.sub(r'\s+(?:with|and|&)\s+', ' + ', text, flags=re.IGNORECASE)
    # Split on '+' or '/'
    parts = [p.strip() for p in re.split(r'[\+/]', s)]
    # Filter empty or very short parts
    return [p for p in parts if len(p) > 1]


def resolve_combination(
    clean_text: str,
    combination_aliases: dict[str, list[str]]
) -> list[str] | None:
    """Resolve combination drug into canonical list of ingredients.
    
    Checks explicit combination aliases first, then falls back to syntactic splitting.
    """
    clean = clean_text.lower().strip()
    if clean in combination_aliases:
        # Canonicalize order alphabetically
        return sorted(list(dict.fromkeys(combination_aliases[clean])))

    parts = detect_combination_delimiter(clean)
    if len(parts) > 1:
        return sorted(list(dict.fromkeys(parts)))

    return None


def format_combination_canonical_name(ingredients: list[str], display_names: dict[str, str]) -> str:
    """Format canonical combination name with proper capitalization in alphabetical order."""
    def _fallback(ing: str) -> str:
        # Multi-word aware capitalization without blind .title():
        # "clavulanic acid" -> "Clavulanic Acid", "n-acetylcysteine" -> "N-acetylcysteine"
        parts = []
        for w in ing.lower().split(" "):
            if "-" in w:
                head, _, tail = w.partition("-")
                if len(head) <= 2 and head:
                    parts.append(head.upper() + "-" + (tail[:1].upper() + tail[1:].lower() if tail else ""))
                else:
                    parts.append(w[:1].upper() + w[1:].lower() if w else w)
            else:
                parts.append(w[:1].upper() + w[1:].lower() if w else w)
        return " ".join(parts)
    formatted_parts = []
    # Deterministic alphabetical sorting by ingredient identifier
    sorted_ingredients = sorted(ingredients)
    for ing in sorted_ingredients:
        display = display_names.get(ing.lower(), _fallback(ing))
        formatted_parts.append(display)
    return " + ".join(formatted_parts)
