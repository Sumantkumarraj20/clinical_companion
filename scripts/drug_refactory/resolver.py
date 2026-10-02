"""Canonical molecule resolution following the strict priority chain."""

from __future__ import annotations
import difflib
from .models import NormalizedDrug, DrugRecord
from .knowledge import KnowledgeBase
from .normalizer import (
    normalize_raw_name,
    extract_strengths,
    extract_dosage_form,
    extract_route,
    remove_brand_noise,
    normalize_ingredient_names
)
from .combinations import resolve_combination, format_combination_canonical_name


def resolve_drug_record(
    source_name: str,
    kb: KnowledgeBase,
    brand_name: str | None = None,
    dosage_form_hint: str | None = None,
    strength_hint: str | None = None
) -> DrugRecord:
    """Resolve a raw drug name into a DrugRecord following the priority hierarchy:

    1. Manual override
    2. Exact canonical match
    3. Explicit alias (generic_aliases / ingredient_aliases on full string)
    4. Combination dictionary & combination detection
    5. Normalized match
    6. Safe deterministic rule (explicit brand-alias lookup)
    7. Unresolved
    """
    raw_lower = source_name.lower().strip()

    # Stage 0: raw normalization (needed for manual-override key fallback)
    norm_text = normalize_raw_name(source_name)

    # Step 1: Manual Override (raw key AND normalized-name key)
    override = kb.manual_overrides.get(raw_lower)
    if override is None and norm_text and norm_text != raw_lower:
        override = kb.manual_overrides.get(norm_text)
    if override is not None:
        canon_key = str(override.get("canonical_name", "") or "").lower().strip()
        display = override.get("display_name") or kb.get_display_name(canon_key or raw_lower)
        record = DrugRecord(
            source_name=source_name,
            canonical_name=canon_key or None,
            display_name=display,
            ingredients=override.get("ingredients", []),
            strengths=[],
            dosage_forms=[],
            routes=["Oral"],
            confidence=override.get("confidence", "HIGH"),
            data_status="RESOLVED",
            data_source="MANUAL_OVERRIDE",
            knowledge_version=kb.version
        )
        return record

    # Stage 1: Preprocessing & extraction (reuse Stage-0 normalization)
    cleaned_after_strengths, extracted_strengths = extract_strengths(norm_text)
    if strength_hint and strength_hint.lower() not in extracted_strengths:
        extracted_strengths.append(strength_hint.lower())

    cleaned_after_forms, extracted_forms = extract_dosage_form(cleaned_after_strengths, kb.dosage_forms)
    if dosage_form_hint and dosage_form_hint.lower() not in extracted_forms:
        extracted_forms.append(dosage_form_hint.lower())

    routes = extract_route(extracted_forms)
    cleaned_generic = remove_brand_noise(cleaned_after_forms)

    # Step 2: Exact canonical match (normalized full string)
    if cleaned_generic and kb.is_canonical(cleaned_generic):
        display = kb.get_display_name(cleaned_generic)
        return DrugRecord(
            source_name=source_name,
            canonical_name=cleaned_generic,
            display_name=display,
            ingredients=[cleaned_generic],
            strengths=extracted_strengths,
            dosage_forms=extracted_forms,
            routes=routes,
            confidence="HIGH",
            data_status="RESOLVED",
            data_source="LOCAL_CURATED",
            knowledge_version=kb.version
        )

    # Step 3: Explicit alias on the full normalized string
    if cleaned_generic and cleaned_generic in kb.generic_aliases:
        alias_target = kb.generic_aliases[cleaned_generic]
        if " + " in alias_target:
            parts = [p.strip() for p in alias_target.split("+")]
            norm_parts, _ = normalize_ingredient_names(parts, kb.ingredient_aliases, kb.salts)
            sorted_parts = sorted(norm_parts)
            display = format_combination_canonical_name(sorted_parts, kb.display_names)
            return DrugRecord(
                source_name=source_name,
                canonical_name=" + ".join(sorted_parts),
                display_name=display,
                ingredients=sorted_parts,
                strengths=extracted_strengths,
                dosage_forms=extracted_forms,
                routes=routes,
                confidence="HIGH",
                data_status="RESOLVED",
                data_source="LOCAL_CURATED",
                knowledge_version=kb.version
            )
        norm_ing, _ = normalize_ingredient_names([alias_target], kb.ingredient_aliases, kb.salts)
        final_ing = norm_ing[0] if norm_ing else alias_target
        display = kb.get_display_name(final_ing)
        return DrugRecord(
            source_name=source_name,
            canonical_name=final_ing,
            display_name=display,
            ingredients=[final_ing],
            strengths=extracted_strengths,
            dosage_forms=extracted_forms,
            routes=routes,
            confidence="HIGH",
            data_status="RESOLVED",
            data_source="LOCAL_CURATED",
            knowledge_version=kb.version
        )

    # Step 4: Combination Detection & Aliases
    combo_parts = resolve_combination(cleaned_generic, kb.combination_aliases)
    if not combo_parts:
        combo_parts = resolve_combination(cleaned_after_strengths, kb.combination_aliases)

    if combo_parts and len(combo_parts) > 1:
        cleaned_parts = []
        for p in combo_parts:
            p_clean, _ = extract_dosage_form(p, kb.dosage_forms)
            p_clean = remove_brand_noise(p_clean)
            if p_clean:
                cleaned_parts.append(p_clean)

        norm_ingredients, detected_salts = normalize_ingredient_names(
            cleaned_parts,
            kb.ingredient_aliases,
            kb.salts
        )
        if norm_ingredients:
            sorted_ingredients = sorted(norm_ingredients)
            canonical_combo_key = " + ".join(sorted_ingredients)
            canonical_display = format_combination_canonical_name(sorted_ingredients, kb.display_names)

            all_known = all(kb.is_canonical(ing) for ing in sorted_ingredients)
            data_status = "RESOLVED" if all_known else "PARTIALLY_RESOLVED"
            confidence = "HIGH" if all_known else "MEDIUM"

            return DrugRecord(
                source_name=source_name,
                canonical_name=canonical_combo_key,
                display_name=canonical_display,
                ingredients=sorted_ingredients,
                strengths=extracted_strengths,
                dosage_forms=extracted_forms,
                routes=routes,
                confidence=confidence,
                data_status=data_status,
                data_source="LOCAL_CURATED",
                knowledge_version=kb.version
            )

    # Step 5: Normalized Match (Salt stripping / single ingredient normalization)
    # Note: exact/alias matches were already attempted before combinations;
    # this covers salt-stripped parent fallback (e.g. "xyz sodium" -> "xyz").
    norm_ingredients, detected_salts = normalize_ingredient_names(
        [cleaned_generic],
        kb.ingredient_aliases,
        kb.salts
    )
    if norm_ingredients:
        parent_ing = norm_ingredients[0]
        if kb.is_canonical(parent_ing):
            display = kb.get_display_name(parent_ing)
            return DrugRecord(
                source_name=source_name,
                canonical_name=parent_ing,
                display_name=display,
                ingredients=[parent_ing],
                strengths=extracted_strengths,
                dosage_forms=extracted_forms,
                routes=routes,
                confidence="HIGH",
                data_status="RESOLVED",
                data_source="LOCAL_CURATED",
                knowledge_version=kb.version
            )

    # Step 6: Safe Deterministic Rule (Explicit Brand Alias Lookup if provided)
    if brand_name and brand_name.lower().strip() in kb.brand_aliases:
        canonical_brand_target = kb.brand_aliases[brand_name.lower().strip()]
        if " + " in canonical_brand_target:
            parts = [p.strip() for p in canonical_brand_target.split("+")]
            norm_parts, _ = normalize_ingredient_names(parts, kb.ingredient_aliases, kb.salts)
            sorted_parts = sorted(norm_parts)
            display = format_combination_canonical_name(sorted_parts, kb.display_names)
            return DrugRecord(
                source_name=source_name,
                canonical_name=" + ".join(sorted_parts),
                display_name=display,
                ingredients=sorted_parts,
                strengths=extracted_strengths,
                dosage_forms=extracted_forms,
                routes=routes,
                confidence="HIGH",
                data_status="RESOLVED",
                data_source="LOCAL_CURATED",
                knowledge_version=kb.version
            )
        if kb.is_canonical(canonical_brand_target):
            display = kb.get_display_name(canonical_brand_target)
            return DrugRecord(
                source_name=source_name,
                canonical_name=canonical_brand_target,
                display_name=display,
                ingredients=[canonical_brand_target],
                strengths=extracted_strengths,
                dosage_forms=extracted_forms,
                routes=routes,
                confidence="HIGH",
                data_status="RESOLVED",
                data_source="LOCAL_CURATED",
                knowledge_version=kb.version
            )

    # Step 7: Unresolved (Do not hallucinate, generate candidate matches for review queue)
    candidate_matches = []
    if kb.canonical_molecules:
        matches = difflib.get_close_matches(cleaned_generic, list(kb.canonical_molecules), n=3, cutoff=0.82)
        candidate_matches = matches

    # Never use blind .title() for scientific display names; reuse the
    # canonical display helper (handles multi-word + N-acetylcysteine).
    fallback_display = kb.get_display_name(cleaned_generic) if cleaned_generic else "Unknown"
    unresolved_record = DrugRecord(
        source_name=source_name,
        canonical_name=None,
        display_name=fallback_display,
        ingredients=[],
        strengths=extracted_strengths,
        dosage_forms=extracted_forms,
        routes=routes,
        confidence="LOW",
        data_status="UNRESOLVED",
        data_source="RAW_FALLBACK",
        knowledge_version=kb.version
    )
    unresolved_record._candidate_matches = candidate_matches
    return unresolved_record
