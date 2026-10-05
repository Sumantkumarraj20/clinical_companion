/// Sprint 17 "ClinCom" — decides how to spend the API call for a page.
///
/// The cheapest correct option wins: dense on-device OCR means we can send
/// TEXT ONLY and skip the image entirely. Sparse or handwriting-shaped OCR
/// means the local recogniser failed, so we must send a compressed image and
/// let the vision model read the page itself.
enum ClinComEscalation {
  /// Local OCR was trustworthy — text-only prompt, no image upload.
  textOnly,

  /// Local OCR was sparse or handwriting-shaped — send a compressed image.
  multimodalVision,
}

/// Heuristic gate for "can I trust the device's own OCR?".
///
/// Tuned against Indian ward documents: a typed pathology report yields
/// hundreds of clean tokens, while a handwritten "C/o ... Rx ..." drug chart
/// yields very few even when perfectly legible to a human.
ClinComEscalation chooseEscalation({
  required String ocrText,
  int minCharsForTextOnly = 180,
}) {
  final text = ocrText.trim();

  // Handwriting markers: even a *dense* transcript containing these is suspect,
  // because ML Kit often emits plausible-looking garbage for cursive.
  const handwritingMarkers = <String>[
    'rx',
    'c/o',
    'c.o.',
    ' od',
    ' bd',
    'tds',
    'sos',
    'tab',
    'caps',
  ];
  final lower = ' ${text.toLowerCase()} ';
  final looksHandwritten = handwritingMarkers.any(lower.contains);

  // Sparse: the recogniser barely read anything.
  if (text.length < minCharsForTextOnly) {
    return ClinComEscalation.multimodalVision;
  }
  // Handwriting-shaped, even if lengthy.
  if (looksHandwritten) return ClinComEscalation.multimodalVision;

  // Fragment soup: many very short tokens means garbage, not prose.
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length >= 20) {
    final avgWordLength =
        words.fold<int>(0, (sum, w) => sum + w.length) / words.length;
    if (avgWordLength < 3.0) return ClinComEscalation.multimodalVision;
  }

  return ClinComEscalation.textOnly;
}
