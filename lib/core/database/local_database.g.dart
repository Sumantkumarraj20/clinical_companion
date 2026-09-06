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
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternateContactMeta = const VerificationMeta(
    'alternateContact',
  );
  @override
  late final GeneratedColumn<String> alternateContact = GeneratedColumn<String>(
    'alternate_contact',
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
    phoneNumber,
    alternateContact,
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
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('alternate_contact')) {
      context.handle(
        _alternateContactMeta,
        alternateContact.isAcceptableOrUnknown(
          data['alternate_contact']!,
          _alternateContactMeta,
        ),
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
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      alternateContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_contact'],
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
  final String? phoneNumber;
  final String? alternateContact;
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
    this.phoneNumber,
    this.alternateContact,
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
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || alternateContact != null) {
      map['alternate_contact'] = Variable<String>(alternateContact);
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
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      alternateContact: alternateContact == null && nullToAbsent
          ? const Value.absent()
          : Value(alternateContact),
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
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      alternateContact: serializer.fromJson<String?>(json['alternateContact']),
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
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'alternateContact': serializer.toJson<String?>(alternateContact),
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
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> alternateContact = const Value.absent(),
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
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    alternateContact: alternateContact.present
        ? alternateContact.value
        : this.alternateContact,
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
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      alternateContact: data.alternateContact.present
          ? data.alternateContact.value
          : this.alternateContact,
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
          ..write('phoneNumber: $phoneNumber, ')
          ..write('alternateContact: $alternateContact, ')
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
    phoneNumber,
    alternateContact,
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
          other.phoneNumber == this.phoneNumber &&
          other.alternateContact == this.alternateContact &&
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
  final Value<String?> phoneNumber;
  final Value<String?> alternateContact;
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
    this.phoneNumber = const Value.absent(),
    this.alternateContact = const Value.absent(),
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
    this.phoneNumber = const Value.absent(),
    this.alternateContact = const Value.absent(),
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
    Expression<String>? phoneNumber,
    Expression<String>? alternateContact,
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
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (alternateContact != null) 'alternate_contact': alternateContact,
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
    Value<String?>? phoneNumber,
    Value<String?>? alternateContact,
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
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternateContact: alternateContact ?? this.alternateContact,
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
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (alternateContact.present) {
      map['alternate_contact'] = Variable<String>(alternateContact.value);
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
          ..write('phoneNumber: $phoneNumber, ')
          ..write('alternateContact: $alternateContact, ')
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sideEffectsMeta = const VerificationMeta(
    'sideEffects',
  );
  @override
  late final GeneratedColumn<String> sideEffects = GeneratedColumn<String>(
    'side_effects',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usesMeta = const VerificationMeta('uses');
  @override
  late final GeneratedColumn<String> uses = GeneratedColumn<String>(
    'uses',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chemicalClassMeta = const VerificationMeta(
    'chemicalClass',
  );
  @override
  late final GeneratedColumn<String> chemicalClass = GeneratedColumn<String>(
    'chemical_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
      ),
      sideEffects: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side_effects'],
      ),
      uses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uses'],
      ),
      chemicalClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chemical_class'],
      ),
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
  final String? substitutes;
  final String? sideEffects;
  final String? uses;
  final String? chemicalClass;
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
    this.substitutes,
    this.sideEffects,
    this.uses,
    this.chemicalClass,
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
    if (!nullToAbsent || substitutes != null) {
      map['substitutes'] = Variable<String>(substitutes);
    }
    if (!nullToAbsent || sideEffects != null) {
      map['side_effects'] = Variable<String>(sideEffects);
    }
    if (!nullToAbsent || uses != null) {
      map['uses'] = Variable<String>(uses);
    }
    if (!nullToAbsent || chemicalClass != null) {
      map['chemical_class'] = Variable<String>(chemicalClass);
    }
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
      substitutes: substitutes == null && nullToAbsent
          ? const Value.absent()
          : Value(substitutes),
      sideEffects: sideEffects == null && nullToAbsent
          ? const Value.absent()
          : Value(sideEffects),
      uses: uses == null && nullToAbsent ? const Value.absent() : Value(uses),
      chemicalClass: chemicalClass == null && nullToAbsent
          ? const Value.absent()
          : Value(chemicalClass),
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
      substitutes: serializer.fromJson<String?>(json['substitutes']),
      sideEffects: serializer.fromJson<String?>(json['sideEffects']),
      uses: serializer.fromJson<String?>(json['uses']),
      chemicalClass: serializer.fromJson<String?>(json['chemicalClass']),
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
      'substitutes': serializer.toJson<String?>(substitutes),
      'sideEffects': serializer.toJson<String?>(sideEffects),
      'uses': serializer.toJson<String?>(uses),
      'chemicalClass': serializer.toJson<String?>(chemicalClass),
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
    Value<String?> substitutes = const Value.absent(),
    Value<String?> sideEffects = const Value.absent(),
    Value<String?> uses = const Value.absent(),
    Value<String?> chemicalClass = const Value.absent(),
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
    substitutes: substitutes.present ? substitutes.value : this.substitutes,
    sideEffects: sideEffects.present ? sideEffects.value : this.sideEffects,
    uses: uses.present ? uses.value : this.uses,
    chemicalClass: chemicalClass.present
        ? chemicalClass.value
        : this.chemicalClass,
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
  final Value<String?> substitutes;
  final Value<String?> sideEffects;
  final Value<String?> uses;
  final Value<String?> chemicalClass;
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
    Value<String?>? substitutes,
    Value<String?>? sideEffects,
    Value<String?>? uses,
    Value<String?>? chemicalClass,
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
  static const VerificationMeta _requiresPreAuthMeta = const VerificationMeta(
    'requiresPreAuth',
  );
  @override
  late final GeneratedColumn<bool> requiresPreAuth = GeneratedColumn<bool>(
    'requires_pre_auth',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_pre_auth" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _medicolegalAlertMeta = const VerificationMeta(
    'medicolegalAlert',
  );
  @override
  late final GeneratedColumn<String> medicolegalAlert = GeneratedColumn<String>(
    'medicolegal_alert',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiresPreAuth,
    medicolegalAlert,
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
    if (data.containsKey('requires_pre_auth')) {
      context.handle(
        _requiresPreAuthMeta,
        requiresPreAuth.isAcceptableOrUnknown(
          data['requires_pre_auth']!,
          _requiresPreAuthMeta,
        ),
      );
    }
    if (data.containsKey('medicolegal_alert')) {
      context.handle(
        _medicolegalAlertMeta,
        medicolegalAlert.isAcceptableOrUnknown(
          data['medicolegal_alert']!,
          _medicolegalAlertMeta,
        ),
      );
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
      requiresPreAuth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_pre_auth'],
      )!,
      medicolegalAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicolegal_alert'],
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
  final bool requiresPreAuth;
  final String medicolegalAlert;
  final DateTime lastUpdated;
  const CdssRule({
    required this.id,
    required this.targetProblem,
    required this.triggerCondition,
    required this.suggestedAction,
    required this.evidenceSource,
    required this.requiresPreAuth,
    required this.medicolegalAlert,
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
    map['requires_pre_auth'] = Variable<bool>(requiresPreAuth);
    map['medicolegal_alert'] = Variable<String>(medicolegalAlert);
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
      requiresPreAuth: Value(requiresPreAuth),
      medicolegalAlert: Value(medicolegalAlert),
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
      requiresPreAuth: serializer.fromJson<bool>(json['requiresPreAuth']),
      medicolegalAlert: serializer.fromJson<String>(json['medicolegalAlert']),
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
      'requiresPreAuth': serializer.toJson<bool>(requiresPreAuth),
      'medicolegalAlert': serializer.toJson<String>(medicolegalAlert),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  CdssRule copyWith({
    String? id,
    String? targetProblem,
    String? triggerCondition,
    String? suggestedAction,
    String? evidenceSource,
    bool? requiresPreAuth,
    String? medicolegalAlert,
    DateTime? lastUpdated,
  }) => CdssRule(
    id: id ?? this.id,
    targetProblem: targetProblem ?? this.targetProblem,
    triggerCondition: triggerCondition ?? this.triggerCondition,
    suggestedAction: suggestedAction ?? this.suggestedAction,
    evidenceSource: evidenceSource ?? this.evidenceSource,
    requiresPreAuth: requiresPreAuth ?? this.requiresPreAuth,
    medicolegalAlert: medicolegalAlert ?? this.medicolegalAlert,
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
      requiresPreAuth: data.requiresPreAuth.present
          ? data.requiresPreAuth.value
          : this.requiresPreAuth,
      medicolegalAlert: data.medicolegalAlert.present
          ? data.medicolegalAlert.value
          : this.medicolegalAlert,
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
          ..write('requiresPreAuth: $requiresPreAuth, ')
          ..write('medicolegalAlert: $medicolegalAlert, ')
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
    requiresPreAuth,
    medicolegalAlert,
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
          other.requiresPreAuth == this.requiresPreAuth &&
          other.medicolegalAlert == this.medicolegalAlert &&
          other.lastUpdated == this.lastUpdated);
}

class CdssRulesCompanion extends UpdateCompanion<CdssRule> {
  final Value<String> id;
  final Value<String> targetProblem;
  final Value<String> triggerCondition;
  final Value<String> suggestedAction;
  final Value<String> evidenceSource;
  final Value<bool> requiresPreAuth;
  final Value<String> medicolegalAlert;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const CdssRulesCompanion({
    this.id = const Value.absent(),
    this.targetProblem = const Value.absent(),
    this.triggerCondition = const Value.absent(),
    this.suggestedAction = const Value.absent(),
    this.evidenceSource = const Value.absent(),
    this.requiresPreAuth = const Value.absent(),
    this.medicolegalAlert = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CdssRulesCompanion.insert({
    this.id = const Value.absent(),
    required String targetProblem,
    required String triggerCondition,
    required String suggestedAction,
    required String evidenceSource,
    this.requiresPreAuth = const Value.absent(),
    this.medicolegalAlert = const Value.absent(),
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
    Expression<bool>? requiresPreAuth,
    Expression<String>? medicolegalAlert,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetProblem != null) 'target_problem': targetProblem,
      if (triggerCondition != null) 'trigger_condition': triggerCondition,
      if (suggestedAction != null) 'suggested_action': suggestedAction,
      if (evidenceSource != null) 'evidence_source': evidenceSource,
      if (requiresPreAuth != null) 'requires_pre_auth': requiresPreAuth,
      if (medicolegalAlert != null) 'medicolegal_alert': medicolegalAlert,
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
    Value<bool>? requiresPreAuth,
    Value<String>? medicolegalAlert,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return CdssRulesCompanion(
      id: id ?? this.id,
      targetProblem: targetProblem ?? this.targetProblem,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      evidenceSource: evidenceSource ?? this.evidenceSource,
      requiresPreAuth: requiresPreAuth ?? this.requiresPreAuth,
      medicolegalAlert: medicolegalAlert ?? this.medicolegalAlert,
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
    if (requiresPreAuth.present) {
      map['requires_pre_auth'] = Variable<bool>(requiresPreAuth.value);
    }
    if (medicolegalAlert.present) {
      map['medicolegal_alert'] = Variable<String>(medicolegalAlert.value);
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
          ..write('requiresPreAuth: $requiresPreAuth, ')
          ..write('medicolegalAlert: $medicolegalAlert, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AyushmanPackagesTable extends AyushmanPackages
    with TableInfo<$AyushmanPackagesTable, AyushmanPackage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyushmanPackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stratificationMeta = const VerificationMeta(
    'stratification',
  );
  @override
  late final GeneratedColumn<String> stratification = GeneratedColumn<String>(
    'stratification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    packageName,
    stratification,
    rate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayushman_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyushmanPackage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('stratification')) {
      context.handle(
        _stratificationMeta,
        stratification.isAcceptableOrUnknown(
          data['stratification']!,
          _stratificationMeta,
        ),
      );
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  AyushmanPackage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyushmanPackage(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      stratification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stratification'],
      ),
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      ),
    );
  }

  @override
  $AyushmanPackagesTable createAlias(String alias) {
    return $AyushmanPackagesTable(attachedDatabase, alias);
  }
}

class AyushmanPackage extends DataClass implements Insertable<AyushmanPackage> {
  final String code;
  final String packageName;
  final String? stratification;
  final double? rate;
  const AyushmanPackage({
    required this.code,
    required this.packageName,
    this.stratification,
    this.rate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['package_name'] = Variable<String>(packageName);
    if (!nullToAbsent || stratification != null) {
      map['stratification'] = Variable<String>(stratification);
    }
    if (!nullToAbsent || rate != null) {
      map['rate'] = Variable<double>(rate);
    }
    return map;
  }

  AyushmanPackagesCompanion toCompanion(bool nullToAbsent) {
    return AyushmanPackagesCompanion(
      code: Value(code),
      packageName: Value(packageName),
      stratification: stratification == null && nullToAbsent
          ? const Value.absent()
          : Value(stratification),
      rate: rate == null && nullToAbsent ? const Value.absent() : Value(rate),
    );
  }

  factory AyushmanPackage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyushmanPackage(
      code: serializer.fromJson<String>(json['code']),
      packageName: serializer.fromJson<String>(json['packageName']),
      stratification: serializer.fromJson<String?>(json['stratification']),
      rate: serializer.fromJson<double?>(json['rate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'packageName': serializer.toJson<String>(packageName),
      'stratification': serializer.toJson<String?>(stratification),
      'rate': serializer.toJson<double?>(rate),
    };
  }

  AyushmanPackage copyWith({
    String? code,
    String? packageName,
    Value<String?> stratification = const Value.absent(),
    Value<double?> rate = const Value.absent(),
  }) => AyushmanPackage(
    code: code ?? this.code,
    packageName: packageName ?? this.packageName,
    stratification: stratification.present
        ? stratification.value
        : this.stratification,
    rate: rate.present ? rate.value : this.rate,
  );
  AyushmanPackage copyWithCompanion(AyushmanPackagesCompanion data) {
    return AyushmanPackage(
      code: data.code.present ? data.code.value : this.code,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      stratification: data.stratification.present
          ? data.stratification.value
          : this.stratification,
      rate: data.rate.present ? data.rate.value : this.rate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyushmanPackage(')
          ..write('code: $code, ')
          ..write('packageName: $packageName, ')
          ..write('stratification: $stratification, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, packageName, stratification, rate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyushmanPackage &&
          other.code == this.code &&
          other.packageName == this.packageName &&
          other.stratification == this.stratification &&
          other.rate == this.rate);
}

class AyushmanPackagesCompanion extends UpdateCompanion<AyushmanPackage> {
  final Value<String> code;
  final Value<String> packageName;
  final Value<String?> stratification;
  final Value<double?> rate;
  final Value<int> rowid;
  const AyushmanPackagesCompanion({
    this.code = const Value.absent(),
    this.packageName = const Value.absent(),
    this.stratification = const Value.absent(),
    this.rate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyushmanPackagesCompanion.insert({
    required String code,
    required String packageName,
    this.stratification = const Value.absent(),
    this.rate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       packageName = Value(packageName);
  static Insertable<AyushmanPackage> custom({
    Expression<String>? code,
    Expression<String>? packageName,
    Expression<String>? stratification,
    Expression<double>? rate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (packageName != null) 'package_name': packageName,
      if (stratification != null) 'stratification': stratification,
      if (rate != null) 'rate': rate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyushmanPackagesCompanion copyWith({
    Value<String>? code,
    Value<String>? packageName,
    Value<String?>? stratification,
    Value<double?>? rate,
    Value<int>? rowid,
  }) {
    return AyushmanPackagesCompanion(
      code: code ?? this.code,
      packageName: packageName ?? this.packageName,
      stratification: stratification ?? this.stratification,
      rate: rate ?? this.rate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (stratification.present) {
      map['stratification'] = Variable<String>(stratification.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyushmanPackagesCompanion(')
          ..write('code: $code, ')
          ..write('packageName: $packageName, ')
          ..write('stratification: $stratification, ')
          ..write('rate: $rate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HbpProceduresTable extends HbpProcedures
    with TableInfo<$HbpProceduresTable, HbpProcedure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HbpProceduresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _procedureCodeMeta = const VerificationMeta(
    'procedureCode',
  );
  @override
  late final GeneratedColumn<String> procedureCode = GeneratedColumn<String>(
    'procedure_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _procedureNameMeta = const VerificationMeta(
    'procedureName',
  );
  @override
  late final GeneratedColumn<String> procedureName = GeneratedColumn<String>(
    'procedure_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    procedureCode,
    packageName,
    procedureName,
    rate,
    specialty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hbp_procedures';
  @override
  VerificationContext validateIntegrity(
    Insertable<HbpProcedure> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('procedure_code')) {
      context.handle(
        _procedureCodeMeta,
        procedureCode.isAcceptableOrUnknown(
          data['procedure_code']!,
          _procedureCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_procedureCodeMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('procedure_name')) {
      context.handle(
        _procedureNameMeta,
        procedureName.isAcceptableOrUnknown(
          data['procedure_name']!,
          _procedureNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_procedureNameMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    }
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {procedureCode};
  @override
  HbpProcedure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HbpProcedure(
      procedureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure_code'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      procedureName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure_name'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      ),
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      )!,
    );
  }

  @override
  $HbpProceduresTable createAlias(String alias) {
    return $HbpProceduresTable(attachedDatabase, alias);
  }
}

class HbpProcedure extends DataClass implements Insertable<HbpProcedure> {
  final String procedureCode;
  final String packageName;
  final String procedureName;
  final double? rate;
  final String specialty;
  const HbpProcedure({
    required this.procedureCode,
    required this.packageName,
    required this.procedureName,
    this.rate,
    required this.specialty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['procedure_code'] = Variable<String>(procedureCode);
    map['package_name'] = Variable<String>(packageName);
    map['procedure_name'] = Variable<String>(procedureName);
    if (!nullToAbsent || rate != null) {
      map['rate'] = Variable<double>(rate);
    }
    map['specialty'] = Variable<String>(specialty);
    return map;
  }

  HbpProceduresCompanion toCompanion(bool nullToAbsent) {
    return HbpProceduresCompanion(
      procedureCode: Value(procedureCode),
      packageName: Value(packageName),
      procedureName: Value(procedureName),
      rate: rate == null && nullToAbsent ? const Value.absent() : Value(rate),
      specialty: Value(specialty),
    );
  }

  factory HbpProcedure.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HbpProcedure(
      procedureCode: serializer.fromJson<String>(json['procedureCode']),
      packageName: serializer.fromJson<String>(json['packageName']),
      procedureName: serializer.fromJson<String>(json['procedureName']),
      rate: serializer.fromJson<double?>(json['rate']),
      specialty: serializer.fromJson<String>(json['specialty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'procedureCode': serializer.toJson<String>(procedureCode),
      'packageName': serializer.toJson<String>(packageName),
      'procedureName': serializer.toJson<String>(procedureName),
      'rate': serializer.toJson<double?>(rate),
      'specialty': serializer.toJson<String>(specialty),
    };
  }

  HbpProcedure copyWith({
    String? procedureCode,
    String? packageName,
    String? procedureName,
    Value<double?> rate = const Value.absent(),
    String? specialty,
  }) => HbpProcedure(
    procedureCode: procedureCode ?? this.procedureCode,
    packageName: packageName ?? this.packageName,
    procedureName: procedureName ?? this.procedureName,
    rate: rate.present ? rate.value : this.rate,
    specialty: specialty ?? this.specialty,
  );
  HbpProcedure copyWithCompanion(HbpProceduresCompanion data) {
    return HbpProcedure(
      procedureCode: data.procedureCode.present
          ? data.procedureCode.value
          : this.procedureCode,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      procedureName: data.procedureName.present
          ? data.procedureName.value
          : this.procedureName,
      rate: data.rate.present ? data.rate.value : this.rate,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HbpProcedure(')
          ..write('procedureCode: $procedureCode, ')
          ..write('packageName: $packageName, ')
          ..write('procedureName: $procedureName, ')
          ..write('rate: $rate, ')
          ..write('specialty: $specialty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(procedureCode, packageName, procedureName, rate, specialty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HbpProcedure &&
          other.procedureCode == this.procedureCode &&
          other.packageName == this.packageName &&
          other.procedureName == this.procedureName &&
          other.rate == this.rate &&
          other.specialty == this.specialty);
}

class HbpProceduresCompanion extends UpdateCompanion<HbpProcedure> {
  final Value<String> procedureCode;
  final Value<String> packageName;
  final Value<String> procedureName;
  final Value<double?> rate;
  final Value<String> specialty;
  final Value<int> rowid;
  const HbpProceduresCompanion({
    this.procedureCode = const Value.absent(),
    this.packageName = const Value.absent(),
    this.procedureName = const Value.absent(),
    this.rate = const Value.absent(),
    this.specialty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HbpProceduresCompanion.insert({
    required String procedureCode,
    required String packageName,
    required String procedureName,
    this.rate = const Value.absent(),
    this.specialty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : procedureCode = Value(procedureCode),
       packageName = Value(packageName),
       procedureName = Value(procedureName);
  static Insertable<HbpProcedure> custom({
    Expression<String>? procedureCode,
    Expression<String>? packageName,
    Expression<String>? procedureName,
    Expression<double>? rate,
    Expression<String>? specialty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (procedureCode != null) 'procedure_code': procedureCode,
      if (packageName != null) 'package_name': packageName,
      if (procedureName != null) 'procedure_name': procedureName,
      if (rate != null) 'rate': rate,
      if (specialty != null) 'specialty': specialty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HbpProceduresCompanion copyWith({
    Value<String>? procedureCode,
    Value<String>? packageName,
    Value<String>? procedureName,
    Value<double?>? rate,
    Value<String>? specialty,
    Value<int>? rowid,
  }) {
    return HbpProceduresCompanion(
      procedureCode: procedureCode ?? this.procedureCode,
      packageName: packageName ?? this.packageName,
      procedureName: procedureName ?? this.procedureName,
      rate: rate ?? this.rate,
      specialty: specialty ?? this.specialty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (procedureCode.present) {
      map['procedure_code'] = Variable<String>(procedureCode.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (procedureName.present) {
      map['procedure_name'] = Variable<String>(procedureName.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HbpProceduresCompanion(')
          ..write('procedureCode: $procedureCode, ')
          ..write('packageName: $packageName, ')
          ..write('procedureName: $procedureName, ')
          ..write('rate: $rate, ')
          ..write('specialty: $specialty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HbpImplantsTable extends HbpImplants
    with TableInfo<$HbpImplantsTable, HbpImplant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HbpImplantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _procedureCodeMeta = const VerificationMeta(
    'procedureCode',
  );
  @override
  late final GeneratedColumn<String> procedureCode = GeneratedColumn<String>(
    'procedure_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _implantCodeMeta = const VerificationMeta(
    'implantCode',
  );
  @override
  late final GeneratedColumn<String> implantCode = GeneratedColumn<String>(
    'implant_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _implantNameMeta = const VerificationMeta(
    'implantName',
  );
  @override
  late final GeneratedColumn<String> implantName = GeneratedColumn<String>(
    'implant_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maximumPriceMeta = const VerificationMeta(
    'maximumPrice',
  );
  @override
  late final GeneratedColumn<double> maximumPrice = GeneratedColumn<double>(
    'maximum_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    procedureCode,
    implantCode,
    implantName,
    maximumPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hbp_implants';
  @override
  VerificationContext validateIntegrity(
    Insertable<HbpImplant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('procedure_code')) {
      context.handle(
        _procedureCodeMeta,
        procedureCode.isAcceptableOrUnknown(
          data['procedure_code']!,
          _procedureCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_procedureCodeMeta);
    }
    if (data.containsKey('implant_code')) {
      context.handle(
        _implantCodeMeta,
        implantCode.isAcceptableOrUnknown(
          data['implant_code']!,
          _implantCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_implantCodeMeta);
    }
    if (data.containsKey('implant_name')) {
      context.handle(
        _implantNameMeta,
        implantName.isAcceptableOrUnknown(
          data['implant_name']!,
          _implantNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_implantNameMeta);
    }
    if (data.containsKey('maximum_price')) {
      context.handle(
        _maximumPriceMeta,
        maximumPrice.isAcceptableOrUnknown(
          data['maximum_price']!,
          _maximumPriceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HbpImplant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HbpImplant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      procedureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure_code'],
      )!,
      implantCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}implant_code'],
      )!,
      implantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}implant_name'],
      )!,
      maximumPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}maximum_price'],
      ),
    );
  }

  @override
  $HbpImplantsTable createAlias(String alias) {
    return $HbpImplantsTable(attachedDatabase, alias);
  }
}

class HbpImplant extends DataClass implements Insertable<HbpImplant> {
  final int id;
  final String procedureCode;
  final String implantCode;
  final String implantName;
  final double? maximumPrice;
  const HbpImplant({
    required this.id,
    required this.procedureCode,
    required this.implantCode,
    required this.implantName,
    this.maximumPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['procedure_code'] = Variable<String>(procedureCode);
    map['implant_code'] = Variable<String>(implantCode);
    map['implant_name'] = Variable<String>(implantName);
    if (!nullToAbsent || maximumPrice != null) {
      map['maximum_price'] = Variable<double>(maximumPrice);
    }
    return map;
  }

  HbpImplantsCompanion toCompanion(bool nullToAbsent) {
    return HbpImplantsCompanion(
      id: Value(id),
      procedureCode: Value(procedureCode),
      implantCode: Value(implantCode),
      implantName: Value(implantName),
      maximumPrice: maximumPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumPrice),
    );
  }

  factory HbpImplant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HbpImplant(
      id: serializer.fromJson<int>(json['id']),
      procedureCode: serializer.fromJson<String>(json['procedureCode']),
      implantCode: serializer.fromJson<String>(json['implantCode']),
      implantName: serializer.fromJson<String>(json['implantName']),
      maximumPrice: serializer.fromJson<double?>(json['maximumPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'procedureCode': serializer.toJson<String>(procedureCode),
      'implantCode': serializer.toJson<String>(implantCode),
      'implantName': serializer.toJson<String>(implantName),
      'maximumPrice': serializer.toJson<double?>(maximumPrice),
    };
  }

  HbpImplant copyWith({
    int? id,
    String? procedureCode,
    String? implantCode,
    String? implantName,
    Value<double?> maximumPrice = const Value.absent(),
  }) => HbpImplant(
    id: id ?? this.id,
    procedureCode: procedureCode ?? this.procedureCode,
    implantCode: implantCode ?? this.implantCode,
    implantName: implantName ?? this.implantName,
    maximumPrice: maximumPrice.present ? maximumPrice.value : this.maximumPrice,
  );
  HbpImplant copyWithCompanion(HbpImplantsCompanion data) {
    return HbpImplant(
      id: data.id.present ? data.id.value : this.id,
      procedureCode: data.procedureCode.present
          ? data.procedureCode.value
          : this.procedureCode,
      implantCode: data.implantCode.present
          ? data.implantCode.value
          : this.implantCode,
      implantName: data.implantName.present
          ? data.implantName.value
          : this.implantName,
      maximumPrice: data.maximumPrice.present
          ? data.maximumPrice.value
          : this.maximumPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HbpImplant(')
          ..write('id: $id, ')
          ..write('procedureCode: $procedureCode, ')
          ..write('implantCode: $implantCode, ')
          ..write('implantName: $implantName, ')
          ..write('maximumPrice: $maximumPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, procedureCode, implantCode, implantName, maximumPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HbpImplant &&
          other.id == this.id &&
          other.procedureCode == this.procedureCode &&
          other.implantCode == this.implantCode &&
          other.implantName == this.implantName &&
          other.maximumPrice == this.maximumPrice);
}

class HbpImplantsCompanion extends UpdateCompanion<HbpImplant> {
  final Value<int> id;
  final Value<String> procedureCode;
  final Value<String> implantCode;
  final Value<String> implantName;
  final Value<double?> maximumPrice;
  const HbpImplantsCompanion({
    this.id = const Value.absent(),
    this.procedureCode = const Value.absent(),
    this.implantCode = const Value.absent(),
    this.implantName = const Value.absent(),
    this.maximumPrice = const Value.absent(),
  });
  HbpImplantsCompanion.insert({
    this.id = const Value.absent(),
    required String procedureCode,
    required String implantCode,
    required String implantName,
    this.maximumPrice = const Value.absent(),
  }) : procedureCode = Value(procedureCode),
       implantCode = Value(implantCode),
       implantName = Value(implantName);
  static Insertable<HbpImplant> custom({
    Expression<int>? id,
    Expression<String>? procedureCode,
    Expression<String>? implantCode,
    Expression<String>? implantName,
    Expression<double>? maximumPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (procedureCode != null) 'procedure_code': procedureCode,
      if (implantCode != null) 'implant_code': implantCode,
      if (implantName != null) 'implant_name': implantName,
      if (maximumPrice != null) 'maximum_price': maximumPrice,
    });
  }

  HbpImplantsCompanion copyWith({
    Value<int>? id,
    Value<String>? procedureCode,
    Value<String>? implantCode,
    Value<String>? implantName,
    Value<double?>? maximumPrice,
  }) {
    return HbpImplantsCompanion(
      id: id ?? this.id,
      procedureCode: procedureCode ?? this.procedureCode,
      implantCode: implantCode ?? this.implantCode,
      implantName: implantName ?? this.implantName,
      maximumPrice: maximumPrice ?? this.maximumPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (procedureCode.present) {
      map['procedure_code'] = Variable<String>(procedureCode.value);
    }
    if (implantCode.present) {
      map['implant_code'] = Variable<String>(implantCode.value);
    }
    if (implantName.present) {
      map['implant_name'] = Variable<String>(implantName.value);
    }
    if (maximumPrice.present) {
      map['maximum_price'] = Variable<double>(maximumPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HbpImplantsCompanion(')
          ..write('id: $id, ')
          ..write('procedureCode: $procedureCode, ')
          ..write('implantCode: $implantCode, ')
          ..write('implantName: $implantName, ')
          ..write('maximumPrice: $maximumPrice')
          ..write(')'))
        .toString();
  }
}

class $HbpStratificationsTable extends HbpStratifications
    with TableInfo<$HbpStratificationsTable, HbpStratification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HbpStratificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _procedureCodeMeta = const VerificationMeta(
    'procedureCode',
  );
  @override
  late final GeneratedColumn<String> procedureCode = GeneratedColumn<String>(
    'procedure_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stratificationCodeMeta =
      const VerificationMeta('stratificationCode');
  @override
  late final GeneratedColumn<String> stratificationCode =
      GeneratedColumn<String>(
        'stratification_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stratificationNameMeta =
      const VerificationMeta('stratificationName');
  @override
  late final GeneratedColumn<String> stratificationName =
      GeneratedColumn<String>(
        'stratification_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ruleMeta = const VerificationMeta('rule');
  @override
  late final GeneratedColumn<String> rule = GeneratedColumn<String>(
    'rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    procedureCode,
    stratificationCode,
    stratificationName,
    rule,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hbp_stratifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<HbpStratification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('procedure_code')) {
      context.handle(
        _procedureCodeMeta,
        procedureCode.isAcceptableOrUnknown(
          data['procedure_code']!,
          _procedureCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_procedureCodeMeta);
    }
    if (data.containsKey('stratification_code')) {
      context.handle(
        _stratificationCodeMeta,
        stratificationCode.isAcceptableOrUnknown(
          data['stratification_code']!,
          _stratificationCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stratificationCodeMeta);
    }
    if (data.containsKey('stratification_name')) {
      context.handle(
        _stratificationNameMeta,
        stratificationName.isAcceptableOrUnknown(
          data['stratification_name']!,
          _stratificationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stratificationNameMeta);
    }
    if (data.containsKey('rule')) {
      context.handle(
        _ruleMeta,
        rule.isAcceptableOrUnknown(data['rule']!, _ruleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HbpStratification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HbpStratification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      procedureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure_code'],
      )!,
      stratificationCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stratification_code'],
      )!,
      stratificationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stratification_name'],
      )!,
      rule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule'],
      )!,
    );
  }

  @override
  $HbpStratificationsTable createAlias(String alias) {
    return $HbpStratificationsTable(attachedDatabase, alias);
  }
}

class HbpStratification extends DataClass
    implements Insertable<HbpStratification> {
  final int id;
  final String procedureCode;
  final String stratificationCode;
  final String stratificationName;
  final String rule;
  const HbpStratification({
    required this.id,
    required this.procedureCode,
    required this.stratificationCode,
    required this.stratificationName,
    required this.rule,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['procedure_code'] = Variable<String>(procedureCode);
    map['stratification_code'] = Variable<String>(stratificationCode);
    map['stratification_name'] = Variable<String>(stratificationName);
    map['rule'] = Variable<String>(rule);
    return map;
  }

  HbpStratificationsCompanion toCompanion(bool nullToAbsent) {
    return HbpStratificationsCompanion(
      id: Value(id),
      procedureCode: Value(procedureCode),
      stratificationCode: Value(stratificationCode),
      stratificationName: Value(stratificationName),
      rule: Value(rule),
    );
  }

  factory HbpStratification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HbpStratification(
      id: serializer.fromJson<int>(json['id']),
      procedureCode: serializer.fromJson<String>(json['procedureCode']),
      stratificationCode: serializer.fromJson<String>(
        json['stratificationCode'],
      ),
      stratificationName: serializer.fromJson<String>(
        json['stratificationName'],
      ),
      rule: serializer.fromJson<String>(json['rule']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'procedureCode': serializer.toJson<String>(procedureCode),
      'stratificationCode': serializer.toJson<String>(stratificationCode),
      'stratificationName': serializer.toJson<String>(stratificationName),
      'rule': serializer.toJson<String>(rule),
    };
  }

  HbpStratification copyWith({
    int? id,
    String? procedureCode,
    String? stratificationCode,
    String? stratificationName,
    String? rule,
  }) => HbpStratification(
    id: id ?? this.id,
    procedureCode: procedureCode ?? this.procedureCode,
    stratificationCode: stratificationCode ?? this.stratificationCode,
    stratificationName: stratificationName ?? this.stratificationName,
    rule: rule ?? this.rule,
  );
  HbpStratification copyWithCompanion(HbpStratificationsCompanion data) {
    return HbpStratification(
      id: data.id.present ? data.id.value : this.id,
      procedureCode: data.procedureCode.present
          ? data.procedureCode.value
          : this.procedureCode,
      stratificationCode: data.stratificationCode.present
          ? data.stratificationCode.value
          : this.stratificationCode,
      stratificationName: data.stratificationName.present
          ? data.stratificationName.value
          : this.stratificationName,
      rule: data.rule.present ? data.rule.value : this.rule,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HbpStratification(')
          ..write('id: $id, ')
          ..write('procedureCode: $procedureCode, ')
          ..write('stratificationCode: $stratificationCode, ')
          ..write('stratificationName: $stratificationName, ')
          ..write('rule: $rule')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    procedureCode,
    stratificationCode,
    stratificationName,
    rule,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HbpStratification &&
          other.id == this.id &&
          other.procedureCode == this.procedureCode &&
          other.stratificationCode == this.stratificationCode &&
          other.stratificationName == this.stratificationName &&
          other.rule == this.rule);
}

class HbpStratificationsCompanion extends UpdateCompanion<HbpStratification> {
  final Value<int> id;
  final Value<String> procedureCode;
  final Value<String> stratificationCode;
  final Value<String> stratificationName;
  final Value<String> rule;
  const HbpStratificationsCompanion({
    this.id = const Value.absent(),
    this.procedureCode = const Value.absent(),
    this.stratificationCode = const Value.absent(),
    this.stratificationName = const Value.absent(),
    this.rule = const Value.absent(),
  });
  HbpStratificationsCompanion.insert({
    this.id = const Value.absent(),
    required String procedureCode,
    required String stratificationCode,
    required String stratificationName,
    this.rule = const Value.absent(),
  }) : procedureCode = Value(procedureCode),
       stratificationCode = Value(stratificationCode),
       stratificationName = Value(stratificationName);
  static Insertable<HbpStratification> custom({
    Expression<int>? id,
    Expression<String>? procedureCode,
    Expression<String>? stratificationCode,
    Expression<String>? stratificationName,
    Expression<String>? rule,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (procedureCode != null) 'procedure_code': procedureCode,
      if (stratificationCode != null) 'stratification_code': stratificationCode,
      if (stratificationName != null) 'stratification_name': stratificationName,
      if (rule != null) 'rule': rule,
    });
  }

  HbpStratificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? procedureCode,
    Value<String>? stratificationCode,
    Value<String>? stratificationName,
    Value<String>? rule,
  }) {
    return HbpStratificationsCompanion(
      id: id ?? this.id,
      procedureCode: procedureCode ?? this.procedureCode,
      stratificationCode: stratificationCode ?? this.stratificationCode,
      stratificationName: stratificationName ?? this.stratificationName,
      rule: rule ?? this.rule,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (procedureCode.present) {
      map['procedure_code'] = Variable<String>(procedureCode.value);
    }
    if (stratificationCode.present) {
      map['stratification_code'] = Variable<String>(stratificationCode.value);
    }
    if (stratificationName.present) {
      map['stratification_name'] = Variable<String>(stratificationName.value);
    }
    if (rule.present) {
      map['rule'] = Variable<String>(rule.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HbpStratificationsCompanion(')
          ..write('id: $id, ')
          ..write('procedureCode: $procedureCode, ')
          ..write('stratificationCode: $stratificationCode, ')
          ..write('stratificationName: $stratificationName, ')
          ..write('rule: $rule')
          ..write(')'))
        .toString();
  }
}

class $DocumentRegistriesTable extends DocumentRegistries
    with TableInfo<$DocumentRegistriesTable, DocumentRegistry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentRegistriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _documentCategoryMeta = const VerificationMeta(
    'documentCategory',
  );
  @override
  late final GeneratedColumn<String> documentCategory = GeneratedColumn<String>(
    'document_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawOcrTranscriptMeta = const VerificationMeta(
    'rawOcrTranscript',
  );
  @override
  late final GeneratedColumn<String> rawOcrTranscript = GeneratedColumn<String>(
    'raw_ocr_transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _documentedAtMeta = const VerificationMeta(
    'documentedAt',
  );
  @override
  late final GeneratedColumn<DateTime> documentedAt = GeneratedColumn<DateTime>(
    'documented_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    documentCategory,
    imagePath,
    rawOcrTranscript,
    confidenceScore,
    documentedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_registries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRegistry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('document_category')) {
      context.handle(
        _documentCategoryMeta,
        documentCategory.isAcceptableOrUnknown(
          data['document_category']!,
          _documentCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentCategoryMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('raw_ocr_transcript')) {
      context.handle(
        _rawOcrTranscriptMeta,
        rawOcrTranscript.isAcceptableOrUnknown(
          data['raw_ocr_transcript']!,
          _rawOcrTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    }
    if (data.containsKey('documented_at')) {
      context.handle(
        _documentedAtMeta,
        documentedAt.isAcceptableOrUnknown(
          data['documented_at']!,
          _documentedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRegistry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRegistry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      documentCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_category'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      rawOcrTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_ocr_transcript'],
      )!,
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_score'],
      )!,
      documentedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}documented_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DocumentRegistriesTable createAlias(String alias) {
    return $DocumentRegistriesTable(attachedDatabase, alias);
  }
}

class DocumentRegistry extends DataClass
    implements Insertable<DocumentRegistry> {
  final String id;
  final String patientId;
  final String documentCategory;
  final String imagePath;
  final String rawOcrTranscript;
  final double confidenceScore;
  final DateTime documentedAt;
  final DateTime createdAt;
  const DocumentRegistry({
    required this.id,
    required this.patientId,
    required this.documentCategory,
    required this.imagePath,
    required this.rawOcrTranscript,
    required this.confidenceScore,
    required this.documentedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['document_category'] = Variable<String>(documentCategory);
    map['image_path'] = Variable<String>(imagePath);
    map['raw_ocr_transcript'] = Variable<String>(rawOcrTranscript);
    map['confidence_score'] = Variable<double>(confidenceScore);
    map['documented_at'] = Variable<DateTime>(documentedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentRegistriesCompanion toCompanion(bool nullToAbsent) {
    return DocumentRegistriesCompanion(
      id: Value(id),
      patientId: Value(patientId),
      documentCategory: Value(documentCategory),
      imagePath: Value(imagePath),
      rawOcrTranscript: Value(rawOcrTranscript),
      confidenceScore: Value(confidenceScore),
      documentedAt: Value(documentedAt),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentRegistry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRegistry(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      documentCategory: serializer.fromJson<String>(json['documentCategory']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      rawOcrTranscript: serializer.fromJson<String>(json['rawOcrTranscript']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
      documentedAt: serializer.fromJson<DateTime>(json['documentedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'documentCategory': serializer.toJson<String>(documentCategory),
      'imagePath': serializer.toJson<String>(imagePath),
      'rawOcrTranscript': serializer.toJson<String>(rawOcrTranscript),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
      'documentedAt': serializer.toJson<DateTime>(documentedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentRegistry copyWith({
    String? id,
    String? patientId,
    String? documentCategory,
    String? imagePath,
    String? rawOcrTranscript,
    double? confidenceScore,
    DateTime? documentedAt,
    DateTime? createdAt,
  }) => DocumentRegistry(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    documentCategory: documentCategory ?? this.documentCategory,
    imagePath: imagePath ?? this.imagePath,
    rawOcrTranscript: rawOcrTranscript ?? this.rawOcrTranscript,
    confidenceScore: confidenceScore ?? this.confidenceScore,
    documentedAt: documentedAt ?? this.documentedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentRegistry copyWithCompanion(DocumentRegistriesCompanion data) {
    return DocumentRegistry(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      documentCategory: data.documentCategory.present
          ? data.documentCategory.value
          : this.documentCategory,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      rawOcrTranscript: data.rawOcrTranscript.present
          ? data.rawOcrTranscript.value
          : this.rawOcrTranscript,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      documentedAt: data.documentedAt.present
          ? data.documentedAt.value
          : this.documentedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRegistry(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentCategory: $documentCategory, ')
          ..write('imagePath: $imagePath, ')
          ..write('rawOcrTranscript: $rawOcrTranscript, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('documentedAt: $documentedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    documentCategory,
    imagePath,
    rawOcrTranscript,
    confidenceScore,
    documentedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRegistry &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.documentCategory == this.documentCategory &&
          other.imagePath == this.imagePath &&
          other.rawOcrTranscript == this.rawOcrTranscript &&
          other.confidenceScore == this.confidenceScore &&
          other.documentedAt == this.documentedAt &&
          other.createdAt == this.createdAt);
}

class DocumentRegistriesCompanion extends UpdateCompanion<DocumentRegistry> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> documentCategory;
  final Value<String> imagePath;
  final Value<String> rawOcrTranscript;
  final Value<double> confidenceScore;
  final Value<DateTime> documentedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DocumentRegistriesCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.documentCategory = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rawOcrTranscript = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.documentedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentRegistriesCompanion.insert({
    required String id,
    required String patientId,
    required String documentCategory,
    required String imagePath,
    this.rawOcrTranscript = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    required DateTime documentedAt,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       documentCategory = Value(documentCategory),
       imagePath = Value(imagePath),
       documentedAt = Value(documentedAt);
  static Insertable<DocumentRegistry> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? documentCategory,
    Expression<String>? imagePath,
    Expression<String>? rawOcrTranscript,
    Expression<double>? confidenceScore,
    Expression<DateTime>? documentedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (documentCategory != null) 'document_category': documentCategory,
      if (imagePath != null) 'image_path': imagePath,
      if (rawOcrTranscript != null) 'raw_ocr_transcript': rawOcrTranscript,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (documentedAt != null) 'documented_at': documentedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentRegistriesCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? documentCategory,
    Value<String>? imagePath,
    Value<String>? rawOcrTranscript,
    Value<double>? confidenceScore,
    Value<DateTime>? documentedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DocumentRegistriesCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      documentCategory: documentCategory ?? this.documentCategory,
      imagePath: imagePath ?? this.imagePath,
      rawOcrTranscript: rawOcrTranscript ?? this.rawOcrTranscript,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      documentedAt: documentedAt ?? this.documentedAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (documentCategory.present) {
      map['document_category'] = Variable<String>(documentCategory.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rawOcrTranscript.present) {
      map['raw_ocr_transcript'] = Variable<String>(rawOcrTranscript.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (documentedAt.present) {
      map['documented_at'] = Variable<DateTime>(documentedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRegistriesCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentCategory: $documentCategory, ')
          ..write('imagePath: $imagePath, ')
          ..write('rawOcrTranscript: $rawOcrTranscript, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('documentedAt: $documentedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClinicalObservationsTable extends ClinicalObservations
    with TableInfo<$ClinicalObservationsTable, ClinicalObservation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_registries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _observationCategoryMeta =
      const VerificationMeta('observationCategory');
  @override
  late final GeneratedColumn<String> observationCategory =
      GeneratedColumn<String>(
        'observation_category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numericValueMeta = const VerificationMeta(
    'numericValue',
  );
  @override
  late final GeneratedColumn<double> numericValue = GeneratedColumn<double>(
    'numeric_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceLowMeta = const VerificationMeta(
    'referenceLow',
  );
  @override
  late final GeneratedColumn<double> referenceLow = GeneratedColumn<double>(
    'reference_low',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceHighMeta = const VerificationMeta(
    'referenceHigh',
  );
  @override
  late final GeneratedColumn<double> referenceHigh = GeneratedColumn<double>(
    'reference_high',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAbnormalMeta = const VerificationMeta(
    'isAbnormal',
  );
  @override
  late final GeneratedColumn<bool> isAbnormal = GeneratedColumn<bool>(
    'is_abnormal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_abnormal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _corroborationNoteMeta = const VerificationMeta(
    'corroborationNote',
  );
  @override
  late final GeneratedColumn<String> corroborationNote =
      GeneratedColumn<String>(
        'corroboration_note',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    documentId,
    observationCategory,
    code,
    displayName,
    numericValue,
    textValue,
    unit,
    referenceLow,
    referenceHigh,
    isAbnormal,
    recordedAt,
    corroborationNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClinicalObservation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('observation_category')) {
      context.handle(
        _observationCategoryMeta,
        observationCategory.isAcceptableOrUnknown(
          data['observation_category']!,
          _observationCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationCategoryMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('numeric_value')) {
      context.handle(
        _numericValueMeta,
        numericValue.isAcceptableOrUnknown(
          data['numeric_value']!,
          _numericValueMeta,
        ),
      );
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('reference_low')) {
      context.handle(
        _referenceLowMeta,
        referenceLow.isAcceptableOrUnknown(
          data['reference_low']!,
          _referenceLowMeta,
        ),
      );
    }
    if (data.containsKey('reference_high')) {
      context.handle(
        _referenceHighMeta,
        referenceHigh.isAcceptableOrUnknown(
          data['reference_high']!,
          _referenceHighMeta,
        ),
      );
    }
    if (data.containsKey('is_abnormal')) {
      context.handle(
        _isAbnormalMeta,
        isAbnormal.isAcceptableOrUnknown(data['is_abnormal']!, _isAbnormalMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('corroboration_note')) {
      context.handle(
        _corroborationNoteMeta,
        corroborationNote.isAcceptableOrUnknown(
          data['corroboration_note']!,
          _corroborationNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalObservation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalObservation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      observationCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_category'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      numericValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}numeric_value'],
      ),
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      referenceLow: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_low'],
      ),
      referenceHigh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_high'],
      ),
      isAbnormal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_abnormal'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      corroborationNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corroboration_note'],
      ),
    );
  }

  @override
  $ClinicalObservationsTable createAlias(String alias) {
    return $ClinicalObservationsTable(attachedDatabase, alias);
  }
}

class ClinicalObservation extends DataClass
    implements Insertable<ClinicalObservation> {
  final String id;
  final String patientId;
  final String documentId;
  final String observationCategory;
  final String code;
  final String displayName;
  final double? numericValue;
  final String? textValue;
  final String? unit;
  final double? referenceLow;
  final double? referenceHigh;
  final bool isAbnormal;
  final DateTime recordedAt;
  final String? corroborationNote;
  const ClinicalObservation({
    required this.id,
    required this.patientId,
    required this.documentId,
    required this.observationCategory,
    required this.code,
    required this.displayName,
    this.numericValue,
    this.textValue,
    this.unit,
    this.referenceLow,
    this.referenceHigh,
    required this.isAbnormal,
    required this.recordedAt,
    this.corroborationNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['document_id'] = Variable<String>(documentId);
    map['observation_category'] = Variable<String>(observationCategory);
    map['code'] = Variable<String>(code);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<double>(numericValue);
    }
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || referenceLow != null) {
      map['reference_low'] = Variable<double>(referenceLow);
    }
    if (!nullToAbsent || referenceHigh != null) {
      map['reference_high'] = Variable<double>(referenceHigh);
    }
    map['is_abnormal'] = Variable<bool>(isAbnormal);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || corroborationNote != null) {
      map['corroboration_note'] = Variable<String>(corroborationNote);
    }
    return map;
  }

  ClinicalObservationsCompanion toCompanion(bool nullToAbsent) {
    return ClinicalObservationsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      documentId: Value(documentId),
      observationCategory: Value(observationCategory),
      code: Value(code),
      displayName: Value(displayName),
      numericValue: numericValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numericValue),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      referenceLow: referenceLow == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceLow),
      referenceHigh: referenceHigh == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceHigh),
      isAbnormal: Value(isAbnormal),
      recordedAt: Value(recordedAt),
      corroborationNote: corroborationNote == null && nullToAbsent
          ? const Value.absent()
          : Value(corroborationNote),
    );
  }

  factory ClinicalObservation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalObservation(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      observationCategory: serializer.fromJson<String>(
        json['observationCategory'],
      ),
      code: serializer.fromJson<String>(json['code']),
      displayName: serializer.fromJson<String>(json['displayName']),
      numericValue: serializer.fromJson<double?>(json['numericValue']),
      textValue: serializer.fromJson<String?>(json['textValue']),
      unit: serializer.fromJson<String?>(json['unit']),
      referenceLow: serializer.fromJson<double?>(json['referenceLow']),
      referenceHigh: serializer.fromJson<double?>(json['referenceHigh']),
      isAbnormal: serializer.fromJson<bool>(json['isAbnormal']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      corroborationNote: serializer.fromJson<String?>(
        json['corroborationNote'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'documentId': serializer.toJson<String>(documentId),
      'observationCategory': serializer.toJson<String>(observationCategory),
      'code': serializer.toJson<String>(code),
      'displayName': serializer.toJson<String>(displayName),
      'numericValue': serializer.toJson<double?>(numericValue),
      'textValue': serializer.toJson<String?>(textValue),
      'unit': serializer.toJson<String?>(unit),
      'referenceLow': serializer.toJson<double?>(referenceLow),
      'referenceHigh': serializer.toJson<double?>(referenceHigh),
      'isAbnormal': serializer.toJson<bool>(isAbnormal),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'corroborationNote': serializer.toJson<String?>(corroborationNote),
    };
  }

  ClinicalObservation copyWith({
    String? id,
    String? patientId,
    String? documentId,
    String? observationCategory,
    String? code,
    String? displayName,
    Value<double?> numericValue = const Value.absent(),
    Value<String?> textValue = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<double?> referenceLow = const Value.absent(),
    Value<double?> referenceHigh = const Value.absent(),
    bool? isAbnormal,
    DateTime? recordedAt,
    Value<String?> corroborationNote = const Value.absent(),
  }) => ClinicalObservation(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    documentId: documentId ?? this.documentId,
    observationCategory: observationCategory ?? this.observationCategory,
    code: code ?? this.code,
    displayName: displayName ?? this.displayName,
    numericValue: numericValue.present ? numericValue.value : this.numericValue,
    textValue: textValue.present ? textValue.value : this.textValue,
    unit: unit.present ? unit.value : this.unit,
    referenceLow: referenceLow.present ? referenceLow.value : this.referenceLow,
    referenceHigh: referenceHigh.present
        ? referenceHigh.value
        : this.referenceHigh,
    isAbnormal: isAbnormal ?? this.isAbnormal,
    recordedAt: recordedAt ?? this.recordedAt,
    corroborationNote: corroborationNote.present
        ? corroborationNote.value
        : this.corroborationNote,
  );
  ClinicalObservation copyWithCompanion(ClinicalObservationsCompanion data) {
    return ClinicalObservation(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      observationCategory: data.observationCategory.present
          ? data.observationCategory.value
          : this.observationCategory,
      code: data.code.present ? data.code.value : this.code,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      numericValue: data.numericValue.present
          ? data.numericValue.value
          : this.numericValue,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      referenceLow: data.referenceLow.present
          ? data.referenceLow.value
          : this.referenceLow,
      referenceHigh: data.referenceHigh.present
          ? data.referenceHigh.value
          : this.referenceHigh,
      isAbnormal: data.isAbnormal.present
          ? data.isAbnormal.value
          : this.isAbnormal,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      corroborationNote: data.corroborationNote.present
          ? data.corroborationNote.value
          : this.corroborationNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalObservation(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('observationCategory: $observationCategory, ')
          ..write('code: $code, ')
          ..write('displayName: $displayName, ')
          ..write('numericValue: $numericValue, ')
          ..write('textValue: $textValue, ')
          ..write('unit: $unit, ')
          ..write('referenceLow: $referenceLow, ')
          ..write('referenceHigh: $referenceHigh, ')
          ..write('isAbnormal: $isAbnormal, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('corroborationNote: $corroborationNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    documentId,
    observationCategory,
    code,
    displayName,
    numericValue,
    textValue,
    unit,
    referenceLow,
    referenceHigh,
    isAbnormal,
    recordedAt,
    corroborationNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalObservation &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.documentId == this.documentId &&
          other.observationCategory == this.observationCategory &&
          other.code == this.code &&
          other.displayName == this.displayName &&
          other.numericValue == this.numericValue &&
          other.textValue == this.textValue &&
          other.unit == this.unit &&
          other.referenceLow == this.referenceLow &&
          other.referenceHigh == this.referenceHigh &&
          other.isAbnormal == this.isAbnormal &&
          other.recordedAt == this.recordedAt &&
          other.corroborationNote == this.corroborationNote);
}

class ClinicalObservationsCompanion
    extends UpdateCompanion<ClinicalObservation> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> documentId;
  final Value<String> observationCategory;
  final Value<String> code;
  final Value<String> displayName;
  final Value<double?> numericValue;
  final Value<String?> textValue;
  final Value<String?> unit;
  final Value<double?> referenceLow;
  final Value<double?> referenceHigh;
  final Value<bool> isAbnormal;
  final Value<DateTime> recordedAt;
  final Value<String?> corroborationNote;
  final Value<int> rowid;
  const ClinicalObservationsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.observationCategory = const Value.absent(),
    this.code = const Value.absent(),
    this.displayName = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.referenceLow = const Value.absent(),
    this.referenceHigh = const Value.absent(),
    this.isAbnormal = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.corroborationNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalObservationsCompanion.insert({
    required String id,
    required String patientId,
    required String documentId,
    required String observationCategory,
    required String code,
    required String displayName,
    this.numericValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.referenceLow = const Value.absent(),
    this.referenceHigh = const Value.absent(),
    this.isAbnormal = const Value.absent(),
    required DateTime recordedAt,
    this.corroborationNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       documentId = Value(documentId),
       observationCategory = Value(observationCategory),
       code = Value(code),
       displayName = Value(displayName),
       recordedAt = Value(recordedAt);
  static Insertable<ClinicalObservation> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? documentId,
    Expression<String>? observationCategory,
    Expression<String>? code,
    Expression<String>? displayName,
    Expression<double>? numericValue,
    Expression<String>? textValue,
    Expression<String>? unit,
    Expression<double>? referenceLow,
    Expression<double>? referenceHigh,
    Expression<bool>? isAbnormal,
    Expression<DateTime>? recordedAt,
    Expression<String>? corroborationNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (documentId != null) 'document_id': documentId,
      if (observationCategory != null)
        'observation_category': observationCategory,
      if (code != null) 'code': code,
      if (displayName != null) 'display_name': displayName,
      if (numericValue != null) 'numeric_value': numericValue,
      if (textValue != null) 'text_value': textValue,
      if (unit != null) 'unit': unit,
      if (referenceLow != null) 'reference_low': referenceLow,
      if (referenceHigh != null) 'reference_high': referenceHigh,
      if (isAbnormal != null) 'is_abnormal': isAbnormal,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (corroborationNote != null) 'corroboration_note': corroborationNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? documentId,
    Value<String>? observationCategory,
    Value<String>? code,
    Value<String>? displayName,
    Value<double?>? numericValue,
    Value<String?>? textValue,
    Value<String?>? unit,
    Value<double?>? referenceLow,
    Value<double?>? referenceHigh,
    Value<bool>? isAbnormal,
    Value<DateTime>? recordedAt,
    Value<String?>? corroborationNote,
    Value<int>? rowid,
  }) {
    return ClinicalObservationsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      documentId: documentId ?? this.documentId,
      observationCategory: observationCategory ?? this.observationCategory,
      code: code ?? this.code,
      displayName: displayName ?? this.displayName,
      numericValue: numericValue ?? this.numericValue,
      textValue: textValue ?? this.textValue,
      unit: unit ?? this.unit,
      referenceLow: referenceLow ?? this.referenceLow,
      referenceHigh: referenceHigh ?? this.referenceHigh,
      isAbnormal: isAbnormal ?? this.isAbnormal,
      recordedAt: recordedAt ?? this.recordedAt,
      corroborationNote: corroborationNote ?? this.corroborationNote,
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
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (observationCategory.present) {
      map['observation_category'] = Variable<String>(observationCategory.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (numericValue.present) {
      map['numeric_value'] = Variable<double>(numericValue.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (referenceLow.present) {
      map['reference_low'] = Variable<double>(referenceLow.value);
    }
    if (referenceHigh.present) {
      map['reference_high'] = Variable<double>(referenceHigh.value);
    }
    if (isAbnormal.present) {
      map['is_abnormal'] = Variable<bool>(isAbnormal.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (corroborationNote.present) {
      map['corroboration_note'] = Variable<String>(corroborationNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalObservationsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('observationCategory: $observationCategory, ')
          ..write('code: $code, ')
          ..write('displayName: $displayName, ')
          ..write('numericValue: $numericValue, ')
          ..write('textValue: $textValue, ')
          ..write('unit: $unit, ')
          ..write('referenceLow: $referenceLow, ')
          ..write('referenceHigh: $referenceHigh, ')
          ..write('isAbnormal: $isAbnormal, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('corroborationNote: $corroborationNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrescriptionOrdersTable extends PrescriptionOrders
    with TableInfo<$PrescriptionOrdersTable, PrescriptionOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrescriptionOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_registries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _drugNameMeta = const VerificationMeta(
    'drugName',
  );
  @override
  late final GeneratedColumn<String> drugName = GeneratedColumn<String>(
    'drug_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diluentAndRateMeta = const VerificationMeta(
    'diluentAndRate',
  );
  @override
  late final GeneratedColumn<String> diluentAndRate = GeneratedColumn<String>(
    'diluent_and_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _orderedAtMeta = const VerificationMeta(
    'orderedAt',
  );
  @override
  late final GeneratedColumn<DateTime> orderedAt = GeneratedColumn<DateTime>(
    'ordered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    documentId,
    drugName,
    strength,
    dosageForm,
    route,
    frequency,
    diluentAndRate,
    isActive,
    orderedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prescription_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrescriptionOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('drug_name')) {
      context.handle(
        _drugNameMeta,
        drugName.isAcceptableOrUnknown(data['drug_name']!, _drugNameMeta),
      );
    } else if (isInserting) {
      context.missing(_drugNameMeta);
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
    } else if (isInserting) {
      context.missing(_routeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('diluent_and_rate')) {
      context.handle(
        _diluentAndRateMeta,
        diluentAndRate.isAcceptableOrUnknown(
          data['diluent_and_rate']!,
          _diluentAndRateMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('ordered_at')) {
      context.handle(
        _orderedAtMeta,
        orderedAt.isAcceptableOrUnknown(data['ordered_at']!, _orderedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_orderedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrescriptionOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrescriptionOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      drugName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_name'],
      )!,
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
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      diluentAndRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diluent_and_rate'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      orderedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ordered_at'],
      )!,
    );
  }

  @override
  $PrescriptionOrdersTable createAlias(String alias) {
    return $PrescriptionOrdersTable(attachedDatabase, alias);
  }
}

class PrescriptionOrder extends DataClass
    implements Insertable<PrescriptionOrder> {
  final String id;
  final String patientId;
  final String documentId;
  final String drugName;
  final String? strength;
  final String? dosageForm;
  final String route;
  final String frequency;
  final String? diluentAndRate;
  final bool isActive;
  final DateTime orderedAt;
  const PrescriptionOrder({
    required this.id,
    required this.patientId,
    required this.documentId,
    required this.drugName,
    this.strength,
    this.dosageForm,
    required this.route,
    required this.frequency,
    this.diluentAndRate,
    required this.isActive,
    required this.orderedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['document_id'] = Variable<String>(documentId);
    map['drug_name'] = Variable<String>(drugName);
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    if (!nullToAbsent || dosageForm != null) {
      map['dosage_form'] = Variable<String>(dosageForm);
    }
    map['route'] = Variable<String>(route);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || diluentAndRate != null) {
      map['diluent_and_rate'] = Variable<String>(diluentAndRate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['ordered_at'] = Variable<DateTime>(orderedAt);
    return map;
  }

  PrescriptionOrdersCompanion toCompanion(bool nullToAbsent) {
    return PrescriptionOrdersCompanion(
      id: Value(id),
      patientId: Value(patientId),
      documentId: Value(documentId),
      drugName: Value(drugName),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      dosageForm: dosageForm == null && nullToAbsent
          ? const Value.absent()
          : Value(dosageForm),
      route: Value(route),
      frequency: Value(frequency),
      diluentAndRate: diluentAndRate == null && nullToAbsent
          ? const Value.absent()
          : Value(diluentAndRate),
      isActive: Value(isActive),
      orderedAt: Value(orderedAt),
    );
  }

  factory PrescriptionOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrescriptionOrder(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      drugName: serializer.fromJson<String>(json['drugName']),
      strength: serializer.fromJson<String?>(json['strength']),
      dosageForm: serializer.fromJson<String?>(json['dosageForm']),
      route: serializer.fromJson<String>(json['route']),
      frequency: serializer.fromJson<String>(json['frequency']),
      diluentAndRate: serializer.fromJson<String?>(json['diluentAndRate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      orderedAt: serializer.fromJson<DateTime>(json['orderedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'documentId': serializer.toJson<String>(documentId),
      'drugName': serializer.toJson<String>(drugName),
      'strength': serializer.toJson<String?>(strength),
      'dosageForm': serializer.toJson<String?>(dosageForm),
      'route': serializer.toJson<String>(route),
      'frequency': serializer.toJson<String>(frequency),
      'diluentAndRate': serializer.toJson<String?>(diluentAndRate),
      'isActive': serializer.toJson<bool>(isActive),
      'orderedAt': serializer.toJson<DateTime>(orderedAt),
    };
  }

  PrescriptionOrder copyWith({
    String? id,
    String? patientId,
    String? documentId,
    String? drugName,
    Value<String?> strength = const Value.absent(),
    Value<String?> dosageForm = const Value.absent(),
    String? route,
    String? frequency,
    Value<String?> diluentAndRate = const Value.absent(),
    bool? isActive,
    DateTime? orderedAt,
  }) => PrescriptionOrder(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    documentId: documentId ?? this.documentId,
    drugName: drugName ?? this.drugName,
    strength: strength.present ? strength.value : this.strength,
    dosageForm: dosageForm.present ? dosageForm.value : this.dosageForm,
    route: route ?? this.route,
    frequency: frequency ?? this.frequency,
    diluentAndRate: diluentAndRate.present
        ? diluentAndRate.value
        : this.diluentAndRate,
    isActive: isActive ?? this.isActive,
    orderedAt: orderedAt ?? this.orderedAt,
  );
  PrescriptionOrder copyWithCompanion(PrescriptionOrdersCompanion data) {
    return PrescriptionOrder(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      drugName: data.drugName.present ? data.drugName.value : this.drugName,
      strength: data.strength.present ? data.strength.value : this.strength,
      dosageForm: data.dosageForm.present
          ? data.dosageForm.value
          : this.dosageForm,
      route: data.route.present ? data.route.value : this.route,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      diluentAndRate: data.diluentAndRate.present
          ? data.diluentAndRate.value
          : this.diluentAndRate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      orderedAt: data.orderedAt.present ? data.orderedAt.value : this.orderedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrescriptionOrder(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('drugName: $drugName, ')
          ..write('strength: $strength, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('route: $route, ')
          ..write('frequency: $frequency, ')
          ..write('diluentAndRate: $diluentAndRate, ')
          ..write('isActive: $isActive, ')
          ..write('orderedAt: $orderedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    documentId,
    drugName,
    strength,
    dosageForm,
    route,
    frequency,
    diluentAndRate,
    isActive,
    orderedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrescriptionOrder &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.documentId == this.documentId &&
          other.drugName == this.drugName &&
          other.strength == this.strength &&
          other.dosageForm == this.dosageForm &&
          other.route == this.route &&
          other.frequency == this.frequency &&
          other.diluentAndRate == this.diluentAndRate &&
          other.isActive == this.isActive &&
          other.orderedAt == this.orderedAt);
}

class PrescriptionOrdersCompanion extends UpdateCompanion<PrescriptionOrder> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> documentId;
  final Value<String> drugName;
  final Value<String?> strength;
  final Value<String?> dosageForm;
  final Value<String> route;
  final Value<String> frequency;
  final Value<String?> diluentAndRate;
  final Value<bool> isActive;
  final Value<DateTime> orderedAt;
  final Value<int> rowid;
  const PrescriptionOrdersCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.drugName = const Value.absent(),
    this.strength = const Value.absent(),
    this.dosageForm = const Value.absent(),
    this.route = const Value.absent(),
    this.frequency = const Value.absent(),
    this.diluentAndRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.orderedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrescriptionOrdersCompanion.insert({
    required String id,
    required String patientId,
    required String documentId,
    required String drugName,
    this.strength = const Value.absent(),
    this.dosageForm = const Value.absent(),
    required String route,
    required String frequency,
    this.diluentAndRate = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime orderedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       documentId = Value(documentId),
       drugName = Value(drugName),
       route = Value(route),
       frequency = Value(frequency),
       orderedAt = Value(orderedAt);
  static Insertable<PrescriptionOrder> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? documentId,
    Expression<String>? drugName,
    Expression<String>? strength,
    Expression<String>? dosageForm,
    Expression<String>? route,
    Expression<String>? frequency,
    Expression<String>? diluentAndRate,
    Expression<bool>? isActive,
    Expression<DateTime>? orderedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (documentId != null) 'document_id': documentId,
      if (drugName != null) 'drug_name': drugName,
      if (strength != null) 'strength': strength,
      if (dosageForm != null) 'dosage_form': dosageForm,
      if (route != null) 'route': route,
      if (frequency != null) 'frequency': frequency,
      if (diluentAndRate != null) 'diluent_and_rate': diluentAndRate,
      if (isActive != null) 'is_active': isActive,
      if (orderedAt != null) 'ordered_at': orderedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrescriptionOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? documentId,
    Value<String>? drugName,
    Value<String?>? strength,
    Value<String?>? dosageForm,
    Value<String>? route,
    Value<String>? frequency,
    Value<String?>? diluentAndRate,
    Value<bool>? isActive,
    Value<DateTime>? orderedAt,
    Value<int>? rowid,
  }) {
    return PrescriptionOrdersCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      documentId: documentId ?? this.documentId,
      drugName: drugName ?? this.drugName,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      diluentAndRate: diluentAndRate ?? this.diluentAndRate,
      isActive: isActive ?? this.isActive,
      orderedAt: orderedAt ?? this.orderedAt,
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
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (drugName.present) {
      map['drug_name'] = Variable<String>(drugName.value);
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
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (diluentAndRate.present) {
      map['diluent_and_rate'] = Variable<String>(diluentAndRate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (orderedAt.present) {
      map['ordered_at'] = Variable<DateTime>(orderedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrescriptionOrdersCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('drugName: $drugName, ')
          ..write('strength: $strength, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('route: $route, ')
          ..write('frequency: $frequency, ')
          ..write('diluentAndRate: $diluentAndRate, ')
          ..write('isActive: $isActive, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MicrobiologyCulturesTable extends MicrobiologyCultures
    with TableInfo<$MicrobiologyCulturesTable, MicrobiologyCulture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MicrobiologyCulturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_registries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sampleTypeMeta = const VerificationMeta(
    'sampleType',
  );
  @override
  late final GeneratedColumn<String> sampleType = GeneratedColumn<String>(
    'sample_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organismIdentifiedMeta =
      const VerificationMeta('organismIdentified');
  @override
  late final GeneratedColumn<String> organismIdentified =
      GeneratedColumn<String>(
        'organism_identified',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _colonyCountMeta = const VerificationMeta(
    'colonyCount',
  );
  @override
  late final GeneratedColumn<String> colonyCount = GeneratedColumn<String>(
    'colony_count',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _antibiogramJsonMeta = const VerificationMeta(
    'antibiogramJson',
  );
  @override
  late final GeneratedColumn<String> antibiogramJson = GeneratedColumn<String>(
    'antibiogram_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _reportedAtMeta = const VerificationMeta(
    'reportedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reportedAt = GeneratedColumn<DateTime>(
    'reported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    documentId,
    sampleType,
    organismIdentified,
    colonyCount,
    antibiogramJson,
    reportedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'microbiology_cultures';
  @override
  VerificationContext validateIntegrity(
    Insertable<MicrobiologyCulture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('sample_type')) {
      context.handle(
        _sampleTypeMeta,
        sampleType.isAcceptableOrUnknown(data['sample_type']!, _sampleTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sampleTypeMeta);
    }
    if (data.containsKey('organism_identified')) {
      context.handle(
        _organismIdentifiedMeta,
        organismIdentified.isAcceptableOrUnknown(
          data['organism_identified']!,
          _organismIdentifiedMeta,
        ),
      );
    }
    if (data.containsKey('colony_count')) {
      context.handle(
        _colonyCountMeta,
        colonyCount.isAcceptableOrUnknown(
          data['colony_count']!,
          _colonyCountMeta,
        ),
      );
    }
    if (data.containsKey('antibiogram_json')) {
      context.handle(
        _antibiogramJsonMeta,
        antibiogramJson.isAcceptableOrUnknown(
          data['antibiogram_json']!,
          _antibiogramJsonMeta,
        ),
      );
    }
    if (data.containsKey('reported_at')) {
      context.handle(
        _reportedAtMeta,
        reportedAt.isAcceptableOrUnknown(data['reported_at']!, _reportedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reportedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MicrobiologyCulture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MicrobiologyCulture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      sampleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sample_type'],
      )!,
      organismIdentified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organism_identified'],
      ),
      colonyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colony_count'],
      ),
      antibiogramJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}antibiogram_json'],
      )!,
      reportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reported_at'],
      )!,
    );
  }

  @override
  $MicrobiologyCulturesTable createAlias(String alias) {
    return $MicrobiologyCulturesTable(attachedDatabase, alias);
  }
}

class MicrobiologyCulture extends DataClass
    implements Insertable<MicrobiologyCulture> {
  final String id;
  final String patientId;
  final String documentId;
  final String sampleType;
  final String? organismIdentified;
  final String? colonyCount;
  final String antibiogramJson;
  final DateTime reportedAt;
  const MicrobiologyCulture({
    required this.id,
    required this.patientId,
    required this.documentId,
    required this.sampleType,
    this.organismIdentified,
    this.colonyCount,
    required this.antibiogramJson,
    required this.reportedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['document_id'] = Variable<String>(documentId);
    map['sample_type'] = Variable<String>(sampleType);
    if (!nullToAbsent || organismIdentified != null) {
      map['organism_identified'] = Variable<String>(organismIdentified);
    }
    if (!nullToAbsent || colonyCount != null) {
      map['colony_count'] = Variable<String>(colonyCount);
    }
    map['antibiogram_json'] = Variable<String>(antibiogramJson);
    map['reported_at'] = Variable<DateTime>(reportedAt);
    return map;
  }

  MicrobiologyCulturesCompanion toCompanion(bool nullToAbsent) {
    return MicrobiologyCulturesCompanion(
      id: Value(id),
      patientId: Value(patientId),
      documentId: Value(documentId),
      sampleType: Value(sampleType),
      organismIdentified: organismIdentified == null && nullToAbsent
          ? const Value.absent()
          : Value(organismIdentified),
      colonyCount: colonyCount == null && nullToAbsent
          ? const Value.absent()
          : Value(colonyCount),
      antibiogramJson: Value(antibiogramJson),
      reportedAt: Value(reportedAt),
    );
  }

  factory MicrobiologyCulture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MicrobiologyCulture(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      sampleType: serializer.fromJson<String>(json['sampleType']),
      organismIdentified: serializer.fromJson<String?>(
        json['organismIdentified'],
      ),
      colonyCount: serializer.fromJson<String?>(json['colonyCount']),
      antibiogramJson: serializer.fromJson<String>(json['antibiogramJson']),
      reportedAt: serializer.fromJson<DateTime>(json['reportedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'documentId': serializer.toJson<String>(documentId),
      'sampleType': serializer.toJson<String>(sampleType),
      'organismIdentified': serializer.toJson<String?>(organismIdentified),
      'colonyCount': serializer.toJson<String?>(colonyCount),
      'antibiogramJson': serializer.toJson<String>(antibiogramJson),
      'reportedAt': serializer.toJson<DateTime>(reportedAt),
    };
  }

  MicrobiologyCulture copyWith({
    String? id,
    String? patientId,
    String? documentId,
    String? sampleType,
    Value<String?> organismIdentified = const Value.absent(),
    Value<String?> colonyCount = const Value.absent(),
    String? antibiogramJson,
    DateTime? reportedAt,
  }) => MicrobiologyCulture(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    documentId: documentId ?? this.documentId,
    sampleType: sampleType ?? this.sampleType,
    organismIdentified: organismIdentified.present
        ? organismIdentified.value
        : this.organismIdentified,
    colonyCount: colonyCount.present ? colonyCount.value : this.colonyCount,
    antibiogramJson: antibiogramJson ?? this.antibiogramJson,
    reportedAt: reportedAt ?? this.reportedAt,
  );
  MicrobiologyCulture copyWithCompanion(MicrobiologyCulturesCompanion data) {
    return MicrobiologyCulture(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      sampleType: data.sampleType.present
          ? data.sampleType.value
          : this.sampleType,
      organismIdentified: data.organismIdentified.present
          ? data.organismIdentified.value
          : this.organismIdentified,
      colonyCount: data.colonyCount.present
          ? data.colonyCount.value
          : this.colonyCount,
      antibiogramJson: data.antibiogramJson.present
          ? data.antibiogramJson.value
          : this.antibiogramJson,
      reportedAt: data.reportedAt.present
          ? data.reportedAt.value
          : this.reportedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MicrobiologyCulture(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('sampleType: $sampleType, ')
          ..write('organismIdentified: $organismIdentified, ')
          ..write('colonyCount: $colonyCount, ')
          ..write('antibiogramJson: $antibiogramJson, ')
          ..write('reportedAt: $reportedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    documentId,
    sampleType,
    organismIdentified,
    colonyCount,
    antibiogramJson,
    reportedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MicrobiologyCulture &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.documentId == this.documentId &&
          other.sampleType == this.sampleType &&
          other.organismIdentified == this.organismIdentified &&
          other.colonyCount == this.colonyCount &&
          other.antibiogramJson == this.antibiogramJson &&
          other.reportedAt == this.reportedAt);
}

class MicrobiologyCulturesCompanion
    extends UpdateCompanion<MicrobiologyCulture> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> documentId;
  final Value<String> sampleType;
  final Value<String?> organismIdentified;
  final Value<String?> colonyCount;
  final Value<String> antibiogramJson;
  final Value<DateTime> reportedAt;
  final Value<int> rowid;
  const MicrobiologyCulturesCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.sampleType = const Value.absent(),
    this.organismIdentified = const Value.absent(),
    this.colonyCount = const Value.absent(),
    this.antibiogramJson = const Value.absent(),
    this.reportedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MicrobiologyCulturesCompanion.insert({
    required String id,
    required String patientId,
    required String documentId,
    required String sampleType,
    this.organismIdentified = const Value.absent(),
    this.colonyCount = const Value.absent(),
    this.antibiogramJson = const Value.absent(),
    required DateTime reportedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       documentId = Value(documentId),
       sampleType = Value(sampleType),
       reportedAt = Value(reportedAt);
  static Insertable<MicrobiologyCulture> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? documentId,
    Expression<String>? sampleType,
    Expression<String>? organismIdentified,
    Expression<String>? colonyCount,
    Expression<String>? antibiogramJson,
    Expression<DateTime>? reportedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (documentId != null) 'document_id': documentId,
      if (sampleType != null) 'sample_type': sampleType,
      if (organismIdentified != null) 'organism_identified': organismIdentified,
      if (colonyCount != null) 'colony_count': colonyCount,
      if (antibiogramJson != null) 'antibiogram_json': antibiogramJson,
      if (reportedAt != null) 'reported_at': reportedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MicrobiologyCulturesCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? documentId,
    Value<String>? sampleType,
    Value<String?>? organismIdentified,
    Value<String?>? colonyCount,
    Value<String>? antibiogramJson,
    Value<DateTime>? reportedAt,
    Value<int>? rowid,
  }) {
    return MicrobiologyCulturesCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      documentId: documentId ?? this.documentId,
      sampleType: sampleType ?? this.sampleType,
      organismIdentified: organismIdentified ?? this.organismIdentified,
      colonyCount: colonyCount ?? this.colonyCount,
      antibiogramJson: antibiogramJson ?? this.antibiogramJson,
      reportedAt: reportedAt ?? this.reportedAt,
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
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (sampleType.present) {
      map['sample_type'] = Variable<String>(sampleType.value);
    }
    if (organismIdentified.present) {
      map['organism_identified'] = Variable<String>(organismIdentified.value);
    }
    if (colonyCount.present) {
      map['colony_count'] = Variable<String>(colonyCount.value);
    }
    if (antibiogramJson.present) {
      map['antibiogram_json'] = Variable<String>(antibiogramJson.value);
    }
    if (reportedAt.present) {
      map['reported_at'] = Variable<DateTime>(reportedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MicrobiologyCulturesCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('sampleType: $sampleType, ')
          ..write('organismIdentified: $organismIdentified, ')
          ..write('colonyCount: $colonyCount, ')
          ..write('antibiogramJson: $antibiogramJson, ')
          ..write('reportedAt: $reportedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImagingStudiesTable extends ImagingStudies
    with TableInfo<$ImagingStudiesTable, ImagingStudy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImagingStudiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_registries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modalityMeta = const VerificationMeta(
    'modality',
  );
  @override
  late final GeneratedColumn<String> modality = GeneratedColumn<String>(
    'modality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anatomicalRegionMeta = const VerificationMeta(
    'anatomicalRegion',
  );
  @override
  late final GeneratedColumn<String> anatomicalRegion = GeneratedColumn<String>(
    'anatomical_region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _findingsMeta = const VerificationMeta(
    'findings',
  );
  @override
  late final GeneratedColumn<String> findings = GeneratedColumn<String>(
    'findings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _impressionMeta = const VerificationMeta(
    'impression',
  );
  @override
  late final GeneratedColumn<String> impression = GeneratedColumn<String>(
    'impression',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    documentId,
    modality,
    anatomicalRegion,
    findings,
    impression,
    performedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imaging_studies';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImagingStudy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('modality')) {
      context.handle(
        _modalityMeta,
        modality.isAcceptableOrUnknown(data['modality']!, _modalityMeta),
      );
    } else if (isInserting) {
      context.missing(_modalityMeta);
    }
    if (data.containsKey('anatomical_region')) {
      context.handle(
        _anatomicalRegionMeta,
        anatomicalRegion.isAcceptableOrUnknown(
          data['anatomical_region']!,
          _anatomicalRegionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anatomicalRegionMeta);
    }
    if (data.containsKey('findings')) {
      context.handle(
        _findingsMeta,
        findings.isAcceptableOrUnknown(data['findings']!, _findingsMeta),
      );
    } else if (isInserting) {
      context.missing(_findingsMeta);
    }
    if (data.containsKey('impression')) {
      context.handle(
        _impressionMeta,
        impression.isAcceptableOrUnknown(data['impression']!, _impressionMeta),
      );
    } else if (isInserting) {
      context.missing(_impressionMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImagingStudy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImagingStudy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      modality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modality'],
      )!,
      anatomicalRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anatomical_region'],
      )!,
      findings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}findings'],
      )!,
      impression: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impression'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
    );
  }

  @override
  $ImagingStudiesTable createAlias(String alias) {
    return $ImagingStudiesTable(attachedDatabase, alias);
  }
}

class ImagingStudy extends DataClass implements Insertable<ImagingStudy> {
  final String id;
  final String patientId;
  final String documentId;
  final String modality;
  final String anatomicalRegion;
  final String findings;
  final String impression;
  final DateTime performedAt;
  const ImagingStudy({
    required this.id,
    required this.patientId,
    required this.documentId,
    required this.modality,
    required this.anatomicalRegion,
    required this.findings,
    required this.impression,
    required this.performedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['document_id'] = Variable<String>(documentId);
    map['modality'] = Variable<String>(modality);
    map['anatomical_region'] = Variable<String>(anatomicalRegion);
    map['findings'] = Variable<String>(findings);
    map['impression'] = Variable<String>(impression);
    map['performed_at'] = Variable<DateTime>(performedAt);
    return map;
  }

  ImagingStudiesCompanion toCompanion(bool nullToAbsent) {
    return ImagingStudiesCompanion(
      id: Value(id),
      patientId: Value(patientId),
      documentId: Value(documentId),
      modality: Value(modality),
      anatomicalRegion: Value(anatomicalRegion),
      findings: Value(findings),
      impression: Value(impression),
      performedAt: Value(performedAt),
    );
  }

  factory ImagingStudy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImagingStudy(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      documentId: serializer.fromJson<String>(json['documentId']),
      modality: serializer.fromJson<String>(json['modality']),
      anatomicalRegion: serializer.fromJson<String>(json['anatomicalRegion']),
      findings: serializer.fromJson<String>(json['findings']),
      impression: serializer.fromJson<String>(json['impression']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'documentId': serializer.toJson<String>(documentId),
      'modality': serializer.toJson<String>(modality),
      'anatomicalRegion': serializer.toJson<String>(anatomicalRegion),
      'findings': serializer.toJson<String>(findings),
      'impression': serializer.toJson<String>(impression),
      'performedAt': serializer.toJson<DateTime>(performedAt),
    };
  }

  ImagingStudy copyWith({
    String? id,
    String? patientId,
    String? documentId,
    String? modality,
    String? anatomicalRegion,
    String? findings,
    String? impression,
    DateTime? performedAt,
  }) => ImagingStudy(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    documentId: documentId ?? this.documentId,
    modality: modality ?? this.modality,
    anatomicalRegion: anatomicalRegion ?? this.anatomicalRegion,
    findings: findings ?? this.findings,
    impression: impression ?? this.impression,
    performedAt: performedAt ?? this.performedAt,
  );
  ImagingStudy copyWithCompanion(ImagingStudiesCompanion data) {
    return ImagingStudy(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      modality: data.modality.present ? data.modality.value : this.modality,
      anatomicalRegion: data.anatomicalRegion.present
          ? data.anatomicalRegion.value
          : this.anatomicalRegion,
      findings: data.findings.present ? data.findings.value : this.findings,
      impression: data.impression.present
          ? data.impression.value
          : this.impression,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImagingStudy(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('modality: $modality, ')
          ..write('anatomicalRegion: $anatomicalRegion, ')
          ..write('findings: $findings, ')
          ..write('impression: $impression, ')
          ..write('performedAt: $performedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    documentId,
    modality,
    anatomicalRegion,
    findings,
    impression,
    performedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImagingStudy &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.documentId == this.documentId &&
          other.modality == this.modality &&
          other.anatomicalRegion == this.anatomicalRegion &&
          other.findings == this.findings &&
          other.impression == this.impression &&
          other.performedAt == this.performedAt);
}

class ImagingStudiesCompanion extends UpdateCompanion<ImagingStudy> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> documentId;
  final Value<String> modality;
  final Value<String> anatomicalRegion;
  final Value<String> findings;
  final Value<String> impression;
  final Value<DateTime> performedAt;
  final Value<int> rowid;
  const ImagingStudiesCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.modality = const Value.absent(),
    this.anatomicalRegion = const Value.absent(),
    this.findings = const Value.absent(),
    this.impression = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImagingStudiesCompanion.insert({
    required String id,
    required String patientId,
    required String documentId,
    required String modality,
    required String anatomicalRegion,
    required String findings,
    required String impression,
    required DateTime performedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       documentId = Value(documentId),
       modality = Value(modality),
       anatomicalRegion = Value(anatomicalRegion),
       findings = Value(findings),
       impression = Value(impression),
       performedAt = Value(performedAt);
  static Insertable<ImagingStudy> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? documentId,
    Expression<String>? modality,
    Expression<String>? anatomicalRegion,
    Expression<String>? findings,
    Expression<String>? impression,
    Expression<DateTime>? performedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (documentId != null) 'document_id': documentId,
      if (modality != null) 'modality': modality,
      if (anatomicalRegion != null) 'anatomical_region': anatomicalRegion,
      if (findings != null) 'findings': findings,
      if (impression != null) 'impression': impression,
      if (performedAt != null) 'performed_at': performedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImagingStudiesCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? documentId,
    Value<String>? modality,
    Value<String>? anatomicalRegion,
    Value<String>? findings,
    Value<String>? impression,
    Value<DateTime>? performedAt,
    Value<int>? rowid,
  }) {
    return ImagingStudiesCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      documentId: documentId ?? this.documentId,
      modality: modality ?? this.modality,
      anatomicalRegion: anatomicalRegion ?? this.anatomicalRegion,
      findings: findings ?? this.findings,
      impression: impression ?? this.impression,
      performedAt: performedAt ?? this.performedAt,
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
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (modality.present) {
      map['modality'] = Variable<String>(modality.value);
    }
    if (anatomicalRegion.present) {
      map['anatomical_region'] = Variable<String>(anatomicalRegion.value);
    }
    if (findings.present) {
      map['findings'] = Variable<String>(findings.value);
    }
    if (impression.present) {
      map['impression'] = Variable<String>(impression.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagingStudiesCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('documentId: $documentId, ')
          ..write('modality: $modality, ')
          ..write('anatomicalRegion: $anatomicalRegion, ')
          ..write('findings: $findings, ')
          ..write('impression: $impression, ')
          ..write('performedAt: $performedAt, ')
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
  late final $AyushmanPackagesTable ayushmanPackages = $AyushmanPackagesTable(
    this,
  );
  late final $HbpProceduresTable hbpProcedures = $HbpProceduresTable(this);
  late final $HbpImplantsTable hbpImplants = $HbpImplantsTable(this);
  late final $HbpStratificationsTable hbpStratifications =
      $HbpStratificationsTable(this);
  late final $DocumentRegistriesTable documentRegistries =
      $DocumentRegistriesTable(this);
  late final $ClinicalObservationsTable clinicalObservations =
      $ClinicalObservationsTable(this);
  late final $PrescriptionOrdersTable prescriptionOrders =
      $PrescriptionOrdersTable(this);
  late final $MicrobiologyCulturesTable microbiologyCultures =
      $MicrobiologyCulturesTable(this);
  late final $ImagingStudiesTable imagingStudies = $ImagingStudiesTable(this);
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
    ayushmanPackages,
    hbpProcedures,
    hbpImplants,
    hbpStratifications,
    documentRegistries,
    clinicalObservations,
    prescriptionOrders,
    microbiologyCultures,
    imagingStudies,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_registries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clinical_observations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_registries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clinical_observations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prescription_orders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_registries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prescription_orders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('microbiology_cultures', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_registries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('microbiology_cultures', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('imaging_studies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_registries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('imaging_studies', kind: UpdateKind.delete)],
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
      Value<String?> phoneNumber,
      Value<String?> alternateContact,
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
      Value<String?> phoneNumber,
      Value<String?> alternateContact,
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

  static MultiTypedResultKey<$DocumentRegistriesTable, List<DocumentRegistry>>
  _documentRegistriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.documentRegistries,
        aliasName: 'patients__id__document_registries__patient_id',
      );

  $$DocumentRegistriesTableProcessedTableManager get documentRegistriesRefs {
    final manager = $$DocumentRegistriesTableTableManager(
      $_db,
      $_db.documentRegistries,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentRegistriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ClinicalObservationsTable,
    List<ClinicalObservation>
  >
  _clinicalObservationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.clinicalObservations,
        aliasName: 'patients__id__clinical_observations__patient_id',
      );

  $$ClinicalObservationsTableProcessedTableManager
  get clinicalObservationsRefs {
    final manager = $$ClinicalObservationsTableTableManager(
      $_db,
      $_db.clinicalObservations,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _clinicalObservationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrescriptionOrdersTable, List<PrescriptionOrder>>
  _prescriptionOrdersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.prescriptionOrders,
        aliasName: 'patients__id__prescription_orders__patient_id',
      );

  $$PrescriptionOrdersTableProcessedTableManager get prescriptionOrdersRefs {
    final manager = $$PrescriptionOrdersTableTableManager(
      $_db,
      $_db.prescriptionOrders,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _prescriptionOrdersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MicrobiologyCulturesTable,
    List<MicrobiologyCulture>
  >
  _microbiologyCulturesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.microbiologyCultures,
        aliasName: 'patients__id__microbiology_cultures__patient_id',
      );

  $$MicrobiologyCulturesTableProcessedTableManager
  get microbiologyCulturesRefs {
    final manager = $$MicrobiologyCulturesTableTableManager(
      $_db,
      $_db.microbiologyCultures,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _microbiologyCulturesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImagingStudiesTable, List<ImagingStudy>>
  _imagingStudiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.imagingStudies,
    aliasName: 'patients__id__imaging_studies__patient_id',
  );

  $$ImagingStudiesTableProcessedTableManager get imagingStudiesRefs {
    final manager = $$ImagingStudiesTableTableManager(
      $_db,
      $_db.imagingStudies,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagingStudiesRefsTable($_db));
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

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternateContact => $composableBuilder(
    column: $table.alternateContact,
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

  Expression<bool> documentRegistriesRefs(
    Expression<bool> Function($$DocumentRegistriesTableFilterComposer f) f,
  ) {
    final $$DocumentRegistriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableFilterComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clinicalObservationsRefs(
    Expression<bool> Function($$ClinicalObservationsTableFilterComposer f) f,
  ) {
    final $$ClinicalObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalObservations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalObservationsTableFilterComposer(
            $db: $db,
            $table: $db.clinicalObservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionOrdersRefs(
    Expression<bool> Function($$PrescriptionOrdersTableFilterComposer f) f,
  ) {
    final $$PrescriptionOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptionOrders,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionOrdersTableFilterComposer(
            $db: $db,
            $table: $db.prescriptionOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> microbiologyCulturesRefs(
    Expression<bool> Function($$MicrobiologyCulturesTableFilterComposer f) f,
  ) {
    final $$MicrobiologyCulturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.microbiologyCultures,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MicrobiologyCulturesTableFilterComposer(
            $db: $db,
            $table: $db.microbiologyCultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imagingStudiesRefs(
    Expression<bool> Function($$ImagingStudiesTableFilterComposer f) f,
  ) {
    final $$ImagingStudiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imagingStudies,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagingStudiesTableFilterComposer(
            $db: $db,
            $table: $db.imagingStudies,
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

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternateContact => $composableBuilder(
    column: $table.alternateContact,
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

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alternateContact => $composableBuilder(
    column: $table.alternateContact,
    builder: (column) => column,
  );

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

  Expression<T> documentRegistriesRefs<T extends Object>(
    Expression<T> Function($$DocumentRegistriesTableAnnotationComposer a) f,
  ) {
    final $$DocumentRegistriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.documentRegistries,
          getReferencedColumn: (t) => t.patientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentRegistriesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentRegistries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> clinicalObservationsRefs<T extends Object>(
    Expression<T> Function($$ClinicalObservationsTableAnnotationComposer a) f,
  ) {
    final $$ClinicalObservationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.clinicalObservations,
          getReferencedColumn: (t) => t.patientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ClinicalObservationsTableAnnotationComposer(
                $db: $db,
                $table: $db.clinicalObservations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> prescriptionOrdersRefs<T extends Object>(
    Expression<T> Function($$PrescriptionOrdersTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionOrdersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.prescriptionOrders,
          getReferencedColumn: (t) => t.patientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PrescriptionOrdersTableAnnotationComposer(
                $db: $db,
                $table: $db.prescriptionOrders,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> microbiologyCulturesRefs<T extends Object>(
    Expression<T> Function($$MicrobiologyCulturesTableAnnotationComposer a) f,
  ) {
    final $$MicrobiologyCulturesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.microbiologyCultures,
          getReferencedColumn: (t) => t.patientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MicrobiologyCulturesTableAnnotationComposer(
                $db: $db,
                $table: $db.microbiologyCultures,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> imagingStudiesRefs<T extends Object>(
    Expression<T> Function($$ImagingStudiesTableAnnotationComposer a) f,
  ) {
    final $$ImagingStudiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imagingStudies,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagingStudiesTableAnnotationComposer(
            $db: $db,
            $table: $db.imagingStudies,
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
            bool documentRegistriesRefs,
            bool clinicalObservationsRefs,
            bool prescriptionOrdersRefs,
            bool microbiologyCulturesRefs,
            bool imagingStudiesRefs,
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
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> alternateContact = const Value.absent(),
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
                phoneNumber: phoneNumber,
                alternateContact: alternateContact,
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
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> alternateContact = const Value.absent(),
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
                phoneNumber: phoneNumber,
                alternateContact: alternateContact,
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
                documentRegistriesRefs = false,
                clinicalObservationsRefs = false,
                prescriptionOrdersRefs = false,
                microbiologyCulturesRefs = false,
                imagingStudiesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clinicalEncountersRefs) db.clinicalEncounters,
                    if (investigationsRefs) db.investigations,
                    if (patientProblemsRefs) db.patientProblems,
                    if (clinicalActionsRefs) db.clinicalActions,
                    if (documentRegistriesRefs) db.documentRegistries,
                    if (clinicalObservationsRefs) db.clinicalObservations,
                    if (prescriptionOrdersRefs) db.prescriptionOrders,
                    if (microbiologyCulturesRefs) db.microbiologyCultures,
                    if (imagingStudiesRefs) db.imagingStudies,
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
                      if (documentRegistriesRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          DocumentRegistry
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._documentRegistriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentRegistriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (clinicalObservationsRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          ClinicalObservation
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._clinicalObservationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).clinicalObservationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prescriptionOrdersRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          PrescriptionOrder
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._prescriptionOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).prescriptionOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (microbiologyCulturesRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          MicrobiologyCulture
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._microbiologyCulturesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).microbiologyCulturesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imagingStudiesRefs)
                        await $_getPrefetchedData<
                          Patient,
                          $PatientsTable,
                          ImagingStudy
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._imagingStudiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).imagingStudiesRefs,
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
        bool documentRegistriesRefs,
        bool clinicalObservationsRefs,
        bool prescriptionOrdersRefs,
        bool microbiologyCulturesRefs,
        bool imagingStudiesRefs,
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
      Value<String?> substitutes,
      Value<String?> sideEffects,
      Value<String?> uses,
      Value<String?> chemicalClass,
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
      Value<String?> substitutes,
      Value<String?> sideEffects,
      Value<String?> uses,
      Value<String?> chemicalClass,
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
                Value<String?> substitutes = const Value.absent(),
                Value<String?> sideEffects = const Value.absent(),
                Value<String?> uses = const Value.absent(),
                Value<String?> chemicalClass = const Value.absent(),
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
                Value<String?> substitutes = const Value.absent(),
                Value<String?> sideEffects = const Value.absent(),
                Value<String?> uses = const Value.absent(),
                Value<String?> chemicalClass = const Value.absent(),
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
      Value<bool> requiresPreAuth,
      Value<String> medicolegalAlert,
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
      Value<bool> requiresPreAuth,
      Value<String> medicolegalAlert,
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

  ColumnFilters<bool> get requiresPreAuth => $composableBuilder(
    column: $table.requiresPreAuth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicolegalAlert => $composableBuilder(
    column: $table.medicolegalAlert,
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

  ColumnOrderings<bool> get requiresPreAuth => $composableBuilder(
    column: $table.requiresPreAuth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicolegalAlert => $composableBuilder(
    column: $table.medicolegalAlert,
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

  GeneratedColumn<bool> get requiresPreAuth => $composableBuilder(
    column: $table.requiresPreAuth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicolegalAlert => $composableBuilder(
    column: $table.medicolegalAlert,
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
                Value<bool> requiresPreAuth = const Value.absent(),
                Value<String> medicolegalAlert = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CdssRulesCompanion(
                id: id,
                targetProblem: targetProblem,
                triggerCondition: triggerCondition,
                suggestedAction: suggestedAction,
                evidenceSource: evidenceSource,
                requiresPreAuth: requiresPreAuth,
                medicolegalAlert: medicolegalAlert,
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
                Value<bool> requiresPreAuth = const Value.absent(),
                Value<String> medicolegalAlert = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CdssRulesCompanion.insert(
                id: id,
                targetProblem: targetProblem,
                triggerCondition: triggerCondition,
                suggestedAction: suggestedAction,
                evidenceSource: evidenceSource,
                requiresPreAuth: requiresPreAuth,
                medicolegalAlert: medicolegalAlert,
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
typedef $$AyushmanPackagesTableCreateCompanionBuilder =
    AyushmanPackagesCompanion Function({
      required String code,
      required String packageName,
      Value<String?> stratification,
      Value<double?> rate,
      Value<int> rowid,
    });
typedef $$AyushmanPackagesTableUpdateCompanionBuilder =
    AyushmanPackagesCompanion Function({
      Value<String> code,
      Value<String> packageName,
      Value<String?> stratification,
      Value<double?> rate,
      Value<int> rowid,
    });

class $$AyushmanPackagesTableFilterComposer
    extends Composer<_$AppDatabase, $AyushmanPackagesTable> {
  $$AyushmanPackagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stratification => $composableBuilder(
    column: $table.stratification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AyushmanPackagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AyushmanPackagesTable> {
  $$AyushmanPackagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stratification => $composableBuilder(
    column: $table.stratification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AyushmanPackagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AyushmanPackagesTable> {
  $$AyushmanPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stratification => $composableBuilder(
    column: $table.stratification,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);
}

class $$AyushmanPackagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AyushmanPackagesTable,
          AyushmanPackage,
          $$AyushmanPackagesTableFilterComposer,
          $$AyushmanPackagesTableOrderingComposer,
          $$AyushmanPackagesTableAnnotationComposer,
          $$AyushmanPackagesTableCreateCompanionBuilder,
          $$AyushmanPackagesTableUpdateCompanionBuilder,
          (
            AyushmanPackage,
            BaseReferences<
              _$AppDatabase,
              $AyushmanPackagesTable,
              AyushmanPackage
            >,
          ),
          AyushmanPackage,
          PrefetchHooks Function()
        > {
  $$AyushmanPackagesTableTableManager(
    _$AppDatabase db,
    $AyushmanPackagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyushmanPackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyushmanPackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyushmanPackagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String?> stratification = const Value.absent(),
                Value<double?> rate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyushmanPackagesCompanion(
                code: code,
                packageName: packageName,
                stratification: stratification,
                rate: rate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String packageName,
                Value<String?> stratification = const Value.absent(),
                Value<double?> rate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyushmanPackagesCompanion.insert(
                code: code,
                packageName: packageName,
                stratification: stratification,
                rate: rate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AyushmanPackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AyushmanPackagesTable,
      AyushmanPackage,
      $$AyushmanPackagesTableFilterComposer,
      $$AyushmanPackagesTableOrderingComposer,
      $$AyushmanPackagesTableAnnotationComposer,
      $$AyushmanPackagesTableCreateCompanionBuilder,
      $$AyushmanPackagesTableUpdateCompanionBuilder,
      (
        AyushmanPackage,
        BaseReferences<_$AppDatabase, $AyushmanPackagesTable, AyushmanPackage>,
      ),
      AyushmanPackage,
      PrefetchHooks Function()
    >;
typedef $$HbpProceduresTableCreateCompanionBuilder =
    HbpProceduresCompanion Function({
      required String procedureCode,
      required String packageName,
      required String procedureName,
      Value<double?> rate,
      Value<String> specialty,
      Value<int> rowid,
    });
typedef $$HbpProceduresTableUpdateCompanionBuilder =
    HbpProceduresCompanion Function({
      Value<String> procedureCode,
      Value<String> packageName,
      Value<String> procedureName,
      Value<double?> rate,
      Value<String> specialty,
      Value<int> rowid,
    });

class $$HbpProceduresTableFilterComposer
    extends Composer<_$AppDatabase, $HbpProceduresTable> {
  $$HbpProceduresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get procedureName => $composableBuilder(
    column: $table.procedureName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HbpProceduresTableOrderingComposer
    extends Composer<_$AppDatabase, $HbpProceduresTable> {
  $$HbpProceduresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get procedureName => $composableBuilder(
    column: $table.procedureName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HbpProceduresTableAnnotationComposer
    extends Composer<_$AppDatabase, $HbpProceduresTable> {
  $$HbpProceduresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get procedureName => $composableBuilder(
    column: $table.procedureName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);
}

class $$HbpProceduresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HbpProceduresTable,
          HbpProcedure,
          $$HbpProceduresTableFilterComposer,
          $$HbpProceduresTableOrderingComposer,
          $$HbpProceduresTableAnnotationComposer,
          $$HbpProceduresTableCreateCompanionBuilder,
          $$HbpProceduresTableUpdateCompanionBuilder,
          (
            HbpProcedure,
            BaseReferences<_$AppDatabase, $HbpProceduresTable, HbpProcedure>,
          ),
          HbpProcedure,
          PrefetchHooks Function()
        > {
  $$HbpProceduresTableTableManager(_$AppDatabase db, $HbpProceduresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HbpProceduresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HbpProceduresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HbpProceduresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> procedureCode = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> procedureName = const Value.absent(),
                Value<double?> rate = const Value.absent(),
                Value<String> specialty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HbpProceduresCompanion(
                procedureCode: procedureCode,
                packageName: packageName,
                procedureName: procedureName,
                rate: rate,
                specialty: specialty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String procedureCode,
                required String packageName,
                required String procedureName,
                Value<double?> rate = const Value.absent(),
                Value<String> specialty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HbpProceduresCompanion.insert(
                procedureCode: procedureCode,
                packageName: packageName,
                procedureName: procedureName,
                rate: rate,
                specialty: specialty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HbpProceduresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HbpProceduresTable,
      HbpProcedure,
      $$HbpProceduresTableFilterComposer,
      $$HbpProceduresTableOrderingComposer,
      $$HbpProceduresTableAnnotationComposer,
      $$HbpProceduresTableCreateCompanionBuilder,
      $$HbpProceduresTableUpdateCompanionBuilder,
      (
        HbpProcedure,
        BaseReferences<_$AppDatabase, $HbpProceduresTable, HbpProcedure>,
      ),
      HbpProcedure,
      PrefetchHooks Function()
    >;
typedef $$HbpImplantsTableCreateCompanionBuilder =
    HbpImplantsCompanion Function({
      Value<int> id,
      required String procedureCode,
      required String implantCode,
      required String implantName,
      Value<double?> maximumPrice,
    });
typedef $$HbpImplantsTableUpdateCompanionBuilder =
    HbpImplantsCompanion Function({
      Value<int> id,
      Value<String> procedureCode,
      Value<String> implantCode,
      Value<String> implantName,
      Value<double?> maximumPrice,
    });

class $$HbpImplantsTableFilterComposer
    extends Composer<_$AppDatabase, $HbpImplantsTable> {
  $$HbpImplantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get implantCode => $composableBuilder(
    column: $table.implantCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get implantName => $composableBuilder(
    column: $table.implantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maximumPrice => $composableBuilder(
    column: $table.maximumPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HbpImplantsTableOrderingComposer
    extends Composer<_$AppDatabase, $HbpImplantsTable> {
  $$HbpImplantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get implantCode => $composableBuilder(
    column: $table.implantCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get implantName => $composableBuilder(
    column: $table.implantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maximumPrice => $composableBuilder(
    column: $table.maximumPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HbpImplantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HbpImplantsTable> {
  $$HbpImplantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get implantCode => $composableBuilder(
    column: $table.implantCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get implantName => $composableBuilder(
    column: $table.implantName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maximumPrice => $composableBuilder(
    column: $table.maximumPrice,
    builder: (column) => column,
  );
}

class $$HbpImplantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HbpImplantsTable,
          HbpImplant,
          $$HbpImplantsTableFilterComposer,
          $$HbpImplantsTableOrderingComposer,
          $$HbpImplantsTableAnnotationComposer,
          $$HbpImplantsTableCreateCompanionBuilder,
          $$HbpImplantsTableUpdateCompanionBuilder,
          (
            HbpImplant,
            BaseReferences<_$AppDatabase, $HbpImplantsTable, HbpImplant>,
          ),
          HbpImplant,
          PrefetchHooks Function()
        > {
  $$HbpImplantsTableTableManager(_$AppDatabase db, $HbpImplantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HbpImplantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HbpImplantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HbpImplantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> procedureCode = const Value.absent(),
                Value<String> implantCode = const Value.absent(),
                Value<String> implantName = const Value.absent(),
                Value<double?> maximumPrice = const Value.absent(),
              }) => HbpImplantsCompanion(
                id: id,
                procedureCode: procedureCode,
                implantCode: implantCode,
                implantName: implantName,
                maximumPrice: maximumPrice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String procedureCode,
                required String implantCode,
                required String implantName,
                Value<double?> maximumPrice = const Value.absent(),
              }) => HbpImplantsCompanion.insert(
                id: id,
                procedureCode: procedureCode,
                implantCode: implantCode,
                implantName: implantName,
                maximumPrice: maximumPrice,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HbpImplantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HbpImplantsTable,
      HbpImplant,
      $$HbpImplantsTableFilterComposer,
      $$HbpImplantsTableOrderingComposer,
      $$HbpImplantsTableAnnotationComposer,
      $$HbpImplantsTableCreateCompanionBuilder,
      $$HbpImplantsTableUpdateCompanionBuilder,
      (
        HbpImplant,
        BaseReferences<_$AppDatabase, $HbpImplantsTable, HbpImplant>,
      ),
      HbpImplant,
      PrefetchHooks Function()
    >;
typedef $$HbpStratificationsTableCreateCompanionBuilder =
    HbpStratificationsCompanion Function({
      Value<int> id,
      required String procedureCode,
      required String stratificationCode,
      required String stratificationName,
      Value<String> rule,
    });
typedef $$HbpStratificationsTableUpdateCompanionBuilder =
    HbpStratificationsCompanion Function({
      Value<int> id,
      Value<String> procedureCode,
      Value<String> stratificationCode,
      Value<String> stratificationName,
      Value<String> rule,
    });

class $$HbpStratificationsTableFilterComposer
    extends Composer<_$AppDatabase, $HbpStratificationsTable> {
  $$HbpStratificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stratificationCode => $composableBuilder(
    column: $table.stratificationCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stratificationName => $composableBuilder(
    column: $table.stratificationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HbpStratificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $HbpStratificationsTable> {
  $$HbpStratificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stratificationCode => $composableBuilder(
    column: $table.stratificationCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stratificationName => $composableBuilder(
    column: $table.stratificationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HbpStratificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HbpStratificationsTable> {
  $$HbpStratificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get procedureCode => $composableBuilder(
    column: $table.procedureCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stratificationCode => $composableBuilder(
    column: $table.stratificationCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stratificationName => $composableBuilder(
    column: $table.stratificationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rule =>
      $composableBuilder(column: $table.rule, builder: (column) => column);
}

class $$HbpStratificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HbpStratificationsTable,
          HbpStratification,
          $$HbpStratificationsTableFilterComposer,
          $$HbpStratificationsTableOrderingComposer,
          $$HbpStratificationsTableAnnotationComposer,
          $$HbpStratificationsTableCreateCompanionBuilder,
          $$HbpStratificationsTableUpdateCompanionBuilder,
          (
            HbpStratification,
            BaseReferences<
              _$AppDatabase,
              $HbpStratificationsTable,
              HbpStratification
            >,
          ),
          HbpStratification,
          PrefetchHooks Function()
        > {
  $$HbpStratificationsTableTableManager(
    _$AppDatabase db,
    $HbpStratificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HbpStratificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HbpStratificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HbpStratificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> procedureCode = const Value.absent(),
                Value<String> stratificationCode = const Value.absent(),
                Value<String> stratificationName = const Value.absent(),
                Value<String> rule = const Value.absent(),
              }) => HbpStratificationsCompanion(
                id: id,
                procedureCode: procedureCode,
                stratificationCode: stratificationCode,
                stratificationName: stratificationName,
                rule: rule,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String procedureCode,
                required String stratificationCode,
                required String stratificationName,
                Value<String> rule = const Value.absent(),
              }) => HbpStratificationsCompanion.insert(
                id: id,
                procedureCode: procedureCode,
                stratificationCode: stratificationCode,
                stratificationName: stratificationName,
                rule: rule,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HbpStratificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HbpStratificationsTable,
      HbpStratification,
      $$HbpStratificationsTableFilterComposer,
      $$HbpStratificationsTableOrderingComposer,
      $$HbpStratificationsTableAnnotationComposer,
      $$HbpStratificationsTableCreateCompanionBuilder,
      $$HbpStratificationsTableUpdateCompanionBuilder,
      (
        HbpStratification,
        BaseReferences<
          _$AppDatabase,
          $HbpStratificationsTable,
          HbpStratification
        >,
      ),
      HbpStratification,
      PrefetchHooks Function()
    >;
typedef $$DocumentRegistriesTableCreateCompanionBuilder =
    DocumentRegistriesCompanion Function({
      required String id,
      required String patientId,
      required String documentCategory,
      required String imagePath,
      Value<String> rawOcrTranscript,
      Value<double> confidenceScore,
      required DateTime documentedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DocumentRegistriesTableUpdateCompanionBuilder =
    DocumentRegistriesCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> documentCategory,
      Value<String> imagePath,
      Value<String> rawOcrTranscript,
      Value<double> confidenceScore,
      Value<DateTime> documentedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DocumentRegistriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentRegistriesTable,
          DocumentRegistry
        > {
  $$DocumentRegistriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('document_registries__patient_id__patients__id');

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

  static MultiTypedResultKey<
    $ClinicalObservationsTable,
    List<ClinicalObservation>
  >
  _clinicalObservationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.clinicalObservations,
        aliasName:
            'document_registries__id__clinical_observations__document_id',
      );

  $$ClinicalObservationsTableProcessedTableManager
  get clinicalObservationsRefs {
    final manager = $$ClinicalObservationsTableTableManager(
      $_db,
      $_db.clinicalObservations,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _clinicalObservationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrescriptionOrdersTable, List<PrescriptionOrder>>
  _prescriptionOrdersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.prescriptionOrders,
        aliasName: 'document_registries__id__prescription_orders__document_id',
      );

  $$PrescriptionOrdersTableProcessedTableManager get prescriptionOrdersRefs {
    final manager = $$PrescriptionOrdersTableTableManager(
      $_db,
      $_db.prescriptionOrders,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _prescriptionOrdersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MicrobiologyCulturesTable,
    List<MicrobiologyCulture>
  >
  _microbiologyCulturesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.microbiologyCultures,
        aliasName:
            'document_registries__id__microbiology_cultures__document_id',
      );

  $$MicrobiologyCulturesTableProcessedTableManager
  get microbiologyCulturesRefs {
    final manager = $$MicrobiologyCulturesTableTableManager(
      $_db,
      $_db.microbiologyCultures,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _microbiologyCulturesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImagingStudiesTable, List<ImagingStudy>>
  _imagingStudiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.imagingStudies,
    aliasName: 'document_registries__id__imaging_studies__document_id',
  );

  $$ImagingStudiesTableProcessedTableManager get imagingStudiesRefs {
    final manager = $$ImagingStudiesTableTableManager(
      $_db,
      $_db.imagingStudies,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagingStudiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentRegistriesTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentRegistriesTable> {
  $$DocumentRegistriesTableFilterComposer({
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

  ColumnFilters<String> get documentCategory => $composableBuilder(
    column: $table.documentCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawOcrTranscript => $composableBuilder(
    column: $table.rawOcrTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get documentedAt => $composableBuilder(
    column: $table.documentedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  Expression<bool> clinicalObservationsRefs(
    Expression<bool> Function($$ClinicalObservationsTableFilterComposer f) f,
  ) {
    final $$ClinicalObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clinicalObservations,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalObservationsTableFilterComposer(
            $db: $db,
            $table: $db.clinicalObservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionOrdersRefs(
    Expression<bool> Function($$PrescriptionOrdersTableFilterComposer f) f,
  ) {
    final $$PrescriptionOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptionOrders,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionOrdersTableFilterComposer(
            $db: $db,
            $table: $db.prescriptionOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> microbiologyCulturesRefs(
    Expression<bool> Function($$MicrobiologyCulturesTableFilterComposer f) f,
  ) {
    final $$MicrobiologyCulturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.microbiologyCultures,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MicrobiologyCulturesTableFilterComposer(
            $db: $db,
            $table: $db.microbiologyCultures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imagingStudiesRefs(
    Expression<bool> Function($$ImagingStudiesTableFilterComposer f) f,
  ) {
    final $$ImagingStudiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imagingStudies,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagingStudiesTableFilterComposer(
            $db: $db,
            $table: $db.imagingStudies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentRegistriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentRegistriesTable> {
  $$DocumentRegistriesTableOrderingComposer({
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

  ColumnOrderings<String> get documentCategory => $composableBuilder(
    column: $table.documentCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawOcrTranscript => $composableBuilder(
    column: $table.rawOcrTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get documentedAt => $composableBuilder(
    column: $table.documentedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$DocumentRegistriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentRegistriesTable> {
  $$DocumentRegistriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentCategory => $composableBuilder(
    column: $table.documentCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get rawOcrTranscript => $composableBuilder(
    column: $table.rawOcrTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get documentedAt => $composableBuilder(
    column: $table.documentedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  Expression<T> clinicalObservationsRefs<T extends Object>(
    Expression<T> Function($$ClinicalObservationsTableAnnotationComposer a) f,
  ) {
    final $$ClinicalObservationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.clinicalObservations,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ClinicalObservationsTableAnnotationComposer(
                $db: $db,
                $table: $db.clinicalObservations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> prescriptionOrdersRefs<T extends Object>(
    Expression<T> Function($$PrescriptionOrdersTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionOrdersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.prescriptionOrders,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PrescriptionOrdersTableAnnotationComposer(
                $db: $db,
                $table: $db.prescriptionOrders,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> microbiologyCulturesRefs<T extends Object>(
    Expression<T> Function($$MicrobiologyCulturesTableAnnotationComposer a) f,
  ) {
    final $$MicrobiologyCulturesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.microbiologyCultures,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MicrobiologyCulturesTableAnnotationComposer(
                $db: $db,
                $table: $db.microbiologyCultures,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> imagingStudiesRefs<T extends Object>(
    Expression<T> Function($$ImagingStudiesTableAnnotationComposer a) f,
  ) {
    final $$ImagingStudiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imagingStudies,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagingStudiesTableAnnotationComposer(
            $db: $db,
            $table: $db.imagingStudies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentRegistriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentRegistriesTable,
          DocumentRegistry,
          $$DocumentRegistriesTableFilterComposer,
          $$DocumentRegistriesTableOrderingComposer,
          $$DocumentRegistriesTableAnnotationComposer,
          $$DocumentRegistriesTableCreateCompanionBuilder,
          $$DocumentRegistriesTableUpdateCompanionBuilder,
          (DocumentRegistry, $$DocumentRegistriesTableReferences),
          DocumentRegistry,
          PrefetchHooks Function({
            bool patientId,
            bool clinicalObservationsRefs,
            bool prescriptionOrdersRefs,
            bool microbiologyCulturesRefs,
            bool imagingStudiesRefs,
          })
        > {
  $$DocumentRegistriesTableTableManager(
    _$AppDatabase db,
    $DocumentRegistriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentRegistriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentRegistriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentRegistriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> documentCategory = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> rawOcrTranscript = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<DateTime> documentedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentRegistriesCompanion(
                id: id,
                patientId: patientId,
                documentCategory: documentCategory,
                imagePath: imagePath,
                rawOcrTranscript: rawOcrTranscript,
                confidenceScore: confidenceScore,
                documentedAt: documentedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String documentCategory,
                required String imagePath,
                Value<String> rawOcrTranscript = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                required DateTime documentedAt,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentRegistriesCompanion.insert(
                id: id,
                patientId: patientId,
                documentCategory: documentCategory,
                imagePath: imagePath,
                rawOcrTranscript: rawOcrTranscript,
                confidenceScore: confidenceScore,
                documentedAt: documentedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentRegistriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                patientId = false,
                clinicalObservationsRefs = false,
                prescriptionOrdersRefs = false,
                microbiologyCulturesRefs = false,
                imagingStudiesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clinicalObservationsRefs) db.clinicalObservations,
                    if (prescriptionOrdersRefs) db.prescriptionOrders,
                    if (microbiologyCulturesRefs) db.microbiologyCultures,
                    if (imagingStudiesRefs) db.imagingStudies,
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
                                        $$DocumentRegistriesTableReferences
                                            ._patientIdTable(db),
                                    referencedColumn:
                                        $$DocumentRegistriesTableReferences
                                            ._patientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (clinicalObservationsRefs)
                        await $_getPrefetchedData<
                          DocumentRegistry,
                          $DocumentRegistriesTable,
                          ClinicalObservation
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentRegistriesTableReferences
                              ._clinicalObservationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentRegistriesTableReferences(
                                db,
                                table,
                                p0,
                              ).clinicalObservationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prescriptionOrdersRefs)
                        await $_getPrefetchedData<
                          DocumentRegistry,
                          $DocumentRegistriesTable,
                          PrescriptionOrder
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentRegistriesTableReferences
                              ._prescriptionOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentRegistriesTableReferences(
                                db,
                                table,
                                p0,
                              ).prescriptionOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (microbiologyCulturesRefs)
                        await $_getPrefetchedData<
                          DocumentRegistry,
                          $DocumentRegistriesTable,
                          MicrobiologyCulture
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentRegistriesTableReferences
                              ._microbiologyCulturesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentRegistriesTableReferences(
                                db,
                                table,
                                p0,
                              ).microbiologyCulturesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imagingStudiesRefs)
                        await $_getPrefetchedData<
                          DocumentRegistry,
                          $DocumentRegistriesTable,
                          ImagingStudy
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentRegistriesTableReferences
                              ._imagingStudiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentRegistriesTableReferences(
                                db,
                                table,
                                p0,
                              ).imagingStudiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
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

typedef $$DocumentRegistriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentRegistriesTable,
      DocumentRegistry,
      $$DocumentRegistriesTableFilterComposer,
      $$DocumentRegistriesTableOrderingComposer,
      $$DocumentRegistriesTableAnnotationComposer,
      $$DocumentRegistriesTableCreateCompanionBuilder,
      $$DocumentRegistriesTableUpdateCompanionBuilder,
      (DocumentRegistry, $$DocumentRegistriesTableReferences),
      DocumentRegistry,
      PrefetchHooks Function({
        bool patientId,
        bool clinicalObservationsRefs,
        bool prescriptionOrdersRefs,
        bool microbiologyCulturesRefs,
        bool imagingStudiesRefs,
      })
    >;
typedef $$ClinicalObservationsTableCreateCompanionBuilder =
    ClinicalObservationsCompanion Function({
      required String id,
      required String patientId,
      required String documentId,
      required String observationCategory,
      required String code,
      required String displayName,
      Value<double?> numericValue,
      Value<String?> textValue,
      Value<String?> unit,
      Value<double?> referenceLow,
      Value<double?> referenceHigh,
      Value<bool> isAbnormal,
      required DateTime recordedAt,
      Value<String?> corroborationNote,
      Value<int> rowid,
    });
typedef $$ClinicalObservationsTableUpdateCompanionBuilder =
    ClinicalObservationsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> documentId,
      Value<String> observationCategory,
      Value<String> code,
      Value<String> displayName,
      Value<double?> numericValue,
      Value<String?> textValue,
      Value<String?> unit,
      Value<double?> referenceLow,
      Value<double?> referenceHigh,
      Value<bool> isAbnormal,
      Value<DateTime> recordedAt,
      Value<String?> corroborationNote,
      Value<int> rowid,
    });

final class $$ClinicalObservationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ClinicalObservationsTable,
          ClinicalObservation
        > {
  $$ClinicalObservationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) => db.patients
      .createAlias('clinical_observations__patient_id__patients__id');

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

  static $DocumentRegistriesTable _documentIdTable(_$AppDatabase db) =>
      db.documentRegistries.createAlias(
        'clinical_observations__document_id__document_registries__id',
      );

  $$DocumentRegistriesTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentRegistriesTableTableManager(
      $_db,
      $_db.documentRegistries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClinicalObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalObservationsTable> {
  $$ClinicalObservationsTableFilterComposer({
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

  ColumnFilters<String> get observationCategory => $composableBuilder(
    column: $table.observationCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceLow => $composableBuilder(
    column: $table.referenceLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceHigh => $composableBuilder(
    column: $table.referenceHigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAbnormal => $composableBuilder(
    column: $table.isAbnormal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get corroborationNote => $composableBuilder(
    column: $table.corroborationNote,
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

  $$DocumentRegistriesTableFilterComposer get documentId {
    final $$DocumentRegistriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableFilterComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalObservationsTable> {
  $$ClinicalObservationsTableOrderingComposer({
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

  ColumnOrderings<String> get observationCategory => $composableBuilder(
    column: $table.observationCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceLow => $composableBuilder(
    column: $table.referenceLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceHigh => $composableBuilder(
    column: $table.referenceHigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAbnormal => $composableBuilder(
    column: $table.isAbnormal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get corroborationNote => $composableBuilder(
    column: $table.corroborationNote,
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

  $$DocumentRegistriesTableOrderingComposer get documentId {
    final $$DocumentRegistriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableOrderingComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClinicalObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalObservationsTable> {
  $$ClinicalObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get observationCategory => $composableBuilder(
    column: $table.observationCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get numericValue => $composableBuilder(
    column: $table.numericValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get referenceLow => $composableBuilder(
    column: $table.referenceLow,
    builder: (column) => column,
  );

  GeneratedColumn<double> get referenceHigh => $composableBuilder(
    column: $table.referenceHigh,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAbnormal => $composableBuilder(
    column: $table.isAbnormal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get corroborationNote => $composableBuilder(
    column: $table.corroborationNote,
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

  $$DocumentRegistriesTableAnnotationComposer get documentId {
    final $$DocumentRegistriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.documentRegistries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentRegistriesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentRegistries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ClinicalObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicalObservationsTable,
          ClinicalObservation,
          $$ClinicalObservationsTableFilterComposer,
          $$ClinicalObservationsTableOrderingComposer,
          $$ClinicalObservationsTableAnnotationComposer,
          $$ClinicalObservationsTableCreateCompanionBuilder,
          $$ClinicalObservationsTableUpdateCompanionBuilder,
          (ClinicalObservation, $$ClinicalObservationsTableReferences),
          ClinicalObservation,
          PrefetchHooks Function({bool patientId, bool documentId})
        > {
  $$ClinicalObservationsTableTableManager(
    _$AppDatabase db,
    $ClinicalObservationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalObservationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ClinicalObservationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> observationCategory = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<double?> numericValue = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> referenceLow = const Value.absent(),
                Value<double?> referenceHigh = const Value.absent(),
                Value<bool> isAbnormal = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String?> corroborationNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalObservationsCompanion(
                id: id,
                patientId: patientId,
                documentId: documentId,
                observationCategory: observationCategory,
                code: code,
                displayName: displayName,
                numericValue: numericValue,
                textValue: textValue,
                unit: unit,
                referenceLow: referenceLow,
                referenceHigh: referenceHigh,
                isAbnormal: isAbnormal,
                recordedAt: recordedAt,
                corroborationNote: corroborationNote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String documentId,
                required String observationCategory,
                required String code,
                required String displayName,
                Value<double?> numericValue = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> referenceLow = const Value.absent(),
                Value<double?> referenceHigh = const Value.absent(),
                Value<bool> isAbnormal = const Value.absent(),
                required DateTime recordedAt,
                Value<String?> corroborationNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalObservationsCompanion.insert(
                id: id,
                patientId: patientId,
                documentId: documentId,
                observationCategory: observationCategory,
                code: code,
                displayName: displayName,
                numericValue: numericValue,
                textValue: textValue,
                unit: unit,
                referenceLow: referenceLow,
                referenceHigh: referenceHigh,
                isAbnormal: isAbnormal,
                recordedAt: recordedAt,
                corroborationNote: corroborationNote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClinicalObservationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, documentId = false}) {
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
                                    $$ClinicalObservationsTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$ClinicalObservationsTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$ClinicalObservationsTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$ClinicalObservationsTableReferences
                                        ._documentIdTable(db)
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

typedef $$ClinicalObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicalObservationsTable,
      ClinicalObservation,
      $$ClinicalObservationsTableFilterComposer,
      $$ClinicalObservationsTableOrderingComposer,
      $$ClinicalObservationsTableAnnotationComposer,
      $$ClinicalObservationsTableCreateCompanionBuilder,
      $$ClinicalObservationsTableUpdateCompanionBuilder,
      (ClinicalObservation, $$ClinicalObservationsTableReferences),
      ClinicalObservation,
      PrefetchHooks Function({bool patientId, bool documentId})
    >;
typedef $$PrescriptionOrdersTableCreateCompanionBuilder =
    PrescriptionOrdersCompanion Function({
      required String id,
      required String patientId,
      required String documentId,
      required String drugName,
      Value<String?> strength,
      Value<String?> dosageForm,
      required String route,
      required String frequency,
      Value<String?> diluentAndRate,
      Value<bool> isActive,
      required DateTime orderedAt,
      Value<int> rowid,
    });
typedef $$PrescriptionOrdersTableUpdateCompanionBuilder =
    PrescriptionOrdersCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> documentId,
      Value<String> drugName,
      Value<String?> strength,
      Value<String?> dosageForm,
      Value<String> route,
      Value<String> frequency,
      Value<String?> diluentAndRate,
      Value<bool> isActive,
      Value<DateTime> orderedAt,
      Value<int> rowid,
    });

final class $$PrescriptionOrdersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PrescriptionOrdersTable,
          PrescriptionOrder
        > {
  $$PrescriptionOrdersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('prescription_orders__patient_id__patients__id');

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

  static $DocumentRegistriesTable _documentIdTable(_$AppDatabase db) => db
      .documentRegistries
      .createAlias('prescription_orders__document_id__document_registries__id');

  $$DocumentRegistriesTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentRegistriesTableTableManager(
      $_db,
      $_db.documentRegistries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrescriptionOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $PrescriptionOrdersTable> {
  $$PrescriptionOrdersTableFilterComposer({
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

  ColumnFilters<String> get drugName => $composableBuilder(
    column: $table.drugName,
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

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diluentAndRate => $composableBuilder(
    column: $table.diluentAndRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
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

  $$DocumentRegistriesTableFilterComposer get documentId {
    final $$DocumentRegistriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableFilterComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $PrescriptionOrdersTable> {
  $$PrescriptionOrdersTableOrderingComposer({
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

  ColumnOrderings<String> get drugName => $composableBuilder(
    column: $table.drugName,
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

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diluentAndRate => $composableBuilder(
    column: $table.diluentAndRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
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

  $$DocumentRegistriesTableOrderingComposer get documentId {
    final $$DocumentRegistriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableOrderingComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrescriptionOrdersTable> {
  $$PrescriptionOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get drugName =>
      $composableBuilder(column: $table.drugName, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get diluentAndRate => $composableBuilder(
    column: $table.diluentAndRate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get orderedAt =>
      $composableBuilder(column: $table.orderedAt, builder: (column) => column);

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

  $$DocumentRegistriesTableAnnotationComposer get documentId {
    final $$DocumentRegistriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.documentRegistries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentRegistriesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentRegistries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PrescriptionOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrescriptionOrdersTable,
          PrescriptionOrder,
          $$PrescriptionOrdersTableFilterComposer,
          $$PrescriptionOrdersTableOrderingComposer,
          $$PrescriptionOrdersTableAnnotationComposer,
          $$PrescriptionOrdersTableCreateCompanionBuilder,
          $$PrescriptionOrdersTableUpdateCompanionBuilder,
          (PrescriptionOrder, $$PrescriptionOrdersTableReferences),
          PrescriptionOrder,
          PrefetchHooks Function({bool patientId, bool documentId})
        > {
  $$PrescriptionOrdersTableTableManager(
    _$AppDatabase db,
    $PrescriptionOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrescriptionOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrescriptionOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrescriptionOrdersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> drugName = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> dosageForm = const Value.absent(),
                Value<String> route = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> diluentAndRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> orderedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionOrdersCompanion(
                id: id,
                patientId: patientId,
                documentId: documentId,
                drugName: drugName,
                strength: strength,
                dosageForm: dosageForm,
                route: route,
                frequency: frequency,
                diluentAndRate: diluentAndRate,
                isActive: isActive,
                orderedAt: orderedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String documentId,
                required String drugName,
                Value<String?> strength = const Value.absent(),
                Value<String?> dosageForm = const Value.absent(),
                required String route,
                required String frequency,
                Value<String?> diluentAndRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime orderedAt,
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionOrdersCompanion.insert(
                id: id,
                patientId: patientId,
                documentId: documentId,
                drugName: drugName,
                strength: strength,
                dosageForm: dosageForm,
                route: route,
                frequency: frequency,
                diluentAndRate: diluentAndRate,
                isActive: isActive,
                orderedAt: orderedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrescriptionOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, documentId = false}) {
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
                                    $$PrescriptionOrdersTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$PrescriptionOrdersTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$PrescriptionOrdersTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$PrescriptionOrdersTableReferences
                                        ._documentIdTable(db)
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

typedef $$PrescriptionOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrescriptionOrdersTable,
      PrescriptionOrder,
      $$PrescriptionOrdersTableFilterComposer,
      $$PrescriptionOrdersTableOrderingComposer,
      $$PrescriptionOrdersTableAnnotationComposer,
      $$PrescriptionOrdersTableCreateCompanionBuilder,
      $$PrescriptionOrdersTableUpdateCompanionBuilder,
      (PrescriptionOrder, $$PrescriptionOrdersTableReferences),
      PrescriptionOrder,
      PrefetchHooks Function({bool patientId, bool documentId})
    >;
typedef $$MicrobiologyCulturesTableCreateCompanionBuilder =
    MicrobiologyCulturesCompanion Function({
      required String id,
      required String patientId,
      required String documentId,
      required String sampleType,
      Value<String?> organismIdentified,
      Value<String?> colonyCount,
      Value<String> antibiogramJson,
      required DateTime reportedAt,
      Value<int> rowid,
    });
typedef $$MicrobiologyCulturesTableUpdateCompanionBuilder =
    MicrobiologyCulturesCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> documentId,
      Value<String> sampleType,
      Value<String?> organismIdentified,
      Value<String?> colonyCount,
      Value<String> antibiogramJson,
      Value<DateTime> reportedAt,
      Value<int> rowid,
    });

final class $$MicrobiologyCulturesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MicrobiologyCulturesTable,
          MicrobiologyCulture
        > {
  $$MicrobiologyCulturesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) => db.patients
      .createAlias('microbiology_cultures__patient_id__patients__id');

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

  static $DocumentRegistriesTable _documentIdTable(_$AppDatabase db) =>
      db.documentRegistries.createAlias(
        'microbiology_cultures__document_id__document_registries__id',
      );

  $$DocumentRegistriesTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentRegistriesTableTableManager(
      $_db,
      $_db.documentRegistries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MicrobiologyCulturesTableFilterComposer
    extends Composer<_$AppDatabase, $MicrobiologyCulturesTable> {
  $$MicrobiologyCulturesTableFilterComposer({
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

  ColumnFilters<String> get sampleType => $composableBuilder(
    column: $table.sampleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organismIdentified => $composableBuilder(
    column: $table.organismIdentified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colonyCount => $composableBuilder(
    column: $table.colonyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get antibiogramJson => $composableBuilder(
    column: $table.antibiogramJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reportedAt => $composableBuilder(
    column: $table.reportedAt,
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

  $$DocumentRegistriesTableFilterComposer get documentId {
    final $$DocumentRegistriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableFilterComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MicrobiologyCulturesTableOrderingComposer
    extends Composer<_$AppDatabase, $MicrobiologyCulturesTable> {
  $$MicrobiologyCulturesTableOrderingComposer({
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

  ColumnOrderings<String> get sampleType => $composableBuilder(
    column: $table.sampleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organismIdentified => $composableBuilder(
    column: $table.organismIdentified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colonyCount => $composableBuilder(
    column: $table.colonyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get antibiogramJson => $composableBuilder(
    column: $table.antibiogramJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reportedAt => $composableBuilder(
    column: $table.reportedAt,
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

  $$DocumentRegistriesTableOrderingComposer get documentId {
    final $$DocumentRegistriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableOrderingComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MicrobiologyCulturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MicrobiologyCulturesTable> {
  $$MicrobiologyCulturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sampleType => $composableBuilder(
    column: $table.sampleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organismIdentified => $composableBuilder(
    column: $table.organismIdentified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colonyCount => $composableBuilder(
    column: $table.colonyCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get antibiogramJson => $composableBuilder(
    column: $table.antibiogramJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reportedAt => $composableBuilder(
    column: $table.reportedAt,
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

  $$DocumentRegistriesTableAnnotationComposer get documentId {
    final $$DocumentRegistriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.documentRegistries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentRegistriesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentRegistries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MicrobiologyCulturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MicrobiologyCulturesTable,
          MicrobiologyCulture,
          $$MicrobiologyCulturesTableFilterComposer,
          $$MicrobiologyCulturesTableOrderingComposer,
          $$MicrobiologyCulturesTableAnnotationComposer,
          $$MicrobiologyCulturesTableCreateCompanionBuilder,
          $$MicrobiologyCulturesTableUpdateCompanionBuilder,
          (MicrobiologyCulture, $$MicrobiologyCulturesTableReferences),
          MicrobiologyCulture,
          PrefetchHooks Function({bool patientId, bool documentId})
        > {
  $$MicrobiologyCulturesTableTableManager(
    _$AppDatabase db,
    $MicrobiologyCulturesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MicrobiologyCulturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MicrobiologyCulturesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MicrobiologyCulturesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> sampleType = const Value.absent(),
                Value<String?> organismIdentified = const Value.absent(),
                Value<String?> colonyCount = const Value.absent(),
                Value<String> antibiogramJson = const Value.absent(),
                Value<DateTime> reportedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MicrobiologyCulturesCompanion(
                id: id,
                patientId: patientId,
                documentId: documentId,
                sampleType: sampleType,
                organismIdentified: organismIdentified,
                colonyCount: colonyCount,
                antibiogramJson: antibiogramJson,
                reportedAt: reportedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String documentId,
                required String sampleType,
                Value<String?> organismIdentified = const Value.absent(),
                Value<String?> colonyCount = const Value.absent(),
                Value<String> antibiogramJson = const Value.absent(),
                required DateTime reportedAt,
                Value<int> rowid = const Value.absent(),
              }) => MicrobiologyCulturesCompanion.insert(
                id: id,
                patientId: patientId,
                documentId: documentId,
                sampleType: sampleType,
                organismIdentified: organismIdentified,
                colonyCount: colonyCount,
                antibiogramJson: antibiogramJson,
                reportedAt: reportedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MicrobiologyCulturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, documentId = false}) {
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
                                    $$MicrobiologyCulturesTableReferences
                                        ._patientIdTable(db),
                                referencedColumn:
                                    $$MicrobiologyCulturesTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$MicrobiologyCulturesTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$MicrobiologyCulturesTableReferences
                                        ._documentIdTable(db)
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

typedef $$MicrobiologyCulturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MicrobiologyCulturesTable,
      MicrobiologyCulture,
      $$MicrobiologyCulturesTableFilterComposer,
      $$MicrobiologyCulturesTableOrderingComposer,
      $$MicrobiologyCulturesTableAnnotationComposer,
      $$MicrobiologyCulturesTableCreateCompanionBuilder,
      $$MicrobiologyCulturesTableUpdateCompanionBuilder,
      (MicrobiologyCulture, $$MicrobiologyCulturesTableReferences),
      MicrobiologyCulture,
      PrefetchHooks Function({bool patientId, bool documentId})
    >;
typedef $$ImagingStudiesTableCreateCompanionBuilder =
    ImagingStudiesCompanion Function({
      required String id,
      required String patientId,
      required String documentId,
      required String modality,
      required String anatomicalRegion,
      required String findings,
      required String impression,
      required DateTime performedAt,
      Value<int> rowid,
    });
typedef $$ImagingStudiesTableUpdateCompanionBuilder =
    ImagingStudiesCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> documentId,
      Value<String> modality,
      Value<String> anatomicalRegion,
      Value<String> findings,
      Value<String> impression,
      Value<DateTime> performedAt,
      Value<int> rowid,
    });

final class $$ImagingStudiesTableReferences
    extends BaseReferences<_$AppDatabase, $ImagingStudiesTable, ImagingStudy> {
  $$ImagingStudiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('imaging_studies__patient_id__patients__id');

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

  static $DocumentRegistriesTable _documentIdTable(_$AppDatabase db) => db
      .documentRegistries
      .createAlias('imaging_studies__document_id__document_registries__id');

  $$DocumentRegistriesTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentRegistriesTableTableManager(
      $_db,
      $_db.documentRegistries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImagingStudiesTableFilterComposer
    extends Composer<_$AppDatabase, $ImagingStudiesTable> {
  $$ImagingStudiesTableFilterComposer({
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

  ColumnFilters<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anatomicalRegion => $composableBuilder(
    column: $table.anatomicalRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get findings => $composableBuilder(
    column: $table.findings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impression => $composableBuilder(
    column: $table.impression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
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

  $$DocumentRegistriesTableFilterComposer get documentId {
    final $$DocumentRegistriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableFilterComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImagingStudiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImagingStudiesTable> {
  $$ImagingStudiesTableOrderingComposer({
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

  ColumnOrderings<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anatomicalRegion => $composableBuilder(
    column: $table.anatomicalRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get findings => $composableBuilder(
    column: $table.findings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impression => $composableBuilder(
    column: $table.impression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
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

  $$DocumentRegistriesTableOrderingComposer get documentId {
    final $$DocumentRegistriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documentRegistries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRegistriesTableOrderingComposer(
            $db: $db,
            $table: $db.documentRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImagingStudiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImagingStudiesTable> {
  $$ImagingStudiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modality =>
      $composableBuilder(column: $table.modality, builder: (column) => column);

  GeneratedColumn<String> get anatomicalRegion => $composableBuilder(
    column: $table.anatomicalRegion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get findings =>
      $composableBuilder(column: $table.findings, builder: (column) => column);

  GeneratedColumn<String> get impression => $composableBuilder(
    column: $table.impression,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
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

  $$DocumentRegistriesTableAnnotationComposer get documentId {
    final $$DocumentRegistriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.documentId,
          referencedTable: $db.documentRegistries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentRegistriesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentRegistries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ImagingStudiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImagingStudiesTable,
          ImagingStudy,
          $$ImagingStudiesTableFilterComposer,
          $$ImagingStudiesTableOrderingComposer,
          $$ImagingStudiesTableAnnotationComposer,
          $$ImagingStudiesTableCreateCompanionBuilder,
          $$ImagingStudiesTableUpdateCompanionBuilder,
          (ImagingStudy, $$ImagingStudiesTableReferences),
          ImagingStudy,
          PrefetchHooks Function({bool patientId, bool documentId})
        > {
  $$ImagingStudiesTableTableManager(
    _$AppDatabase db,
    $ImagingStudiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImagingStudiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImagingStudiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImagingStudiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> modality = const Value.absent(),
                Value<String> anatomicalRegion = const Value.absent(),
                Value<String> findings = const Value.absent(),
                Value<String> impression = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagingStudiesCompanion(
                id: id,
                patientId: patientId,
                documentId: documentId,
                modality: modality,
                anatomicalRegion: anatomicalRegion,
                findings: findings,
                impression: impression,
                performedAt: performedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String documentId,
                required String modality,
                required String anatomicalRegion,
                required String findings,
                required String impression,
                required DateTime performedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImagingStudiesCompanion.insert(
                id: id,
                patientId: patientId,
                documentId: documentId,
                modality: modality,
                anatomicalRegion: anatomicalRegion,
                findings: findings,
                impression: impression,
                performedAt: performedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImagingStudiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, documentId = false}) {
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
                                referencedTable: $$ImagingStudiesTableReferences
                                    ._patientIdTable(db),
                                referencedColumn:
                                    $$ImagingStudiesTableReferences
                                        ._patientIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$ImagingStudiesTableReferences
                                    ._documentIdTable(db),
                                referencedColumn:
                                    $$ImagingStudiesTableReferences
                                        ._documentIdTable(db)
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

typedef $$ImagingStudiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImagingStudiesTable,
      ImagingStudy,
      $$ImagingStudiesTableFilterComposer,
      $$ImagingStudiesTableOrderingComposer,
      $$ImagingStudiesTableAnnotationComposer,
      $$ImagingStudiesTableCreateCompanionBuilder,
      $$ImagingStudiesTableUpdateCompanionBuilder,
      (ImagingStudy, $$ImagingStudiesTableReferences),
      ImagingStudy,
      PrefetchHooks Function({bool patientId, bool documentId})
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
  $$AyushmanPackagesTableTableManager get ayushmanPackages =>
      $$AyushmanPackagesTableTableManager(_db, _db.ayushmanPackages);
  $$HbpProceduresTableTableManager get hbpProcedures =>
      $$HbpProceduresTableTableManager(_db, _db.hbpProcedures);
  $$HbpImplantsTableTableManager get hbpImplants =>
      $$HbpImplantsTableTableManager(_db, _db.hbpImplants);
  $$HbpStratificationsTableTableManager get hbpStratifications =>
      $$HbpStratificationsTableTableManager(_db, _db.hbpStratifications);
  $$DocumentRegistriesTableTableManager get documentRegistries =>
      $$DocumentRegistriesTableTableManager(_db, _db.documentRegistries);
  $$ClinicalObservationsTableTableManager get clinicalObservations =>
      $$ClinicalObservationsTableTableManager(_db, _db.clinicalObservations);
  $$PrescriptionOrdersTableTableManager get prescriptionOrders =>
      $$PrescriptionOrdersTableTableManager(_db, _db.prescriptionOrders);
  $$MicrobiologyCulturesTableTableManager get microbiologyCultures =>
      $$MicrobiologyCulturesTableTableManager(_db, _db.microbiologyCultures);
  $$ImagingStudiesTableTableManager get imagingStudies =>
      $$ImagingStudiesTableTableManager(_db, _db.imagingStudies);
}
