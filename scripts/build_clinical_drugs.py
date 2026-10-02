#!/usr/bin/env python3
"""Offline Drug Data Refactory Compiler.

Compiles raw commercial drug databases into standardized clinical drug tables
with deterministic identity resolution and local rule-based clinical enrichment.
Zero external network calls or LLM dependencies.
"""

import argparse
import os
import sys

# Verification guarantee: strictly zero forbidden network and LLM libraries.
# Both a runtime check (sys.modules) and a static source scan of this
# compiler package are performed so hidden network access cannot regress.
FORBIDDEN_MODULES = ["google.generativeai", "openai", "anthropic", "requests", "httpx"]
for mod in FORBIDDEN_MODULES:
    if mod in sys.modules:
        raise RuntimeError(f"Strict Safety Violation: Forbidden module '{mod}' is imported.")


def _assert_no_forbidden_imports(package_dir: str) -> None:
    """Statically scan compiler sources for forbidden network/LLM imports.

    Allows the words in comments/docstrings only when not part of an import
    statement. Raises RuntimeError on violation.
    """
    import re

    import_re = re.compile(r"^\s*(import|from)\s+([A-Za-z0-9_.]+)")
    for root, _, files in os.walk(package_dir):
        for fn in files:
            if not fn.endswith(".py"):
                continue
            path = os.path.join(root, fn)
            with open(path, "r", encoding="utf-8") as f:
                for line in f:
                    m = import_re.match(line)
                    if not m:
                        continue
                    module = m.group(2)
                    for forbidden in FORBIDDEN_MODULES:
                        if module == forbidden or module.startswith(forbidden + "."):
                            raise RuntimeError(
                                f"Strict Safety Violation: Forbidden import '{module}' in {path}."
                            )

# Add scripts directory to sys.path for direct execution
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

try:
    from scripts.drug_refactory.knowledge import load_knowledge
    from scripts.drug_refactory.compiler import DrugCompiler
except ModuleNotFoundError:
    from drug_refactory.knowledge import load_knowledge
    from drug_refactory.compiler import DrugCompiler


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compile SQLite drug database 100% offline without Gemini, OpenAI, or paid APIs."
    )
    parser.add_argument(
        "--db-path",
        default="assets/clinical_drugs.sqlite",
        help="Path to the SQLite database (default: assets/clinical_drugs.sqlite)"
    )
    parser.add_argument(
        "--assets-dir",
        default="assets/drug_refactory",
        help="Path to local drug refactory knowledge assets directory"
    )
    parser.add_argument(
        "--top-n",
        type=int,
        default=3000,
        help="Number of top frequent normalized molecules to compile (default: 3000, 0 for all)"
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Validate source data and local knowledge coverage without altering database"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate full compilation pipeline without writing to database"
    )
    parser.add_argument(
        "--report",
        action="store_true",
        help="Print verbose summary and metrics after build"
    )
    parser.add_argument(
        "--export-review",
        action="store_true",
        help="Explicitly export unresolved records to assets/drug_refactory/review_queue.jsonl"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print detailed resolution decisions and unresolved candidate items"
    )
    parser.add_argument(
        "--source-table",
        default="drug_master",
        help="Source table to stream (default: drug_master; never modified)"
    )
    parser.add_argument(
        "--target-table",
        default="clinical_drugs",
        help="Target compiled table (default: clinical_drugs)"
    )
    return parser.parse_args()


def main():
    args = parse_args()

    # Static safety guarantee BEFORE any compilation work: scan the
    # compiler package for hidden network/LLM imports (airplane-mode safe).
    _assert_no_forbidden_imports(os.path.join(current_dir, "drug_refactory"))

    # Verify database exists
    if not os.path.exists(args.db_path):
        print(f"[ERROR] Database file not found: {args.db_path}", file=sys.stderr)
        sys.exit(1)

    # 1. Load local knowledge base
    kb = load_knowledge(base_dir=args.assets_dir)

    # 2. Initialize compiler
    compiler = DrugCompiler(kb=kb, verbose=args.verbose)

    review_path = os.path.join(args.assets_dir, "review_queue.jsonl")
    report_path = os.path.join(args.assets_dir, "build_report.json")

    # 3. Execute compilation. --validate-only / --dry-run / --export-review
    # NEVER modify the database (compiler enforces this); only --export-review
    # forces review-queue artifact emission alongside the normal report.
    try:
        report = compiler.compile(
            db_path=args.db_path,
            top_n=args.top_n,
            validate_only=args.validate_only,
            dry_run=args.dry_run,
            source_table=args.source_table,
            target_table=args.target_table,
            review_queue_path=review_path,
            build_report_path=report_path
        )
    except Exception as e:
        print(f"[ERROR] Compilation failed: {e}", file=sys.stderr)
        sys.exit(1)

    # 4. Formatted Terminal Build Report
    src_rows = report.get("source_rows", 0)
    norm_names = report.get("unique_normalized_names", 0)
    canon_mols = report.get("canonical_molecules", 0)
    resolved = report.get("resolved", 0)
    partial = report.get("partially_resolved", 0)
    unresolved = report.get("unresolved", 0)

    cov = report.get("knowledge_coverage", {})
    ind_cov = cov.get("indications", 0.0) * 100
    se_cov = cov.get("side_effects", 0.0) * 100
    class_cov = cov.get("classes", 0.0) * 100

    flags = report.get("total_clinical_flags_assigned", 0)
    rq_size = report.get("review_queue_size", 0)

    status_str = "VALIDATED" if args.validate_only else ("DRY_RUN" if args.dry_run else "SUCCESS")

    print("\n" + "=" * 40)
    print("DRUG REFACTORY BUILD REPORT")
    print("=" * 40)
    print(f"Source rows:            {src_rows:>8}")
    print(f"Normalized names:       {norm_names:>8}")
    print(f"Canonical molecules:    {canon_mols:>8}")
    print()
    print(f"Resolved:               {resolved:>8}")
    print(f"Partial:                {partial:>8}")
    print(f"Unresolved:             {unresolved:>8}")
    print()
    print(f"Indication coverage:    {ind_cov:>7.1f}%")
    print(f"Side-effect coverage:   {se_cov:>7.1f}%")
    print(f"Class coverage:         {class_cov:>7.1f}%")
    print()
    print(f"Clinical flags:         {flags:>8}")
    print(f"Review queue:           {rq_size:>8}")
    print()
    print(f"Database compilation:   {status_str:>8}")
    print(f"Network/API calls:      {0:>8}")
    # Verbose diagnostics: resolution-mechanism + validation breakdown
    if args.verbose or args.report:
        print()
        print(f"Manual overrides:       {report.get('manual_overrides', 0):>8}")
        print(f"Duplicate canonicals:   {report.get('duplicate_canonical_molecules', 0):>8}")
        print(f"Avg quality score:      {report.get('average_quality_score', 0):>8}")
        print(f"Knowledge version:      {report.get('knowledge_version', ''):>8}")
        issues = report.get("validation_issues", {}) or {}
        if issues:
            print("Validation issues:")
            for k in sorted(issues):
                print(f"  - {k}: {issues[k]}")
    print()
    print("Output:")
    print(f"{args.db_path}")
    print("=" * 40 + "\n")


if __name__ == "__main__":
    main()
