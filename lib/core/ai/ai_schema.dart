/// Sprint 27 — Interactions API structured-output schema.
///
/// Replaces `package:google_generative_ai`'s `Schema` type. The GA
/// Interactions API takes the JSON Schema subset directly inside
/// `response_format.schema` and expects lower-case JSON Schema types
/// (`"string"`, `"object"`, ...), so serialization is owned here instead of
/// being inherited from the legacy generateContent SDK.
///
/// The factory surface (`.object`, `.array`, `.string`, ...) is intentionally
/// API-compatible with the package it replaces, so every existing schema
/// definition keeps working unchanged.
class Schema {
  const Schema._({
    required this.type,
    this.properties,
    this.items,
    this.requiredProperties = const [],
    this.enumValues,
    this.nullable,
    this.description,
  });

  /// Lower-case JSON Schema type: object, array, string, number, integer,
  /// boolean.
  final String type;

  /// Object member schemas, keyed by property name.
  final Map<String, Schema>? properties;

  /// Item schema for `array` types.
  final Schema? items;

  /// Required property names for `object` types.
  final List<String> requiredProperties;

  /// Allowed values for `enumString` schemas.
  final List<String>? enumValues;

  /// When `true`, the field may be absent/null in the model response.
  final bool? nullable;

  /// Clinician/model-facing description of the field.
  final String? description;

  factory Schema.object({
    required Map<String, Schema> properties,
    List<String> requiredProperties = const [],
    bool? nullable,
    String? description,
  }) => Schema._(
    type: 'object',
    properties: properties,
    requiredProperties: requiredProperties,
    nullable: nullable,
    description: description,
  );

  factory Schema.array({
    required Schema items,
    bool? nullable,
    String? description,
  }) => Schema._(type: 'array', items: items, nullable: nullable, description: description);

  factory Schema.string({bool? nullable, String? description}) =>
      Schema._(type: 'string', nullable: nullable, description: description);

  factory Schema.number({bool? nullable, String? description}) =>
      Schema._(type: 'number', nullable: nullable, description: description);

  factory Schema.integer({bool? nullable, String? description}) =>
      Schema._(type: 'integer', nullable: nullable, description: description);

  factory Schema.boolean({bool? nullable, String? description}) =>
      Schema._(type: 'boolean', nullable: nullable, description: description);

  factory Schema.enumString({
    required List<String> enumValues,
    bool? nullable,
    String? description,
  }) => Schema._(
    type: 'string',
    enumValues: enumValues,
    nullable: nullable,
    description: description,
  );

  /// Serializes to the JSON Schema subset accepted by
  /// `response_format: {"type": "text", "mime_type": "application/json", "schema": ...}`.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    if (enumValues != null) 'enum': enumValues,
    if (properties != null)
      'properties': {
        for (final entry in properties!.entries)
          entry.key: entry.value.toJson(),
      },
    if (items != null) 'items': items!.toJson(),
    if (requiredProperties.isNotEmpty) 'required': requiredProperties,
    if (nullable == true) 'nullable': true,
    if (description != null) 'description': description,
  };
}
