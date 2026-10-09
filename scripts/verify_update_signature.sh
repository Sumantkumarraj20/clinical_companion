#!/usr/bin/env bash
# =============================================================================
# ClinCom — signing-key diagnostic for the "package conflicts" install failure
# =============================================================================
#
# WHY THIS EXISTS
#   Android only allows an in-place update when the new APK is signed with the
#   EXACT same key as the app already installed on the device. If you previously
#   shipped builds signed with the auto-generated DEBUG key and now sign with
#   RELEASE_KEYSTORE, the installer rejects the update with:
#
#     App not installed as package conflicts with an existing package
#
#   No amount of workflow tweaking can bypass that — it is enforced by the OS.
#   The first step is therefore to PROVE which key is on the device and which
#   key is on the APK, so you know whether you have a mismatch at all.
#
# USAGE
#   ./scripts/verify_update_signature.sh                      # local APK vs local keystore
#   ./scripts/verify_update_signature.sh path/to/app.apk      # explicit APK
#   DEVICE_SERIAL=emulator-5554 ./scripts/verify_update_signature.sh   # over adb
#
# EXIT CODES
#   0  keys match — the update will install cleanly
#   1  keys differ — an in-place update is IMPOSSIBLE (see the printed runbook)
#   2  missing tooling / file not found (a usage problem, not a key problem)
# =============================================================================
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'

PACKAGE_ID="com.example.clinical_companion"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

APK="${1:-}"
if [ -z "$APK" ]; then
  # Default: newest release APK produced by the build.
  APK="$(ls -t "$REPO_ROOT"/build/app/outputs/flutter-apk/ClinCom-*-release.apk 2>/dev/null | head -n 1 || true)"
fi

# --- Locate build-tools for apksigner ---------------------------------------
find_build_tools() {
  local root="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
  ls "$root"/build-tools/*/apksigner 2>/dev/null | sort -V | tail -n 1
}

APKSIGNER="$(find_build_tools)"
if [ -z "$APKSIGNER" ]; then
  echo "${RED}apksigner not found. Set ANDROID_HOME / ANDROID_SDK_ROOT.${NC}" >&2
  exit 2
fi
APKSIGNER="${APKSIGNER%/apksigner}/apksigner"

# --- 1. Fingerprint of the APK we intend to install -------------------------
echo "APK under test : ${APK:-<none found>}"
if [ -z "$APK" ] || [ ! -f "$APK" ]; then
  echo "${RED}No APK found. Build one first: flutter build apk --release${NC}" >&2
  exit 2
fi

APK_LINE="$("$APKSIGNER" verify --print-certs "$APK" 2>/dev/null \
  | grep -i 'certificate SHA-256 digest' | head -n 1 || true)"
APK_FP="$(echo "$APK_LINE" | awk '{print tolower($NF)}')"

if [ -z "$APK_FP" ]; then
  echo "${RED}APK is UNSIGNED or apksigner could not read it.${NC}" >&2
  exit 2
fi
echo "APK  SHA-256   : $APK_FP"

# --- 2. Fingerprint of the release keystore ---------------------------------
KS_FP=""
if [ -f "$REPO_ROOT/android/app/release.keystore" ]; then
  read -r -s -p "keystore password: " KSPW; echo
  KS_LINE="$(keytool -list -v \
      -keystore "$REPO_ROOT/android/app/release.keystore" \
      -storepass "$KSPW" \
      -alias "${RELEASE_KEY_ALIAS:-release}" 2>/dev/null \
    | grep -i 'SHA256:' | head -n 1)"
  KS_FP="$(echo "$KS_LINE" | tr -d ':' | awk '{print tolower($2)}')"
  echo "Keystore SHA-256: ${KS_FP:-<unreadable>}"
fi

# --- 3. Fingerprint of what is ALREADY installed on the device --------------
echo ""
DEVICE_FP=""
if command -v adb >/dev/null 2>&1 && [ -n "${DEVICE_SERIAL:-}" -o -n "${ADB:-}" -o -t "$(adb get-state 2>/dev/null)" ]; then
  echo "Checking device for existing install of $PACKAGE_ID ..."
  DEVICE_FP="$(adb ${DEVICE_SERIAL:+-s "$DEVICE_SERIAL"} shell dumpsys package "$PACKAGE_ID" 2>/dev/null \
    | grep -i 'signatures' | head -n 1 | tr -d ' \r' | tr 'A-F' 'a-f' || true)"
  echo "device (dumpsys): ${DEVICE_FP:-<app not installed>}"
else
  echo "${YELLOW}adb not available — skipping on-device comparison.${NC}"
fi

# --- 4. Verdict -------------------------------------------------------------
echo ""
if [ -n "$KS_FP" ] && [ "$APK_FP" = "$KS_FP" ]; then
  echo "${GREEN}OK: APK matches the release keystore.${NC}"
fi

if [ -n "$DEVICE_FP" ] && [ -n "$APK_FP" ]; then
  # dumpsys prints a truncated/differently-formatted digest, so only claim a
  # mismatch when the digests are both full length and clearly unequal.
  if [ "${#DEVICE_FP}" -ge 60 ] && [ "$DEVICE_FP" != "$APK_FP" ]; then
    echo ""
    echo "${RED}MISMATCH: the APK on this device was signed with a DIFFERENT key.${NC}"
    cat <<EOF

${YELLOW}RUNBOOK — one-time migration (keys cannot be changed in place)${NC}

  Android will NEVER install an APK over an existing app unless both are
  signed with the same key. So you must choose ONE of these:

  A. REINSTALL (recommended, preserves data via Supabase sync)
     1. Open ClinCom and let it sync  ->  pushLocalChanges() uploads
        patients, encounters, problems, prescriptions, investigations.
        NOTE: scanned image files and document_registries rows are pushed,
        but local image bytes are NOT re-downloaded by pullRemoteChanges.
        Export/backup any originals you cannot re-scan first.
     2. Uninstall the old app:  adb uninstall $PACKAGE_ID
     3. Install the new APK:    adb install -r "$APK"
     4. Open ClinCom and let it sync  ->  pullRemoteChanges() restores the
        cloud-backed tables listed above.

  B. KEEP THE OLD KEY (no reinstall, zero data risk)
     Keep signing with the SAME key that produced the currently installed
     app, and retire that key only when you are willing to do (A) once.

  Verify afterwards with:
     adb shell dumpsys package $PACKAGE_ID | grep -i signature

EOF
    exit 1
  fi
fi

echo "${GREEN}No key conflict detected (or the app is not installed on a device yet).${NC}"
exit 0
