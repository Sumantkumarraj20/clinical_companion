// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hospitalRegNoMeta = const VerificationMeta(
    'hospitalRegNo',
  );
  @override
  late final GeneratedColumn<String> hospitalRegNo = GeneratedColumn<String>(
    'hospital_reg_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosisMeta = const VerificationMeta(
    'diagnosis',
  );
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
    'diagnosis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentDepartmentMeta = const VerificationMeta(
    'currentDepartment',
  );
  @override
  late final GeneratedColumn<String> currentDepartment =
      GeneratedColumn<String>(
        'current_department',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('Surgery'),
      );
  static const VerificationMeta _surgeryTypeMeta = const VerificationMeta(
    'surgeryType',
  );
  @override
  late final GeneratedColumn<String> surgeryType = GeneratedColumn<String>(
    'surgery_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _complicationsMeta = const VerificationMeta(
    'complications',
  );
  @override
  late final GeneratedColumn<String> complications = GeneratedColumn<String>(
    'complications',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _admissionDateMeta = const VerificationMeta(
    'admissionDate',
  );
  @override
  late final GeneratedColumn<DateTime> admissionDate =
      GeneratedColumn<DateTime>(
        'admission_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dischargeDateMeta = const VerificationMeta(
    'dischargeDate',
  );
  @override
  late final GeneratedColumn<DateTime> dischargeDate =
      GeneratedColumn<DateTime>(
        'discharge_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    hospitalRegNo,
    fullName,
    dateOfBirth,
    sex,
    phone,
    diagnosis,
    currentDepartment,
    surgeryType,
    complications,
    admissionDate,
    dischargeDate,
    isActive,
    metadata,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('hospital_reg_no')) {
      context.handle(
        _hospitalRegNoMeta,
        hospitalRegNo.isAcceptableOrUnknown(
          data['hospital_reg_no']!,
          _hospitalRegNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hospitalRegNoMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('diagnosis')) {
      context.handle(
        _diagnosisMeta,
        diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta),
      );
    }
    if (data.containsKey('current_department')) {
      context.handle(
        _currentDepartmentMeta,
        currentDepartment.isAcceptableOrUnknown(
          data['current_department']!,
          _currentDepartmentMeta,
        ),
      );
    }
    if (data.containsKey('surgery_type')) {
      context.handle(
        _surgeryTypeMeta,
        surgeryType.isAcceptableOrUnknown(
          data['surgery_type']!,
          _surgeryTypeMeta,
        ),
      );
    }
    if (data.containsKey('complications')) {
      context.handle(
        _complicationsMeta,
        complications.isAcceptableOrUnknown(
          data['complications']!,
          _complicationsMeta,
        ),
      );
    }
    if (data.containsKey('admission_date')) {
      context.handle(
        _admissionDateMeta,
        admissionDate.isAcceptableOrUnknown(
          data['admission_date']!,
          _admissionDateMeta,
        ),
      );
    }
    if (data.containsKey('discharge_date')) {
      context.handle(
        _dischargeDateMeta,
        dischargeDate.isAcceptableOrUnknown(
          data['discharge_date']!,
          _dischargeDateMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, hospitalRegNo},
  ];
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      hospitalRegNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hospital_reg_no'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      diagnosis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosis'],
      ),
      currentDepartment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_department'],
      )!,
      surgeryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surgery_type'],
      ),
      complications: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}complications'],
      ),
      admissionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}admission_date'],
      ),
      dischargeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discharge_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final String id;
  final String ownerId;
  final String hospitalRegNo;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? sex;
  final String? phone;
  final String? diagnosis;
  final String currentDepartment;
  final String? surgeryType;
  final String? complications;
  final DateTime? admissionDate;
  final DateTime? dischargeDate;
  final bool isActive;
  final String metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const Patient({
    required this.id,
    required this.ownerId,
    required this.hospitalRegNo,
    required this.fullName,
    this.dateOfBirth,
    this.sex,
    this.phone,
    this.diagnosis,
    required this.currentDepartment,
    this.surgeryType,
    this.complications,
    this.admissionDate,
    this.dischargeDate,
    required this.isActive,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['hospital_reg_no'] = Variable<String>(hospitalRegNo);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || diagnosis != null) {
      map['diagnosis'] = Variable<String>(diagnosis);
    }
    map['current_department'] = Variable<String>(currentDepartment);
    if (!nullToAbsent || surgeryType != null) {
      map['surgery_type'] = Variable<String>(surgeryType);
    }
    if (!nullToAbsent || complications != null) {
      map['complications'] = Variable<String>(complications);
    }
    if (!nullToAbsent || admissionDate != null) {
      map['admission_date'] = Variable<DateTime>(admissionDate);
    }
    if (!nullToAbsent || dischargeDate != null) {
      map['discharge_date'] = Variable<DateTime>(dischargeDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      hospitalRegNo: Value(hospitalRegNo),
      fullName: Value(fullName),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      diagnosis: diagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosis),
      currentDepartment: Value(currentDepartment),
      surgeryType: surgeryType == null && nullToAbsent
          ? const Value.absent()
          : Value(surgeryType),
      complications: complications == null && nullToAbsent
          ? const Value.absent()
          : Value(complications),
      admissionDate: admissionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(admissionDate),
      dischargeDate: dischargeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dischargeDate),
      isActive: Value(isActive),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Patient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      hospitalRegNo: serializer.fromJson<String>(json['hospitalRegNo']),
      fullName: serializer.fromJson<String>(json['fullName']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      sex: serializer.fromJson<String?>(json['sex']),
      phone: serializer.fromJson<String?>(json['phone']),
      diagnosis: serializer.fromJson<String?>(json['diagnosis']),
      currentDepartment: serializer.fromJson<String>(json['currentDepartment']),
      surgeryType: serializer.fromJson<String?>(json['surgeryType']),
      complications: serializer.fromJson<String?>(json['complications']),
      admissionDate: serializer.fromJson<DateTime?>(json['admissionDate']),
      dischargeDate: serializer.fromJson<DateTime?>(json['dischargeDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      metadata: serializer.fromJson<String>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'hospitalRegNo': serializer.toJson<String>(hospitalRegNo),
      'fullName': serializer.toJson<String>(fullName),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'sex': serializer.toJson<String?>(sex),
      'phone': serializer.toJson<String?>(phone),
      'diagnosis': serializer.toJson<String?>(diagnosis),
      'currentDepartment': serializer.toJson<String>(currentDepartment),
      'surgeryType': serializer.toJson<String?>(surgeryType),
      'complications': serializer.toJson<String?>(complications),
      'admissionDate': serializer.toJson<DateTime?>(admissionDate),
      'dischargeDate': serializer.toJson<DateTime?>(dischargeDate),
      'isActive': serializer.toJson<bool>(isActive),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Patient copyWith({
    String? id,
    String? ownerId,
    String? hospitalRegNo,
    String? fullName,
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> diagnosis = const Value.absent(),
    String? currentDepartment,
    Value<String?> surgeryType = const Value.absent(),
    Value<String?> complications = const Value.absent(),
    Value<DateTime?> admissionDate = const Value.absent(),
    Value<DateTime?> dischargeDate = const Value.absent(),
    bool? isActive,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => Patient(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    hospitalRegNo: hospitalRegNo ?? this.hospitalRegNo,
    fullName: fullName ?? this.fullName,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    sex: sex.present ? sex.value : this.sex,
    phone: phone.present ? phone.value : this.phone,
    diagnosis: diagnosis.present ? diagnosis.value : this.diagnosis,
    currentDepartment: currentDepartment ?? this.currentDepartment,
    surgeryType: surgeryType.present ? surgeryType.value : this.surgeryType,
    complications: complications.present
        ? complications.value
        : this.complications,
    admissionDate: admissionDate.present
        ? admissionDate.value
        : this.admissionDate,
    dischargeDate: dischargeDate.present
        ? dischargeDate.value
        : this.dischargeDate,
    isActive: isActive ?? this.isActive,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      hospitalRegNo: data.hospitalRegNo.present
          ? data.hospitalRegNo.value
          : this.hospitalRegNo,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      sex: data.sex.present ? data.sex.value : this.sex,
      phone: data.phone.present ? data.phone.value : this.phone,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      currentDepartment: data.currentDepartment.present
          ? data.currentDepartment.value
          : this.currentDepartment,
      surgeryType: data.surgeryType.present
          ? data.surgeryType.value
          : this.surgeryType,
      complications: data.complications.present
          ? data.complications.value
          : this.complications,
      admissionDate: data.admissionDate.present
          ? data.admissionDate.value
          : this.admissionDate,
      dischargeDate: data.dischargeDate.present
          ? data.dischargeDate.value
          : this.dischargeDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('hospitalRegNo: $hospitalRegNo, ')
          ..write('fullName: $fullName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('sex: $sex, ')
          ..write('phone: $phone, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('currentDepartment: $currentDepartment, ')
          ..write('surgeryType: $surgeryType, ')
          ..write('complications: $complications, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('dischargeDate: $dischargeDate, ')
          ..write('isActive: $isActive, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    hospitalRegNo,
    fullName,
    dateOfBirth,
    sex,
    phone,
    diagnosis,
    currentDepartment,
    surgeryType,
    complications,
    admissionDate,
    dischargeDate,
    isActive,
    metadata,
    createdAt,
    updatedAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.hospitalRegNo == this.hospitalRegNo &&
          other.fullName == this.fullName &&
          other.dateOfBirth == this.dateOfBirth &&
          other.sex == this.sex &&
          other.phone == this.phone &&
          other.diagnosis == this.diagnosis &&
          other.currentDepartment == this.currentDepartment &&
          other.surgeryType == this.surgeryType &&
          other.complications == this.complications &&
          other.admissionDate == this.admissionDate &&
          other.dischargeDate == this.dischargeDate &&
          other.isActive == this.isActive &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> hospitalRegNo;
  final Value<String> fullName;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> sex;
  final Value<String?> phone;
  final Value<String?> diagnosis;
  final Value<String> currentDepartment;
  final Value<String?> surgeryType;
  final Value<String?> complications;
  final Value<DateTime?> admissionDate;
  final Value<DateTime?> dischargeDate;
  final Value<bool> isActive;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.hospitalRegNo = const Value.absent(),
    this.fullName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.sex = const Value.absent(),
    this.phone = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.currentDepartment = const Value.absent(),
    this.surgeryType = const Value.absent(),
    this.complications = const Value.absent(),
    this.admissionDate = const Value.absent(),
    this.dischargeDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    this.id = const Value.absent(),
    required String ownerId,
    required String hospitalRegNo,
    required String fullName,
    this.dateOfBirth = const Value.absent(),
    this.sex = const Value.absent(),
    this.phone = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.currentDepartment = const Value.absent(),
    this.surgeryType = const Value.absent(),
    this.complications = const Value.absent(),
    this.admissionDate = const Value.absent(),
    this.dischargeDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       hospitalRegNo = Value(hospitalRegNo),
       fullName = Value(fullName);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? hospitalRegNo,
    Expression<String>? fullName,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? sex,
    Expression<String>? phone,
    Expression<String>? diagnosis,
    Expression<String>? currentDepartment,
    Expression<String>? surgeryType,
    Expression<String>? complications,
    Expression<DateTime>? admissionDate,
    Expression<DateTime>? dischargeDate,
    Expression<bool>? isActive,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (hospitalRegNo != null) 'hospital_reg_no': hospitalRegNo,
      if (fullName != null) 'full_name': fullName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (sex != null) 'sex': sex,
      if (phone != null) 'phone': phone,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (currentDepartment != null) 'current_department': currentDepartment,
      if (surgeryType != null) 'surgery_type': surgeryType,
      if (complications != null) 'complications': complications,
      if (admissionDate != null) 'admission_date': admissionDate,
      if (dischargeDate != null) 'discharge_date': dischargeDate,
      if (isActive != null) 'is_active': isActive,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? hospitalRegNo,
    Value<String>? fullName,
    Value<DateTime?>? dateOfBirth,
    Value<String?>? sex,
    Value<String?>? phone,
    Value<String?>? diagnosis,
    Value<String>? currentDepartment,
    Value<String?>? surgeryType,
    Value<String?>? complications,
    Value<DateTime?>? admissionDate,
    Value<DateTime?>? dischargeDate,
    Value<bool>? isActive,
    Value<String>? metadata,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      hospitalRegNo: hospitalRegNo ?? this.hospitalRegNo,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      phone: phone ?? this.phone,
      diagnosis: diagnosis ?? this.diagnosis,
      currentDepartment: currentDepartment ?? this.currentDepartment,
      surgeryType: surgeryType ?? this.surgeryType,
      complications: complications ?? this.complications,
      admissionDate: admissionDate ?? this.admissionDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (hospitalRegNo.present) {
      map['hospital_reg_no'] = Variable<String>(hospitalRegNo.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (currentDepartment.present) {
      map['current_department'] = Variable<String>(currentDepartment.value);
    }
    if (surgeryType.present) {
      map['surgery_type'] = Variable<String>(surgeryType.value);
    }
    if (complications.present) {
      map['complications'] = Variable<String>(complications.value);
    }
    if (admissionDate.present) {
      map['admission_date'] = Variable<DateTime>(admissionDate.value);
    }
    if (dischargeDate.present) {
      map['discharge_date'] = Variable<DateTime>(dischargeDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('hospitalRegNo: $hospitalRegNo, ')
          ..write('fullName: $fullName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('sex: $sex, ')
          ..write('phone: $phone, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('currentDepartment: $currentDepartment, ')
          ..write('surgeryType: $surgeryType, ')
          ..write('complications: $complications, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('dischargeDate: $dischargeDate, ')
          ..write('isActive: $isActive, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClinicalEncountersTable extends ClinicalEncounters
    with TableInfo<$ClinicalEncountersTable, ClinicalEncounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalEncountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _encounterTypeMeta = const VerificationMeta(
    'encounterType',
  );
  @override
  late final GeneratedColumn<String> encounterType = GeneratedColumn<String>(
    'encounter_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Ward Round'),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sbpMeta = const VerificationMeta('sbp');
  @override
  late final GeneratedColumn<int> sbp = GeneratedColumn<int>(
    'sbp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dbpMeta = const VerificationMeta('dbp');
  @override
  late final GeneratedColumn<int> dbp = GeneratedColumn<int>(
    'dbp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pulseMeta = const VerificationMeta('pulse');
  @override
  late final GeneratedColumn<int> pulse = GeneratedColumn<int>(
    'pulse',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureCMeta = const VerificationMeta(
    'temperatureC',
  );
  @override
  late final GeneratedColumn<double> temperatureC = GeneratedColumn<double>(
    'temperature_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respiratoryRateMeta = const VerificationMeta(
    'respiratoryRate',
  );
  @override
  late final GeneratedColumn<int> respiratoryRate = GeneratedColumn<int>(
    'respiratory_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spo2Meta = const VerificationMeta('spo2');
  @override
  late final GeneratedColumn<int> spo2 = GeneratedColumn<int>(
    'spo2',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meanArterialPressureMeta =
      const VerificationMeta('meanArterialPressure');
  @override
  late final GeneratedColumn<double> meanArterialPressure =
      GeneratedColumn<double>(
        'map',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _chiefComplaintMeta = const VerificationMeta(
    'chiefComplaint',
  );
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
    'chief_complaint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consultantAdviceMeta = const VerificationMeta(
    'consultantAdvice',
  );
  @override
  late final GeneratedColumn<String> consultantAdvice = GeneratedColumn<String>(
    'consultant_advice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  dynamicData =
      GeneratedColumn<String>(
        'dynamic_data',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      ).withConverter<Map<String, dynamic>>(
        $ClinicalEncountersTable.$converterdynamicData,
      );
  static const VerificationMeta _departmentMeta = const VerificationMeta(
    'department',
  );
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
    'department',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wardNameMeta = const VerificationMeta(
    'wardName',
  );
  @override
  late final GeneratedColumn<String> wardName = GeneratedColumn<String>(
    'ward_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bedNumberMeta = const VerificationMeta(
    'bedNumber',
  );
  @override
  late final GeneratedColumn<String> bedNumber = GeneratedColumn<String>(
    'bed_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiSummaryMeta = const VerificationMeta(
    'aiSummary',
  );
  @override
  late final GeneratedColumn<String> aiSummary = GeneratedColumn<String>(
    'ai_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _problemIdMeta = const VerificationMeta(
    'problemId',
  );
  @override
  late final GeneratedColumn<String> problemId = GeneratedColumn<String>(
    'problem_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    patientId,
    encounterType,
    occurredAt,
    sbp,
    dbp,
    pulse,
    temperatureC,
    respiratoryRate,
    spo2,
    meanArterialPressure,
    chiefComplaint,
    consultantAdvice,
    note,
    dynamicData,
    department,
    wardName,
    bedNumber,
    imagePath,
    aiSummary,
    problemId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_encounters';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClinicalEncounter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('encounter_type')) {
      context.handle(
        _encounterTypeMeta,
        encounterType.isAcceptableOrUnknown(
          data['encounter_type']!,
          _encounterTypeMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    }
    if (data.containsKey('sbp')) {
      context.handle(
        _sbpMeta,
        sbp.isAcceptableOrUnknown(data['sbp']!, _sbpMeta),
      );
    }
    if (data.containsKey('dbp')) {
      context.handle(
        _dbpMeta,
        dbp.isAcceptableOrUnknown(data['dbp']!, _dbpMeta),
      );
    }
    if (data.containsKey('pulse')) {
      context.handle(
        _pulseMeta,
        pulse.isAcceptableOrUnknown(data['pulse']!, _pulseMeta),
      );
    }
    if (data.containsKey('temperature_c')) {
      context.handle(
        _temperatureCMeta,
        temperatureC.isAcceptableOrUnknown(
          data['temperature_c']!,
          _temperatureCMeta,
        ),
      );
    }
    if (data.containsKey('respiratory_rate')) {
      context.handle(
        _respiratoryRateMeta,
        respiratoryRate.isAcceptableOrUnknown(
          data['respiratory_rate']!,
          _respiratoryRateMeta,
        ),
      );
    }
    if (data.containsKey('spo2')) {
      context.handle(
        _spo2Meta,
        spo2.isAcceptableOrUnknown(data['spo2']!, _spo2Meta),
      );
    }
    if (data.containsKey('map')) {
      context.handle(
        _meanArterialPressureMeta,
        meanArterialPressure.isAcceptableOrUnknown(
          data['map']!,
          _meanArterialPressureMeta,
        ),
      );
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
        _chiefComplaintMeta,
        chiefComplaint.isAcceptableOrUnknown(
          data['chief_complaint']!,
          _chiefComplaintMeta,
        ),
      );
    }
    if (data.containsKey('consultant_advice')) {
      context.handle(
        _consultantAdviceMeta,
        consultantAdvice.isAcceptableOrUnknown(
          data['consultant_advice']!,
          _consultantAdviceMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('department')) {
      context.handle(
        _departmentMeta,
        department.isAcceptableOrUnknown(data['department']!, _departmentMeta),
      );
    }
    if (data.containsKey('ward_name')) {
      context.handle(
        _wardNameMeta,
        wardName.isAcceptableOrUnknown(data['ward_name']!, _wardNameMeta),
      );
    }
    if (data.containsKey('bed_number')) {
      context.handle(
        _bedNumberMeta,
        bedNumber.isAcceptableOrUnknown(data['bed_number']!, _bedNumberMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('ai_summary')) {
      context.handle(
        _aiSummaryMeta,
        aiSummary.isAcceptableOrUnknown(data['ai_summary']!, _aiSummaryMeta),
      );
    }
    if (data.containsKey('problem_id')) {
      context.handle(
        _problemIdMeta,
        problemId.isAcceptableOrUnknown(data['problem_id']!, _problemIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalEncounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalEncounter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      encounterType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encounter_type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      sbp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sbp'],
      ),
      dbp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dbp'],
      ),
      pulse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pulse'],
      ),
      temperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_c'],
      ),
      respiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}respiratory_rate'],
      ),
      spo2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spo2'],
      ),
      meanArterialPressure: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}map'],
      ),
      chiefComplaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chief_complaint'],
      ),
      consultantAdvice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consultant_advice'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      dynamicData: $ClinicalEncountersTable.$converterdynamicData.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}dynamic_data'],
        )!,
      ),
      department: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department'],
      ),
      wardName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ward_name'],
      ),
      bedNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bed_number'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      aiSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_summary'],
      ),
      problemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $ClinicalEncountersTable createAlias(String alias) {
    return $ClinicalEncountersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, dynamic>, String, Map<String, Object?>>
  $converterdynamicData = const JsonMapConverter();
}

class ClinicalEncounter extends DataClass
    implements Insertable<ClinicalEncounter> {
  final String id;
  final String ownerId;
  final String patientId;
  final String encounterType;
  final DateTime occurredAt;
  final int? sbp;
  final int? dbp;
  final int? pulse;
  final double? temperatureC;
  final int? respiratoryRate;
  final int? spo2;

  /// Kept as the `map` database column for compatibility with existing data.
  /// The Dart name avoids colliding with Drift's generated `map` method.
  final double? meanArterialPressure;
  final String? chiefComplaint;
  final String? consultantAdvice;
  final String? note;
  final Map<String, dynamic> dynamicData;
  final String? department;
  final String? wardName;
  final String? bedNumber;
  final String? imagePath;
  final String? aiSummary;
  final String? problemId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const ClinicalEncounter({
    required this.id,
    required this.ownerId,
    required this.patientId,
    required this.encounterType,
    required this.occurredAt,
    this.sbp,
    this.dbp,
    this.pulse,
    this.temperatureC,
    this.respiratoryRate,
    this.spo2,
    this.meanArterialPressure,
    this.chiefComplaint,
    this.consultantAdvice,
    this.note,
    required this.dynamicData,
    this.department,
    this.wardName,
    this.bedNumber,
    this.imagePath,
    this.aiSummary,
    this.problemId,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['patient_id'] = Variable<String>(patientId);
    map['encounter_type'] = Variable<String>(encounterType);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || sbp != null) {
      map['sbp'] = Variable<int>(sbp);
    }
    if (!nullToAbsent || dbp != null) {
      map['dbp'] = Variable<int>(dbp);
    }
    if (!nullToAbsent || pulse != null) {
      map['pulse'] = Variable<int>(pulse);
    }
    if (!nullToAbsent || temperatureC != null) {
      map['temperature_c'] = Variable<double>(temperatureC);
    }
    if (!nullToAbsent || respiratoryRate != null) {
      map['respiratory_rate'] = Variable<int>(respiratoryRate);
    }
    if (!nullToAbsent || spo2 != null) {
      map['spo2'] = Variable<int>(spo2);
    }
    if (!nullToAbsent || meanArterialPressure != null) {
      map['map'] = Variable<double>(meanArterialPressure);
    }
    if (!nullToAbsent || chiefComplaint != null) {
      map['chief_complaint'] = Variable<String>(chiefComplaint);
    }
    if (!nullToAbsent || consultantAdvice != null) {
      map['consultant_advice'] = Variable<String>(consultantAdvice);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['dynamic_data'] = Variable<String>(
        $ClinicalEncountersTable.$converterdynamicData.toSql(dynamicData),
      );
    }
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    if (!nullToAbsent || wardName != null) {
      map['ward_name'] = Variable<String>(wardName);
    }
    if (!nullToAbsent || bedNumber != null) {
      map['bed_number'] = Variable<String>(bedNumber);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || aiSummary != null) {
      map['ai_summary'] = Variable<String>(aiSummary);
    }
    if (!nullToAbsent || problemId != null) {
      map['problem_id'] = Variable<String>(problemId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ClinicalEncountersCompanion toCompanion(bool nullToAbsent) {
    return ClinicalEncountersCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      patientId: Value(patientId),
      encounterType: Value(encounterType),
      occurredAt: Value(occurredAt),
      sbp: sbp == null && nullToAbsent ? const Value.absent() : Value(sbp),
      dbp: dbp == null && nullToAbsent ? const Value.absent() : Value(dbp),
      pulse: pulse == null && nullToAbsent
          ? const Value.absent()
          : Value(pulse),
      temperatureC: temperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureC),
      respiratoryRate: respiratoryRate == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRate),
      spo2: spo2 == null && nullToAbsent ? const Value.absent() : Value(spo2),
      meanArterialPressure: meanArterialPressure == null && nullToAbsent
          ? const Value.absent()
          : Value(meanArterialPressure),
      chiefComplaint: chiefComplaint == null && nullToAbsent
          ? const Value.absent()
          : Value(chiefComplaint),
      consultantAdvice: consultantAdvice == null && nullToAbsent
          ? const Value.absent()
          : Value(consultantAdvice),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dynamicData: Value(dynamicData),
      department: department == null && nullToAbsent
          ? const Value.absent()
          : Value(department),
      wardName: wardName == null && nullToAbsent
          ? const Value.absent()
          : Value(wardName),
      bedNumber: bedNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(bedNumber),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      aiSummary: aiSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(aiSummary),
      problemId: problemId == null && nullToAbsent
          ? const Value.absent()
          : Value(problemId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ClinicalEncounter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalEncounter(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      encounterType: serializer.fromJson<String>(json['encounterType']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      sbp: serializer.fromJson<int?>(json['sbp']),
      dbp: serializer.fromJson<int?>(json['dbp']),
      pulse: serializer.fromJson<int?>(json['pulse']),
      temperatureC: serializer.fromJson<double?>(json['temperatureC']),
      respiratoryRate: serializer.fromJson<int?>(json['respiratoryRate']),
      spo2: serializer.fromJson<int?>(json['spo2']),
      meanArterialPressure: serializer.fromJson<double?>(
        json['meanArterialPressure'],
      ),
      chiefComplaint: serializer.fromJson<String?>(json['chiefComplaint']),
      consultantAdvice: serializer.fromJson<String?>(json['consultantAdvice']),
      note: serializer.fromJson<String?>(json['note']),
      dynamicData: $ClinicalEncountersTable.$converterdynamicData.fromJson(
        serializer.fromJson<Map<String, Object?>>(json['dynamicData']),
      ),
      department: serializer.fromJson<String?>(json['department']),
      wardName: serializer.fromJson<String?>(json['wardName']),
      bedNumber: serializer.fromJson<String?>(json['bedNumber']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      aiSummary: serializer.fromJson<String?>(json['aiSummary']),
      problemId: serializer.fromJson<String?>(json['problemId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'patientId': serializer.toJson<String>(patientId),
      'encounterType': serializer.toJson<String>(encounterType),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'sbp': serializer.toJson<int?>(sbp),
      'dbp': serializer.toJson<int?>(dbp),
      'pulse': serializer.toJson<int?>(pulse),
      'temperatureC': serializer.toJson<double?>(temperatureC),
      'respiratoryRate': serializer.toJson<int?>(respiratoryRate),
      'spo2': serializer.toJson<int?>(spo2),
      'meanArterialPressure': serializer.toJson<double?>(meanArterialPressure),
      'chiefComplaint': serializer.toJson<String?>(chiefComplaint),
      'consultantAdvice': serializer.toJson<String?>(consultantAdvice),
      'note': serializer.toJson<String?>(note),
      'dynamicData': serializer.toJson<Map<String, Object?>>(
        $ClinicalEncountersTable.$converterdynamicData.toJson(dynamicData),
      ),
      'department': serializer.toJson<String?>(department),
      'wardName': serializer.toJson<String?>(wardName),
      'bedNumber': serializer.toJson<String?>(bedNumber),
      'imagePath': serializer.toJson<String?>(imagePath),
      'aiSummary': serializer.toJson<String?>(aiSummary),
      'problemId': serializer.toJson<String?>(problemId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ClinicalEncounter copyWith({
    String? id,
    String? ownerId,
    String? patientId,
    String? encounterType,
    DateTime? occurredAt,
    Value<int?> sbp = const Value.absent(),
    Value<int?> dbp = const Value.absent(),
    Value<int?> pulse = const Value.absent(),
    Value<double?> temperatureC = const Value.absent(),
    Value<int?> respiratoryRate = const Value.absent(),
    Value<int?> spo2 = const Value.absent(),
    Value<double?> meanArterialPressure = const Value.absent(),
    Value<String?> chiefComplaint = const Value.absent(),
    Value<String?> consultantAdvice = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Map<String, dynamic>? dynamicData,
    Value<String?> department = const Value.absent(),
    Value<String?> wardName = const Value.absent(),
    Value<String?> bedNumber = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> aiSummary = const Value.absent(),
    Value<String?> problemId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => ClinicalEncounter(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    patientId: patientId ?? this.patientId,
    encounterType: encounterType ?? this.encounterType,
    occurredAt: occurredAt ?? this.occurredAt,
    sbp: sbp.present ? sbp.value : this.sbp,
    dbp: dbp.present ? dbp.value : this.dbp,
    pulse: pulse.present ? pulse.value : this.pulse,
    temperatureC: temperatureC.present ? temperatureC.value : this.temperatureC,
    respiratoryRate: respiratoryRate.present
        ? respiratoryRate.value
        : this.respiratoryRate,
    spo2: spo2.present ? spo2.value : this.spo2,
    meanArterialPressure: meanArterialPressure.present
        ? meanArterialPressure.value
        : this.meanArterialPressure,
    chiefComplaint: chiefComplaint.present
        ? chiefComplaint.value
        : this.chiefComplaint,
    consultantAdvice: consultantAdvice.present
        ? consultantAdvice.value
        : this.consultantAdvice,
    note: note.present ? note.value : this.note,
    dynamicData: dynamicData ?? this.dynamicData,
    department: department.present ? department.value : this.department,
    wardName: wardName.present ? wardName.value : this.wardName,
    bedNumber: bedNumber.present ? bedNumber.value : this.bedNumber,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    aiSummary: aiSummary.present ? aiSummary.value : this.aiSummary,
    problemId: problemId.present ? problemId.value : this.problemId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  ClinicalEncounter copyWithCompanion(ClinicalEncountersCompanion data) {
    return ClinicalEncounter(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      encounterType: data.encounterType.present
          ? data.encounterType.value
          : this.encounterType,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      sbp: data.sbp.present ? data.sbp.value : this.sbp,
      dbp: data.dbp.present ? data.dbp.value : this.dbp,
      pulse: data.pulse.present ? data.pulse.value : this.pulse,
      temperatureC: data.temperatureC.present
          ? data.temperatureC.value
          : this.temperatureC,
      respiratoryRate: data.respiratoryRate.present
          ? data.respiratoryRate.value
          : this.respiratoryRate,
      spo2: data.spo2.present ? data.spo2.value : this.spo2,
      meanArterialPressure: data.meanArterialPressure.present
          ? data.meanArterialPressure.value
          : this.meanArterialPressure,
      chiefComplaint: data.chiefComplaint.present
          ? data.chiefComplaint.value
          : this.chiefComplaint,
      consultantAdvice: data.consultantAdvice.present
          ? data.consultantAdvice.value
          : this.consultantAdvice,
      note: data.note.present ? data.note.value : this.note,
      dynamicData: data.dynamicData.present
          ? data.dynamicData.value
          : this.dynamicData,
      department: data.department.present
          ? data.department.value
          : this.department,
      wardName: data.wardName.present ? data.wardName.value : this.wardName,
      bedNumber: data.bedNumber.present ? data.bedNumber.value : this.bedNumber,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      aiSummary: data.aiSummary.present ? data.aiSummary.value : this.aiSummary,
      problemId: data.problemId.present ? data.problemId.value : this.problemId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalEncounter(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('patientId: $patientId, ')
          ..write('encounterType: $encounterType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('sbp: $sbp, ')
          ..write('dbp: $dbp, ')
          ..write('pulse: $pulse, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('spo2: $spo2, ')
          ..write('meanArterialPressure: $meanArterialPressure, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('consultantAdvice: $consultantAdvice, ')
          ..write('note: $note, ')
          ..write('dynamicData: $dynamicData, ')
          ..write('department: $department, ')
          ..write('wardName: $wardName, ')
          ..write('bedNumber: $bedNumber, ')
          ..write('imagePath: $imagePath, ')
          ..write('aiSummary: $aiSummary, ')
          ..write('problemId: $problemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerId,
    patientId,
    encounterType,
    occurredAt,
    sbp,
    dbp,
    pulse,
    temperatureC,
    respiratoryRate,
    spo2,
    meanArterialPressure,
    chiefComplaint,
    consultantAdvice,
    note,
    dynamicData,
    department,
    wardName,
    bedNumber,
    imagePath,
    aiSummary,
    problemId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalEncounter &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.patientId == this.patientId &&
          other.encounterType == this.encounterType &&
          other.occurredAt == this.occurredAt &&
          other.sbp == this.sbp &&
          other.dbp == this.dbp &&
          other.pulse == this.pulse &&
          other.temperatureC == this.temperatureC &&
          other.respiratoryRate == this.respiratoryRate &&
          other.spo2 == this.spo2 &&
          other.meanArterialPressure == this.meanArterialPressure &&
          other.chiefComplaint == this.chiefComplaint &&
          other.consultantAdvice == this.consultantAdvice &&
          other.note == this.note &&
          other.dynamicData == this.dynamicData &&
          other.department == this.department &&
          other.wardName == this.wardName &&
          other.bedNumber == this.bedNumber &&
          other.imagePath == this.imagePath &&
          other.aiSummary == this.aiSummary &&
          other.problemId == this.problemId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClinicalEncountersCompanion extends UpdateCompanion<ClinicalEncounter> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> patientId;
  final Value<String> encounterType;
  final Value<DateTime> occurredAt;
  final Value<int?> sbp;
  final Value<int?> dbp;
  final Value<int?> pulse;
  final Value<double?> temperatureC;
  final Value<int?> respiratoryRate;
  final Value<int?> spo2;
  final Value<double?> meanArterialPressure;
  final Value<String?> chiefComplaint;
  final Value<String?> consultantAdvice;
  final Value<String?> note;
  final Value<Map<String, dynamic>> dynamicData;
  final Value<String?> department;
  final Value<String?> wardName;
  final Value<String?> bedNumber;
  final Value<String?> imagePath;
  final Value<String?> aiSummary;
  final Value<String?> problemId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ClinicalEncountersCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.encounterType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.sbp = const Value.absent(),
    this.dbp = const Value.absent(),
    this.pulse = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.spo2 = const Value.absent(),
    this.meanArterialPressure = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.consultantAdvice = const Value.absent(),
    this.note = const Value.absent(),
    this.dynamicData = const Value.absent(),
    this.department = const Value.absent(),
    this.wardName = const Value.absent(),
    this.bedNumber = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.aiSummary = const Value.absent(),
    this.problemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalEncountersCompanion.insert({
    this.id = const Value.absent(),
    required String ownerId,
    required String patientId,
    this.encounterType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.sbp = const Value.absent(),
    this.dbp = const Value.absent(),
    this.pulse = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.spo2 = const Value.absent(),
    this.meanArterialPressure = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.consultantAdvice = const Value.absent(),
    this.note = const Value.absent(),
    this.dynamicData = const Value.absent(),
    this.department = const Value.absent(),
    this.wardName = const Value.absent(),
    this.bedNumber = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.aiSummary = const Value.absent(),
    this.problemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       patientId = Value(patientId);
  static Insertable<ClinicalEncounter> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? patientId,
    Expression<String>? encounterType,
    Expression<DateTime>? occurredAt,
    Expression<int>? sbp,
    Expression<int>? dbp,
    Expression<int>? pulse,
    Expression<double>? temperatureC,
    Expression<int>? respiratoryRate,
    Expression<int>? spo2,
    Expression<double>? meanArterialPressure,
    Expression<String>? chiefComplaint,
    Expression<String>? consultantAdvice,
    Expression<String>? note,
    Expression<String>? dynamicData,
    Expression<String>? department,
    Expression<String>? wardName,
    Expression<String>? bedNumber,
    Expression<String>? imagePath,
    Expression<String>? aiSummary,
    Expression<String>? problemId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (patientId != null) 'patient_id': patientId,
      if (encounterType != null) 'encounter_type': encounterType,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (sbp != null) 'sbp': sbp,
      if (dbp != null) 'dbp': dbp,
      if (pulse != null) 'pulse': pulse,
      if (temperatureC != null) 'temperature_c': temperatureC,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (spo2 != null) 'spo2': spo2,
      if (meanArterialPressure != null) 'map': meanArterialPressure,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (consultantAdvice != null) 'consultant_advice': consultantAdvice,
      if (note != null) 'note': note,
      if (dynamicData != null) 'dynamic_data': dynamicData,
      if (department != null) 'department': department,
      if (wardName != null) 'ward_name': wardName,
      if (bedNumber != null) 'bed_number': bedNumber,
      if (imagePath != null) 'image_path': imagePath,
      if (aiSummary != null) 'ai_summary': aiSummary,
      if (problemId != null) 'problem_id': problemId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalEncountersCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? patientId,
    Value<String>? encounterType,
    Value<DateTime>? occurredAt,
    Value<int?>? sbp,
    Value<int?>? dbp,
    Value<int?>? pulse,
    Value<double?>? temperatureC,
    Value<int?>? respiratoryRate,
    Value<int?>? spo2,
    Value<double?>? meanArterialPressure,
    Value<String?>? chiefComplaint,
    Value<String?>? consultantAdvice,
    Value<String?>? note,
    Value<Map<String, dynamic>>? dynamicData,
    Value<String?>? department,
    Value<String?>? wardName,
    Value<String?>? bedNumber,
    Value<String?>? imagePath,
    Value<String?>? aiSummary,
    Value<String?>? problemId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return ClinicalEncountersCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      patientId: patientId ?? this.patientId,
      encounterType: encounterType ?? this.encounterType,
      occurredAt: occurredAt ?? this.occurredAt,
      sbp: sbp ?? this.sbp,
      dbp: dbp ?? this.dbp,
      pulse: pulse ?? this.pulse,
      temperatureC: temperatureC ?? this.temperatureC,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      spo2: spo2 ?? this.spo2,
      meanArterialPressure: meanArterialPressure ?? this.meanArterialPressure,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      consultantAdvice: consultantAdvice ?? this.consultantAdvice,
      note: note ?? this.note,
      dynamicData: dynamicData ?? this.dynamicData,
      department: department ?? this.department,
      wardName: wardName ?? this.wardName,
      bedNumber: bedNumber ?? this.bedNumber,
      imagePath: imagePath ?? this.imagePath,
      aiSummary: aiSummary ?? this.aiSummary,
      problemId: problemId ?? this.problemId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (encounterType.present) {
      map['encounter_type'] = Variable<String>(encounterType.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (sbp.present) {
      map['sbp'] = Variable<int>(sbp.value);
    }
    if (dbp.present) {
      map['dbp'] = Variable<int>(dbp.value);
    }
    if (pulse.present) {
      map['pulse'] = Variable<int>(pulse.value);
    }
    if (temperatureC.present) {
      map['temperature_c'] = Variable<double>(temperatureC.value);
    }
    if (respiratoryRate.present) {
      map['respiratory_rate'] = Variable<int>(respiratoryRate.value);
    }
    if (spo2.present) {
      map['spo2'] = Variable<int>(spo2.value);
    }
    if (meanArterialPressure.present) {
      map['map'] = Variable<double>(meanArterialPressure.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (consultantAdvice.present) {
      map['consultant_advice'] = Variable<String>(consultantAdvice.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dynamicData.present) {
      map['dynamic_data'] = Variable<String>(
        $ClinicalEncountersTable.$converterdynamicData.toSql(dynamicData.value),
      );
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (wardName.present) {
      map['ward_name'] = Variable<String>(wardName.value);
    }
    if (bedNumber.present) {
      map['bed_number'] = Variable<String>(bedNumber.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (aiSummary.present) {
      map['ai_summary'] = Variable<String>(aiSummary.value);
    }
    if (problemId.present) {
      map['problem_id'] = Variable<String>(problemId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalEncountersCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('patientId: $patientId, ')
          ..write('encounterType: $encounterType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('sbp: $sbp, ')
          ..write('dbp: $dbp, ')
          ..write('pulse: $pulse, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('spo2: $spo2, ')
          ..write('meanArterialPressure: $meanArterialPressure, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('consultantAdvice: $consultantAdvice, ')
          ..write('note: $note, ')
          ..write('dynamicData: $dynamicData, ')
          ..write('department: $department, ')
          ..write('wardName: $wardName, ')
          ..write('bedNumber: $bedNumber, ')
          ..write('imagePath: $imagePath, ')
          ..write('aiSummary: $aiSummary, ')
          ..write('problemId: $problemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestigationsTable extends Investigations
    with TableInfo<$InvestigationsTable, Investigation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestigationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _testNameMeta = const VerificationMeta(
    'testName',
  );
  @override
  late final GeneratedColumn<String> testName = GeneratedColumn<String>(
    'test_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _testCodeMeta = const VerificationMeta(
    'testCode',
  );
  @override
  late final GeneratedColumn<String> testCode = GeneratedColumn<String>(
    'test_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _orderedAtMeta = const VerificationMeta(
    'orderedAt',
  );
  @override
  late final GeneratedColumn<DateTime> orderedAt = GeneratedColumn<DateTime>(
    'ordered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sampleSentAtMeta = const VerificationMeta(
    'sampleSentAt',
  );
  @override
  late final GeneratedColumn<DateTime> sampleSentAt = GeneratedColumn<DateTime>(
    'sample_sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultReceivedAtMeta = const VerificationMeta(
    'resultReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resultReceivedAt =
      GeneratedColumn<DateTime>(
        'result_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resultValueMeta = const VerificationMeta(
    'resultValue',
  );
  @override
  late final GeneratedColumn<String> resultValue = GeneratedColumn<String>(
    'result_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultUnitMeta = const VerificationMeta(
    'resultUnit',
  );
  @override
  late final GeneratedColumn<String> resultUnit = GeneratedColumn<String>(
    'result_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceRangeMeta = const VerificationMeta(
    'referenceRange',
  );
  @override
  late final GeneratedColumn<String> referenceRange = GeneratedColumn<String>(
    'reference_range',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _organismMeta = const VerificationMeta(
    'organism',
  );
  @override
  late final GeneratedColumn<String> organism = GeneratedColumn<String>(
    'organism',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sensitiveAntibioticsMeta =
      const VerificationMeta('sensitiveAntibiotics');
  @override
  late final GeneratedColumn<String> sensitiveAntibiotics =
      GeneratedColumn<String>(
        'sensitive_antibiotics',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _resistantAntibioticsMeta =
      const VerificationMeta('resistantAntibiotics');
  @override
  late final GeneratedColumn<String> resistantAntibiotics =
      GeneratedColumn<String>(
        'resistant_antibiotics',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _problemIdMeta = const VerificationMeta(
    'problemId',
  );
  @override
  late final GeneratedColumn<String> problemId = GeneratedColumn<String>(
    'problem_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    patientId,
    testName,
    testCode,
    status,
    orderedAt,
    sampleSentAt,
    resultReceivedAt,
    resultValue,
    resultUnit,
    referenceRange,
    organism,
    sensitiveAntibiotics,
    resistantAntibiotics,
    notes,
    problemId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investigation_tracker';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investigation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('test_name')) {
      context.handle(
        _testNameMeta,
        testName.isAcceptableOrUnknown(data['test_name']!, _testNameMeta),
      );
    } else if (isInserting) {
      context.missing(_testNameMeta);
    }
    if (data.containsKey('test_code')) {
      context.handle(
        _testCodeMeta,
        testCode.isAcceptableOrUnknown(data['test_code']!, _testCodeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('ordered_at')) {
      context.handle(
        _orderedAtMeta,
        orderedAt.isAcceptableOrUnknown(data['ordered_at']!, _orderedAtMeta),
      );
    }
    if (data.containsKey('sample_sent_at')) {
      context.handle(
        _sampleSentAtMeta,
        sampleSentAt.isAcceptableOrUnknown(
          data['sample_sent_at']!,
          _sampleSentAtMeta,
        ),
      );
    }
    if (data.containsKey('result_received_at')) {
      context.handle(
        _resultReceivedAtMeta,
        resultReceivedAt.isAcceptableOrUnknown(
          data['result_received_at']!,
          _resultReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('result_value')) {
      context.handle(
        _resultValueMeta,
        resultValue.isAcceptableOrUnknown(
          data['result_value']!,
          _resultValueMeta,
        ),
      );
    }
    if (data.containsKey('result_unit')) {
      context.handle(
        _resultUnitMeta,
        resultUnit.isAcceptableOrUnknown(data['result_unit']!, _resultUnitMeta),
      );
    }
    if (data.containsKey('reference_range')) {
      context.handle(
        _referenceRangeMeta,
        referenceRange.isAcceptableOrUnknown(
          data['reference_range']!,
          _referenceRangeMeta,
        ),
      );
    }
    if (data.containsKey('organism')) {
      context.handle(
        _organismMeta,
        organism.isAcceptableOrUnknown(data['organism']!, _organismMeta),
      );
    }
    if (data.containsKey('sensitive_antibiotics')) {
      context.handle(
        _sensitiveAntibioticsMeta,
        sensitiveAntibiotics.isAcceptableOrUnknown(
          data['sensitive_antibiotics']!,
          _sensitiveAntibioticsMeta,
        ),
      );
    }
    if (data.containsKey('resistant_antibiotics')) {
      context.handle(
        _resistantAntibioticsMeta,
        resistantAntibiotics.isAcceptableOrUnknown(
          data['resistant_antibiotics']!,
          _resistantAntibioticsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('problem_id')) {
      context.handle(
        _problemIdMeta,
        problemId.isAcceptableOrUnknown(data['problem_id']!, _problemIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investigation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investigation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      testName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_name'],
      )!,
      testCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_code'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      orderedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ordered_at'],
      )!,
      sampleSentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sample_sent_at'],
      ),
      resultReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}result_received_at'],
      ),
      resultValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_value'],
      ),
      resultUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_unit'],
      ),
      referenceRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_range'],
      ),
      organism: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organism'],
      ),
      sensitiveAntibiotics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensitive_antibiotics'],
      )!,
      resistantAntibiotics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resistant_antibiotics'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      problemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $InvestigationsTable createAlias(String alias) {
    return $InvestigationsTable(attachedDatabase, alias);
  }
}

class Investigation extends DataClass implements Insertable<Investigation> {
  final String id;
  final String ownerId;
  final String patientId;
  final String testName;
  final String? testCode;
  final String status;
  final DateTime orderedAt;
  final DateTime? sampleSentAt;
  final DateTime? resultReceivedAt;
  final String? resultValue;
  final String? resultUnit;
  final String? referenceRange;
  final String? organism;
  final String sensitiveAntibiotics;
  final String resistantAntibiotics;
  final String? notes;
  final String? problemId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const Investigation({
    required this.id,
    required this.ownerId,
    required this.patientId,
    required this.testName,
    this.testCode,
    required this.status,
    required this.orderedAt,
    this.sampleSentAt,
    this.resultReceivedAt,
    this.resultValue,
    this.resultUnit,
    this.referenceRange,
    this.organism,
    required this.sensitiveAntibiotics,
    required this.resistantAntibiotics,
    this.notes,
    this.problemId,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['patient_id'] = Variable<String>(patientId);
    map['test_name'] = Variable<String>(testName);
    if (!nullToAbsent || testCode != null) {
      map['test_code'] = Variable<String>(testCode);
    }
    map['status'] = Variable<String>(status);
    map['ordered_at'] = Variable<DateTime>(orderedAt);
    if (!nullToAbsent || sampleSentAt != null) {
      map['sample_sent_at'] = Variable<DateTime>(sampleSentAt);
    }
    if (!nullToAbsent || resultReceivedAt != null) {
      map['result_received_at'] = Variable<DateTime>(resultReceivedAt);
    }
    if (!nullToAbsent || resultValue != null) {
      map['result_value'] = Variable<String>(resultValue);
    }
    if (!nullToAbsent || resultUnit != null) {
      map['result_unit'] = Variable<String>(resultUnit);
    }
    if (!nullToAbsent || referenceRange != null) {
      map['reference_range'] = Variable<String>(referenceRange);
    }
    if (!nullToAbsent || organism != null) {
      map['organism'] = Variable<String>(organism);
    }
    map['sensitive_antibiotics'] = Variable<String>(sensitiveAntibiotics);
    map['resistant_antibiotics'] = Variable<String>(resistantAntibiotics);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || problemId != null) {
      map['problem_id'] = Variable<String>(problemId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  InvestigationsCompanion toCompanion(bool nullToAbsent) {
    return InvestigationsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      patientId: Value(patientId),
      testName: Value(testName),
      testCode: testCode == null && nullToAbsent
          ? const Value.absent()
          : Value(testCode),
      status: Value(status),
      orderedAt: Value(orderedAt),
      sampleSentAt: sampleSentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleSentAt),
      resultReceivedAt: resultReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resultReceivedAt),
      resultValue: resultValue == null && nullToAbsent
          ? const Value.absent()
          : Value(resultValue),
      resultUnit: resultUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(resultUnit),
      referenceRange: referenceRange == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceRange),
      organism: organism == null && nullToAbsent
          ? const Value.absent()
          : Value(organism),
      sensitiveAntibiotics: Value(sensitiveAntibiotics),
      resistantAntibiotics: Value(resistantAntibiotics),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      problemId: problemId == null && nullToAbsent
          ? const Value.absent()
          : Value(problemId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Investigation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investigation(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      testName: serializer.fromJson<String>(json['testName']),
      testCode: serializer.fromJson<String?>(json['testCode']),
      status: serializer.fromJson<String>(json['status']),
      orderedAt: serializer.fromJson<DateTime>(json['orderedAt']),
      sampleSentAt: serializer.fromJson<DateTime?>(json['sampleSentAt']),
      resultReceivedAt: serializer.fromJson<DateTime?>(
        json['resultReceivedAt'],
      ),
      resultValue: serializer.fromJson<String?>(json['resultValue']),
      resultUnit: serializer.fromJson<String?>(json['resultUnit']),
      referenceRange: serializer.fromJson<String?>(json['referenceRange']),
      organism: serializer.fromJson<String?>(json['organism']),
      sensitiveAntibiotics: serializer.fromJson<String>(
        json['sensitiveAntibiotics'],
      ),
      resistantAntibiotics: serializer.fromJson<String>(
        json['resistantAntibiotics'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      problemId: serializer.fromJson<String?>(json['problemId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'patientId': serializer.toJson<String>(patientId),
      'testName': serializer.toJson<String>(testName),
      'testCode': serializer.toJson<String?>(testCode),
      'status': serializer.toJson<String>(status),
      'orderedAt': serializer.toJson<DateTime>(orderedAt),
      'sampleSentAt': serializer.toJson<DateTime?>(sampleSentAt),
      'resultReceivedAt': serializer.toJson<DateTime?>(resultReceivedAt),
      'resultValue': serializer.toJson<String?>(resultValue),
      'resultUnit': serializer.toJson<String?>(resultUnit),
      'referenceRange': serializer.toJson<String?>(referenceRange),
      'organism': serializer.toJson<String?>(organism),
      'sensitiveAntibiotics': serializer.toJson<String>(sensitiveAntibiotics),
      'resistantAntibiotics': serializer.toJson<String>(resistantAntibiotics),
      'notes': serializer.toJson<String?>(notes),
      'problemId': serializer.toJson<String?>(problemId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Investigation copyWith({
    String? id,
    String? ownerId,
    String? patientId,
    String? testName,
    Value<String?> testCode = const Value.absent(),
    String? status,
    DateTime? orderedAt,
    Value<DateTime?> sampleSentAt = const Value.absent(),
    Value<DateTime?> resultReceivedAt = const Value.absent(),
    Value<String?> resultValue = const Value.absent(),
    Value<String?> resultUnit = const Value.absent(),
    Value<String?> referenceRange = const Value.absent(),
    Value<String?> organism = const Value.absent(),
    String? sensitiveAntibiotics,
    String? resistantAntibiotics,
    Value<String?> notes = const Value.absent(),
    Value<String?> problemId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => Investigation(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    patientId: patientId ?? this.patientId,
    testName: testName ?? this.testName,
    testCode: testCode.present ? testCode.value : this.testCode,
    status: status ?? this.status,
    orderedAt: orderedAt ?? this.orderedAt,
    sampleSentAt: sampleSentAt.present ? sampleSentAt.value : this.sampleSentAt,
    resultReceivedAt: resultReceivedAt.present
        ? resultReceivedAt.value
        : this.resultReceivedAt,
    resultValue: resultValue.present ? resultValue.value : this.resultValue,
    resultUnit: resultUnit.present ? resultUnit.value : this.resultUnit,
    referenceRange: referenceRange.present
        ? referenceRange.value
        : this.referenceRange,
    organism: organism.present ? organism.value : this.organism,
    sensitiveAntibiotics: sensitiveAntibiotics ?? this.sensitiveAntibiotics,
    resistantAntibiotics: resistantAntibiotics ?? this.resistantAntibiotics,
    notes: notes.present ? notes.value : this.notes,
    problemId: problemId.present ? problemId.value : this.problemId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  Investigation copyWithCompanion(InvestigationsCompanion data) {
    return Investigation(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      testName: data.testName.present ? data.testName.value : this.testName,
      testCode: data.testCode.present ? data.testCode.value : this.testCode,
      status: data.status.present ? data.status.value : this.status,
      orderedAt: data.orderedAt.present ? data.orderedAt.value : this.orderedAt,
      sampleSentAt: data.sampleSentAt.present
          ? data.sampleSentAt.value
          : this.sampleSentAt,
      resultReceivedAt: data.resultReceivedAt.present
          ? data.resultReceivedAt.value
          : this.resultReceivedAt,
      resultValue: data.resultValue.present
          ? data.resultValue.value
          : this.resultValue,
      resultUnit: data.resultUnit.present
          ? data.resultUnit.value
          : this.resultUnit,
      referenceRange: data.referenceRange.present
          ? data.referenceRange.value
          : this.referenceRange,
      organism: data.organism.present ? data.organism.value : this.organism,
      sensitiveAntibiotics: data.sensitiveAntibiotics.present
          ? data.sensitiveAntibiotics.value
          : this.sensitiveAntibiotics,
      resistantAntibiotics: data.resistantAntibiotics.present
          ? data.resistantAntibiotics.value
          : this.resistantAntibiotics,
      notes: data.notes.present ? data.notes.value : this.notes,
      problemId: data.problemId.present ? data.problemId.value : this.problemId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investigation(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('patientId: $patientId, ')
          ..write('testName: $testName, ')
          ..write('testCode: $testCode, ')
          ..write('status: $status, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('sampleSentAt: $sampleSentAt, ')
          ..write('resultReceivedAt: $resultReceivedAt, ')
          ..write('resultValue: $resultValue, ')
          ..write('resultUnit: $resultUnit, ')
          ..write('referenceRange: $referenceRange, ')
          ..write('organism: $organism, ')
          ..write('sensitiveAntibiotics: $sensitiveAntibiotics, ')
          ..write('resistantAntibiotics: $resistantAntibiotics, ')
          ..write('notes: $notes, ')
          ..write('problemId: $problemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    patientId,
    testName,
    testCode,
    status,
    orderedAt,
    sampleSentAt,
    resultReceivedAt,
    resultValue,
    resultUnit,
    referenceRange,
    organism,
    sensitiveAntibiotics,
    resistantAntibiotics,
    notes,
    problemId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investigation &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.patientId == this.patientId &&
          other.testName == this.testName &&
          other.testCode == this.testCode &&
          other.status == this.status &&
          other.orderedAt == this.orderedAt &&
          other.sampleSentAt == this.sampleSentAt &&
          other.resultReceivedAt == this.resultReceivedAt &&
          other.resultValue == this.resultValue &&
          other.resultUnit == this.resultUnit &&
          other.referenceRange == this.referenceRange &&
          other.organism == this.organism &&
          other.sensitiveAntibiotics == this.sensitiveAntibiotics &&
          other.resistantAntibiotics == this.resistantAntibiotics &&
          other.notes == this.notes &&
          other.problemId == this.problemId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class InvestigationsCompanion extends UpdateCompanion<Investigation> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> patientId;
  final Value<String> testName;
  final Value<String?> testCode;
  final Value<String> status;
  final Value<DateTime> orderedAt;
  final Value<DateTime?> sampleSentAt;
  final Value<DateTime?> resultReceivedAt;
  final Value<String?> resultValue;
  final Value<String?> resultUnit;
  final Value<String?> referenceRange;
  final Value<String?> organism;
  final Value<String> sensitiveAntibiotics;
  final Value<String> resistantAntibiotics;
  final Value<String?> notes;
  final Value<String?> problemId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const InvestigationsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.testName = const Value.absent(),
    this.testCode = const Value.absent(),
    this.status = const Value.absent(),
    this.orderedAt = const Value.absent(),
    this.sampleSentAt = const Value.absent(),
    this.resultReceivedAt = const Value.absent(),
    this.resultValue = const Value.absent(),
    this.resultUnit = const Value.absent(),
    this.referenceRange = const Value.absent(),
    this.organism = const Value.absent(),
    this.sensitiveAntibiotics = const Value.absent(),
    this.resistantAntibiotics = const Value.absent(),
    this.notes = const Value.absent(),
    this.problemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestigationsCompanion.insert({
    this.id = const Value.absent(),
    required String ownerId,
    required String patientId,
    required String testName,
    this.testCode = const Value.absent(),
    this.status = const Value.absent(),
    this.orderedAt = const Value.absent(),
    this.sampleSentAt = const Value.absent(),
    this.resultReceivedAt = const Value.absent(),
    this.resultValue = const Value.absent(),
    this.resultUnit = const Value.absent(),
    this.referenceRange = const Value.absent(),
    this.organism = const Value.absent(),
    this.sensitiveAntibiotics = const Value.absent(),
    this.resistantAntibiotics = const Value.absent(),
    this.notes = const Value.absent(),
    this.problemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       patientId = Value(patientId),
       testName = Value(testName);
  static Insertable<Investigation> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? patientId,
    Expression<String>? testName,
    Expression<String>? testCode,
    Expression<String>? status,
    Expression<DateTime>? orderedAt,
    Expression<DateTime>? sampleSentAt,
    Expression<DateTime>? resultReceivedAt,
    Expression<String>? resultValue,
    Expression<String>? resultUnit,
    Expression<String>? referenceRange,
    Expression<String>? organism,
    Expression<String>? sensitiveAntibiotics,
    Expression<String>? resistantAntibiotics,
    Expression<String>? notes,
    Expression<String>? problemId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (patientId != null) 'patient_id': patientId,
      if (testName != null) 'test_name': testName,
      if (testCode != null) 'test_code': testCode,
      if (status != null) 'status': status,
      if (orderedAt != null) 'ordered_at': orderedAt,
      if (sampleSentAt != null) 'sample_sent_at': sampleSentAt,
      if (resultReceivedAt != null) 'result_received_at': resultReceivedAt,
      if (resultValue != null) 'result_value': resultValue,
      if (resultUnit != null) 'result_unit': resultUnit,
      if (referenceRange != null) 'reference_range': referenceRange,
      if (organism != null) 'organism': organism,
      if (sensitiveAntibiotics != null)
        'sensitive_antibiotics': sensitiveAntibiotics,
      if (resistantAntibiotics != null)
        'resistant_antibiotics': resistantAntibiotics,
      if (notes != null) 'notes': notes,
      if (problemId != null) 'problem_id': problemId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestigationsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? patientId,
    Value<String>? testName,
    Value<String?>? testCode,
    Value<String>? status,
    Value<DateTime>? orderedAt,
    Value<DateTime?>? sampleSentAt,
    Value<DateTime?>? resultReceivedAt,
    Value<String?>? resultValue,
    Value<String?>? resultUnit,
    Value<String?>? referenceRange,
    Value<String?>? organism,
    Value<String>? sensitiveAntibiotics,
    Value<String>? resistantAntibiotics,
    Value<String?>? notes,
    Value<String?>? problemId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return InvestigationsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      patientId: patientId ?? this.patientId,
      testName: testName ?? this.testName,
      testCode: testCode ?? this.testCode,
      status: status ?? this.status,
      orderedAt: orderedAt ?? this.orderedAt,
      sampleSentAt: sampleSentAt ?? this.sampleSentAt,
      resultReceivedAt: resultReceivedAt ?? this.resultReceivedAt,
      resultValue: resultValue ?? this.resultValue,
      resultUnit: resultUnit ?? this.resultUnit,
      referenceRange: referenceRange ?? this.referenceRange,
      organism: organism ?? this.organism,
      sensitiveAntibiotics: sensitiveAntibiotics ?? this.sensitiveAntibiotics,
      resistantAntibiotics: resistantAntibiotics ?? this.resistantAntibiotics,
      notes: notes ?? this.notes,
      problemId: problemId ?? this.problemId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (testName.present) {
      map['test_name'] = Variable<String>(testName.value);
    }
    if (testCode.present) {
      map['test_code'] = Variable<String>(testCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (orderedAt.present) {
      map['ordered_at'] = Variable<DateTime>(orderedAt.value);
    }
    if (sampleSentAt.present) {
      map['sample_sent_at'] = Variable<DateTime>(sampleSentAt.value);
    }
    if (resultReceivedAt.present) {
      map['result_received_at'] = Variable<DateTime>(resultReceivedAt.value);
    }
    if (resultValue.present) {
      map['result_value'] = Variable<String>(resultValue.value);
    }
    if (resultUnit.present) {
      map['result_unit'] = Variable<String>(resultUnit.value);
    }
    if (referenceRange.present) {
      map['reference_range'] = Variable<String>(referenceRange.value);
    }
    if (organism.present) {
      map['organism'] = Variable<String>(organism.value);
    }
    if (sensitiveAntibiotics.present) {
      map['sensitive_antibiotics'] = Variable<String>(
        sensitiveAntibiotics.value,
      );
    }
    if (resistantAntibiotics.present) {
      map['resistant_antibiotics'] = Variable<String>(
        resistantAntibiotics.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (problemId.present) {
      map['problem_id'] = Variable<String>(problemId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestigationsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('patientId: $patientId, ')
          ..write('testName: $testName, ')
          ..write('testCode: $testCode, ')
          ..write('status: $status, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('sampleSentAt: $sampleSentAt, ')
          ..write('resultReceivedAt: $resultReceivedAt, ')
          ..write('resultValue: $resultValue, ')
          ..write('resultUnit: $resultUnit, ')
          ..write('referenceRange: $referenceRange, ')
          ..write('organism: $organism, ')
          ..write('sensitiveAntibiotics: $sensitiveAntibiotics, ')
          ..write('resistantAntibiotics: $resistantAntibiotics, ')
          ..write('notes: $notes, ')
          ..write('problemId: $problemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrugsTable extends Drugs with TableInfo<$DrugsTable, Drug> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrugsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genericNameMeta = const VerificationMeta(
    'genericName',
  );
  @override
  late final GeneratedColumn<String> genericName = GeneratedColumn<String>(
    'generic_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
    'strength',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosageFormMeta = const VerificationMeta(
    'dosageForm',
  );
  @override
  late final GeneratedColumn<String> dosageForm = GeneratedColumn<String>(
    'dosage_form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _substitutesMeta = const VerificationMeta(
    'substitutes',
  );
  @override
  late final GeneratedColumn<String> substitutes = GeneratedColumn<String>(
    'substitutes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sideEffectsMeta = const VerificationMeta(
    'sideEffects',
  );
  @override
  late final GeneratedColumn<String> sideEffects = GeneratedColumn<String>(
    'side_effects',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usesMeta = const VerificationMeta('uses');
  @override
  late final GeneratedColumn<String> uses = GeneratedColumn<String>(
    'uses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _chemicalClassMeta = const VerificationMeta(
    'chemicalClass',
  );
  @override
  late final GeneratedColumn<String> chemicalClass = GeneratedColumn<String>(
    'chemical_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priceEstimateMeta = const VerificationMeta(
    'priceEstimate',
  );
  @override
  late final GeneratedColumn<String> priceEstimate = GeneratedColumn<String>(
    'price_estimate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTrustedMeta = const VerificationMeta(
    'isTrusted',
  );
  @override
  late final GeneratedColumn<bool> isTrusted = GeneratedColumn<bool>(
    'is_trusted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_trusted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customNotesMeta = const VerificationMeta(
    'customNotes',
  );
  @override
  late final GeneratedColumn<String> customNotes = GeneratedColumn<String>(
    'custom_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageFrequencyMeta = const VerificationMeta(
    'usageFrequency',
  );
  @override
  late final GeneratedColumn<int> usageFrequency = GeneratedColumn<int>(
    'usage_frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _associatedProblemsMeta =
      const VerificationMeta('associatedProblems');
  @override
  late final GeneratedColumn<String> associatedProblems =
      GeneratedColumn<String>(
        'associated_problems',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    genericName,
    brandName,
    strength,
    dosageForm,
    route,
    category,
    substitutes,
    sideEffects,
    uses,
    chemicalClass,
    priceEstimate,
    isTrusted,
    customNotes,
    usageFrequency,
    associatedProblems,
    isActive,
    metadata,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drug_master';
  @override
  VerificationContext validateIntegrity(
    Insertable<Drug> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('generic_name')) {
      context.handle(
        _genericNameMeta,
        genericName.isAcceptableOrUnknown(
          data['generic_name']!,
          _genericNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_genericNameMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('dosage_form')) {
      context.handle(
        _dosageFormMeta,
        dosageForm.isAcceptableOrUnknown(data['dosage_form']!, _dosageFormMeta),
      );
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('substitutes')) {
      context.handle(
        _substitutesMeta,
        substitutes.isAcceptableOrUnknown(
          data['substitutes']!,
          _substitutesMeta,
        ),
      );
    }
    if (data.containsKey('side_effects')) {
      context.handle(
        _sideEffectsMeta,
        sideEffects.isAcceptableOrUnknown(
          data['side_effects']!,
          _sideEffectsMeta,
        ),
      );
    }
    if (data.containsKey('uses')) {
      context.handle(
        _usesMeta,
        uses.isAcceptableOrUnknown(data['uses']!, _usesMeta),
      );
    }
    if (data.containsKey('chemical_class')) {
      context.handle(
        _chemicalClassMeta,
        chemicalClass.isAcceptableOrUnknown(
          data['chemical_class']!,
          _chemicalClassMeta,
        ),
      );
    }
    if (data.containsKey('price_estimate')) {
      context.handle(
        _priceEstimateMeta,
        priceEstimate.isAcceptableOrUnknown(
          data['price_estimate']!,
          _priceEstimateMeta,
        ),
      );
    }
    if (data.containsKey('is_trusted')) {
      context.handle(
        _isTrustedMeta,
        isTrusted.isAcceptableOrUnknown(data['is_trusted']!, _isTrustedMeta),
      );
    }
    if (data.containsKey('custom_notes')) {
      context.handle(
        _customNotesMeta,
        customNotes.isAcceptableOrUnknown(
          data['custom_notes']!,
          _customNotesMeta,
        ),
      );
    }
    if (data.containsKey('usage_frequency')) {
      context.handle(
        _usageFrequencyMeta,
        usageFrequency.isAcceptableOrUnknown(
          data['usage_frequency']!,
          _usageFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('associated_problems')) {
      context.handle(
        _associatedProblemsMeta,
        associatedProblems.isAcceptableOrUnknown(
          data['associated_problems']!,
          _associatedProblemsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Drug map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Drug(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      genericName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generic_name'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      ),
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength'],
      ),
      dosageForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage_form'],
      ),
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      substitutes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substitutes'],
      )!,
      sideEffects: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side_effects'],
      )!,
      uses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uses'],
      )!,
      chemicalClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chemical_class'],
      )!,
      priceEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_estimate'],
      ),
      isTrusted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_trusted'],
      )!,
      customNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_notes'],
      ),
      usageFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_frequency'],
      )!,
      associatedProblems: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}associated_problems'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $DrugsTable createAlias(String alias) {
    return $DrugsTable(attachedDatabase, alias);
  }
}

class Drug extends DataClass implements Insertable<Drug> {
  final String id;
  final String ownerId;
  final String genericName;
  final String? brandName;
  final String? strength;
  final String? dosageForm;
  final String? route;
  final String? category;
  final String substitutes;
  final String sideEffects;
  final String uses;
  final String chemicalClass;
  final String? priceEstimate;
  final bool isTrusted;
  final String? customNotes;
  final int usageFrequency;
  final String associatedProblems;
  final bool isActive;
  final String metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const Drug({
    required this.id,
    required this.ownerId,
    required this.genericName,
    this.brandName,
    this.strength,
    this.dosageForm,
    this.route,
    this.category,
    required this.substitutes,
    required this.sideEffects,
    required this.uses,
    required this.chemicalClass,
    this.priceEstimate,
    required this.isTrusted,
    this.customNotes,
    required this.usageFrequency,
    required this.associatedProblems,
    required this.isActive,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['generic_name'] = Variable<String>(genericName);
    if (!nullToAbsent || brandName != null) {
      map['brand_name'] = Variable<String>(brandName);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    if (!nullToAbsent || dosageForm != null) {
      map['dosage_form'] = Variable<String>(dosageForm);
    }
    if (!nullToAbsent || route != null) {
      map['route'] = Variable<String>(route);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['substitutes'] = Variable<String>(substitutes);
    map['side_effects'] = Variable<String>(sideEffects);
    map['uses'] = Variable<String>(uses);
    map['chemical_class'] = Variable<String>(chemicalClass);
    if (!nullToAbsent || priceEstimate != null) {
      map['price_estimate'] = Variable<String>(priceEstimate);
    }
    map['is_trusted'] = Variable<bool>(isTrusted);
    if (!nullToAbsent || customNotes != null) {
      map['custom_notes'] = Variable<String>(customNotes);
    }
    map['usage_frequency'] = Variable<int>(usageFrequency);
    map['associated_problems'] = Variable<String>(associatedProblems);
    map['is_active'] = Variable<bool>(isActive);
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  DrugsCompanion toCompanion(bool nullToAbsent) {
    return DrugsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      genericName: Value(genericName),
      brandName: brandName == null && nullToAbsent
          ? const Value.absent()
          : Value(brandName),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      dosageForm: dosageForm == null && nullToAbsent
          ? const Value.absent()
          : Value(dosageForm),
      route: route == null && nullToAbsent
          ? const Value.absent()
          : Value(route),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      substitutes: Value(substitutes),
      sideEffects: Value(sideEffects),
      uses: Value(uses),
      chemicalClass: Value(chemicalClass),
      priceEstimate: priceEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(priceEstimate),
      isTrusted: Value(isTrusted),
      customNotes: customNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(customNotes),
      usageFrequency: Value(usageFrequency),
      associatedProblems: Value(associatedProblems),
      isActive: Value(isActive),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Drug.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Drug(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      genericName: serializer.fromJson<String>(json['genericName']),
      brandName: serializer.fromJson<String?>(json['brandName']),
      strength: serializer.fromJson<String?>(json['strength']),
      dosageForm: serializer.fromJson<String?>(json['dosageForm']),
      route: serializer.fromJson<String?>(json['route']),
      category: serializer.fromJson<String?>(json['category']),
      substitutes: serializer.fromJson<String>(json['substitutes']),
      sideEffects: serializer.fromJson<String>(json['sideEffects']),
      uses: serializer.fromJson<String>(json['uses']),
      chemicalClass: serializer.fromJson<String>(json['chemicalClass']),
      priceEstimate: serializer.fromJson<String?>(json['priceEstimate']),
      isTrusted: serializer.fromJson<bool>(json['isTrusted']),
      customNotes: serializer.fromJson<String?>(json['customNotes']),
      usageFrequency: serializer.fromJson<int>(json['usageFrequency']),
      associatedProblems: serializer.fromJson<String>(
        json['associatedProblems'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      metadata: serializer.fromJson<String>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'genericName': serializer.toJson<String>(genericName),
      'brandName': serializer.toJson<String?>(brandName),
      'strength': serializer.toJson<String?>(strength),
      'dosageForm': serializer.toJson<String?>(dosageForm),
      'route': serializer.toJson<String?>(route),
      'category': serializer.toJson<String?>(category),
      'substitutes': serializer.toJson<String>(substitutes),
      'sideEffects': serializer.toJson<String>(sideEffects),
      'uses': serializer.toJson<String>(uses),
      'chemicalClass': serializer.toJson<String>(chemicalClass),
      'priceEstimate': serializer.toJson<String?>(priceEstimate),
      'isTrusted': serializer.toJson<bool>(isTrusted),
      'customNotes': serializer.toJson<String?>(customNotes),
      'usageFrequency': serializer.toJson<int>(usageFrequency),
      'associatedProblems': serializer.toJson<String>(associatedProblems),
      'isActive': serializer.toJson<bool>(isActive),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Drug copyWith({
    String? id,
    String? ownerId,
    String? genericName,
    Value<String?> brandName = const Value.absent(),
    Value<String?> strength = const Value.absent(),
    Value<String?> dosageForm = const Value.absent(),
    Value<String?> route = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? substitutes,
    String? sideEffects,
    String? uses,
    String? chemicalClass,
    Value<String?> priceEstimate = const Value.absent(),
    bool? isTrusted,
    Value<String?> customNotes = const Value.absent(),
    int? usageFrequency,
    String? associatedProblems,
    bool? isActive,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => Drug(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    genericName: genericName ?? this.genericName,
    brandName: brandName.present ? brandName.value : this.brandName,
    strength: strength.present ? strength.value : this.strength,
    dosageForm: dosageForm.present ? dosageForm.value : this.dosageForm,
    route: route.present ? route.value : this.route,
    category: category.present ? category.value : this.category,
    substitutes: substitutes ?? this.substitutes,
    sideEffects: sideEffects ?? this.sideEffects,
    uses: uses ?? this.uses,
    chemicalClass: chemicalClass ?? this.chemicalClass,
    priceEstimate: priceEstimate.present
        ? priceEstimate.value
        : this.priceEstimate,
    isTrusted: isTrusted ?? this.isTrusted,
    customNotes: customNotes.present ? customNotes.value : this.customNotes,
    usageFrequency: usageFrequency ?? this.usageFrequency,
    associatedProblems: associatedProblems ?? this.associatedProblems,
    isActive: isActive ?? this.isActive,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  Drug copyWithCompanion(DrugsCompanion data) {
    return Drug(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      genericName: data.genericName.present
          ? data.genericName.value
          : this.genericName,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      strength: data.strength.present ? data.strength.value : this.strength,
      dosageForm: data.dosageForm.present
          ? data.dosageForm.value
          : this.dosageForm,
      route: data.route.present ? data.route.value : this.route,
      category: data.category.present ? data.category.value : this.category,
      substitutes: data.substitutes.present
          ? data.substitutes.value
          : this.substitutes,
      sideEffects: data.sideEffects.present
          ? data.sideEffects.value
          : this.sideEffects,
      uses: data.uses.present ? data.uses.value : this.uses,
      chemicalClass: data.chemicalClass.present
          ? data.chemicalClass.value
          : this.chemicalClass,
      priceEstimate: data.priceEstimate.present
          ? data.priceEstimate.value
          : this.priceEstimate,
      isTrusted: data.isTrusted.present ? data.isTrusted.value : this.isTrusted,
      customNotes: data.customNotes.present
          ? data.customNotes.value
          : this.customNotes,
      usageFrequency: data.usageFrequency.present
          ? data.usageFrequency.value
          : this.usageFrequency,
      associatedProblems: data.associatedProblems.present
          ? data.associatedProblems.value
          : this.associatedProblems,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Drug(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('genericName: $genericName, ')
          ..write('brandName: $brandName, ')
          ..write('strength: $strength, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('route: $route, ')
          ..write('category: $category, ')
          ..write('substitutes: $substitutes, ')
          ..write('sideEffects: $sideEffects, ')
          ..write('uses: $uses, ')
          ..write('chemicalClass: $chemicalClass, ')
          ..write('priceEstimate: $priceEstimate, ')
          ..write('isTrusted: $isTrusted, ')
          ..write('customNotes: $customNotes, ')
          ..write('usageFrequency: $usageFrequency, ')
          ..write('associatedProblems: $associatedProblems, ')
          ..write('isActive: $isActive, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerId,
    genericName,
    brandName,
    strength,
    dosageForm,
    route,
    category,
    substitutes,
    sideEffects,
    uses,
    chemicalClass,
    priceEstimate,
    isTrusted,
    customNotes,
    usageFrequency,
    associatedProblems,
    isActive,
    metadata,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Drug &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.genericName == this.genericName &&
          other.brandName == this.brandName &&
          other.strength == this.strength &&
          other.dosageForm == this.dosageForm &&
          other.route == this.route &&
          other.category == this.category &&
          other.substitutes == this.substitutes &&
          other.sideEffects == this.sideEffects &&
          other.uses == this.uses &&
          other.chemicalClass == this.chemicalClass &&
          other.priceEstimate == this.priceEstimate &&
          other.isTrusted == this.isTrusted &&
          other.customNotes == this.customNotes &&
          other.usageFrequency == this.usageFrequency &&
          other.associatedProblems == this.associatedProblems &&
          other.isActive == this.isActive &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class DrugsCompanion extends UpdateCompanion<Drug> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> genericName;
  final Value<String?> brandName;
  final Value<String?> strength;
  final Value<String?> dosageForm;
  final Value<String?> route;
  final Value<String?> category;
  final Value<String> substitutes;
  final Value<String> sideEffects;
  final Value<String> uses;
  final Value<String> chemicalClass;
  final Value<String?> priceEstimate;
  final Value<bool> isTrusted;
  final Value<String?> customNotes;
  final Value<int> usageFrequency;
  final Value<String> associatedProblems;
  final Value<bool> isActive;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const DrugsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.genericName = const Value.absent(),
    this.brandName = const Value.absent(),
    this.strength = const Value.absent(),
    this.dosageForm = const Value.absent(),
    this.route = const Value.absent(),
    this.category = const Value.absent(),
    this.substitutes = const Value.absent(),
    this.sideEffects = const Value.absent(),
    this.uses = const Value.absent(),
    this.chemicalClass = const Value.absent(),
    this.priceEstimate = const Value.absent(),
    this.isTrusted = const Value.absent(),
    this.customNotes = const Value.absent(),
    this.usageFrequency = const Value.absent(),
    this.associatedProblems = const Value.absent(),
    this.isActive = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DrugsCompanion.insert({
    this.id = const Value.absent(),
    required String ownerId,
    required String genericName,
    this.brandName = const Value.absent(),
    this.strength = const Value.absent(),
    this.dosageForm = const Value.absent(),
    this.route = const Value.absent(),
    this.category = const Value.absent(),
    this.substitutes = const Value.absent(),
    this.sideEffects = const Value.absent(),
    this.uses = const Value.absent(),
    this.chemicalClass = const Value.absent(),
    this.priceEstimate = const Value.absent(),
    this.isTrusted = const Value.absent(),
    this.customNotes = const Value.absent(),
    this.usageFrequency = const Value.absent(),
    this.associatedProblems = const Value.absent(),
    this.isActive = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       genericName = Value(genericName);
  static Insertable<Drug> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? genericName,
    Expression<String>? brandName,
    Expression<String>? strength,
    Expression<String>? dosageForm,
    Expression<String>? route,
    Expression<String>? category,
    Expression<String>? substitutes,
    Expression<String>? sideEffects,
    Expression<String>? uses,
    Expression<String>? chemicalClass,
    Expression<String>? priceEstimate,
    Expression<bool>? isTrusted,
    Expression<String>? customNotes,
    Expression<int>? usageFrequency,
    Expression<String>? associatedProblems,
    Expression<bool>? isActive,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (genericName != null) 'generic_name': genericName,
      if (brandName != null) 'brand_name': brandName,
      if (strength != null) 'strength': strength,
      if (dosageForm != null) 'dosage_form': dosageForm,
      if (route != null) 'route': route,
      if (category != null) 'category': category,
      if (substitutes != null) 'substitutes': substitutes,
      if (sideEffects != null) 'side_effects': sideEffects,
      if (uses != null) 'uses': uses,
      if (chemicalClass != null) 'chemical_class': chemicalClass,
      if (priceEstimate != null) 'price_estimate': priceEstimate,
      if (isTrusted != null) 'is_trusted': isTrusted,
      if (customNotes != null) 'custom_notes': customNotes,
      if (usageFrequency != null) 'usage_frequency': usageFrequency,
      if (associatedProblems != null) 'associated_problems': associatedProblems,
      if (isActive != null) 'is_active': isActive,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DrugsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? genericName,
    Value<String?>? brandName,
    Value<String?>? strength,
    Value<String?>? dosageForm,
    Value<String?>? route,
    Value<String?>? category,
    Value<String>? substitutes,
    Value<String>? sideEffects,
    Value<String>? uses,
    Value<String>? chemicalClass,
    Value<String?>? priceEstimate,
    Value<bool>? isTrusted,
    Value<String?>? customNotes,
    Value<int>? usageFrequency,
    Value<String>? associatedProblems,
    Value<bool>? isActive,
    Value<String>? metadata,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return DrugsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      genericName: genericName ?? this.genericName,
      brandName: brandName ?? this.brandName,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      route: route ?? this.route,
      category: category ?? this.category,
      substitutes: substitutes ?? this.substitutes,
      sideEffects: sideEffects ?? this.sideEffects,
      uses: uses ?? this.uses,
      chemicalClass: chemicalClass ?? this.chemicalClass,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      isTrusted: isTrusted ?? this.isTrusted,
      customNotes: customNotes ?? this.customNotes,
      usageFrequency: usageFrequency ?? this.usageFrequency,
      associatedProblems: associatedProblems ?? this.associatedProblems,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (genericName.present) {
      map['generic_name'] = Variable<String>(genericName.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (dosageForm.present) {
      map['dosage_form'] = Variable<String>(dosageForm.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (substitutes.present) {
      map['substitutes'] = Variable<String>(substitutes.value);
    }
    if (sideEffects.present) {
      map['side_effects'] = Variable<String>(sideEffects.value);
    }
    if (uses.present) {
      map['uses'] = Variable<String>(uses.value);
    }
    if (chemicalClass.present) {
      map['chemical_class'] = Variable<String>(chemicalClass.value);
    }
    if (priceEstimate.present) {
      map['price_estimate'] = Variable<String>(priceEstimate.value);
    }
    if (isTrusted.present) {
      map['is_trusted'] = Variable<bool>(isTrusted.value);
    }
    if (customNotes.present) {
      map['custom_notes'] = Variable<String>(customNotes.value);
    }
    if (usageFrequency.present) {
      map['usage_frequency'] = Variable<int>(usageFrequency.value);
    }
    if (associatedProblems.present) {
      map['associated_problems'] = Variable<String>(associatedProblems.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrugsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('genericName: $genericName, ')
          ..write('brandName: $brandName, ')
          ..write('strength: $strength, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('route: $route, ')
          ..write('category: $category, ')
          ..write('substitutes: $substitutes, ')
          ..write('sideEffects: $sideEffects, ')
          ..write('uses: $uses, ')
          ..write('chemicalClass: $chemicalClass, ')
          ..write('priceEstimate: $priceEstimate, ')
          ..write('isTrusted: $isTrusted, ')
          ..write('customNotes: $customNotes, ')
          ..write('usageFrequency: $usageFrequency, ')
          ..write('associatedProblems: $associatedProblems, ')
          ..write('isActive: $isActive, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalWikiTable extends PersonalWiki
    with TableInfo<$PersonalWikiTable, WikiEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalWikiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markdownContentMeta = const VerificationMeta(
    'markdownContent',
  );
  @override
  late final GeneratedColumn<String> markdownContent = GeneratedColumn<String>(
    'markdown_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($PersonalWikiTable.$convertertags);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  departmentRelevance =
      GeneratedColumn<String>(
        'department_relevance',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>(
        $PersonalWikiTable.$converterdepartmentRelevance,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    topic,
    markdownContent,
    tags,
    departmentRelevance,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_wiki';
  @override
  VerificationContext validateIntegrity(
    Insertable<WikiEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('markdown_content')) {
      context.handle(
        _markdownContentMeta,
        markdownContent.isAcceptableOrUnknown(
          data['markdown_content']!,
          _markdownContentMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WikiEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WikiEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      markdownContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}markdown_content'],
      )!,
      tags: $PersonalWikiTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      departmentRelevance: $PersonalWikiTable.$converterdepartmentRelevance
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}department_relevance'],
            )!,
          ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $PersonalWikiTable createAlias(String alias) {
    return $PersonalWikiTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<List<String>, String, List<Object?>>
  $convertertags = const StringListConverter();
  static JsonTypeConverter2<List<String>, String, List<Object?>>
  $converterdepartmentRelevance = const StringListConverter();
}

class WikiEntry extends DataClass implements Insertable<WikiEntry> {
  final String id;
  final String ownerId;
  final String topic;
  final String markdownContent;
  final List<String> tags;
  final List<String> departmentRelevance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const WikiEntry({
    required this.id,
    required this.ownerId,
    required this.topic,
    required this.markdownContent,
    required this.tags,
    required this.departmentRelevance,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['topic'] = Variable<String>(topic);
    map['markdown_content'] = Variable<String>(markdownContent);
    {
      map['tags'] = Variable<String>(
        $PersonalWikiTable.$convertertags.toSql(tags),
      );
    }
    {
      map['department_relevance'] = Variable<String>(
        $PersonalWikiTable.$converterdepartmentRelevance.toSql(
          departmentRelevance,
        ),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  PersonalWikiCompanion toCompanion(bool nullToAbsent) {
    return PersonalWikiCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      topic: Value(topic),
      markdownContent: Value(markdownContent),
      tags: Value(tags),
      departmentRelevance: Value(departmentRelevance),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory WikiEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WikiEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      topic: serializer.fromJson<String>(json['topic']),
      markdownContent: serializer.fromJson<String>(json['markdownContent']),
      tags: $PersonalWikiTable.$convertertags.fromJson(
        serializer.fromJson<List<Object?>>(json['tags']),
      ),
      departmentRelevance: $PersonalWikiTable.$converterdepartmentRelevance
          .fromJson(
            serializer.fromJson<List<Object?>>(json['departmentRelevance']),
          ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'topic': serializer.toJson<String>(topic),
      'markdownContent': serializer.toJson<String>(markdownContent),
      'tags': serializer.toJson<List<Object?>>(
        $PersonalWikiTable.$convertertags.toJson(tags),
      ),
      'departmentRelevance': serializer.toJson<List<Object?>>(
        $PersonalWikiTable.$converterdepartmentRelevance.toJson(
          departmentRelevance,
        ),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  WikiEntry copyWith({
    String? id,
    String? ownerId,
    String? topic,
    String? markdownContent,
    List<String>? tags,
    List<String>? departmentRelevance,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => WikiEntry(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    topic: topic ?? this.topic,
    markdownContent: markdownContent ?? this.markdownContent,
    tags: tags ?? this.tags,
    departmentRelevance: departmentRelevance ?? this.departmentRelevance,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  WikiEntry copyWithCompanion(PersonalWikiCompanion data) {
    return WikiEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      topic: data.topic.present ? data.topic.value : this.topic,
      markdownContent: data.markdownContent.present
          ? data.markdownContent.value
          : this.markdownContent,
      tags: data.tags.present ? data.tags.value : this.tags,
      departmentRelevance: data.departmentRelevance.present
          ? data.departmentRelevance.value
          : this.departmentRelevance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WikiEntry(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('topic: $topic, ')
          ..write('markdownContent: $markdownContent, ')
          ..write('tags: $tags, ')
          ..write('departmentRelevance: $departmentRelevance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    topic,
    markdownContent,
    tags,
    departmentRelevance,
    createdAt,
    updatedAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WikiEntry &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.topic == this.topic &&
          other.markdownContent == this.markdownContent &&
          other.tags == this.tags &&
          other.departmentRelevance == this.departmentRelevance &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class PersonalWikiCompanion extends UpdateCompanion<WikiEntry> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> topic;
  final Value<String> markdownContent;
  final Value<List<String>> tags;
  final Value<List<String>> departmentRelevance;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const PersonalWikiCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.topic = const Value.absent(),
    this.markdownContent = const Value.absent(),
    this.tags = const Value.absent(),
    this.departmentRelevance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalWikiCompanion.insert({
    this.id = const Value.absent(),
    required String ownerId,
    required String topic,
    this.markdownContent = const Value.absent(),
    this.tags = const Value.absent(),
    this.departmentRelevance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       topic = Value(topic);
  static Insertable<WikiEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? topic,
    Expression<String>? markdownContent,
    Expression<String>? tags,
    Expression<String>? departmentRelevance,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (topic != null) 'topic': topic,
      if (markdownContent != null) 'markdown_content': markdownContent,
      if (tags != null) 'tags': tags,
      if (departmentRelevance != null)
        'department_relevance': departmentRelevance,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalWikiCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? topic,
    Value<String>? markdownContent,
    Value<List<String>>? tags,
    Value<List<String>>? departmentRelevance,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return PersonalWikiCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      topic: topic ?? this.topic,
      markdownContent: markdownContent ?? this.markdownContent,
      tags: tags ?? this.tags,
      departmentRelevance: departmentRelevance ?? this.departmentRelevance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (markdownContent.present) {
      map['markdown_content'] = Variable<String>(markdownContent.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $PersonalWikiTable.$convertertags.toSql(tags.value),
      );
    }
    if (departmentRelevance.present) {
      map['department_relevance'] = Variable<String>(
        $PersonalWikiTable.$converterdepartmentRelevance.toSql(
          departmentRelevance.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalWikiCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('topic: $topic, ')
          ..write('markdownContent: $markdownContent, ')
          ..write('tags: $tags, ')
          ..write('departmentRelevance: $departmentRelevance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineSyncQueueTable extends OfflineSyncQueue
    with TableInfo<$OfflineSyncQueueTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineSyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientUpdatedAt =
      GeneratedColumn<DateTime>(
        'client_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    entityType,
    entityId,
    operation,
    payload,
    clientUpdatedAt,
    attempts,
    nextAttemptAt,
    lastError,
    processedAt,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_updated_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $OfflineSyncQueueTable createAlias(String alias) {
    return $OfflineSyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final String id;
  final String ownerId;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final DateTime clientUpdatedAt;
  final int attempts;
  final DateTime nextAttemptAt;
  final String? lastError;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const SyncQueueEntry({
    required this.id,
    required this.ownerId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.clientUpdatedAt,
    required this.attempts,
    required this.nextAttemptAt,
    this.lastError,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['client_updated_at'] = Variable<DateTime>(clientUpdatedAt);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  OfflineSyncQueueCompanion toCompanion(bool nullToAbsent) {
    return OfflineSyncQueueCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      clientUpdatedAt: Value(clientUpdatedAt),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      clientUpdatedAt: serializer.fromJson<DateTime>(json['clientUpdatedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'clientUpdatedAt': serializer.toJson<DateTime>(clientUpdatedAt),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncQueueEntry copyWith({
    String? id,
    String? ownerId,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    DateTime? clientUpdatedAt,
    int? attempts,
    DateTime? nextAttemptAt,
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> processedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SyncQueueEntry(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    processedAt: processedAt.present ? processedAt.value : this.processedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SyncQueueEntry copyWithCompanion(OfflineSyncQueueCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('processedAt: $processedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    entityType,
    entityId,
    operation,
    payload,
    clientUpdatedAt,
    attempts,
    nextAttemptAt,
    lastError,
    processedAt,
    createdAt,
    updatedAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.processedAt == this.processedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class OfflineSyncQueueCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> clientUpdatedAt;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  final Value<String?> lastError;
  final Value<DateTime?> processedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const OfflineSyncQueueCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineSyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String ownerId,
    required String entityType,
    required String entityId,
    required String operation,
    this.payload = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation);
  static Insertable<SyncQueueEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? clientUpdatedAt,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<DateTime>? processedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (processedAt != null) 'processed_at': processedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineSyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? clientUpdatedAt,
    Value<int>? attempts,
    Value<DateTime>? nextAttemptAt,
    Value<String?>? lastError,
    Value<DateTime?>? processedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return OfflineSyncQueueCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<DateTime>(clientUpdatedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('processedAt: $processedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientProblemsTable extends PatientProblems
    with TableInfo<$PatientProblemsTable, PatientProblem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientProblemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _problemNameMeta = const VerificationMeta(
    'problemName',
  );
  @override
  late final GeneratedColumn<String> problemName = GeneratedColumn<String>(
    'problem_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Active'),
  );
  static const VerificationMeta _onsetDateMeta = const VerificationMeta(
    'onsetDate',
  );
  @override
  late final GeneratedColumn<DateTime> onsetDate = GeneratedColumn<DateTime>(
    'onset_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    problemName,
    status,
    onsetDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patient_problems';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientProblem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('problem_name')) {
      context.handle(
        _problemNameMeta,
        problemName.isAcceptableOrUnknown(
          data['problem_name']!,
          _problemNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_problemNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('onset_date')) {
      context.handle(
        _onsetDateMeta,
        onsetDate.isAcceptableOrUnknown(data['onset_date']!, _onsetDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientProblem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientProblem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      problemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      onsetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}onset_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PatientProblemsTable createAlias(String alias) {
    return $PatientProblemsTable(attachedDatabase, alias);
  }
}

class PatientProblem extends DataClass implements Insertable<PatientProblem> {
  final String id;
  final String patientId;
  final String problemName;
  final String status;
  final DateTime? onsetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PatientProblem({
    required this.id,
    required this.patientId,
    required this.problemName,
    required this.status,
    this.onsetDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['problem_name'] = Variable<String>(problemName);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || onsetDate != null) {
      map['onset_date'] = Variable<DateTime>(onsetDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientProblemsCompanion toCompanion(bool nullToAbsent) {
    return PatientProblemsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      problemName: Value(problemName),
      status: Value(status),
      onsetDate: onsetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(onsetDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PatientProblem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientProblem(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      problemName: serializer.fromJson<String>(json['problemName']),
      status: serializer.fromJson<String>(json['status']),
      onsetDate: serializer.fromJson<DateTime?>(json['onsetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'problemName': serializer.toJson<String>(problemName),
      'status': serializer.toJson<String>(status),
      'onsetDate': serializer.toJson<DateTime?>(onsetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PatientProblem copyWith({
    String? id,
    String? patientId,
    String? problemName,
    String? status,
    Value<DateTime?> onsetDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PatientProblem(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    problemName: problemName ?? this.problemName,
    status: status ?? this.status,
    onsetDate: onsetDate.present ? onsetDate.value : this.onsetDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PatientProblem copyWithCompanion(PatientProblemsCompanion data) {
    return PatientProblem(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      problemName: data.problemName.present
          ? data.problemName.value
          : this.problemName,
      status: data.status.present ? data.status.value : this.status,
      onsetDate: data.onsetDate.present ? data.onsetDate.value : this.onsetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientProblem(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('problemName: $problemName, ')
          ..write('status: $status, ')
          ..write('onsetDate: $onsetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    problemName,
    status,
    onsetDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientProblem &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.problemName == this.problemName &&
          other.status == this.status &&
          other.onsetDate == this.onsetDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientProblemsCompanion extends UpdateCompanion<PatientProblem> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> problemName;
  final Value<String> status;
  final Value<DateTime?> onsetDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientProblemsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.problemName = const Value.absent(),
    this.status = const Value.absent(),
    this.onsetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientProblemsCompanion.insert({
    this.id = const Value.absent(),
    required String patientId,
    required String problemName,
    this.status = const Value.absent(),
    this.onsetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : patientId = Value(patientId),
       problemName = Value(problemName);
  static Insertable<PatientProblem> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? problemName,
    Expression<String>? status,
    Expression<DateTime>? onsetDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (problemName != null) 'problem_name': problemName,
      if (status != null) 'status': status,
      if (onsetDate != null) 'onset_date': onsetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientProblemsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? problemName,
    Value<String>? status,
    Value<DateTime?>? onsetDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PatientProblemsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      problemName: problemName ?? this.problemName,
      status: status ?? this.status,
      onsetDate: onsetDate ?? this.onsetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (problemName.present) {
      map['problem_name'] = Variable<String>(problemName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (onsetDate.present) {
      map['onset_date'] = Variable<DateTime>(onsetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientProblemsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('problemName: $problemName, ')
          ..write('status: $status, ')
          ..write('onsetDate: $onsetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClinicalActionsTable extends ClinicalActions
    with TableInfo<$ClinicalActionsTable, ClinicalAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _problemIdMeta = const VerificationMeta(
    'problemId',
  );
  @override
  late final GeneratedColumn<String> problemId = GeneratedColumn<String>(
    'problem_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patient_problems (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    problemId,
    actionType,
    description,
    occurredAt,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClinicalAction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('problem_id')) {
      context.handle(
        _problemIdMeta,
        problemId.isAcceptableOrUnknown(data['problem_id']!, _problemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_problemIdMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalAction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      problemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
    );
  }

  @override
  $ClinicalActionsTable createAlias(String alias) {
    return $ClinicalActionsTable(attachedDatabase, alias);
  }
}

class ClinicalAction extends DataClass implements Insertable<ClinicalAction> {
  final String id;
  final String patientId;
  final String problemId;
  final String actionType;
  final String description;
  final DateTime occurredAt;
  final String metadata;
  const ClinicalAction({
    required this.id,
    required this.patientId,
    required this.problemId,
    required this.actionType,
    required this.description,
    required this.occurredAt,
    required this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['problem_id'] = Variable<String>(problemId);
    map['action_type'] = Variable<String>(actionType);
    map['description'] = Variable<String>(description);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  ClinicalActionsCompanion toCompanion(bool nullToAbsent) {
    return ClinicalActionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      problemId: Value(problemId),
      actionType: Value(actionType),
      description: Value(description),
      occurredAt: Value(occurredAt),
      metadata: Value(metadata),
    );
  }

  factory ClinicalAction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalAction(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      problemId: serializer.fromJson<String>(json['problemId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      description: serializer.fromJson<String>(json['description']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'problemId': serializer.toJson<String>(problemId),
      'actionType': serializer.toJson<String>(actionType),
      'description': serializer.toJson<String>(description),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  ClinicalAction copyWith({
    String? id,
    String? patientId,
    String? problemId,
    String? actionType,
    String? description,
    DateTime? occurredAt,
    String? metadata,
  }) => ClinicalAction(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    problemId: problemId ?? this.problemId,
    actionType: actionType ?? this.actionType,
    description: description ?? this.description,
    occurredAt: occurredAt ?? this.occurredAt,
    metadata: metadata ?? this.metadata,
  );
  ClinicalAction copyWithCompanion(ClinicalActionsCompanion data) {
    return ClinicalAction(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      problemId: data.problemId.present ? data.problemId.value : this.problemId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      description: data.description.present
          ? data.description.value
          : this.description,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalAction(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('problemId: $problemId, ')
          ..write('actionType: $actionType, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    problemId,
    actionType,
    description,
    occurredAt,
    metadata,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalAction &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.problemId == this.problemId &&
          other.actionType == this.actionType &&
          other.description == this.description &&
          other.occurredAt == this.occurredAt &&
          other.metadata == this.metadata);
}

class ClinicalActionsCompanion extends UpdateCompanion<ClinicalAction> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> problemId;
  final Value<String> actionType;
  final Value<String> description;
  final Value<DateTime> occurredAt;
  final Value<String> metadata;
  final Value<int> rowid;
  const ClinicalActionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.problemId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.description = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalActionsCompanion.insert({
    this.id = const Value.absent(),
    required String patientId,
    required String problemId,
    required String actionType,
    required String description,
    this.occurredAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : patientId = Value(patientId),
       problemId = Value(problemId),
       actionType = Value(actionType),
       description = Value(description);
  static Insertable<ClinicalAction> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? problemId,
    Expression<String>? actionType,
    Expression<String>? description,
    Expression<DateTime>? occurredAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (problemId != null) 'problem_id': problemId,
      if (actionType != null) 'action_type': actionType,
      if (description != null) 'description': description,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalActionsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? problemId,
    Value<String>? actionType,
    Value<String>? description,
    Value<DateTime>? occurredAt,
    Value<String>? metadata,
    Value<int>? rowid,
  }) {
    return ClinicalActionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      problemId: problemId ?? this.problemId,
      actionType: actionType ?? this.actionType,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (problemId.present) {
      map['problem_id'] = Variable<String>(problemId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalActionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('problemId: $problemId, ')
          ..write('actionType: $actionType, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClinicalOutcomesTable extends ClinicalOutcomes
    with TableInfo<$ClinicalOutcomesTable, ClinicalOutcome> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalOutcomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _problemIdMeta = const VerificationMeta(
    'problemId',
  );
  @override
  late final GeneratedColumn<String> problemId = GeneratedColumn<String>(
    'problem_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patient_problems (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _metricNameMeta = const VerificationMeta(
    'metricName',
  );
  @override
  late final GeneratedColumn<String> metricName = GeneratedColumn<String>(
    'metric_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricValueMeta = const VerificationMeta(
    'metricValue',
  );
  @override
  late final GeneratedColumn<double> metricValue = GeneratedColumn<double>(
    'metric_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricUnitMeta = const VerificationMeta(
    'metricUnit',
  );
  @override
  late final GeneratedColumn<String> metricUnit = GeneratedColumn<String>(
    'metric_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _treatmentMethodMeta = const VerificationMeta(
    'treatmentMethod',
  );
  @override
  late final GeneratedColumn<String> treatmentMethod = GeneratedColumn<String>(
    'treatment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    problemId,
    metricName,
    metricValue,
    metricUnit,
    treatmentMethod,
    measuredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_outcomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClinicalOutcome> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('problem_id')) {
      context.handle(
        _problemIdMeta,
        problemId.isAcceptableOrUnknown(data['problem_id']!, _problemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_problemIdMeta);
    }
    if (data.containsKey('metric_name')) {
      context.handle(
        _metricNameMeta,
        metricName.isAcceptableOrUnknown(data['metric_name']!, _metricNameMeta),
      );
    } else if (isInserting) {
      context.missing(_metricNameMeta);
    }
    if (data.containsKey('metric_value')) {
      context.handle(
        _metricValueMeta,
        metricValue.isAcceptableOrUnknown(
          data['metric_value']!,
          _metricValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metricValueMeta);
    }
    if (data.containsKey('metric_unit')) {
      context.handle(
        _metricUnitMeta,
        metricUnit.isAcceptableOrUnknown(data['metric_unit']!, _metricUnitMeta),
      );
    }
    if (data.containsKey('treatment_method')) {
      context.handle(
        _treatmentMethodMeta,
        treatmentMethod.isAcceptableOrUnknown(
          data['treatment_method']!,
          _treatmentMethodMeta,
        ),
      );
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalOutcome map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalOutcome(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      problemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_id'],
      )!,
      metricName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_name'],
      )!,
      metricValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}metric_value'],
      )!,
      metricUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_unit'],
      ),
      treatmentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment_method'],
      ),
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
    );
  }

  @override
  $ClinicalOutcomesTable createAlias(String alias) {
    return $ClinicalOutcomesTable(attachedDatabase, alias);
  }
}

class ClinicalOutcome extends DataClass implements Insertable<ClinicalOutcome> {
  final String id;
  final String problemId;
  final String metricName;
  final double metricValue;
  final String? metricUnit;
  final String? treatmentMethod;
  final DateTime measuredAt;
  const ClinicalOutcome({
    required this.id,
    required this.problemId,
    required this.metricName,
    required this.metricValue,
    this.metricUnit,
    this.treatmentMethod,
    required this.measuredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['problem_id'] = Variable<String>(problemId);
    map['metric_name'] = Variable<String>(metricName);
    map['metric_value'] = Variable<double>(metricValue);
    if (!nullToAbsent || metricUnit != null) {
      map['metric_unit'] = Variable<String>(metricUnit);
    }
    if (!nullToAbsent || treatmentMethod != null) {
      map['treatment_method'] = Variable<String>(treatmentMethod);
    }
    map['measured_at'] = Variable<DateTime>(measuredAt);
    return map;
  }

  ClinicalOutcomesCompanion toCompanion(bool nullToAbsent) {
    return ClinicalOutcomesCompanion(
      id: Value(id),
      problemId: Value(problemId),
      metricName: Value(metricName),
      metricValue: Value(metricValue),
      metricUnit: metricUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(metricUnit),
      treatmentMethod: treatmentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(treatmentMethod),
      measuredAt: Value(measuredAt),
    );
  }

  factory ClinicalOutcome.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalOutcome(
      id: serializer.fromJson<String>(json['id']),
      problemId: serializer.fromJson<String>(json['problemId']),
      metricName: serializer.fromJson<String>(json['metricName']),
      metricValue: serializer.fromJson<double>(json['metricValue']),
      metricUnit: serializer.fromJson<String?>(json['metricUnit']),
      treatmentMethod: serializer.fromJson<String?>(json['treatmentMethod']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'problemId': serializer.toJson<String>(problemId),
      'metricName': serializer.toJson<String>(metricName),
      'metricValue': serializer.toJson<double>(metricValue),
      'metricUnit': serializer.toJson<String?>(metricUnit),
      'treatmentMethod': serializer.toJson<String?>(treatmentMethod),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
    };
  }

  ClinicalOutcome copyWith({
    String? id,
    String? problemId,
    String? metricName,
    double? metricValue,
    Value<String?> metricUnit = const Value.absent(),
    Value<String?> treatmentMethod = const Value.absent(),
    DateTime? measuredAt,
  }) => ClinicalOutcome(
    id: id ?? this.id,
    problemId: problemId ?? this.problemId,
    metricName: metricName ?? this.metricName,
    metricValue: metricValue ?? this.metricValue,
    metricUnit: metricUnit.present ? metricUnit.value : this.metricUnit,
    treatmentMethod: treatmentMethod.present
        ? treatmentMethod.value
        : this.treatmentMethod,
    measuredAt: measuredAt ?? this.measuredAt,
  );
  ClinicalOutcome copyWithCompanion(ClinicalOutcomesCompanion data) {
    return ClinicalOutcome(
      id: data.id.present ? data.id.value : this.id,
      problemId: data.problemId.present ? data.problemId.value : this.problemId,
      metricName: data.metricName.present
          ? data.metricName.value
          : this.metricName,
      metricValue: data.metricValue.present
          ? data.metricValue.value
          : this.metricValue,
      metricUnit: data.metricUnit.present
          ? data.metricUnit.value
          : this.metricUnit,
      treatmentMethod: data.treatmentMethod.present
          ? data.treatmentMethod.value
          : this.treatmentMethod,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalOutcome(')
          ..write('id: $id, ')
          ..write('problemId: $problemId, ')
          ..write('metricName: $metricName, ')
          ..write('metricValue: $metricValue, ')
          ..write('metricUnit: $metricUnit, ')
          ..write('treatmentMethod: $treatmentMethod, ')
          ..write('measuredAt: $measuredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    problemId,
    metricName,
    metricValue,
    metricUnit,
    treatmentMethod,
    measuredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalOutcome &&
          other.id == this.id &&
          other.problemId == this.problemId &&
          other.metricName == this.metricName &&
          other.metricValue == this.metricValue &&
          other.metricUnit == this.metricUnit &&
          other.treatmentMethod == this.treatmentMethod &&
          other.measuredAt == this.measuredAt);
}

class ClinicalOutcomesCompanion extends UpdateCompanion<ClinicalOutcome> {
  final Value<String> id;
  final Value<String> problemId;
  final Value<String> metricName;
  final Value<double> metricValue;
  final Value<String?> metricUnit;
  final Value<String?> treatmentMethod;
  final Value<DateTime> measuredAt;
  final Value<int> rowid;
  const ClinicalOutcomesCompanion({
    this.id = const Value.absent(),
    this.problemId = const Value.absent(),
    this.metricName = const Value.absent(),
    this.metricValue = const Value.absent(),
    this.metricUnit = const Value.absent(),
    this.treatmentMethod = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalOutcomesCompanion.insert({
    this.id = const Value.absent(),
    required String problemId,
    required String metricName,
    required double metricValue,
    this.metricUnit = const Value.absent(),
    this.treatmentMethod = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : problemId = Value(problemId),
       metricName = Value(metricName),
       metricValue = Value(metricValue);
  static Insertable<ClinicalOutcome> custom({
    Expression<String>? id,
    Expression<String>? problemId,
    Expression<String>? metricName,
    Expression<double>? metricValue,
    Expression<String>? metricUnit,
    Expression<String>? treatmentMethod,
    Expression<DateTime>? measuredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (problemId != null) 'problem_id': problemId,
      if (metricName != null) 'metric_name': metricName,
      if (metricValue != null) 'metric_value': metricValue,
      if (metricUnit != null) 'metric_unit': metricUnit,
      if (treatmentMethod != null) 'treatment_method': treatmentMethod,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalOutcomesCompanion copyWith({
    Value<String>? id,
    Value<String>? problemId,
    Value<String>? metricName,
    Value<double>? metricValue,
    Value<String?>? metricUnit,
    Value<String?>? treatmentMethod,
    Value<DateTime>? measuredAt,
    Value<int>? rowid,
  }) {
    return ClinicalOutcomesCompanion(
      id: id ?? this.id,
      problemId: problemId ?? this.problemId,
      metricName: metricName ?? this.metricName,
      metricValue: metricValue ?? this.metricValue,
      metricUnit: metricUnit ?? this.metricUnit,
      treatmentMethod: treatmentMethod ?? this.treatmentMethod,
      measuredAt: measuredAt ?? this.measuredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (problemId.present) {
      map['problem_id'] = Variable<String>(problemId.value);
    }
    if (metricName.present) {
      map['metric_name'] = Variable<String>(metricName.value);
    }
    if (metricValue.present) {
      map['metric_value'] = Variable<double>(metricValue.value);
    }
    if (metricUnit.present) {
      map['metric_unit'] = Variable<String>(metricUnit.value);
    }
    if (treatmentMethod.present) {
      map['treatment_method'] = Variable<String>(treatmentMethod.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalOutcomesCompanion(')
          ..write('id: $id, ')
          ..write('problemId: $problemId, ')
          ..write('metricName: $metricName, ')
          ..write('metricValue: $metricValue, ')
          ..write('metricUnit: $metricUnit, ')
          ..write('treatmentMethod: $treatmentMethod, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CdssRulesTable extends CdssRules
    with TableInfo<$CdssRulesTable, CdssRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CdssRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _targetProblemMeta = const VerificationMeta(
    'targetProblem',
  );
  @override
  late final GeneratedColumn<String> targetProblem = GeneratedColumn<String>(
    'target_problem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerConditionMeta = const VerificationMeta(
    'triggerCondition',
  );
  @override
  late final GeneratedColumn<String> triggerCondition = GeneratedColumn<String>(
    'trigger_condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedActionMeta = const VerificationMeta(
    'suggestedAction',
  );
  @override
  late final GeneratedColumn<String> suggestedAction = GeneratedColumn<String>(
    'suggested_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceSourceMeta = const VerificationMeta(
    'evidenceSource',
  );
  @override
  late final GeneratedColumn<String> evidenceSource = GeneratedColumn<String>(
    'evidence_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetProblem,
    triggerCondition,
    suggestedAction,
    evidenceSource,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cdss_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CdssRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_problem')) {
      context.handle(
        _targetProblemMeta,
        targetProblem.isAcceptableOrUnknown(
          data['target_problem']!,
          _targetProblemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetProblemMeta);
    }
    if (data.containsKey('trigger_condition')) {
      context.handle(
        _triggerConditionMeta,
        triggerCondition.isAcceptableOrUnknown(
          data['trigger_condition']!,
          _triggerConditionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerConditionMeta);
    }
    if (data.containsKey('suggested_action')) {
      context.handle(
        _suggestedActionMeta,
        suggestedAction.isAcceptableOrUnknown(
          data['suggested_action']!,
          _suggestedActionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suggestedActionMeta);
    }
    if (data.containsKey('evidence_source')) {
      context.handle(
        _evidenceSourceMeta,
        evidenceSource.isAcceptableOrUnknown(
          data['evidence_source']!,
          _evidenceSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceSourceMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CdssRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CdssRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetProblem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_problem'],
      )!,
      triggerCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_condition'],
      )!,
      suggestedAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_action'],
      )!,
      evidenceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_source'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $CdssRulesTable createAlias(String alias) {
    return $CdssRulesTable(attachedDatabase, alias);
  }
}

class CdssRule extends DataClass implements Insertable<CdssRule> {
  final String id;
  final String targetProblem;
  final String triggerCondition;
  final String suggestedAction;
  final String evidenceSource;
  final DateTime lastUpdated;
  const CdssRule({
    required this.id,
    required this.targetProblem,
    required this.triggerCondition,
    required this.suggestedAction,
    required this.evidenceSource,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_problem'] = Variable<String>(targetProblem);
    map['trigger_condition'] = Variable<String>(triggerCondition);
    map['suggested_action'] = Variable<String>(suggestedAction);
    map['evidence_source'] = Variable<String>(evidenceSource);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  CdssRulesCompanion toCompanion(bool nullToAbsent) {
    return CdssRulesCompanion(
      id: Value(id),
      targetProblem: Value(targetProblem),
      triggerCondition: Value(triggerCondition),
      suggestedAction: Value(suggestedAction),
      evidenceSource: Value(evidenceSource),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory CdssRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CdssRule(
      id: serializer.fromJson<String>(json['id']),
      targetProblem: serializer.fromJson<String>(json['targetProblem']),
      triggerCondition: serializer.fromJson<String>(json['triggerCondition']),
      suggestedAction: serializer.fromJson<String>(json['suggestedAction']),
      evidenceSource: serializer.fromJson<String>(json['evidenceSource']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetProblem': serializer.toJson<String>(targetProblem),
      'triggerCondition': serializer.toJson<String>(triggerCondition),
      'suggestedAction': serializer.toJson<String>(suggestedAction),
      'evidenceSource': serializer.toJson<String>(evidenceSource),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  CdssRule copyWith({
    String? id,
    String? targetProblem,
    String? triggerCondition,
    String? suggestedAction,
    String? evidenceSource,
    DateTime? lastUpdated,
  }) => CdssRule(
    id: id ?? this.id,
    targetProblem: targetProblem ?? this.targetProblem,
    triggerCondition: triggerCondition ?? this.triggerCondition,
    suggestedAction: suggestedAction ?? this.suggestedAction,
    evidenceSource: evidenceSource ?? this.evidenceSource,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  CdssRule copyWithCompanion(CdssRulesCompanion data) {
    return CdssRule(
      id: data.id.present ? data.id.value : this.id,
      targetProblem: data.targetProblem.present
          ? data.targetProblem.value
          : this.targetProblem,
      triggerCondition: data.triggerCondition.present
          ? data.triggerCondition.value
          : this.triggerCondition,
      suggestedAction: data.suggestedAction.present
          ? data.suggestedAction.value
          : this.suggestedAction,
      evidenceSource: data.evidenceSource.present
          ? data.evidenceSource.value
          : this.evidenceSource,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CdssRule(')
          ..write('id: $id, ')
          ..write('targetProblem: $targetProblem, ')
          ..write('triggerCondition: $triggerCondition, ')
          ..write('suggestedAction: $suggestedAction, ')
          ..write('evidenceSource: $evidenceSource, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetProblem,
    triggerCondition,
    suggestedAction,
    evidenceSource,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CdssRule &&
          other.id == this.id &&
          other.targetProblem == this.targetProblem &&
          other.triggerCondition == this.triggerCondition &&
          other.suggestedAction == this.suggestedAction &&
          other.evidenceSource == this.evidenceSource &&
          other.lastUpdated == this.lastUpdated);
}

class CdssRulesCompanion extends UpdateCompanion<CdssRule> {
  final Value<String> id;
  final Value<String> targetProblem;
  final Value<String> triggerCondition;
  final Value<String> suggestedAction;
  final Value<String> evidenceSource;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const CdssRulesCompanion({
    this.id = const Value.absent(),
    this.targetProblem = const Value.absent(),
    this.triggerCondition = const Value.absent(),
    this.suggestedAction = const Value.absent(),
    this.evidenceSource = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CdssRulesCompanion.insert({
    this.id = const Value.absent(),
    required String targetProblem,
    required String triggerCondition,
    required String suggestedAction,
    required String evidenceSource,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : targetProblem = Value(targetProblem),
       triggerCondition = Value(triggerCondition),
       suggestedAction = Value(suggestedAction),
       evidenceSource = Value(evidenceSource);
  static Insertable<CdssRule> custom({
    Expression<String>? id,
    Expression<String>? targetProblem,
    Expression<String>? triggerCondition,
    Expression<String>? suggestedAction,
    Expression<String>? evidenceSource,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetProblem != null) 'target_problem': targetProblem,
      if (triggerCondition != null) 'trigger_condition': triggerCondition,
      if (suggestedAction != null) 'suggested_action': suggestedAction,
      if (evidenceSource != null) 'evidence_source': evidenceSource,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CdssRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? targetProblem,
    Value<String>? triggerCondition,
    Value<String>? suggestedAction,
    Value<String>? evidenceSource,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return CdssRulesCompanion(
      id: id ?? this.id,
      targetProblem: targetProblem ?? this.targetProblem,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      evidenceSource: evidenceSource ?? this.evidenceSource,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetProblem.present) {
      map['target_problem'] = Variable<String>(targetProblem.value);
    }
    if (triggerCondition.present) {
      map['trigger_condition'] = Variable<String>(triggerCondition.value);
    }
    if (suggestedAction.present) {
      map['suggested_action'] = Variable<String>(suggestedAction.value);
    }
    if (evidenceSource.present) {
      map['evidence_source'] = Variable<String>(evidenceSource.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CdssRulesCompanion(')
          ..write('id: $id, ')
          ..write('targetProblem: $targetProblem, ')
          ..write('triggerCondition: $triggerCondition, ')
          ..write('suggestedAction: $suggestedAction, ')
          ..write('evidenceSource: $evidenceSource, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $ClinicalEncountersTable clinicalEncounters =
      $ClinicalEncountersTable(this);
  late final $InvestigationsTable investigations = $InvestigationsTable(this);
  late final $DrugsTable drugs = $DrugsTable(this);
  late final $PersonalWikiTable personalWiki = $PersonalWikiTable(this);
  late final $OfflineSyncQueueTable offlineSyncQueue = $OfflineSyncQueueTable(
    this,
  );
  late final $PatientProblemsTable patientProblems = $PatientProblemsTable(
    this,
  );
  late final $ClinicalActionsTable clinicalActions = $ClinicalActionsTable(
    this,
  );
  late final $ClinicalOutcomesTable clinicalOutcomes = $ClinicalOutcomesTable(
    this,
  );
  late final $CdssRulesTable cdssRules = $CdssRulesTable(this);
  late final Index patientsHospitalRegNoIdx = Index(
    'patients_hospital_reg_no_idx',
    'CREATE INDEX patients_hospital_reg_no_idx ON patients (hospital_reg_no)',
  );
  late final Index patientsAdmissionDateIdx = Index(
    'patients_admission_date_idx',
    'CREATE INDEX patients_admission_date_idx ON patients (admission_date)',
  );
  late final Index clinicalEncountersPatientOccurredIdx = Index(
    'clinical_encounters_patient_occurred_idx',
    'CREATE INDEX clinical_encounters_patient_occurred_idx ON clinical_encounters (patient_id, occurred_at)',
  );
  late final Index investigationsStatusIdx = Index(
    'investigations_status_idx',
    'CREATE INDEX investigations_status_idx ON investigation_tracker (status)',
  );
  late final Index investigationsTestNameIdx = Index(
    'investigations_test_name_idx',
    'CREATE INDEX investigations_test_name_idx ON investigation_tracker (test_name)',
  );
  late final Index personalWikiUpdatedIdx = Index(
    'personal_wiki_updated_idx',
    'CREATE INDEX personal_wiki_updated_idx ON personal_wiki (updated_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    clinicalEncounters,
    investigations,
    drugs,
    personalWiki,
    offlineSyncQueue,
    patientProblems,
    clinicalActions,
    clinicalOutcomes,
    cdssRules,
    patientsHospitalRegNoIdx,
    patientsAdmissionDateIdx,
    clinicalEncountersPatientOccurredIdx,
    investigationsStatusIdx,
    investigationsTestNameIdx,
    personalWikiUpdatedIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clinical_encounters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('investigation_tracker', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('patient_problems', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clinical_actions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patient_problems',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clinical_actions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patient_problems',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clinical_outcomes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      Value<String> id,
      required String ownerId,
      required String hospitalRegNo,
      required String fullName,
      Value<DateTime?> dateOfBirth,
      Value<String?> sex,
      Value<String?> phone,
      Value<String?> diagnosis,
      Value<String> currentDepartment,
      Value<String?> surgeryType,
      Value<String?> complications,
      Value<DateTime?> admissionDate,
      Value<DateTime?> dischargeDate,
      Value<bool> isActive,
      Value<String> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> hospitalRegNo,
      Value<String> fullName,
      Value<DateTime?> dateOfBirth,
      Value<String?> sex,
      Value<String?> phone,
      Value<String?> diagnosis,
      Value<String> currentDepartment,
      Value<String?> surgeryType,
      Value<String?> complications,
      Value<DateTime?> admissionDate,
      Value<DateTime?> dischargeDate,
      Value<bool> isActive,
      Value<String> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, Patient> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClinicalEncountersTable, List<ClinicalEncounter>>
  _clinicalEncountersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.clinicalEncounters,
        aliasName: 'patients__id__clinical_encounters__patient_id',
      );

  $$ClinicalEncountersTableProcessedTableManager get clinicalEncountersRefs {
    final manager = $$ClinicalEncountersTableTableManager(
      $_db,
      $_db.clinicalEncounters,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _clinicalEncountersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestigationsTable, List<Investigation>>
  _investigationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investigations,
    aliasName: 'patients__id__investigation_tracker__patient_id',
  );

  $$InvestigationsTableProcessedTableManager get investigationsRefs {
    final manager = $$InvestigationsTableTableManager(
      $_db,
      $_db.investigations,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_investigationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PatientProblemsTable, List<PatientProblem>>
  _patientProblemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.patientProblems,
    aliasName: 'patients__id__patient_problems__patient_id',
  );

  $$PatientProblemsTableProcessedTableManager get patientProblemsRefs {
    final manager = $$PatientProblemsTableTableManager(
      $_db,
      $_db.patientProblems,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _patientProblemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ClinicalActionsTable, List<ClinicalAction>>
  _clinicalActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clinicalActions,
    aliasName: 'patients__id__clinical_actions__patient_id',
  );

  $$ClinicalActionsTableProcessedTableManager get clinicalActionsRefs {
    final manager = $$ClinicalActionsTableTableManager(
      $_db,
      $_db.clinicalActions,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _clinicalActionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hospitalRegNo => $composableBuilder(
    column: $table.hospitalRegNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentDepartment => $composableBuilder(
    column: $table.currentDepartment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surgeryType => $composableBuilder(
    column: $table.surgeryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get complications => $composableBuilder(
    column: $table.complications,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dischargeDate => $composableBuilder(
    column: $table.dischargeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> clinicalEncountersRefs(
    Expression<bool> Function($$ClinicalEncountersTableFilterComposer f) f,
  ) {
    final $$ClinicalEncountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalEncounters,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalEncountersTableFilterComposer(
            $db: $db,
            $table: $db.clinicalEncounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investigationsRefs(
    Expression<bool> Function($$InvestigationsTableFilterComposer f) f,
  ) {
    final $$InvestigationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investigations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestigationsTableFilterComposer(
            $db: $db,
            $table: $db.investigations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> patientProblemsRefs(
    Expression<bool> Function($$PatientProblemsTableFilterComposer f) f,
  ) {
    final $$PatientProblemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableFilterComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clinicalActionsRefs(
    Expression<bool> Function($$ClinicalActionsTableFilterComposer f) f,
  ) {
    final $$ClinicalActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalActions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalActionsTableFilterComposer(
            $db: $db,
            $table: $db.clinicalActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hospitalRegNo => $composableBuilder(
    column: $table.hospitalRegNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentDepartment => $composableBuilder(
    column: $table.currentDepartment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surgeryType => $composableBuilder(
    column: $table.surgeryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get complications => $composableBuilder(
    column: $table.complications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dischargeDate => $composableBuilder(
    column: $table.dischargeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get hospitalRegNo => $composableBuilder(
    column: $table.hospitalRegNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get currentDepartment => $composableBuilder(
    column: $table.currentDepartment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get surgeryType => $composableBuilder(
    column: $table.surgeryType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get complications => $composableBuilder(
    column: $table.complications,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dischargeDate => $composableBuilder(
    column: $table.dischargeDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  Expression<T> clinicalEncountersRefs<T extends Object>(
    Expression<T> Function($$ClinicalEncountersTableAnnotationComposer a) f,
  ) {
    final $$ClinicalEncountersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.clinicalEncounters,
          getReferencedColumn: (t) => t.patientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ClinicalEncountersTableAnnotationComposer(
                $db: $db,
                $table: $db.clinicalEncounters,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> investigationsRefs<T extends Object>(
    Expression<T> Function($$InvestigationsTableAnnotationComposer a) f,
  ) {
    final $$InvestigationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investigations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestigationsTableAnnotationComposer(
            $db: $db,
            $table: $db.investigations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> patientProblemsRefs<T extends Object>(
    Expression<T> Function($$PatientProblemsTableAnnotationComposer a) f,
  ) {
    final $$PatientProblemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableAnnotationComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> clinicalActionsRefs<T extends Object>(
    Expression<T> Function($$ClinicalActionsTableAnnotationComposer a) f,
  ) {
    final $$ClinicalActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalActions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.clinicalActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          Patient,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (Patient, $$PatientsTableReferences),
          Patient,
          PrefetchHooks Function({
            bool clinicalEncountersRefs,
            bool investigationsRefs,
            bool patientProblemsRefs,
            bool clinicalActionsRefs,
          })
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> hospitalRegNo = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> diagnosis = const Value.absent(),
                Value<String> currentDepartment = const Value.absent(),
                Value<String?> surgeryType = const Value.absent(),
                Value<String?> complications = const Value.absent(),
                Value<DateTime?> admissionDate = const Value.absent(),
                Value<DateTime?> dischargeDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                ownerId: ownerId,
                hospitalRegNo: hospitalRegNo,
                fullName: fullName,
                dateOfBirth: dateOfBirth,
                sex: sex,
                phone: phone,
                diagnosis: diagnosis,
                currentDepartment: currentDepartment,
                surgeryType: surgeryType,
                complications: complications,
                admissionDate: admissionDate,
                dischargeDate: dischargeDate,
                isActive: isActive,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String ownerId,
                required String hospitalRegNo,
                required String fullName,
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> diagnosis = const Value.absent(),
                Value<String> currentDepartment = const Value.absent(),
                Value<String?> surgeryType = const Value.absent(),
                Value<String?> complications = const Value.absent(),
                Value<DateTime?> admissionDate = const Value.absent(),
                Value<DateTime?> dischargeDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                ownerId: ownerId,
                hospitalRegNo: hospitalRegNo,
                fullName: fullName,
                dateOfBirth: dateOfBirth,
                sex: sex,
                phone: phone,
                diagnosis: diagnosis,
                currentDepartment: currentDepartment,
                surgeryType: surgeryType,
                complications: complications,
                admissionDate: admissionDate,
                dischargeDate: dischargeDate,
                isActive: isActive,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clinicalEncountersRefs = false,
                investigationsRefs = false,
                patientProblemsRefs = false,
                clinicalActionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clinicalEncountersRefs) db.clinicalEncounters,
                    if (investigationsRefs) db.investigations,
                    if (patientProblemsRefs) db.patientProblems,
                    if (clinicalActionsRefs) db.clinicalActions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (clinicalEncountersRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          ClinicalEncounter
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._clinicalEncountersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).clinicalEncountersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investigationsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          Investigation
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._investigationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).investigationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (patientProblemsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          PatientProblem
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._patientProblemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).patientProblemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (clinicalActionsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          ClinicalAction
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._clinicalActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).clinicalActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      Patient,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (Patient, $$PatientsTableReferences),
      Patient,
      PrefetchHooks Function({
        bool clinicalEncountersRefs,
        bool investigationsRefs,
        bool patientProblemsRefs,
        bool clinicalActionsRefs,
      })
    >;
typedef $$ClinicalEncountersTableCreateCompanionBuilder =
    ClinicalEncountersCompanion Function({
      Value<String> id,
      required String ownerId,
      required String patientId,
      Value<String> encounterType,
      Value<DateTime> occurredAt,
      Value<int?> sbp,
      Value<int?> dbp,
      Value<int?> pulse,
      Value<double?> temperatureC,
      Value<int?> respiratoryRate,
      Value<int?> spo2,
      Value<double?> meanArterialPressure,
      Value<String?> chiefComplaint,
      Value<String?> consultantAdvice,
      Value<String?> note,
      Value<Map<String, dynamic>> dynamicData,
      Value<String?> department,
      Value<String?> wardName,
      Value<String?> bedNumber,
      Value<String?> imagePath,
      Value<String?> aiSummary,
      Value<String?> problemId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$ClinicalEncountersTableUpdateCompanionBuilder =
    ClinicalEncountersCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> patientId,
      Value<String> encounterType,
      Value<DateTime> occurredAt,
      Value<int?> sbp,
      Value<int?> dbp,
      Value<int?> pulse,
      Value<double?> temperatureC,
      Value<int?> respiratoryRate,
      Value<int?> spo2,
      Value<double?> meanArterialPressure,
      Value<String?> chiefComplaint,
      Value<String?> consultantAdvice,
      Value<String?> note,
      Value<Map<String, dynamic>> dynamicData,
      Value<String?> department,
      Value<String?> wardName,
      Value<String?> bedNumber,
      Value<String?> imagePath,
      Value<String?> aiSummary,
      Value<String?> problemId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$ClinicalEncountersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ClinicalEncountersTable,
          ClinicalEncounter
        > {
  $$ClinicalEncountersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('clinical_encounters__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClinicalEncountersTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalEncountersTable> {
  $$ClinicalEncountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encounterType => $composableBuilder(
    column: $table.encounterType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sbp => $composableBuilder(
    column: $table.sbp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dbp => $composableBuilder(
    column: $table.dbp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanArterialPressure => $composableBuilder(
    column: $table.meanArterialPressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consultantAdvice => $composableBuilder(
    column: $table.consultantAdvice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get dynamicData => $composableBuilder(
    column: $table.dynamicData,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wardName => $composableBuilder(
    column: $table.wardName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bedNumber => $composableBuilder(
    column: $table.bedNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiSummary => $composableBuilder(
    column: $table.aiSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalEncountersTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalEncountersTable> {
  $$ClinicalEncountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encounterType => $composableBuilder(
    column: $table.encounterType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sbp => $composableBuilder(
    column: $table.sbp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dbp => $composableBuilder(
    column: $table.dbp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanArterialPressure => $composableBuilder(
    column: $table.meanArterialPressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consultantAdvice => $composableBuilder(
    column: $table.consultantAdvice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dynamicData => $composableBuilder(
    column: $table.dynamicData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wardName => $composableBuilder(
    column: $table.wardName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bedNumber => $composableBuilder(
    column: $table.bedNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiSummary => $composableBuilder(
    column: $table.aiSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalEncountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalEncountersTable> {
  $$ClinicalEncountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get encounterType => $composableBuilder(
    column: $table.encounterType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sbp =>
      $composableBuilder(column: $table.sbp, builder: (column) => column);

  GeneratedColumn<int> get dbp =>
      $composableBuilder(column: $table.dbp, builder: (column) => column);

  GeneratedColumn<int> get pulse =>
      $composableBuilder(column: $table.pulse, builder: (column) => column);

  GeneratedColumn<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get spo2 =>
      $composableBuilder(column: $table.spo2, builder: (column) => column);

  GeneratedColumn<double> get meanArterialPressure => $composableBuilder(
    column: $table.meanArterialPressure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consultantAdvice => $composableBuilder(
    column: $table.consultantAdvice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get dynamicData => $composableBuilder(
    column: $table.dynamicData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wardName =>
      $composableBuilder(column: $table.wardName, builder: (column) => column);

  GeneratedColumn<String> get bedNumber =>
      $composableBuilder(column: $table.bedNumber, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get aiSummary =>
      $composableBuilder(column: $table.aiSummary, builder: (column) => column);

  GeneratedColumn<String> get problemId =>
      $composableBuilder(column: $table.problemId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalEncountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicalEncountersTable,
          ClinicalEncounter,
          $$ClinicalEncountersTableFilterComposer,
          $$ClinicalEncountersTableOrderingComposer,
          $$ClinicalEncountersTableAnnotationComposer,
          $$ClinicalEncountersTableCreateCompanionBuilder,
          $$ClinicalEncountersTableUpdateCompanionBuilder,
          (ClinicalEncounter, $$ClinicalEncountersTableReferences),
          ClinicalEncounter,
          PrefetchHooks Function({bool patientId})
        > {
  $$ClinicalEncountersTableTableManager(
    _$AppDatabase db,
    $ClinicalEncountersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalEncountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalEncountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalEncountersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> encounterType = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int?> sbp = const Value.absent(),
                Value<int?> dbp = const Value.absent(),
                Value<int?> pulse = const Value.absent(),
                Value<double?> temperatureC = const Value.absent(),
                Value<int?> respiratoryRate = const Value.absent(),
                Value<int?> spo2 = const Value.absent(),
                Value<double?> meanArterialPressure = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> consultantAdvice = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<Map<String, dynamic>> dynamicData = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<String?> wardName = const Value.absent(),
                Value<String?> bedNumber = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> aiSummary = const Value.absent(),
                Value<String?> problemId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalEncountersCompanion(
                id: id,
                ownerId: ownerId,
                patientId: patientId,
                encounterType: encounterType,
                occurredAt: occurredAt,
                sbp: sbp,
                dbp: dbp,
                pulse: pulse,
                temperatureC: temperatureC,
                respiratoryRate: respiratoryRate,
                spo2: spo2,
                meanArterialPressure: meanArterialPressure,
                chiefComplaint: chiefComplaint,
                consultantAdvice: consultantAdvice,
                note: note,
                dynamicData: dynamicData,
                department: department,
                wardName: wardName,
                bedNumber: bedNumber,
                imagePath: imagePath,
                aiSummary: aiSummary,
                problemId: problemId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String ownerId,
                required String patientId,
                Value<String> encounterType = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int?> sbp = const Value.absent(),
                Value<int?> dbp = const Value.absent(),
                Value<int?> pulse = const Value.absent(),
                Value<double?> temperatureC = const Value.absent(),
                Value<int?> respiratoryRate = const Value.absent(),
                Value<int?> spo2 = const Value.absent(),
                Value<double?> meanArterialPressure = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> consultantAdvice = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<Map<String, dynamic>> dynamicData = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<String?> wardName = const Value.absent(),
                Value<String?> bedNumber = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> aiSummary = const Value.absent(),
                Value<String?> problemId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalEncountersCompanion.insert(
                id: id,
                ownerId: ownerId,
                patientId: patientId,
                encounterType: encounterType,
                occurredAt: occurredAt,
                sbp: sbp,
                dbp: dbp,
                pulse: pulse,
                temperatureC: temperatureC,
                respiratoryRate: respiratoryRate,
                spo2: spo2,
                meanArterialPressure: meanArterialPressure,
                chiefComplaint: chiefComplaint,
                consultantAdvice: consultantAdvice,
                note: note,
                dynamicData: dynamicData,
                department: department,
                wardName: wardName,
                bedNumber: bedNumber,
                imagePath: imagePath,
                aiSummary: aiSummary,
                problemId: problemId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClinicalEncountersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable:
                                    $$ClinicalEncountersTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$ClinicalEncountersTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClinicalEncountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicalEncountersTable,
      ClinicalEncounter,
      $$ClinicalEncountersTableFilterComposer,
      $$ClinicalEncountersTableOrderingComposer,
      $$ClinicalEncountersTableAnnotationComposer,
      $$ClinicalEncountersTableCreateCompanionBuilder,
      $$ClinicalEncountersTableUpdateCompanionBuilder,
      (ClinicalEncounter, $$ClinicalEncountersTableReferences),
      ClinicalEncounter,
      PrefetchHooks Function({bool patientId})
    >;
typedef $$InvestigationsTableCreateCompanionBuilder =
    InvestigationsCompanion Function({
      Value<String> id,
      required String ownerId,
      required String patientId,
      required String testName,
      Value<String?> testCode,
      Value<String> status,
      Value<DateTime> orderedAt,
      Value<DateTime?> sampleSentAt,
      Value<DateTime?> resultReceivedAt,
      Value<String?> resultValue,
      Value<String?> resultUnit,
      Value<String?> referenceRange,
      Value<String?> organism,
      Value<String> sensitiveAntibiotics,
      Value<String> resistantAntibiotics,
      Value<String?> notes,
      Value<String?> problemId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$InvestigationsTableUpdateCompanionBuilder =
    InvestigationsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> patientId,
      Value<String> testName,
      Value<String?> testCode,
      Value<String> status,
      Value<DateTime> orderedAt,
      Value<DateTime?> sampleSentAt,
      Value<DateTime?> resultReceivedAt,
      Value<String?> resultValue,
      Value<String?> resultUnit,
      Value<String?> referenceRange,
      Value<String?> organism,
      Value<String> sensitiveAntibiotics,
      Value<String> resistantAntibiotics,
      Value<String?> notes,
      Value<String?> problemId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$InvestigationsTableReferences
    extends BaseReferences<_$AppDatabase, $InvestigationsTable, Investigation> {
  $$InvestigationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) => db.patients
      .createAlias('investigation_tracker__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvestigationsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestigationsTable> {
  $$InvestigationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testCode => $composableBuilder(
    column: $table.testCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sampleSentAt => $composableBuilder(
    column: $table.sampleSentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resultReceivedAt => $composableBuilder(
    column: $table.resultReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultValue => $composableBuilder(
    column: $table.resultValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultUnit => $composableBuilder(
    column: $table.resultUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organism => $composableBuilder(
    column: $table.organism,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensitiveAntibiotics => $composableBuilder(
    column: $table.sensitiveAntibiotics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resistantAntibiotics => $composableBuilder(
    column: $table.resistantAntibiotics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestigationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestigationsTable> {
  $$InvestigationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testCode => $composableBuilder(
    column: $table.testCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sampleSentAt => $composableBuilder(
    column: $table.sampleSentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resultReceivedAt => $composableBuilder(
    column: $table.resultReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultValue => $composableBuilder(
    column: $table.resultValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultUnit => $composableBuilder(
    column: $table.resultUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organism => $composableBuilder(
    column: $table.organism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensitiveAntibiotics => $composableBuilder(
    column: $table.sensitiveAntibiotics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resistantAntibiotics => $composableBuilder(
    column: $table.resistantAntibiotics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestigationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestigationsTable> {
  $$InvestigationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get testName =>
      $composableBuilder(column: $table.testName, builder: (column) => column);

  GeneratedColumn<String> get testCode =>
      $composableBuilder(column: $table.testCode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get orderedAt =>
      $composableBuilder(column: $table.orderedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sampleSentAt => $composableBuilder(
    column: $table.sampleSentAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resultReceivedAt => $composableBuilder(
    column: $table.resultReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultValue => $composableBuilder(
    column: $table.resultValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultUnit => $composableBuilder(
    column: $table.resultUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organism =>
      $composableBuilder(column: $table.organism, builder: (column) => column);

  GeneratedColumn<String> get sensitiveAntibiotics => $composableBuilder(
    column: $table.sensitiveAntibiotics,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resistantAntibiotics => $composableBuilder(
    column: $table.resistantAntibiotics,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get problemId =>
      $composableBuilder(column: $table.problemId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestigationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestigationsTable,
          Investigation,
          $$InvestigationsTableFilterComposer,
          $$InvestigationsTableOrderingComposer,
          $$InvestigationsTableAnnotationComposer,
          $$InvestigationsTableCreateCompanionBuilder,
          $$InvestigationsTableUpdateCompanionBuilder,
          (Investigation, $$InvestigationsTableReferences),
          Investigation,
          PrefetchHooks Function({bool patientId})
        > {
  $$InvestigationsTableTableManager(
    _$AppDatabase db,
    $InvestigationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestigationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestigationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestigationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> testName = const Value.absent(),
                Value<String?> testCode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> orderedAt = const Value.absent(),
                Value<DateTime?> sampleSentAt = const Value.absent(),
                Value<DateTime?> resultReceivedAt = const Value.absent(),
                Value<String?> resultValue = const Value.absent(),
                Value<String?> resultUnit = const Value.absent(),
                Value<String?> referenceRange = const Value.absent(),
                Value<String?> organism = const Value.absent(),
                Value<String> sensitiveAntibiotics = const Value.absent(),
                Value<String> resistantAntibiotics = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> problemId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestigationsCompanion(
                id: id,
                ownerId: ownerId,
                patientId: patientId,
                testName: testName,
                testCode: testCode,
                status: status,
                orderedAt: orderedAt,
                sampleSentAt: sampleSentAt,
                resultReceivedAt: resultReceivedAt,
                resultValue: resultValue,
                resultUnit: resultUnit,
                referenceRange: referenceRange,
                organism: organism,
                sensitiveAntibiotics: sensitiveAntibiotics,
                resistantAntibiotics: resistantAntibiotics,
                notes: notes,
                problemId: problemId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String ownerId,
                required String patientId,
                required String testName,
                Value<String?> testCode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> orderedAt = const Value.absent(),
                Value<DateTime?> sampleSentAt = const Value.absent(),
                Value<DateTime?> resultReceivedAt = const Value.absent(),
                Value<String?> resultValue = const Value.absent(),
                Value<String?> resultUnit = const Value.absent(),
                Value<String?> referenceRange = const Value.absent(),
                Value<String?> organism = const Value.absent(),
                Value<String> sensitiveAntibiotics = const Value.absent(),
                Value<String> resistantAntibiotics = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> problemId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestigationsCompanion.insert(
                id: id,
                ownerId: ownerId,
                patientId: patientId,
                testName: testName,
                testCode: testCode,
                status: status,
                orderedAt: orderedAt,
                sampleSentAt: sampleSentAt,
                resultReceivedAt: resultReceivedAt,
                resultValue: resultValue,
                resultUnit: resultUnit,
                referenceRange: referenceRange,
                organism: organism,
                sensitiveAntibiotics: sensitiveAntibiotics,
                resistantAntibiotics: resistantAntibiotics,
                notes: notes,
                problemId: problemId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestigationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$InvestigationsTableReferences
                                    ._patientIdTable(db),
                                referencedColumn:
                                    $$InvestigationsTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvestigationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestigationsTable,
      Investigation,
      $$InvestigationsTableFilterComposer,
      $$InvestigationsTableOrderingComposer,
      $$InvestigationsTableAnnotationComposer,
      $$InvestigationsTableCreateCompanionBuilder,
      $$InvestigationsTableUpdateCompanionBuilder,
      (Investigation, $$InvestigationsTableReferences),
      Investigation,
      PrefetchHooks Function({bool patientId})
    >;
typedef $$DrugsTableCreateCompanionBuilder =
    DrugsCompanion Function({
      Value<String> id,
      required String ownerId,
      required String genericName,
      Value<String?> brandName,
      Value<String?> strength,
      Value<String?> dosageForm,
      Value<String?> route,
      Value<String?> category,
      Value<String> substitutes,
      Value<String> sideEffects,
      Value<String> uses,
      Value<String> chemicalClass,
      Value<String?> priceEstimate,
      Value<bool> isTrusted,
      Value<String?> customNotes,
      Value<int> usageFrequency,
      Value<String> associatedProblems,
      Value<bool> isActive,
      Value<String> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$DrugsTableUpdateCompanionBuilder =
    DrugsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> genericName,
      Value<String?> brandName,
      Value<String?> strength,
      Value<String?> dosageForm,
      Value<String?> route,
      Value<String?> category,
      Value<String> substitutes,
      Value<String> sideEffects,
      Value<String> uses,
      Value<String> chemicalClass,
      Value<String?> priceEstimate,
      Value<bool> isTrusted,
      Value<String?> customNotes,
      Value<int> usageFrequency,
      Value<String> associatedProblems,
      Value<bool> isActive,
      Value<String> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$DrugsTableFilterComposer extends Composer<_$AppDatabase, $DrugsTable> {
  $$DrugsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get substitutes => $composableBuilder(
    column: $table.substitutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sideEffects => $composableBuilder(
    column: $table.sideEffects,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uses => $composableBuilder(
    column: $table.uses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chemicalClass => $composableBuilder(
    column: $table.chemicalClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceEstimate => $composableBuilder(
    column: $table.priceEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTrusted => $composableBuilder(
    column: $table.isTrusted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customNotes => $composableBuilder(
    column: $table.customNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associatedProblems => $composableBuilder(
    column: $table.associatedProblems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DrugsTableOrderingComposer
    extends Composer<_$AppDatabase, $DrugsTable> {
  $$DrugsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get substitutes => $composableBuilder(
    column: $table.substitutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sideEffects => $composableBuilder(
    column: $table.sideEffects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uses => $composableBuilder(
    column: $table.uses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chemicalClass => $composableBuilder(
    column: $table.chemicalClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceEstimate => $composableBuilder(
    column: $table.priceEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTrusted => $composableBuilder(
    column: $table.isTrusted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customNotes => $composableBuilder(
    column: $table.customNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associatedProblems => $composableBuilder(
    column: $table.associatedProblems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DrugsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DrugsTable> {
  $$DrugsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get substitutes => $composableBuilder(
    column: $table.substitutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sideEffects => $composableBuilder(
    column: $table.sideEffects,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uses =>
      $composableBuilder(column: $table.uses, builder: (column) => column);

  GeneratedColumn<String> get chemicalClass => $composableBuilder(
    column: $table.chemicalClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priceEstimate => $composableBuilder(
    column: $table.priceEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTrusted =>
      $composableBuilder(column: $table.isTrusted, builder: (column) => column);

  GeneratedColumn<String> get customNotes => $composableBuilder(
    column: $table.customNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get associatedProblems => $composableBuilder(
    column: $table.associatedProblems,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$DrugsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DrugsTable,
          Drug,
          $$DrugsTableFilterComposer,
          $$DrugsTableOrderingComposer,
          $$DrugsTableAnnotationComposer,
          $$DrugsTableCreateCompanionBuilder,
          $$DrugsTableUpdateCompanionBuilder,
          (Drug, BaseReferences<_$AppDatabase, $DrugsTable, Drug>),
          Drug,
          PrefetchHooks Function()
        > {
  $$DrugsTableTableManager(_$AppDatabase db, $DrugsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrugsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrugsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrugsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> genericName = const Value.absent(),
                Value<String?> brandName = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> dosageForm = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> substitutes = const Value.absent(),
                Value<String> sideEffects = const Value.absent(),
                Value<String> uses = const Value.absent(),
                Value<String> chemicalClass = const Value.absent(),
                Value<String?> priceEstimate = const Value.absent(),
                Value<bool> isTrusted = const Value.absent(),
                Value<String?> customNotes = const Value.absent(),
                Value<int> usageFrequency = const Value.absent(),
                Value<String> associatedProblems = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrugsCompanion(
                id: id,
                ownerId: ownerId,
                genericName: genericName,
                brandName: brandName,
                strength: strength,
                dosageForm: dosageForm,
                route: route,
                category: category,
                substitutes: substitutes,
                sideEffects: sideEffects,
                uses: uses,
                chemicalClass: chemicalClass,
                priceEstimate: priceEstimate,
                isTrusted: isTrusted,
                customNotes: customNotes,
                usageFrequency: usageFrequency,
                associatedProblems: associatedProblems,
                isActive: isActive,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String ownerId,
                required String genericName,
                Value<String?> brandName = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> dosageForm = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> substitutes = const Value.absent(),
                Value<String> sideEffects = const Value.absent(),
                Value<String> uses = const Value.absent(),
                Value<String> chemicalClass = const Value.absent(),
                Value<String?> priceEstimate = const Value.absent(),
                Value<bool> isTrusted = const Value.absent(),
                Value<String?> customNotes = const Value.absent(),
                Value<int> usageFrequency = const Value.absent(),
                Value<String> associatedProblems = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrugsCompanion.insert(
                id: id,
                ownerId: ownerId,
                genericName: genericName,
                brandName: brandName,
                strength: strength,
                dosageForm: dosageForm,
                route: route,
                category: category,
                substitutes: substitutes,
                sideEffects: sideEffects,
                uses: uses,
                chemicalClass: chemicalClass,
                priceEstimate: priceEstimate,
                isTrusted: isTrusted,
                customNotes: customNotes,
                usageFrequency: usageFrequency,
                associatedProblems: associatedProblems,
                isActive: isActive,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DrugsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DrugsTable,
      Drug,
      $$DrugsTableFilterComposer,
      $$DrugsTableOrderingComposer,
      $$DrugsTableAnnotationComposer,
      $$DrugsTableCreateCompanionBuilder,
      $$DrugsTableUpdateCompanionBuilder,
      (Drug, BaseReferences<_$AppDatabase, $DrugsTable, Drug>),
      Drug,
      PrefetchHooks Function()
    >;
typedef $$PersonalWikiTableCreateCompanionBuilder =
    PersonalWikiCompanion Function({
      Value<String> id,
      required String ownerId,
      required String topic,
      Value<String> markdownContent,
      Value<List<String>> tags,
      Value<List<String>> departmentRelevance,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$PersonalWikiTableUpdateCompanionBuilder =
    PersonalWikiCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> topic,
      Value<String> markdownContent,
      Value<List<String>> tags,
      Value<List<String>> departmentRelevance,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$PersonalWikiTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalWikiTable> {
  $$PersonalWikiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markdownContent => $composableBuilder(
    column: $table.markdownContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get departmentRelevance => $composableBuilder(
    column: $table.departmentRelevance,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalWikiTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalWikiTable> {
  $$PersonalWikiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markdownContent => $composableBuilder(
    column: $table.markdownContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departmentRelevance => $composableBuilder(
    column: $table.departmentRelevance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalWikiTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalWikiTable> {
  $$PersonalWikiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get markdownContent => $composableBuilder(
    column: $table.markdownContent,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String>
  get departmentRelevance => $composableBuilder(
    column: $table.departmentRelevance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$PersonalWikiTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalWikiTable,
          WikiEntry,
          $$PersonalWikiTableFilterComposer,
          $$PersonalWikiTableOrderingComposer,
          $$PersonalWikiTableAnnotationComposer,
          $$PersonalWikiTableCreateCompanionBuilder,
          $$PersonalWikiTableUpdateCompanionBuilder,
          (
            WikiEntry,
            BaseReferences<_$AppDatabase, $PersonalWikiTable, WikiEntry>,
          ),
          WikiEntry,
          PrefetchHooks Function()
        > {
  $$PersonalWikiTableTableManager(_$AppDatabase db, $PersonalWikiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalWikiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalWikiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalWikiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String> markdownContent = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<List<String>> departmentRelevance = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalWikiCompanion(
                id: id,
                ownerId: ownerId,
                topic: topic,
                markdownContent: markdownContent,
                tags: tags,
                departmentRelevance: departmentRelevance,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String ownerId,
                required String topic,
                Value<String> markdownContent = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<List<String>> departmentRelevance = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalWikiCompanion.insert(
                id: id,
                ownerId: ownerId,
                topic: topic,
                markdownContent: markdownContent,
                tags: tags,
                departmentRelevance: departmentRelevance,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalWikiTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalWikiTable,
      WikiEntry,
      $$PersonalWikiTableFilterComposer,
      $$PersonalWikiTableOrderingComposer,
      $$PersonalWikiTableAnnotationComposer,
      $$PersonalWikiTableCreateCompanionBuilder,
      $$PersonalWikiTableUpdateCompanionBuilder,
      (WikiEntry, BaseReferences<_$AppDatabase, $PersonalWikiTable, WikiEntry>),
      WikiEntry,
      PrefetchHooks Function()
    >;
typedef $$OfflineSyncQueueTableCreateCompanionBuilder =
    OfflineSyncQueueCompanion Function({
      Value<String> id,
      required String ownerId,
      required String entityType,
      required String entityId,
      required String operation,
      Value<String> payload,
      Value<DateTime> clientUpdatedAt,
      Value<int> attempts,
      Value<DateTime> nextAttemptAt,
      Value<String?> lastError,
      Value<DateTime?> processedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$OfflineSyncQueueTableUpdateCompanionBuilder =
    OfflineSyncQueueCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> clientUpdatedAt,
      Value<int> attempts,
      Value<DateTime> nextAttemptAt,
      Value<String?> lastError,
      Value<DateTime?> processedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$OfflineSyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTable> {
  $$OfflineSyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineSyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTable> {
  $$OfflineSyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineSyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTable> {
  $$OfflineSyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$OfflineSyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineSyncQueueTable,
          SyncQueueEntry,
          $$OfflineSyncQueueTableFilterComposer,
          $$OfflineSyncQueueTableOrderingComposer,
          $$OfflineSyncQueueTableAnnotationComposer,
          $$OfflineSyncQueueTableCreateCompanionBuilder,
          $$OfflineSyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $OfflineSyncQueueTable,
              SyncQueueEntry
            >,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$OfflineSyncQueueTableTableManager(
    _$AppDatabase db,
    $OfflineSyncQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineSyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineSyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineSyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> clientUpdatedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineSyncQueueCompanion(
                id: id,
                ownerId: ownerId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                clientUpdatedAt: clientUpdatedAt,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                processedAt: processedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String ownerId,
                required String entityType,
                required String entityId,
                required String operation,
                Value<String> payload = const Value.absent(),
                Value<DateTime> clientUpdatedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineSyncQueueCompanion.insert(
                id: id,
                ownerId: ownerId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                clientUpdatedAt: clientUpdatedAt,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                processedAt: processedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineSyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineSyncQueueTable,
      SyncQueueEntry,
      $$OfflineSyncQueueTableFilterComposer,
      $$OfflineSyncQueueTableOrderingComposer,
      $$OfflineSyncQueueTableAnnotationComposer,
      $$OfflineSyncQueueTableCreateCompanionBuilder,
      $$OfflineSyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $OfflineSyncQueueTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$PatientProblemsTableCreateCompanionBuilder =
    PatientProblemsCompanion Function({
      Value<String> id,
      required String patientId,
      required String problemName,
      Value<String> status,
      Value<DateTime?> onsetDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PatientProblemsTableUpdateCompanionBuilder =
    PatientProblemsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> problemName,
      Value<String> status,
      Value<DateTime?> onsetDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PatientProblemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PatientProblemsTable, PatientProblem> {
  $$PatientProblemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('patient_problems__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ClinicalActionsTable, List<ClinicalAction>>
  _clinicalActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clinicalActions,
    aliasName: 'patient_problems__id__clinical_actions__problem_id',
  );

  $$ClinicalActionsTableProcessedTableManager get clinicalActionsRefs {
    final manager = $$ClinicalActionsTableTableManager(
      $_db,
      $_db.clinicalActions,
    ).filter((f) => f.problemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _clinicalActionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ClinicalOutcomesTable, List<ClinicalOutcome>>
  _clinicalOutcomesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clinicalOutcomes,
    aliasName: 'patient_problems__id__clinical_outcomes__problem_id',
  );

  $$ClinicalOutcomesTableProcessedTableManager get clinicalOutcomesRefs {
    final manager = $$ClinicalOutcomesTableTableManager(
      $_db,
      $_db.clinicalOutcomes,
    ).filter((f) => f.problemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _clinicalOutcomesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientProblemsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientProblemsTable> {
  $$PatientProblemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get problemName => $composableBuilder(
    column: $table.problemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get onsetDate => $composableBuilder(
    column: $table.onsetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> clinicalActionsRefs(
    Expression<bool> Function($$ClinicalActionsTableFilterComposer f) f,
  ) {
    final $$ClinicalActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalActions,
      getReferencedColumn: (t) => t.problemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalActionsTableFilterComposer(
            $db: $db,
            $table: $db.clinicalActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clinicalOutcomesRefs(
    Expression<bool> Function($$ClinicalOutcomesTableFilterComposer f) f,
  ) {
    final $$ClinicalOutcomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalOutcomes,
      getReferencedColumn: (t) => t.problemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalOutcomesTableFilterComposer(
            $db: $db,
            $table: $db.clinicalOutcomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientProblemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientProblemsTable> {
  $$PatientProblemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get problemName => $composableBuilder(
    column: $table.problemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get onsetDate => $composableBuilder(
    column: $table.onsetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PatientProblemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientProblemsTable> {
  $$PatientProblemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get problemName => $composableBuilder(
    column: $table.problemName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get onsetDate =>
      $composableBuilder(column: $table.onsetDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> clinicalActionsRefs<T extends Object>(
    Expression<T> Function($$ClinicalActionsTableAnnotationComposer a) f,
  ) {
    final $$ClinicalActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalActions,
      getReferencedColumn: (t) => t.problemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.clinicalActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> clinicalOutcomesRefs<T extends Object>(
    Expression<T> Function($$ClinicalOutcomesTableAnnotationComposer a) f,
  ) {
    final $$ClinicalOutcomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalOutcomes,
      getReferencedColumn: (t) => t.problemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalOutcomesTableAnnotationComposer(
            $db: $db,
            $table: $db.clinicalOutcomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientProblemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientProblemsTable,
          PatientProblem,
          $$PatientProblemsTableFilterComposer,
          $$PatientProblemsTableOrderingComposer,
          $$PatientProblemsTableAnnotationComposer,
          $$PatientProblemsTableCreateCompanionBuilder,
          $$PatientProblemsTableUpdateCompanionBuilder,
          (PatientProblem, $$PatientProblemsTableReferences),
          PatientProblem,
          PrefetchHooks Function({
            bool patientId,
            bool clinicalActionsRefs,
            bool clinicalOutcomesRefs,
          })
        > {
  $$PatientProblemsTableTableManager(
    _$AppDatabase db,
    $PatientProblemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientProblemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientProblemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientProblemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> problemName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> onsetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientProblemsCompanion(
                id: id,
                patientId: patientId,
                problemName: problemName,
                status: status,
                onsetDate: onsetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String patientId,
                required String problemName,
                Value<String> status = const Value.absent(),
                Value<DateTime?> onsetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientProblemsCompanion.insert(
                id: id,
                patientId: patientId,
                problemName: problemName,
                status: status,
                onsetDate: onsetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatientProblemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                patientId = false,
                clinicalActionsRefs = false,
                clinicalOutcomesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clinicalActionsRefs) db.clinicalActions,
                    if (clinicalOutcomesRefs) db.clinicalOutcomes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (patientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.patientId,
                                    referencedTable:
                                        $$PatientProblemsTableReferences
                                            ._patientIdTable(db),
                                    referencedColumn:
                                        $$PatientProblemsTableReferences
                                            ._patientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (clinicalActionsRefs)
                        await $_getPrefetchedData<
                          PatientProblem,
                          $PatientProblemsTable,
                          ClinicalAction
                        >(
                          currentTable: table,
                          referencedTable: $$PatientProblemsTableReferences
                              ._clinicalActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientProblemsTableReferences(
                                db,
                                table,
                                p0,
                              ).clinicalActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.problemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (clinicalOutcomesRefs)
                        await $_getPrefetchedData<
                          PatientProblem,
                          $PatientProblemsTable,
                          ClinicalOutcome
                        >(
                          currentTable: table,
                          referencedTable: $$PatientProblemsTableReferences
                              ._clinicalOutcomesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientProblemsTableReferences(
                                db,
                                table,
                                p0,
                              ).clinicalOutcomesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.problemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PatientProblemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientProblemsTable,
      PatientProblem,
      $$PatientProblemsTableFilterComposer,
      $$PatientProblemsTableOrderingComposer,
      $$PatientProblemsTableAnnotationComposer,
      $$PatientProblemsTableCreateCompanionBuilder,
      $$PatientProblemsTableUpdateCompanionBuilder,
      (PatientProblem, $$PatientProblemsTableReferences),
      PatientProblem,
      PrefetchHooks Function({
        bool patientId,
        bool clinicalActionsRefs,
        bool clinicalOutcomesRefs,
      })
    >;
typedef $$ClinicalActionsTableCreateCompanionBuilder =
    ClinicalActionsCompanion Function({
      Value<String> id,
      required String patientId,
      required String problemId,
      required String actionType,
      required String description,
      Value<DateTime> occurredAt,
      Value<String> metadata,
      Value<int> rowid,
    });
typedef $$ClinicalActionsTableUpdateCompanionBuilder =
    ClinicalActionsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> problemId,
      Value<String> actionType,
      Value<String> description,
      Value<DateTime> occurredAt,
      Value<String> metadata,
      Value<int> rowid,
    });

final class $$ClinicalActionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ClinicalActionsTable, ClinicalAction> {
  $$ClinicalActionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('clinical_actions__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PatientProblemsTable _problemIdTable(_$AppDatabase db) => db
      .patientProblems
      .createAlias('clinical_actions__problem_id__patient_problems__id');

  $$PatientProblemsTableProcessedTableManager get problemId {
    final $_column = $_itemColumn<String>('problem_id')!;

    final manager = $$PatientProblemsTableTableManager(
      $_db,
      $_db.patientProblems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_problemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClinicalActionsTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalActionsTable> {
  $$ClinicalActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientProblemsTableFilterComposer get problemId {
    final $$PatientProblemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.problemId,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableFilterComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalActionsTable> {
  $$ClinicalActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientProblemsTableOrderingComposer get problemId {
    final $$PatientProblemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.problemId,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableOrderingComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalActionsTable> {
  $$ClinicalActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PatientProblemsTableAnnotationComposer get problemId {
    final $$PatientProblemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.problemId,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableAnnotationComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicalActionsTable,
          ClinicalAction,
          $$ClinicalActionsTableFilterComposer,
          $$ClinicalActionsTableOrderingComposer,
          $$ClinicalActionsTableAnnotationComposer,
          $$ClinicalActionsTableCreateCompanionBuilder,
          $$ClinicalActionsTableUpdateCompanionBuilder,
          (ClinicalAction, $$ClinicalActionsTableReferences),
          ClinicalAction,
          PrefetchHooks Function({bool patientId, bool problemId})
        > {
  $$ClinicalActionsTableTableManager(
    _$AppDatabase db,
    $ClinicalActionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> problemId = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalActionsCompanion(
                id: id,
                patientId: patientId,
                problemId: problemId,
                actionType: actionType,
                description: description,
                occurredAt: occurredAt,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String patientId,
                required String problemId,
                required String actionType,
                required String description,
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalActionsCompanion.insert(
                id: id,
                patientId: patientId,
                problemId: problemId,
                actionType: actionType,
                description: description,
                occurredAt: occurredAt,
                metadata: metadata,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClinicalActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, problemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable:
                                    $$ClinicalActionsTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$ClinicalActionsTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (problemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.problemId,
                                referencedTable:
                                    $$ClinicalActionsTableReferences
                                        ._problemIdTable(db),
                                referencedColumn:
                                    $$ClinicalActionsTableReferences
                                        ._problemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClinicalActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicalActionsTable,
      ClinicalAction,
      $$ClinicalActionsTableFilterComposer,
      $$ClinicalActionsTableOrderingComposer,
      $$ClinicalActionsTableAnnotationComposer,
      $$ClinicalActionsTableCreateCompanionBuilder,
      $$ClinicalActionsTableUpdateCompanionBuilder,
      (ClinicalAction, $$ClinicalActionsTableReferences),
      ClinicalAction,
      PrefetchHooks Function({bool patientId, bool problemId})
    >;
typedef $$ClinicalOutcomesTableCreateCompanionBuilder =
    ClinicalOutcomesCompanion Function({
      Value<String> id,
      required String problemId,
      required String metricName,
      required double metricValue,
      Value<String?> metricUnit,
      Value<String?> treatmentMethod,
      Value<DateTime> measuredAt,
      Value<int> rowid,
    });
typedef $$ClinicalOutcomesTableUpdateCompanionBuilder =
    ClinicalOutcomesCompanion Function({
      Value<String> id,
      Value<String> problemId,
      Value<String> metricName,
      Value<double> metricValue,
      Value<String?> metricUnit,
      Value<String?> treatmentMethod,
      Value<DateTime> measuredAt,
      Value<int> rowid,
    });

final class $$ClinicalOutcomesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ClinicalOutcomesTable, ClinicalOutcome> {
  $$ClinicalOutcomesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientProblemsTable _problemIdTable(_$AppDatabase db) => db
      .patientProblems
      .createAlias('clinical_outcomes__problem_id__patient_problems__id');

  $$PatientProblemsTableProcessedTableManager get problemId {
    final $_column = $_itemColumn<String>('problem_id')!;

    final manager = $$PatientProblemsTableTableManager(
      $_db,
      $_db.patientProblems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_problemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClinicalOutcomesTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalOutcomesTable> {
  $$ClinicalOutcomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricName => $composableBuilder(
    column: $table.metricName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get metricValue => $composableBuilder(
    column: $table.metricValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricUnit => $composableBuilder(
    column: $table.metricUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatmentMethod => $composableBuilder(
    column: $table.treatmentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientProblemsTableFilterComposer get problemId {
    final $$PatientProblemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.problemId,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableFilterComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalOutcomesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalOutcomesTable> {
  $$ClinicalOutcomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricName => $composableBuilder(
    column: $table.metricName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get metricValue => $composableBuilder(
    column: $table.metricValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricUnit => $composableBuilder(
    column: $table.metricUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatmentMethod => $composableBuilder(
    column: $table.treatmentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientProblemsTableOrderingComposer get problemId {
    final $$PatientProblemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.problemId,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableOrderingComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalOutcomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalOutcomesTable> {
  $$ClinicalOutcomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get metricName => $composableBuilder(
    column: $table.metricName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get metricValue => $composableBuilder(
    column: $table.metricValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricUnit => $composableBuilder(
    column: $table.metricUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get treatmentMethod => $composableBuilder(
    column: $table.treatmentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  $$PatientProblemsTableAnnotationComposer get problemId {
    final $$PatientProblemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.problemId,
      referencedTable: $db.patientProblems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientProblemsTableAnnotationComposer(
            $db: $db,
            $table: $db.patientProblems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalOutcomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicalOutcomesTable,
          ClinicalOutcome,
          $$ClinicalOutcomesTableFilterComposer,
          $$ClinicalOutcomesTableOrderingComposer,
          $$ClinicalOutcomesTableAnnotationComposer,
          $$ClinicalOutcomesTableCreateCompanionBuilder,
          $$ClinicalOutcomesTableUpdateCompanionBuilder,
          (ClinicalOutcome, $$ClinicalOutcomesTableReferences),
          ClinicalOutcome,
          PrefetchHooks Function({bool problemId})
        > {
  $$ClinicalOutcomesTableTableManager(
    _$AppDatabase db,
    $ClinicalOutcomesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalOutcomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalOutcomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalOutcomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> problemId = const Value.absent(),
                Value<String> metricName = const Value.absent(),
                Value<double> metricValue = const Value.absent(),
                Value<String?> metricUnit = const Value.absent(),
                Value<String?> treatmentMethod = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalOutcomesCompanion(
                id: id,
                problemId: problemId,
                metricName: metricName,
                metricValue: metricValue,
                metricUnit: metricUnit,
                treatmentMethod: treatmentMethod,
                measuredAt: measuredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String problemId,
                required String metricName,
                required double metricValue,
                Value<String?> metricUnit = const Value.absent(),
                Value<String?> treatmentMethod = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalOutcomesCompanion.insert(
                id: id,
                problemId: problemId,
                metricName: metricName,
                metricValue: metricValue,
                metricUnit: metricUnit,
                treatmentMethod: treatmentMethod,
                measuredAt: measuredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClinicalOutcomesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({problemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (problemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.problemId,
                                referencedTable:
                                    $$ClinicalOutcomesTableReferences
                                        ._problemIdTable(db),
                                referencedColumn:
                                    $$ClinicalOutcomesTableReferences
                                        ._problemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClinicalOutcomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicalOutcomesTable,
      ClinicalOutcome,
      $$ClinicalOutcomesTableFilterComposer,
      $$ClinicalOutcomesTableOrderingComposer,
      $$ClinicalOutcomesTableAnnotationComposer,
      $$ClinicalOutcomesTableCreateCompanionBuilder,
      $$ClinicalOutcomesTableUpdateCompanionBuilder,
      (ClinicalOutcome, $$ClinicalOutcomesTableReferences),
      ClinicalOutcome,
      PrefetchHooks Function({bool problemId})
    >;
typedef $$CdssRulesTableCreateCompanionBuilder =
    CdssRulesCompanion Function({
      Value<String> id,
      required String targetProblem,
      required String triggerCondition,
      required String suggestedAction,
      required String evidenceSource,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });
typedef $$CdssRulesTableUpdateCompanionBuilder =
    CdssRulesCompanion Function({
      Value<String> id,
      Value<String> targetProblem,
      Value<String> triggerCondition,
      Value<String> suggestedAction,
      Value<String> evidenceSource,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

class $$CdssRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CdssRulesTable> {
  $$CdssRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetProblem => $composableBuilder(
    column: $table.targetProblem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerCondition => $composableBuilder(
    column: $table.triggerCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedAction => $composableBuilder(
    column: $table.suggestedAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceSource => $composableBuilder(
    column: $table.evidenceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CdssRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CdssRulesTable> {
  $$CdssRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetProblem => $composableBuilder(
    column: $table.targetProblem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerCondition => $composableBuilder(
    column: $table.triggerCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedAction => $composableBuilder(
    column: $table.suggestedAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceSource => $composableBuilder(
    column: $table.evidenceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CdssRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CdssRulesTable> {
  $$CdssRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetProblem => $composableBuilder(
    column: $table.targetProblem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerCondition => $composableBuilder(
    column: $table.triggerCondition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestedAction => $composableBuilder(
    column: $table.suggestedAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceSource => $composableBuilder(
    column: $table.evidenceSource,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$CdssRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CdssRulesTable,
          CdssRule,
          $$CdssRulesTableFilterComposer,
          $$CdssRulesTableOrderingComposer,
          $$CdssRulesTableAnnotationComposer,
          $$CdssRulesTableCreateCompanionBuilder,
          $$CdssRulesTableUpdateCompanionBuilder,
          (CdssRule, BaseReferences<_$AppDatabase, $CdssRulesTable, CdssRule>),
          CdssRule,
          PrefetchHooks Function()
        > {
  $$CdssRulesTableTableManager(_$AppDatabase db, $CdssRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CdssRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CdssRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CdssRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetProblem = const Value.absent(),
                Value<String> triggerCondition = const Value.absent(),
                Value<String> suggestedAction = const Value.absent(),
                Value<String> evidenceSource = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CdssRulesCompanion(
                id: id,
                targetProblem: targetProblem,
                triggerCondition: triggerCondition,
                suggestedAction: suggestedAction,
                evidenceSource: evidenceSource,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String targetProblem,
                required String triggerCondition,
                required String suggestedAction,
                required String evidenceSource,
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CdssRulesCompanion.insert(
                id: id,
                targetProblem: targetProblem,
                triggerCondition: triggerCondition,
                suggestedAction: suggestedAction,
                evidenceSource: evidenceSource,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CdssRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CdssRulesTable,
      CdssRule,
      $$CdssRulesTableFilterComposer,
      $$CdssRulesTableOrderingComposer,
      $$CdssRulesTableAnnotationComposer,
      $$CdssRulesTableCreateCompanionBuilder,
      $$CdssRulesTableUpdateCompanionBuilder,
      (CdssRule, BaseReferences<_$AppDatabase, $CdssRulesTable, CdssRule>),
      CdssRule,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$ClinicalEncountersTableTableManager get clinicalEncounters =>
      $$ClinicalEncountersTableTableManager(_db, _db.clinicalEncounters);
  $$InvestigationsTableTableManager get investigations =>
      $$InvestigationsTableTableManager(_db, _db.investigations);
  $$DrugsTableTableManager get drugs =>
      $$DrugsTableTableManager(_db, _db.drugs);
  $$PersonalWikiTableTableManager get personalWiki =>
      $$PersonalWikiTableTableManager(_db, _db.personalWiki);
  $$OfflineSyncQueueTableTableManager get offlineSyncQueue =>
      $$OfflineSyncQueueTableTableManager(_db, _db.offlineSyncQueue);
  $$PatientProblemsTableTableManager get patientProblems =>
      $$PatientProblemsTableTableManager(_db, _db.patientProblems);
  $$ClinicalActionsTableTableManager get clinicalActions =>
      $$ClinicalActionsTableTableManager(_db, _db.clinicalActions);
  $$ClinicalOutcomesTableTableManager get clinicalOutcomes =>
      $$ClinicalOutcomesTableTableManager(_db, _db.clinicalOutcomes);
  $$CdssRulesTableTableManager get cdssRules =>
      $$CdssRulesTableTableManager(_db, _db.cdssRules);
}
