// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PaymentSourcesTable extends PaymentSources
    with TableInfo<$PaymentSourcesTable, PaymentSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commissionRateBpsMeta = const VerificationMeta(
    'commissionRateBps',
  );
  @override
  late final GeneratedColumn<int> commissionRateBps = GeneratedColumn<int>(
    'commission_rate_bps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _defaultTdsRateBpsMeta = const VerificationMeta(
    'defaultTdsRateBps',
  );
  @override
  late final GeneratedColumn<int> defaultTdsRateBps = GeneratedColumn<int>(
    'default_tds_rate_bps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    commissionRateBps,
    defaultTdsRateBps,
    isBuiltIn,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('commission_rate_bps')) {
      context.handle(
        _commissionRateBpsMeta,
        commissionRateBps.isAcceptableOrUnknown(
          data['commission_rate_bps']!,
          _commissionRateBpsMeta,
        ),
      );
    }
    if (data.containsKey('default_tds_rate_bps')) {
      context.handle(
        _defaultTdsRateBpsMeta,
        defaultTdsRateBps.isAcceptableOrUnknown(
          data['default_tds_rate_bps']!,
          _defaultTdsRateBpsMeta,
        ),
      );
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      commissionRateBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commission_rate_bps'],
      )!,
      defaultTdsRateBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_tds_rate_bps'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
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
  $PaymentSourcesTable createAlias(String alias) {
    return $PaymentSourcesTable(attachedDatabase, alias);
  }
}

class PaymentSourceRow extends DataClass
    implements Insertable<PaymentSourceRow> {
  final String id;
  final String displayName;
  final int commissionRateBps;
  final int defaultTdsRateBps;
  final bool isBuiltIn;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PaymentSourceRow({
    required this.id,
    required this.displayName,
    required this.commissionRateBps,
    required this.defaultTdsRateBps,
    required this.isBuiltIn,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['commission_rate_bps'] = Variable<int>(commissionRateBps);
    map['default_tds_rate_bps'] = Variable<int>(defaultTdsRateBps);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaymentSourcesCompanion toCompanion(bool nullToAbsent) {
    return PaymentSourcesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      commissionRateBps: Value(commissionRateBps),
      defaultTdsRateBps: Value(defaultTdsRateBps),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PaymentSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentSourceRow(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      commissionRateBps: serializer.fromJson<int>(json['commissionRateBps']),
      defaultTdsRateBps: serializer.fromJson<int>(json['defaultTdsRateBps']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'commissionRateBps': serializer.toJson<int>(commissionRateBps),
      'defaultTdsRateBps': serializer.toJson<int>(defaultTdsRateBps),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PaymentSourceRow copyWith({
    String? id,
    String? displayName,
    int? commissionRateBps,
    int? defaultTdsRateBps,
    bool? isBuiltIn,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PaymentSourceRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    commissionRateBps: commissionRateBps ?? this.commissionRateBps,
    defaultTdsRateBps: defaultTdsRateBps ?? this.defaultTdsRateBps,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PaymentSourceRow copyWithCompanion(PaymentSourcesCompanion data) {
    return PaymentSourceRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      commissionRateBps: data.commissionRateBps.present
          ? data.commissionRateBps.value
          : this.commissionRateBps,
      defaultTdsRateBps: data.defaultTdsRateBps.present
          ? data.defaultTdsRateBps.value
          : this.defaultTdsRateBps,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentSourceRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('commissionRateBps: $commissionRateBps, ')
          ..write('defaultTdsRateBps: $defaultTdsRateBps, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    commissionRateBps,
    defaultTdsRateBps,
    isBuiltIn,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentSourceRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.commissionRateBps == this.commissionRateBps &&
          other.defaultTdsRateBps == this.defaultTdsRateBps &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentSourcesCompanion extends UpdateCompanion<PaymentSourceRow> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<int> commissionRateBps;
  final Value<int> defaultTdsRateBps;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PaymentSourcesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.commissionRateBps = const Value.absent(),
    this.defaultTdsRateBps = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentSourcesCompanion.insert({
    required String id,
    required String displayName,
    this.commissionRateBps = const Value.absent(),
    this.defaultTdsRateBps = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PaymentSourceRow> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<int>? commissionRateBps,
    Expression<int>? defaultTdsRateBps,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (commissionRateBps != null) 'commission_rate_bps': commissionRateBps,
      if (defaultTdsRateBps != null) 'default_tds_rate_bps': defaultTdsRateBps,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<int>? commissionRateBps,
    Value<int>? defaultTdsRateBps,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaymentSourcesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      commissionRateBps: commissionRateBps ?? this.commissionRateBps,
      defaultTdsRateBps: defaultTdsRateBps ?? this.defaultTdsRateBps,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (commissionRateBps.present) {
      map['commission_rate_bps'] = Variable<int>(commissionRateBps.value);
    }
    if (defaultTdsRateBps.present) {
      map['default_tds_rate_bps'] = Variable<int>(defaultTdsRateBps.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('PaymentSourcesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('commissionRateBps: $commissionRateBps, ')
          ..write('defaultTdsRateBps: $defaultTdsRateBps, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientsTable extends Clients with TableInfo<$ClientsTable, ClientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 320),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    company,
    email,
    phone,
    notes,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class ClientRow extends DataClass implements Insertable<ClientRow> {
  final String id;
  final String name;
  final String? company;
  final String? email;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Non-null means archived. Soft delete keeps years of income history — and
  /// therefore the tax export — intact when a client relationship ends.
  final DateTime? archivedAt;
  const ClientRow({
    required this.id,
    required this.name,
    this.company,
    this.email,
    this.phone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      name: Value(name),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ClientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      company: serializer.fromJson<String?>(json['company']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'company': serializer.toJson<String?>(company),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ClientRow copyWith({
    String? id,
    String? name,
    Value<String?> company = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ClientRow(
    id: id ?? this.id,
    name: name ?? this.name,
    company: company.present ? company.value : this.company,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ClientRow copyWithCompanion(ClientsCompanion data) {
    return ClientRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      company: data.company.present ? data.company.value : this.company,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    company,
    email,
    phone,
    notes,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.company == this.company &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ClientsCompanion extends UpdateCompanion<ClientRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> company;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.company = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required String name,
    this.company = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ClientRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? company,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (company != null) 'company': company,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? company,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultSourceIdMeta = const VerificationMeta(
    'defaultSourceId',
  );
  @override
  late final GeneratedColumn<String> defaultSourceId = GeneratedColumn<String>(
    'default_source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payment_sources (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _defaultCurrencyMeta = const VerificationMeta(
    'defaultCurrency',
  );
  @override
  late final GeneratedColumn<String> defaultCurrency = GeneratedColumn<String>(
    'default_currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalRefMeta = const VerificationMeta(
    'externalRef',
  );
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
    'external_ref',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 128),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    name,
    description,
    defaultSourceId,
    defaultCurrency,
    externalRef,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('default_source_id')) {
      context.handle(
        _defaultSourceIdMeta,
        defaultSourceId.isAcceptableOrUnknown(
          data['default_source_id']!,
          _defaultSourceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultSourceIdMeta);
    }
    if (data.containsKey('default_currency')) {
      context.handle(
        _defaultCurrencyMeta,
        defaultCurrency.isAcceptableOrUnknown(
          data['default_currency']!,
          _defaultCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultCurrencyMeta);
    }
    if (data.containsKey('external_ref')) {
      context.handle(
        _externalRefMeta,
        externalRef.isAcceptableOrUnknown(
          data['external_ref']!,
          _externalRefMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      defaultSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_source_id'],
      )!,
      defaultCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_currency'],
      )!,
      externalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class ProjectRow extends DataClass implements Insertable<ProjectRow> {
  final String id;

  /// `ON DELETE CASCADE`: deleting a client is an explicit, confirmed action in
  /// the UI, and leaving orphaned projects behind would corrupt every total.
  final String clientId;
  final String name;
  final String? description;

  /// Prefill for new milestones only; the milestone's own source is what every
  /// report reads, so changing this never rewrites history.
  final String defaultSourceId;
  final String defaultCurrency;

  /// Platform contract/order id, used by Module 3 to auto-attach payments.
  final String? externalRef;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const ProjectRow({
    required this.id,
    required this.clientId,
    required this.name,
    this.description,
    required this.defaultSourceId,
    required this.defaultCurrency,
    this.externalRef,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['default_source_id'] = Variable<String>(defaultSourceId);
    map['default_currency'] = Variable<String>(defaultCurrency);
    if (!nullToAbsent || externalRef != null) {
      map['external_ref'] = Variable<String>(externalRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      defaultSourceId: Value(defaultSourceId),
      defaultCurrency: Value(defaultCurrency),
      externalRef: externalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRef),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ProjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRow(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      defaultSourceId: serializer.fromJson<String>(json['defaultSourceId']),
      defaultCurrency: serializer.fromJson<String>(json['defaultCurrency']),
      externalRef: serializer.fromJson<String?>(json['externalRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'defaultSourceId': serializer.toJson<String>(defaultSourceId),
      'defaultCurrency': serializer.toJson<String>(defaultCurrency),
      'externalRef': serializer.toJson<String?>(externalRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ProjectRow copyWith({
    String? id,
    String? clientId,
    String? name,
    Value<String?> description = const Value.absent(),
    String? defaultSourceId,
    String? defaultCurrency,
    Value<String?> externalRef = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ProjectRow(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    defaultSourceId: defaultSourceId ?? this.defaultSourceId,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    externalRef: externalRef.present ? externalRef.value : this.externalRef,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ProjectRow copyWithCompanion(ProjectsCompanion data) {
    return ProjectRow(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      defaultSourceId: data.defaultSourceId.present
          ? data.defaultSourceId.value
          : this.defaultSourceId,
      defaultCurrency: data.defaultCurrency.present
          ? data.defaultCurrency.value
          : this.defaultCurrency,
      externalRef: data.externalRef.present
          ? data.externalRef.value
          : this.externalRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRow(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('defaultSourceId: $defaultSourceId, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('externalRef: $externalRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    name,
    description,
    defaultSourceId,
    defaultCurrency,
    externalRef,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRow &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.description == this.description &&
          other.defaultSourceId == this.defaultSourceId &&
          other.defaultCurrency == this.defaultCurrency &&
          other.externalRef == this.externalRef &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ProjectsCompanion extends UpdateCompanion<ProjectRow> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> defaultSourceId;
  final Value<String> defaultCurrency;
  final Value<String?> externalRef;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.defaultSourceId = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String clientId,
    required String name,
    this.description = const Value.absent(),
    required String defaultSourceId,
    required String defaultCurrency,
    this.externalRef = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       name = Value(name),
       defaultSourceId = Value(defaultSourceId),
       defaultCurrency = Value(defaultCurrency),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectRow> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? defaultSourceId,
    Expression<String>? defaultCurrency,
    Expression<String>? externalRef,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (defaultSourceId != null) 'default_source_id': defaultSourceId,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (externalRef != null) 'external_ref': externalRef,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? defaultSourceId,
    Value<String>? defaultCurrency,
    Value<String?>? externalRef,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultSourceId: defaultSourceId ?? this.defaultSourceId,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      externalRef: externalRef ?? this.externalRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (defaultSourceId.present) {
      map['default_source_id'] = Variable<String>(defaultSourceId.value);
    }
    if (defaultCurrency.present) {
      map['default_currency'] = Variable<String>(defaultCurrency.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('defaultSourceId: $defaultSourceId, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('externalRef: $externalRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones
    with TableInfo<$MilestonesTable, MilestoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossAmountMinorMeta = const VerificationMeta(
    'grossAmountMinor',
  );
  @override
  late final GeneratedColumn<int> grossAmountMinor = GeneratedColumn<int>(
    'gross_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payment_sources (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _commissionRateBpsMeta = const VerificationMeta(
    'commissionRateBps',
  );
  @override
  late final GeneratedColumn<int> commissionRateBps = GeneratedColumn<int>(
    'commission_rate_bps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _tdsRateBpsMeta = const VerificationMeta(
    'tdsRateBps',
  );
  @override
  late final GeneratedColumn<int> tdsRateBps = GeneratedColumn<int>(
    'tds_rate_bps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MilestoneStage, String> stage =
      GeneratedColumn<String>(
        'stage',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MilestoneStage>($MilestonesTable.$converterstage);
  static const VerificationMeta _invoiceRefMeta = const VerificationMeta(
    'invoiceRef',
  );
  @override
  late final GeneratedColumn<String> invoiceRef = GeneratedColumn<String>(
    'invoice_ref',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 64),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoicedAtMeta = const VerificationMeta(
    'invoicedAt',
  );
  @override
  late final GeneratedColumn<DateTime> invoicedAt = GeneratedColumn<DateTime>(
    'invoiced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    title,
    grossAmountMinor,
    currency,
    dueDate,
    sourceId,
    commissionRateBps,
    tdsRateBps,
    stage,
    invoiceRef,
    invoicedAt,
    paidAt,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilestoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('gross_amount_minor')) {
      context.handle(
        _grossAmountMinorMeta,
        grossAmountMinor.isAcceptableOrUnknown(
          data['gross_amount_minor']!,
          _grossAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossAmountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('commission_rate_bps')) {
      context.handle(
        _commissionRateBpsMeta,
        commissionRateBps.isAcceptableOrUnknown(
          data['commission_rate_bps']!,
          _commissionRateBpsMeta,
        ),
      );
    }
    if (data.containsKey('tds_rate_bps')) {
      context.handle(
        _tdsRateBpsMeta,
        tdsRateBps.isAcceptableOrUnknown(
          data['tds_rate_bps']!,
          _tdsRateBpsMeta,
        ),
      );
    }
    if (data.containsKey('invoice_ref')) {
      context.handle(
        _invoiceRefMeta,
        invoiceRef.isAcceptableOrUnknown(data['invoice_ref']!, _invoiceRefMeta),
      );
    }
    if (data.containsKey('invoiced_at')) {
      context.handle(
        _invoicedAtMeta,
        invoicedAt.isAcceptableOrUnknown(data['invoiced_at']!, _invoicedAtMeta),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MilestoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilestoneRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      grossAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      commissionRateBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commission_rate_bps'],
      )!,
      tdsRateBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tds_rate_bps'],
      )!,
      stage: $MilestonesTable.$converterstage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}stage'],
        )!,
      ),
      invoiceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_ref'],
      ),
      invoicedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invoiced_at'],
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MilestoneStage, String, String> $converterstage =
      const EnumNameConverter<MilestoneStage>(MilestoneStage.values);
}

class MilestoneRow extends DataClass implements Insertable<MilestoneRow> {
  final String id;
  final String projectId;
  final String title;

  /// Billed amount in minor units. Deductions are applied on read so the
  /// originally agreed figure is never lost.
  final int grossAmountMinor;
  final String currency;

  /// Stored at local midnight: a due date is a calendar date, not an instant.
  final DateTime dueDate;
  final String sourceId;

  /// Rates snapshotted at creation, so historical rows keep reconciling after
  /// a platform changes its commission. See [Milestone.commissionRateBps].
  final int commissionRateBps;
  final int tdsRateBps;

  /// pending | invoiced | cancelled. `overdue` and `paid` are derived on read
  /// and deliberately not stored; see [MilestoneStage].
  final MilestoneStage stage;
  final String? invoiceRef;
  final DateTime? invoicedAt;

  /// Set by the repository when payments first cover the net amount, cleared if
  /// a payment is later removed. Cached rather than derived because Module 5's
  /// tax export needs to know *when* a milestone settled, which the payment
  /// rows alone do not say once there are several of them.
  final DateTime? paidAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MilestoneRow({
    required this.id,
    required this.projectId,
    required this.title,
    required this.grossAmountMinor,
    required this.currency,
    required this.dueDate,
    required this.sourceId,
    required this.commissionRateBps,
    required this.tdsRateBps,
    required this.stage,
    this.invoiceRef,
    this.invoicedAt,
    this.paidAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['title'] = Variable<String>(title);
    map['gross_amount_minor'] = Variable<int>(grossAmountMinor);
    map['currency'] = Variable<String>(currency);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['source_id'] = Variable<String>(sourceId);
    map['commission_rate_bps'] = Variable<int>(commissionRateBps);
    map['tds_rate_bps'] = Variable<int>(tdsRateBps);
    {
      map['stage'] = Variable<String>(
        $MilestonesTable.$converterstage.toSql(stage),
      );
    }
    if (!nullToAbsent || invoiceRef != null) {
      map['invoice_ref'] = Variable<String>(invoiceRef);
    }
    if (!nullToAbsent || invoicedAt != null) {
      map['invoiced_at'] = Variable<DateTime>(invoicedAt);
    }
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      title: Value(title),
      grossAmountMinor: Value(grossAmountMinor),
      currency: Value(currency),
      dueDate: Value(dueDate),
      sourceId: Value(sourceId),
      commissionRateBps: Value(commissionRateBps),
      tdsRateBps: Value(tdsRateBps),
      stage: Value(stage),
      invoiceRef: invoiceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceRef),
      invoicedAt: invoicedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(invoicedAt),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MilestoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilestoneRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      grossAmountMinor: serializer.fromJson<int>(json['grossAmountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      commissionRateBps: serializer.fromJson<int>(json['commissionRateBps']),
      tdsRateBps: serializer.fromJson<int>(json['tdsRateBps']),
      stage: $MilestonesTable.$converterstage.fromJson(
        serializer.fromJson<String>(json['stage']),
      ),
      invoiceRef: serializer.fromJson<String?>(json['invoiceRef']),
      invoicedAt: serializer.fromJson<DateTime?>(json['invoicedAt']),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'title': serializer.toJson<String>(title),
      'grossAmountMinor': serializer.toJson<int>(grossAmountMinor),
      'currency': serializer.toJson<String>(currency),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'sourceId': serializer.toJson<String>(sourceId),
      'commissionRateBps': serializer.toJson<int>(commissionRateBps),
      'tdsRateBps': serializer.toJson<int>(tdsRateBps),
      'stage': serializer.toJson<String>(
        $MilestonesTable.$converterstage.toJson(stage),
      ),
      'invoiceRef': serializer.toJson<String?>(invoiceRef),
      'invoicedAt': serializer.toJson<DateTime?>(invoicedAt),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MilestoneRow copyWith({
    String? id,
    String? projectId,
    String? title,
    int? grossAmountMinor,
    String? currency,
    DateTime? dueDate,
    String? sourceId,
    int? commissionRateBps,
    int? tdsRateBps,
    MilestoneStage? stage,
    Value<String?> invoiceRef = const Value.absent(),
    Value<DateTime?> invoicedAt = const Value.absent(),
    Value<DateTime?> paidAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MilestoneRow(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    grossAmountMinor: grossAmountMinor ?? this.grossAmountMinor,
    currency: currency ?? this.currency,
    dueDate: dueDate ?? this.dueDate,
    sourceId: sourceId ?? this.sourceId,
    commissionRateBps: commissionRateBps ?? this.commissionRateBps,
    tdsRateBps: tdsRateBps ?? this.tdsRateBps,
    stage: stage ?? this.stage,
    invoiceRef: invoiceRef.present ? invoiceRef.value : this.invoiceRef,
    invoicedAt: invoicedAt.present ? invoicedAt.value : this.invoicedAt,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MilestoneRow copyWithCompanion(MilestonesCompanion data) {
    return MilestoneRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      grossAmountMinor: data.grossAmountMinor.present
          ? data.grossAmountMinor.value
          : this.grossAmountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      commissionRateBps: data.commissionRateBps.present
          ? data.commissionRateBps.value
          : this.commissionRateBps,
      tdsRateBps: data.tdsRateBps.present
          ? data.tdsRateBps.value
          : this.tdsRateBps,
      stage: data.stage.present ? data.stage.value : this.stage,
      invoiceRef: data.invoiceRef.present
          ? data.invoiceRef.value
          : this.invoiceRef,
      invoicedAt: data.invoicedAt.present
          ? data.invoicedAt.value
          : this.invoicedAt,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('grossAmountMinor: $grossAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('dueDate: $dueDate, ')
          ..write('sourceId: $sourceId, ')
          ..write('commissionRateBps: $commissionRateBps, ')
          ..write('tdsRateBps: $tdsRateBps, ')
          ..write('stage: $stage, ')
          ..write('invoiceRef: $invoiceRef, ')
          ..write('invoicedAt: $invoicedAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    title,
    grossAmountMinor,
    currency,
    dueDate,
    sourceId,
    commissionRateBps,
    tdsRateBps,
    stage,
    invoiceRef,
    invoicedAt,
    paidAt,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilestoneRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.grossAmountMinor == this.grossAmountMinor &&
          other.currency == this.currency &&
          other.dueDate == this.dueDate &&
          other.sourceId == this.sourceId &&
          other.commissionRateBps == this.commissionRateBps &&
          other.tdsRateBps == this.tdsRateBps &&
          other.stage == this.stage &&
          other.invoiceRef == this.invoiceRef &&
          other.invoicedAt == this.invoicedAt &&
          other.paidAt == this.paidAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MilestonesCompanion extends UpdateCompanion<MilestoneRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> title;
  final Value<int> grossAmountMinor;
  final Value<String> currency;
  final Value<DateTime> dueDate;
  final Value<String> sourceId;
  final Value<int> commissionRateBps;
  final Value<int> tdsRateBps;
  final Value<MilestoneStage> stage;
  final Value<String?> invoiceRef;
  final Value<DateTime?> invoicedAt;
  final Value<DateTime?> paidAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.grossAmountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.commissionRateBps = const Value.absent(),
    this.tdsRateBps = const Value.absent(),
    this.stage = const Value.absent(),
    this.invoiceRef = const Value.absent(),
    this.invoicedAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestonesCompanion.insert({
    required String id,
    required String projectId,
    required String title,
    required int grossAmountMinor,
    required String currency,
    required DateTime dueDate,
    required String sourceId,
    this.commissionRateBps = const Value.absent(),
    this.tdsRateBps = const Value.absent(),
    required MilestoneStage stage,
    this.invoiceRef = const Value.absent(),
    this.invoicedAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       title = Value(title),
       grossAmountMinor = Value(grossAmountMinor),
       currency = Value(currency),
       dueDate = Value(dueDate),
       sourceId = Value(sourceId),
       stage = Value(stage),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MilestoneRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<int>? grossAmountMinor,
    Expression<String>? currency,
    Expression<DateTime>? dueDate,
    Expression<String>? sourceId,
    Expression<int>? commissionRateBps,
    Expression<int>? tdsRateBps,
    Expression<String>? stage,
    Expression<String>? invoiceRef,
    Expression<DateTime>? invoicedAt,
    Expression<DateTime>? paidAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (grossAmountMinor != null) 'gross_amount_minor': grossAmountMinor,
      if (currency != null) 'currency': currency,
      if (dueDate != null) 'due_date': dueDate,
      if (sourceId != null) 'source_id': sourceId,
      if (commissionRateBps != null) 'commission_rate_bps': commissionRateBps,
      if (tdsRateBps != null) 'tds_rate_bps': tdsRateBps,
      if (stage != null) 'stage': stage,
      if (invoiceRef != null) 'invoice_ref': invoiceRef,
      if (invoicedAt != null) 'invoiced_at': invoicedAt,
      if (paidAt != null) 'paid_at': paidAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestonesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? title,
    Value<int>? grossAmountMinor,
    Value<String>? currency,
    Value<DateTime>? dueDate,
    Value<String>? sourceId,
    Value<int>? commissionRateBps,
    Value<int>? tdsRateBps,
    Value<MilestoneStage>? stage,
    Value<String?>? invoiceRef,
    Value<DateTime?>? invoicedAt,
    Value<DateTime?>? paidAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MilestonesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      grossAmountMinor: grossAmountMinor ?? this.grossAmountMinor,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      sourceId: sourceId ?? this.sourceId,
      commissionRateBps: commissionRateBps ?? this.commissionRateBps,
      tdsRateBps: tdsRateBps ?? this.tdsRateBps,
      stage: stage ?? this.stage,
      invoiceRef: invoiceRef ?? this.invoiceRef,
      invoicedAt: invoicedAt ?? this.invoicedAt,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (grossAmountMinor.present) {
      map['gross_amount_minor'] = Variable<int>(grossAmountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (commissionRateBps.present) {
      map['commission_rate_bps'] = Variable<int>(commissionRateBps.value);
    }
    if (tdsRateBps.present) {
      map['tds_rate_bps'] = Variable<int>(tdsRateBps.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(
        $MilestonesTable.$converterstage.toSql(stage.value),
      );
    }
    if (invoiceRef.present) {
      map['invoice_ref'] = Variable<String>(invoiceRef.value);
    }
    if (invoicedAt.present) {
      map['invoiced_at'] = Variable<DateTime>(invoicedAt.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('grossAmountMinor: $grossAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('dueDate: $dueDate, ')
          ..write('sourceId: $sourceId, ')
          ..write('commissionRateBps: $commissionRateBps, ')
          ..write('tdsRateBps: $tdsRateBps, ')
          ..write('stage: $stage, ')
          ..write('invoiceRef: $invoiceRef, ')
          ..write('invoicedAt: $invoicedAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _milestoneIdMeta = const VerificationMeta(
    'milestoneId',
  );
  @override
  late final GeneratedColumn<String> milestoneId = GeneratedColumn<String>(
    'milestone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES milestones (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String> method =
      GeneratedColumn<String>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentMethod>($PaymentsTable.$convertermethod);
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 128),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalTxnIdMeta = const VerificationMeta(
    'externalTxnId',
  );
  @override
  late final GeneratedColumn<String> externalTxnId = GeneratedColumn<String>(
    'external_txn_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 128),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngestSource, String>
  ingestSource = GeneratedColumn<String>(
    'ingest_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<IngestSource>($PaymentsTable.$converteringestSource);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    milestoneId,
    amountMinor,
    currency,
    receivedAt,
    method,
    reference,
    externalTxnId,
    ingestSource,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('milestone_id')) {
      context.handle(
        _milestoneIdMeta,
        milestoneId.isAcceptableOrUnknown(
          data['milestone_id']!,
          _milestoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_milestoneIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('external_txn_id')) {
      context.handle(
        _externalTxnIdMeta,
        externalTxnId.isAcceptableOrUnknown(
          data['external_txn_id']!,
          _externalTxnIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      milestoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milestone_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      method: $PaymentsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}method'],
        )!,
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      externalTxnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_txn_id'],
      ),
      ingestSource: $PaymentsTable.$converteringestSource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ingest_source'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, String, String> $convertermethod =
      const EnumNameConverter<PaymentMethod>(PaymentMethod.values);
  static JsonTypeConverter2<IngestSource, String, String>
  $converteringestSource = const EnumNameConverter<IngestSource>(
    IngestSource.values,
  );
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final String milestoneId;

  /// Amount received, net of platform deductions, in minor units.
  final int amountMinor;
  final String currency;
  final DateTime receivedAt;
  final PaymentMethod method;

  /// UTR, cheque number, or whatever the user can reconcile against.
  final String? reference;

  /// Platform transaction id; part of the Module 3 dedupe key.
  final String? externalTxnId;

  /// Which ingestion path wrote this row — manual for everything Module 1
  /// creates. Kept from the first migration so automatic matches are auditable.
  final IngestSource ingestSource;
  final String? note;
  final DateTime createdAt;
  const PaymentRow({
    required this.id,
    required this.milestoneId,
    required this.amountMinor,
    required this.currency,
    required this.receivedAt,
    required this.method,
    this.reference,
    this.externalTxnId,
    required this.ingestSource,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['milestone_id'] = Variable<String>(milestoneId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['received_at'] = Variable<DateTime>(receivedAt);
    {
      map['method'] = Variable<String>(
        $PaymentsTable.$convertermethod.toSql(method),
      );
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || externalTxnId != null) {
      map['external_txn_id'] = Variable<String>(externalTxnId);
    }
    {
      map['ingest_source'] = Variable<String>(
        $PaymentsTable.$converteringestSource.toSql(ingestSource),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      milestoneId: Value(milestoneId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      receivedAt: Value(receivedAt),
      method: Value(method),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      externalTxnId: externalTxnId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalTxnId),
      ingestSource: Value(ingestSource),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      milestoneId: serializer.fromJson<String>(json['milestoneId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      method: $PaymentsTable.$convertermethod.fromJson(
        serializer.fromJson<String>(json['method']),
      ),
      reference: serializer.fromJson<String?>(json['reference']),
      externalTxnId: serializer.fromJson<String?>(json['externalTxnId']),
      ingestSource: $PaymentsTable.$converteringestSource.fromJson(
        serializer.fromJson<String>(json['ingestSource']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'milestoneId': serializer.toJson<String>(milestoneId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'method': serializer.toJson<String>(
        $PaymentsTable.$convertermethod.toJson(method),
      ),
      'reference': serializer.toJson<String?>(reference),
      'externalTxnId': serializer.toJson<String?>(externalTxnId),
      'ingestSource': serializer.toJson<String>(
        $PaymentsTable.$converteringestSource.toJson(ingestSource),
      ),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentRow copyWith({
    String? id,
    String? milestoneId,
    int? amountMinor,
    String? currency,
    DateTime? receivedAt,
    PaymentMethod? method,
    Value<String?> reference = const Value.absent(),
    Value<String?> externalTxnId = const Value.absent(),
    IngestSource? ingestSource,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => PaymentRow(
    id: id ?? this.id,
    milestoneId: milestoneId ?? this.milestoneId,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    receivedAt: receivedAt ?? this.receivedAt,
    method: method ?? this.method,
    reference: reference.present ? reference.value : this.reference,
    externalTxnId: externalTxnId.present
        ? externalTxnId.value
        : this.externalTxnId,
    ingestSource: ingestSource ?? this.ingestSource,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      milestoneId: data.milestoneId.present
          ? data.milestoneId.value
          : this.milestoneId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      method: data.method.present ? data.method.value : this.method,
      reference: data.reference.present ? data.reference.value : this.reference,
      externalTxnId: data.externalTxnId.present
          ? data.externalTxnId.value
          : this.externalTxnId,
      ingestSource: data.ingestSource.present
          ? data.ingestSource.value
          : this.ingestSource,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('externalTxnId: $externalTxnId, ')
          ..write('ingestSource: $ingestSource, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    milestoneId,
    amountMinor,
    currency,
    receivedAt,
    method,
    reference,
    externalTxnId,
    ingestSource,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.milestoneId == this.milestoneId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.receivedAt == this.receivedAt &&
          other.method == this.method &&
          other.reference == this.reference &&
          other.externalTxnId == this.externalTxnId &&
          other.ingestSource == this.ingestSource &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<String> milestoneId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<DateTime> receivedAt;
  final Value<PaymentMethod> method;
  final Value<String?> reference;
  final Value<String?> externalTxnId;
  final Value<IngestSource> ingestSource;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.milestoneId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    this.externalTxnId = const Value.absent(),
    this.ingestSource = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String milestoneId,
    required int amountMinor,
    required String currency,
    required DateTime receivedAt,
    required PaymentMethod method,
    this.reference = const Value.absent(),
    this.externalTxnId = const Value.absent(),
    required IngestSource ingestSource,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       milestoneId = Value(milestoneId),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       receivedAt = Value(receivedAt),
       method = Value(method),
       ingestSource = Value(ingestSource),
       createdAt = Value(createdAt);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<String>? milestoneId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<DateTime>? receivedAt,
    Expression<String>? method,
    Expression<String>? reference,
    Expression<String>? externalTxnId,
    Expression<String>? ingestSource,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (milestoneId != null) 'milestone_id': milestoneId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (receivedAt != null) 'received_at': receivedAt,
      if (method != null) 'method': method,
      if (reference != null) 'reference': reference,
      if (externalTxnId != null) 'external_txn_id': externalTxnId,
      if (ingestSource != null) 'ingest_source': ingestSource,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? milestoneId,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<DateTime>? receivedAt,
    Value<PaymentMethod>? method,
    Value<String?>? reference,
    Value<String?>? externalTxnId,
    Value<IngestSource>? ingestSource,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      milestoneId: milestoneId ?? this.milestoneId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      receivedAt: receivedAt ?? this.receivedAt,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      externalTxnId: externalTxnId ?? this.externalTxnId,
      ingestSource: ingestSource ?? this.ingestSource,
      note: note ?? this.note,
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
    if (milestoneId.present) {
      map['milestone_id'] = Variable<String>(milestoneId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(
        $PaymentsTable.$convertermethod.toSql(method.value),
      );
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (externalTxnId.present) {
      map['external_txn_id'] = Variable<String>(externalTxnId.value);
    }
    if (ingestSource.present) {
      map['ingest_source'] = Variable<String>(
        $PaymentsTable.$converteringestSource.toSql(ingestSource.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('externalTxnId: $externalTxnId, ')
          ..write('ingestSource: $ingestSource, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngestEventsTable extends IngestEvents
    with TableInfo<$IngestEventsTable, IngestEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngestEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngestSource, String> channel =
      GeneratedColumn<String>(
        'channel',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IngestSource>($IngestEventsTable.$converterchannel);
  static const VerificationMeta _grossAmountMinorMeta = const VerificationMeta(
    'grossAmountMinor',
  );
  @override
  late final GeneratedColumn<int> grossAmountMinor = GeneratedColumn<int>(
    'gross_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netAmountMinorMeta = const VerificationMeta(
    'netAmountMinor',
  );
  @override
  late final GeneratedColumn<int> netAmountMinor = GeneratedColumn<int>(
    'net_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalTxnIdMeta = const VerificationMeta(
    'externalTxnId',
  );
  @override
  late final GeneratedColumn<String> externalTxnId = GeneratedColumn<String>(
    'external_txn_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 128),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientHintMeta = const VerificationMeta(
    'clientHint',
  );
  @override
  late final GeneratedColumn<String> clientHint = GeneratedColumn<String>(
    'client_hint',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectHintMeta = const VerificationMeta(
    'projectHint',
  );
  @override
  late final GeneratedColumn<String> projectHint = GeneratedColumn<String>(
    'project_hint',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 128),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 400,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngestStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IngestStatus>($IngestEventsTable.$converterstatus);
  static const VerificationMeta _matchedMilestoneIdMeta =
      const VerificationMeta('matchedMilestoneId');
  @override
  late final GeneratedColumn<String> matchedMilestoneId =
      GeneratedColumn<String>(
        'matched_milestone_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES milestones (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _importedPaymentIdMeta = const VerificationMeta(
    'importedPaymentId',
  );
  @override
  late final GeneratedColumn<String> importedPaymentId =
      GeneratedColumn<String>(
        'imported_payment_id',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 64),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    channel,
    grossAmountMinor,
    netAmountMinor,
    currency,
    occurredAt,
    externalTxnId,
    clientHint,
    projectHint,
    description,
    raw,
    dedupeKey,
    status,
    matchedMilestoneId,
    importedPaymentId,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingest_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngestEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('gross_amount_minor')) {
      context.handle(
        _grossAmountMinorMeta,
        grossAmountMinor.isAcceptableOrUnknown(
          data['gross_amount_minor']!,
          _grossAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossAmountMinorMeta);
    }
    if (data.containsKey('net_amount_minor')) {
      context.handle(
        _netAmountMinorMeta,
        netAmountMinor.isAcceptableOrUnknown(
          data['net_amount_minor']!,
          _netAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('external_txn_id')) {
      context.handle(
        _externalTxnIdMeta,
        externalTxnId.isAcceptableOrUnknown(
          data['external_txn_id']!,
          _externalTxnIdMeta,
        ),
      );
    }
    if (data.containsKey('client_hint')) {
      context.handle(
        _clientHintMeta,
        clientHint.isAcceptableOrUnknown(data['client_hint']!, _clientHintMeta),
      );
    }
    if (data.containsKey('project_hint')) {
      context.handle(
        _projectHintMeta,
        projectHint.isAcceptableOrUnknown(
          data['project_hint']!,
          _projectHintMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    if (data.containsKey('matched_milestone_id')) {
      context.handle(
        _matchedMilestoneIdMeta,
        matchedMilestoneId.isAcceptableOrUnknown(
          data['matched_milestone_id']!,
          _matchedMilestoneIdMeta,
        ),
      );
    }
    if (data.containsKey('imported_payment_id')) {
      context.handle(
        _importedPaymentIdMeta,
        importedPaymentId.isAcceptableOrUnknown(
          data['imported_payment_id']!,
          _importedPaymentIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngestEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngestEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      channel: $IngestEventsTable.$converterchannel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}channel'],
        )!,
      ),
      grossAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_amount_minor'],
      )!,
      netAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      externalTxnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_txn_id'],
      ),
      clientHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_hint'],
      ),
      projectHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_hint'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw'],
      )!,
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      status: $IngestEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      matchedMilestoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_milestone_id'],
      ),
      importedPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imported_payment_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $IngestEventsTable createAlias(String alias) {
    return $IngestEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IngestSource, String, String> $converterchannel =
      const EnumNameConverter<IngestSource>(IngestSource.values);
  static JsonTypeConverter2<IngestStatus, String, String> $converterstatus =
      const EnumNameConverter<IngestStatus>(IngestStatus.values);
}

class IngestEventRow extends DataClass implements Insertable<IngestEventRow> {
  final String id;
  final String sourceId;

  /// Which of the three ingestion paths produced it.
  final IngestSource channel;
  final int grossAmountMinor;

  /// Net as the platform stated it; null when it only quoted one figure.
  final int? netAmountMinor;
  final String currency;
  final DateTime occurredAt;
  final String? externalTxnId;
  final String? clientHint;
  final String? projectHint;
  final String? description;

  /// The original CSV row or message text, kept so a mis-parse can be
  /// diagnosed from the record instead of by re-downloading the statement.
  final String raw;

  /// source + external id + amount + date. See `PaymentEvent.dedupeKey`.
  final String dedupeKey;

  /// pending | imported | ignored.
  final IngestStatus status;

  /// The milestone the user attached it to, once imported.
  ///
  /// `SET NULL` rather than cascade: if the milestone is later deleted, the
  /// record that this event was seen and handled must survive, or the next
  /// import would offer it again as new.
  final String? matchedMilestoneId;
  final String? importedPaymentId;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  const IngestEventRow({
    required this.id,
    required this.sourceId,
    required this.channel,
    required this.grossAmountMinor,
    this.netAmountMinor,
    required this.currency,
    required this.occurredAt,
    this.externalTxnId,
    this.clientHint,
    this.projectHint,
    this.description,
    required this.raw,
    required this.dedupeKey,
    required this.status,
    this.matchedMilestoneId,
    this.importedPaymentId,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    {
      map['channel'] = Variable<String>(
        $IngestEventsTable.$converterchannel.toSql(channel),
      );
    }
    map['gross_amount_minor'] = Variable<int>(grossAmountMinor);
    if (!nullToAbsent || netAmountMinor != null) {
      map['net_amount_minor'] = Variable<int>(netAmountMinor);
    }
    map['currency'] = Variable<String>(currency);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || externalTxnId != null) {
      map['external_txn_id'] = Variable<String>(externalTxnId);
    }
    if (!nullToAbsent || clientHint != null) {
      map['client_hint'] = Variable<String>(clientHint);
    }
    if (!nullToAbsent || projectHint != null) {
      map['project_hint'] = Variable<String>(projectHint);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['raw'] = Variable<String>(raw);
    map['dedupe_key'] = Variable<String>(dedupeKey);
    {
      map['status'] = Variable<String>(
        $IngestEventsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || matchedMilestoneId != null) {
      map['matched_milestone_id'] = Variable<String>(matchedMilestoneId);
    }
    if (!nullToAbsent || importedPaymentId != null) {
      map['imported_payment_id'] = Variable<String>(importedPaymentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  IngestEventsCompanion toCompanion(bool nullToAbsent) {
    return IngestEventsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      channel: Value(channel),
      grossAmountMinor: Value(grossAmountMinor),
      netAmountMinor: netAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(netAmountMinor),
      currency: Value(currency),
      occurredAt: Value(occurredAt),
      externalTxnId: externalTxnId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalTxnId),
      clientHint: clientHint == null && nullToAbsent
          ? const Value.absent()
          : Value(clientHint),
      projectHint: projectHint == null && nullToAbsent
          ? const Value.absent()
          : Value(projectHint),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      raw: Value(raw),
      dedupeKey: Value(dedupeKey),
      status: Value(status),
      matchedMilestoneId: matchedMilestoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedMilestoneId),
      importedPaymentId: importedPaymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(importedPaymentId),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory IngestEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngestEventRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      channel: $IngestEventsTable.$converterchannel.fromJson(
        serializer.fromJson<String>(json['channel']),
      ),
      grossAmountMinor: serializer.fromJson<int>(json['grossAmountMinor']),
      netAmountMinor: serializer.fromJson<int?>(json['netAmountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      externalTxnId: serializer.fromJson<String?>(json['externalTxnId']),
      clientHint: serializer.fromJson<String?>(json['clientHint']),
      projectHint: serializer.fromJson<String?>(json['projectHint']),
      description: serializer.fromJson<String?>(json['description']),
      raw: serializer.fromJson<String>(json['raw']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      status: $IngestEventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      matchedMilestoneId: serializer.fromJson<String?>(
        json['matchedMilestoneId'],
      ),
      importedPaymentId: serializer.fromJson<String?>(
        json['importedPaymentId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'channel': serializer.toJson<String>(
        $IngestEventsTable.$converterchannel.toJson(channel),
      ),
      'grossAmountMinor': serializer.toJson<int>(grossAmountMinor),
      'netAmountMinor': serializer.toJson<int?>(netAmountMinor),
      'currency': serializer.toJson<String>(currency),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'externalTxnId': serializer.toJson<String?>(externalTxnId),
      'clientHint': serializer.toJson<String?>(clientHint),
      'projectHint': serializer.toJson<String?>(projectHint),
      'description': serializer.toJson<String?>(description),
      'raw': serializer.toJson<String>(raw),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'status': serializer.toJson<String>(
        $IngestEventsTable.$converterstatus.toJson(status),
      ),
      'matchedMilestoneId': serializer.toJson<String?>(matchedMilestoneId),
      'importedPaymentId': serializer.toJson<String?>(importedPaymentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  IngestEventRow copyWith({
    String? id,
    String? sourceId,
    IngestSource? channel,
    int? grossAmountMinor,
    Value<int?> netAmountMinor = const Value.absent(),
    String? currency,
    DateTime? occurredAt,
    Value<String?> externalTxnId = const Value.absent(),
    Value<String?> clientHint = const Value.absent(),
    Value<String?> projectHint = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? raw,
    String? dedupeKey,
    IngestStatus? status,
    Value<String?> matchedMilestoneId = const Value.absent(),
    Value<String?> importedPaymentId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => IngestEventRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    channel: channel ?? this.channel,
    grossAmountMinor: grossAmountMinor ?? this.grossAmountMinor,
    netAmountMinor: netAmountMinor.present
        ? netAmountMinor.value
        : this.netAmountMinor,
    currency: currency ?? this.currency,
    occurredAt: occurredAt ?? this.occurredAt,
    externalTxnId: externalTxnId.present
        ? externalTxnId.value
        : this.externalTxnId,
    clientHint: clientHint.present ? clientHint.value : this.clientHint,
    projectHint: projectHint.present ? projectHint.value : this.projectHint,
    description: description.present ? description.value : this.description,
    raw: raw ?? this.raw,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    status: status ?? this.status,
    matchedMilestoneId: matchedMilestoneId.present
        ? matchedMilestoneId.value
        : this.matchedMilestoneId,
    importedPaymentId: importedPaymentId.present
        ? importedPaymentId.value
        : this.importedPaymentId,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  IngestEventRow copyWithCompanion(IngestEventsCompanion data) {
    return IngestEventRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      channel: data.channel.present ? data.channel.value : this.channel,
      grossAmountMinor: data.grossAmountMinor.present
          ? data.grossAmountMinor.value
          : this.grossAmountMinor,
      netAmountMinor: data.netAmountMinor.present
          ? data.netAmountMinor.value
          : this.netAmountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      externalTxnId: data.externalTxnId.present
          ? data.externalTxnId.value
          : this.externalTxnId,
      clientHint: data.clientHint.present
          ? data.clientHint.value
          : this.clientHint,
      projectHint: data.projectHint.present
          ? data.projectHint.value
          : this.projectHint,
      description: data.description.present
          ? data.description.value
          : this.description,
      raw: data.raw.present ? data.raw.value : this.raw,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      status: data.status.present ? data.status.value : this.status,
      matchedMilestoneId: data.matchedMilestoneId.present
          ? data.matchedMilestoneId.value
          : this.matchedMilestoneId,
      importedPaymentId: data.importedPaymentId.present
          ? data.importedPaymentId.value
          : this.importedPaymentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngestEventRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('channel: $channel, ')
          ..write('grossAmountMinor: $grossAmountMinor, ')
          ..write('netAmountMinor: $netAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('externalTxnId: $externalTxnId, ')
          ..write('clientHint: $clientHint, ')
          ..write('projectHint: $projectHint, ')
          ..write('description: $description, ')
          ..write('raw: $raw, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('status: $status, ')
          ..write('matchedMilestoneId: $matchedMilestoneId, ')
          ..write('importedPaymentId: $importedPaymentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    channel,
    grossAmountMinor,
    netAmountMinor,
    currency,
    occurredAt,
    externalTxnId,
    clientHint,
    projectHint,
    description,
    raw,
    dedupeKey,
    status,
    matchedMilestoneId,
    importedPaymentId,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngestEventRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.channel == this.channel &&
          other.grossAmountMinor == this.grossAmountMinor &&
          other.netAmountMinor == this.netAmountMinor &&
          other.currency == this.currency &&
          other.occurredAt == this.occurredAt &&
          other.externalTxnId == this.externalTxnId &&
          other.clientHint == this.clientHint &&
          other.projectHint == this.projectHint &&
          other.description == this.description &&
          other.raw == this.raw &&
          other.dedupeKey == this.dedupeKey &&
          other.status == this.status &&
          other.matchedMilestoneId == this.matchedMilestoneId &&
          other.importedPaymentId == this.importedPaymentId &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class IngestEventsCompanion extends UpdateCompanion<IngestEventRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<IngestSource> channel;
  final Value<int> grossAmountMinor;
  final Value<int?> netAmountMinor;
  final Value<String> currency;
  final Value<DateTime> occurredAt;
  final Value<String?> externalTxnId;
  final Value<String?> clientHint;
  final Value<String?> projectHint;
  final Value<String?> description;
  final Value<String> raw;
  final Value<String> dedupeKey;
  final Value<IngestStatus> status;
  final Value<String?> matchedMilestoneId;
  final Value<String?> importedPaymentId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const IngestEventsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.channel = const Value.absent(),
    this.grossAmountMinor = const Value.absent(),
    this.netAmountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.externalTxnId = const Value.absent(),
    this.clientHint = const Value.absent(),
    this.projectHint = const Value.absent(),
    this.description = const Value.absent(),
    this.raw = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.status = const Value.absent(),
    this.matchedMilestoneId = const Value.absent(),
    this.importedPaymentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngestEventsCompanion.insert({
    required String id,
    required String sourceId,
    required IngestSource channel,
    required int grossAmountMinor,
    this.netAmountMinor = const Value.absent(),
    required String currency,
    required DateTime occurredAt,
    this.externalTxnId = const Value.absent(),
    this.clientHint = const Value.absent(),
    this.projectHint = const Value.absent(),
    this.description = const Value.absent(),
    required String raw,
    required String dedupeKey,
    required IngestStatus status,
    this.matchedMilestoneId = const Value.absent(),
    this.importedPaymentId = const Value.absent(),
    required DateTime createdAt,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       channel = Value(channel),
       grossAmountMinor = Value(grossAmountMinor),
       currency = Value(currency),
       occurredAt = Value(occurredAt),
       raw = Value(raw),
       dedupeKey = Value(dedupeKey),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<IngestEventRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? channel,
    Expression<int>? grossAmountMinor,
    Expression<int>? netAmountMinor,
    Expression<String>? currency,
    Expression<DateTime>? occurredAt,
    Expression<String>? externalTxnId,
    Expression<String>? clientHint,
    Expression<String>? projectHint,
    Expression<String>? description,
    Expression<String>? raw,
    Expression<String>? dedupeKey,
    Expression<String>? status,
    Expression<String>? matchedMilestoneId,
    Expression<String>? importedPaymentId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (channel != null) 'channel': channel,
      if (grossAmountMinor != null) 'gross_amount_minor': grossAmountMinor,
      if (netAmountMinor != null) 'net_amount_minor': netAmountMinor,
      if (currency != null) 'currency': currency,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (externalTxnId != null) 'external_txn_id': externalTxnId,
      if (clientHint != null) 'client_hint': clientHint,
      if (projectHint != null) 'project_hint': projectHint,
      if (description != null) 'description': description,
      if (raw != null) 'raw': raw,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (status != null) 'status': status,
      if (matchedMilestoneId != null)
        'matched_milestone_id': matchedMilestoneId,
      if (importedPaymentId != null) 'imported_payment_id': importedPaymentId,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngestEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<IngestSource>? channel,
    Value<int>? grossAmountMinor,
    Value<int?>? netAmountMinor,
    Value<String>? currency,
    Value<DateTime>? occurredAt,
    Value<String?>? externalTxnId,
    Value<String?>? clientHint,
    Value<String?>? projectHint,
    Value<String?>? description,
    Value<String>? raw,
    Value<String>? dedupeKey,
    Value<IngestStatus>? status,
    Value<String?>? matchedMilestoneId,
    Value<String?>? importedPaymentId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return IngestEventsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      channel: channel ?? this.channel,
      grossAmountMinor: grossAmountMinor ?? this.grossAmountMinor,
      netAmountMinor: netAmountMinor ?? this.netAmountMinor,
      currency: currency ?? this.currency,
      occurredAt: occurredAt ?? this.occurredAt,
      externalTxnId: externalTxnId ?? this.externalTxnId,
      clientHint: clientHint ?? this.clientHint,
      projectHint: projectHint ?? this.projectHint,
      description: description ?? this.description,
      raw: raw ?? this.raw,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      status: status ?? this.status,
      matchedMilestoneId: matchedMilestoneId ?? this.matchedMilestoneId,
      importedPaymentId: importedPaymentId ?? this.importedPaymentId,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(
        $IngestEventsTable.$converterchannel.toSql(channel.value),
      );
    }
    if (grossAmountMinor.present) {
      map['gross_amount_minor'] = Variable<int>(grossAmountMinor.value);
    }
    if (netAmountMinor.present) {
      map['net_amount_minor'] = Variable<int>(netAmountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (externalTxnId.present) {
      map['external_txn_id'] = Variable<String>(externalTxnId.value);
    }
    if (clientHint.present) {
      map['client_hint'] = Variable<String>(clientHint.value);
    }
    if (projectHint.present) {
      map['project_hint'] = Variable<String>(projectHint.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $IngestEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (matchedMilestoneId.present) {
      map['matched_milestone_id'] = Variable<String>(matchedMilestoneId.value);
    }
    if (importedPaymentId.present) {
      map['imported_payment_id'] = Variable<String>(importedPaymentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngestEventsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('channel: $channel, ')
          ..write('grossAmountMinor: $grossAmountMinor, ')
          ..write('netAmountMinor: $netAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('externalTxnId: $externalTxnId, ')
          ..write('clientHint: $clientHint, ')
          ..write('projectHint: $projectHint, ')
          ..write('description: $description, ')
          ..write('raw: $raw, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('status: $status, ')
          ..write('matchedMilestoneId: $matchedMilestoneId, ')
          ..write('importedPaymentId: $importedPaymentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderLogTable extends ReminderLog
    with TableInfo<$ReminderLogTable, ReminderLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _milestoneIdMeta = const VerificationMeta(
    'milestoneId',
  );
  @override
  late final GeneratedColumn<String> milestoneId = GeneratedColumn<String>(
    'milestone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES milestones (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderTone, String> tone =
      GeneratedColumn<String>(
        'tone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderTone>($ReminderLogTable.$convertertone);
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipientMeta = const VerificationMeta(
    'recipient',
  );
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
    'recipient',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 320),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    milestoneId,
    clientId,
    tone,
    subject,
    body,
    recipient,
    sentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('milestone_id')) {
      context.handle(
        _milestoneIdMeta,
        milestoneId.isAcceptableOrUnknown(
          data['milestone_id']!,
          _milestoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_milestoneIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('recipient')) {
      context.handle(
        _recipientMeta,
        recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      milestoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milestone_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      tone: $ReminderLogTable.$convertertone.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tone'],
        )!,
      ),
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      recipient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient'],
      ),
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
    );
  }

  @override
  $ReminderLogTable createAlias(String alias) {
    return $ReminderLogTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderTone, String, String> $convertertone =
      const EnumNameConverter<ReminderTone>(ReminderTone.values);
}

class ReminderLogRow extends DataClass implements Insertable<ReminderLogRow> {
  final String id;
  final String milestoneId;

  /// Denormalised so the client's chase history survives a milestone being
  /// deleted, and so the history can be read without a join.
  final String clientId;

  /// nudge | firm | formal.
  final ReminderTone tone;
  final String subject;

  /// The text as it was actually sent, after any edits the user made. Stored so
  /// the record is of what went out, not of what the template would produce
  /// today.
  final String? body;
  final String? recipient;
  final DateTime sentAt;
  const ReminderLogRow({
    required this.id,
    required this.milestoneId,
    required this.clientId,
    required this.tone,
    required this.subject,
    this.body,
    this.recipient,
    required this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['milestone_id'] = Variable<String>(milestoneId);
    map['client_id'] = Variable<String>(clientId);
    {
      map['tone'] = Variable<String>(
        $ReminderLogTable.$convertertone.toSql(tone),
      );
    }
    map['subject'] = Variable<String>(subject);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || recipient != null) {
      map['recipient'] = Variable<String>(recipient);
    }
    map['sent_at'] = Variable<DateTime>(sentAt);
    return map;
  }

  ReminderLogCompanion toCompanion(bool nullToAbsent) {
    return ReminderLogCompanion(
      id: Value(id),
      milestoneId: Value(milestoneId),
      clientId: Value(clientId),
      tone: Value(tone),
      subject: Value(subject),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      recipient: recipient == null && nullToAbsent
          ? const Value.absent()
          : Value(recipient),
      sentAt: Value(sentAt),
    );
  }

  factory ReminderLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderLogRow(
      id: serializer.fromJson<String>(json['id']),
      milestoneId: serializer.fromJson<String>(json['milestoneId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      tone: $ReminderLogTable.$convertertone.fromJson(
        serializer.fromJson<String>(json['tone']),
      ),
      subject: serializer.fromJson<String>(json['subject']),
      body: serializer.fromJson<String?>(json['body']),
      recipient: serializer.fromJson<String?>(json['recipient']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'milestoneId': serializer.toJson<String>(milestoneId),
      'clientId': serializer.toJson<String>(clientId),
      'tone': serializer.toJson<String>(
        $ReminderLogTable.$convertertone.toJson(tone),
      ),
      'subject': serializer.toJson<String>(subject),
      'body': serializer.toJson<String?>(body),
      'recipient': serializer.toJson<String?>(recipient),
      'sentAt': serializer.toJson<DateTime>(sentAt),
    };
  }

  ReminderLogRow copyWith({
    String? id,
    String? milestoneId,
    String? clientId,
    ReminderTone? tone,
    String? subject,
    Value<String?> body = const Value.absent(),
    Value<String?> recipient = const Value.absent(),
    DateTime? sentAt,
  }) => ReminderLogRow(
    id: id ?? this.id,
    milestoneId: milestoneId ?? this.milestoneId,
    clientId: clientId ?? this.clientId,
    tone: tone ?? this.tone,
    subject: subject ?? this.subject,
    body: body.present ? body.value : this.body,
    recipient: recipient.present ? recipient.value : this.recipient,
    sentAt: sentAt ?? this.sentAt,
  );
  ReminderLogRow copyWithCompanion(ReminderLogCompanion data) {
    return ReminderLogRow(
      id: data.id.present ? data.id.value : this.id,
      milestoneId: data.milestoneId.present
          ? data.milestoneId.value
          : this.milestoneId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      tone: data.tone.present ? data.tone.value : this.tone,
      subject: data.subject.present ? data.subject.value : this.subject,
      body: data.body.present ? data.body.value : this.body,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderLogRow(')
          ..write('id: $id, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('clientId: $clientId, ')
          ..write('tone: $tone, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('recipient: $recipient, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    milestoneId,
    clientId,
    tone,
    subject,
    body,
    recipient,
    sentAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderLogRow &&
          other.id == this.id &&
          other.milestoneId == this.milestoneId &&
          other.clientId == this.clientId &&
          other.tone == this.tone &&
          other.subject == this.subject &&
          other.body == this.body &&
          other.recipient == this.recipient &&
          other.sentAt == this.sentAt);
}

class ReminderLogCompanion extends UpdateCompanion<ReminderLogRow> {
  final Value<String> id;
  final Value<String> milestoneId;
  final Value<String> clientId;
  final Value<ReminderTone> tone;
  final Value<String> subject;
  final Value<String?> body;
  final Value<String?> recipient;
  final Value<DateTime> sentAt;
  final Value<int> rowid;
  const ReminderLogCompanion({
    this.id = const Value.absent(),
    this.milestoneId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.tone = const Value.absent(),
    this.subject = const Value.absent(),
    this.body = const Value.absent(),
    this.recipient = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderLogCompanion.insert({
    required String id,
    required String milestoneId,
    required String clientId,
    required ReminderTone tone,
    required String subject,
    this.body = const Value.absent(),
    this.recipient = const Value.absent(),
    required DateTime sentAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       milestoneId = Value(milestoneId),
       clientId = Value(clientId),
       tone = Value(tone),
       subject = Value(subject),
       sentAt = Value(sentAt);
  static Insertable<ReminderLogRow> custom({
    Expression<String>? id,
    Expression<String>? milestoneId,
    Expression<String>? clientId,
    Expression<String>? tone,
    Expression<String>? subject,
    Expression<String>? body,
    Expression<String>? recipient,
    Expression<DateTime>? sentAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (milestoneId != null) 'milestone_id': milestoneId,
      if (clientId != null) 'client_id': clientId,
      if (tone != null) 'tone': tone,
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
      if (recipient != null) 'recipient': recipient,
      if (sentAt != null) 'sent_at': sentAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderLogCompanion copyWith({
    Value<String>? id,
    Value<String>? milestoneId,
    Value<String>? clientId,
    Value<ReminderTone>? tone,
    Value<String>? subject,
    Value<String?>? body,
    Value<String?>? recipient,
    Value<DateTime>? sentAt,
    Value<int>? rowid,
  }) {
    return ReminderLogCompanion(
      id: id ?? this.id,
      milestoneId: milestoneId ?? this.milestoneId,
      clientId: clientId ?? this.clientId,
      tone: tone ?? this.tone,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      recipient: recipient ?? this.recipient,
      sentAt: sentAt ?? this.sentAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (milestoneId.present) {
      map['milestone_id'] = Variable<String>(milestoneId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(
        $ReminderLogTable.$convertertone.toSql(tone.value),
      );
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderLogCompanion(')
          ..write('id: $id, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('clientId: $clientId, ')
          ..write('tone: $tone, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('recipient: $recipient, ')
          ..write('sentAt: $sentAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PayTrailDatabase extends GeneratedDatabase {
  _$PayTrailDatabase(QueryExecutor e) : super(e);
  $PayTrailDatabaseManager get managers => $PayTrailDatabaseManager(this);
  late final $PaymentSourcesTable paymentSources = $PaymentSourcesTable(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $IngestEventsTable ingestEvents = $IngestEventsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ReminderLogTable reminderLog = $ReminderLogTable(this);
  late final Index idxClientsArchived = Index(
    'idx_clients_archived',
    'CREATE INDEX idx_clients_archived ON clients (archived_at)',
  );
  late final Index idxProjectsClient = Index(
    'idx_projects_client',
    'CREATE INDEX idx_projects_client ON projects (client_id)',
  );
  late final Index idxMilestonesProject = Index(
    'idx_milestones_project',
    'CREATE INDEX idx_milestones_project ON milestones (project_id)',
  );
  late final Index idxMilestonesDue = Index(
    'idx_milestones_due',
    'CREATE INDEX idx_milestones_due ON milestones (due_date)',
  );
  late final Index idxMilestonesSource = Index(
    'idx_milestones_source',
    'CREATE INDEX idx_milestones_source ON milestones (source_id)',
  );
  late final Index idxPaymentsMilestone = Index(
    'idx_payments_milestone',
    'CREATE INDEX idx_payments_milestone ON payments (milestone_id)',
  );
  late final Index idxPaymentsReceived = Index(
    'idx_payments_received',
    'CREATE INDEX idx_payments_received ON payments (received_at)',
  );
  late final Index idxPaymentsExternalTxn = Index(
    'idx_payments_external_txn',
    'CREATE UNIQUE INDEX idx_payments_external_txn ON payments (external_txn_id) WHERE external_txn_id IS NOT NULL',
  );
  late final Index idxIngestStatus = Index(
    'idx_ingest_status',
    'CREATE INDEX idx_ingest_status ON ingest_events (status)',
  );
  late final Index idxIngestOccurred = Index(
    'idx_ingest_occurred',
    'CREATE INDEX idx_ingest_occurred ON ingest_events (occurred_at)',
  );
  late final Index idxIngestDedupe = Index(
    'idx_ingest_dedupe',
    'CREATE UNIQUE INDEX idx_ingest_dedupe ON ingest_events (dedupe_key)',
  );
  late final Index idxRemindersMilestone = Index(
    'idx_reminders_milestone',
    'CREATE INDEX idx_reminders_milestone ON reminder_log (milestone_id)',
  );
  late final Index idxRemindersClient = Index(
    'idx_reminders_client',
    'CREATE INDEX idx_reminders_client ON reminder_log (client_id)',
  );
  late final Index idxRemindersSent = Index(
    'idx_reminders_sent',
    'CREATE INDEX idx_reminders_sent ON reminder_log (sent_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    paymentSources,
    clients,
    projects,
    milestones,
    payments,
    ingestEvents,
    appSettings,
    reminderLog,
    idxClientsArchived,
    idxProjectsClient,
    idxMilestonesProject,
    idxMilestonesDue,
    idxMilestonesSource,
    idxPaymentsMilestone,
    idxPaymentsReceived,
    idxPaymentsExternalTxn,
    idxIngestStatus,
    idxIngestOccurred,
    idxIngestDedupe,
    idxRemindersMilestone,
    idxRemindersClient,
    idxRemindersSent,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('projects', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('milestones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'milestones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'milestones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ingest_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'milestones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_log', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_log', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PaymentSourcesTableCreateCompanionBuilder =
    PaymentSourcesCompanion Function({
      required String id,
      required String displayName,
      Value<int> commissionRateBps,
      Value<int> defaultTdsRateBps,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PaymentSourcesTableUpdateCompanionBuilder =
    PaymentSourcesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<int> commissionRateBps,
      Value<int> defaultTdsRateBps,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PaymentSourcesTableReferences
    extends
        BaseReferences<
          _$PayTrailDatabase,
          $PaymentSourcesTable,
          PaymentSourceRow
        > {
  $$PaymentSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProjectsTable, List<ProjectRow>>
  _projectsRefsTable(_$PayTrailDatabase db) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: 'payment_sources__id__projects__default_source_id',
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager($_db, $_db.projects).filter(
      (f) => f.defaultSourceId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MilestonesTable, List<MilestoneRow>>
  _milestonesRefsTable(_$PayTrailDatabase db) => MultiTypedResultKey.fromTable(
    db.milestones,
    aliasName: 'payment_sources__id__milestones__source_id',
  );

  $$MilestonesTableProcessedTableManager get milestonesRefs {
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_milestonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentSourcesTableFilterComposer
    extends Composer<_$PayTrailDatabase, $PaymentSourcesTable> {
  $$PaymentSourcesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commissionRateBps => $composableBuilder(
    column: $table.commissionRateBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTdsRateBps => $composableBuilder(
    column: $table.defaultTdsRateBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.defaultSourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> milestonesRefs(
    Expression<bool> Function($$MilestonesTableFilterComposer f) f,
  ) {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentSourcesTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $PaymentSourcesTable> {
  $$PaymentSourcesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commissionRateBps => $composableBuilder(
    column: $table.commissionRateBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTdsRateBps => $composableBuilder(
    column: $table.defaultTdsRateBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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
}

class $$PaymentSourcesTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $PaymentSourcesTable> {
  $$PaymentSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get commissionRateBps => $composableBuilder(
    column: $table.commissionRateBps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultTdsRateBps => $composableBuilder(
    column: $table.defaultTdsRateBps,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.defaultSourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> milestonesRefs<T extends Object>(
    Expression<T> Function($$MilestonesTableAnnotationComposer a) f,
  ) {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentSourcesTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $PaymentSourcesTable,
          PaymentSourceRow,
          $$PaymentSourcesTableFilterComposer,
          $$PaymentSourcesTableOrderingComposer,
          $$PaymentSourcesTableAnnotationComposer,
          $$PaymentSourcesTableCreateCompanionBuilder,
          $$PaymentSourcesTableUpdateCompanionBuilder,
          (PaymentSourceRow, $$PaymentSourcesTableReferences),
          PaymentSourceRow,
          PrefetchHooks Function({bool projectsRefs, bool milestonesRefs})
        > {
  $$PaymentSourcesTableTableManager(
    _$PayTrailDatabase db,
    $PaymentSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> commissionRateBps = const Value.absent(),
                Value<int> defaultTdsRateBps = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentSourcesCompanion(
                id: id,
                displayName: displayName,
                commissionRateBps: commissionRateBps,
                defaultTdsRateBps: defaultTdsRateBps,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<int> commissionRateBps = const Value.absent(),
                Value<int> defaultTdsRateBps = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentSourcesCompanion.insert(
                id: id,
                displayName: displayName,
                commissionRateBps: commissionRateBps,
                defaultTdsRateBps: defaultTdsRateBps,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentSourcesTable, PaymentSourceRow>(table),
                  $$PaymentSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectsRefs = false, milestonesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectsRefs) db.projects,
                    if (milestonesRefs) db.milestones,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectsRefs)
                        await $_getPrefetchedData<
                          PaymentSourceRow,
                          $PaymentSourcesTable,
                          ProjectRow
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentSourcesTableReferences
                              ._projectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.defaultSourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (milestonesRefs)
                        await $_getPrefetchedData<
                          PaymentSourceRow,
                          $PaymentSourcesTable,
                          MilestoneRow
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentSourcesTableReferences
                              ._milestonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).milestonesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
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

typedef $$PaymentSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $PaymentSourcesTable,
      PaymentSourceRow,
      $$PaymentSourcesTableFilterComposer,
      $$PaymentSourcesTableOrderingComposer,
      $$PaymentSourcesTableAnnotationComposer,
      $$PaymentSourcesTableCreateCompanionBuilder,
      $$PaymentSourcesTableUpdateCompanionBuilder,
      (PaymentSourceRow, $$PaymentSourcesTableReferences),
      PaymentSourceRow,
      PrefetchHooks Function({bool projectsRefs, bool milestonesRefs})
    >;
typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      required String id,
      required String name,
      Value<String?> company,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> company,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ClientsTableReferences
    extends BaseReferences<_$PayTrailDatabase, $ClientsTable, ClientRow> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<ProjectRow>>
  _projectsRefsTable(_$PayTrailDatabase db) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: 'clients__id__projects__client_id',
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderLogTable, List<ReminderLogRow>>
  _reminderLogRefsTable(_$PayTrailDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderLog,
    aliasName: 'clients__id__reminder_log__client_id',
  );

  $$ReminderLogTableProcessedTableManager get reminderLogRefs {
    final manager = $$ReminderLogTableTableManager(
      $_db,
      $_db.reminderLog,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$PayTrailDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderLogRefs(
    Expression<bool> Function($$ReminderLogTableFilterComposer f) f,
  ) {
    final $$ReminderLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLog,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogTableFilterComposer(
            $db: $db,
            $table: $db.reminderLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderLogRefs<T extends Object>(
    Expression<T> Function($$ReminderLogTableAnnotationComposer a) f,
  ) {
    final $$ReminderLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLog,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $ClientsTable,
          ClientRow,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (ClientRow, $$ClientsTableReferences),
          ClientRow,
          PrefetchHooks Function({bool projectsRefs, bool reminderLogRefs})
        > {
  $$ClientsTableTableManager(_$PayTrailDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                name: name,
                company: company,
                email: email,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> company = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                name: name,
                company: company,
                email: email,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientsTable, ClientRow>(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectsRefs = false, reminderLogRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectsRefs) db.projects,
                    if (reminderLogRefs) db.reminderLog,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectsRefs)
                        await $_getPrefetchedData<
                          ClientRow,
                          $ClientsTable,
                          ProjectRow
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._projectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderLogRefs)
                        await $_getPrefetchedData<
                          ClientRow,
                          $ClientsTable,
                          ReminderLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._reminderLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
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

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $ClientsTable,
      ClientRow,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (ClientRow, $$ClientsTableReferences),
      ClientRow,
      PrefetchHooks Function({bool projectsRefs, bool reminderLogRefs})
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String clientId,
      required String name,
      Value<String?> description,
      required String defaultSourceId,
      required String defaultCurrency,
      Value<String?> externalRef,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> name,
      Value<String?> description,
      Value<String> defaultSourceId,
      Value<String> defaultCurrency,
      Value<String?> externalRef,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$PayTrailDatabase, $ProjectsTable, ProjectRow> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$PayTrailDatabase db) =>
      db.clients.createAlias('projects__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentSourcesTable _defaultSourceIdTable(_$PayTrailDatabase db) => db
      .paymentSources
      .createAlias('projects__default_source_id__payment_sources__id');

  $$PaymentSourcesTableProcessedTableManager get defaultSourceId {
    final $_column = $_itemColumn<String>('default_source_id')!;

    final manager = $$PaymentSourcesTableTableManager(
      $_db,
      $_db.paymentSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defaultSourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MilestonesTable, List<MilestoneRow>>
  _milestonesRefsTable(_$PayTrailDatabase db) => MultiTypedResultKey.fromTable(
    db.milestones,
    aliasName: 'projects__id__milestones__project_id',
  );

  $$MilestonesTableProcessedTableManager get milestonesRefs {
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_milestonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$PayTrailDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
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

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentSourcesTableFilterComposer get defaultSourceId {
    final $$PaymentSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultSourceId,
      referencedTable: $db.paymentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSourcesTableFilterComposer(
            $db: $db,
            $table: $db.paymentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> milestonesRefs(
    Expression<bool> Function($$MilestonesTableFilterComposer f) f,
  ) {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
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

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentSourcesTableOrderingComposer get defaultSourceId {
    final $$PaymentSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultSourceId,
      referencedTable: $db.paymentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.paymentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentSourcesTableAnnotationComposer get defaultSourceId {
    final $$PaymentSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultSourceId,
      referencedTable: $db.paymentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> milestonesRefs<T extends Object>(
    Expression<T> Function($$MilestonesTableAnnotationComposer a) f,
  ) {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $ProjectsTable,
          ProjectRow,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (ProjectRow, $$ProjectsTableReferences),
          ProjectRow,
          PrefetchHooks Function({
            bool clientId,
            bool defaultSourceId,
            bool milestonesRefs,
          })
        > {
  $$ProjectsTableTableManager(_$PayTrailDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> defaultSourceId = const Value.absent(),
                Value<String> defaultCurrency = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                clientId: clientId,
                name: name,
                description: description,
                defaultSourceId: defaultSourceId,
                defaultCurrency: defaultCurrency,
                externalRef: externalRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String name,
                Value<String?> description = const Value.absent(),
                required String defaultSourceId,
                required String defaultCurrency,
                Value<String?> externalRef = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                clientId: clientId,
                name: name,
                description: description,
                defaultSourceId: defaultSourceId,
                defaultCurrency: defaultCurrency,
                externalRef: externalRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, ProjectRow>(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                defaultSourceId = false,
                milestonesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (milestonesRefs) db.milestones],
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
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable: $$ProjectsTableReferences
                                        ._clientIdTable(db),
                                    referencedColumn: $$ProjectsTableReferences
                                        ._clientIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (defaultSourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.defaultSourceId,
                                    referencedTable: $$ProjectsTableReferences
                                        ._defaultSourceIdTable(db),
                                    referencedColumn: $$ProjectsTableReferences
                                        ._defaultSourceIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (milestonesRefs)
                        await $_getPrefetchedData<
                          ProjectRow,
                          $ProjectsTable,
                          MilestoneRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._milestonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).milestonesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
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

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $ProjectsTable,
      ProjectRow,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (ProjectRow, $$ProjectsTableReferences),
      ProjectRow,
      PrefetchHooks Function({
        bool clientId,
        bool defaultSourceId,
        bool milestonesRefs,
      })
    >;
typedef $$MilestonesTableCreateCompanionBuilder =
    MilestonesCompanion Function({
      required String id,
      required String projectId,
      required String title,
      required int grossAmountMinor,
      required String currency,
      required DateTime dueDate,
      required String sourceId,
      Value<int> commissionRateBps,
      Value<int> tdsRateBps,
      required MilestoneStage stage,
      Value<String?> invoiceRef,
      Value<DateTime?> invoicedAt,
      Value<DateTime?> paidAt,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MilestonesTableUpdateCompanionBuilder =
    MilestonesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> title,
      Value<int> grossAmountMinor,
      Value<String> currency,
      Value<DateTime> dueDate,
      Value<String> sourceId,
      Value<int> commissionRateBps,
      Value<int> tdsRateBps,
      Value<MilestoneStage> stage,
      Value<String?> invoiceRef,
      Value<DateTime?> invoicedAt,
      Value<DateTime?> paidAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MilestonesTableReferences
    extends BaseReferences<_$PayTrailDatabase, $MilestonesTable, MilestoneRow> {
  $$MilestonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$PayTrailDatabase db) =>
      db.projects.createAlias('milestones__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentSourcesTable _sourceIdTable(_$PayTrailDatabase db) => db
      .paymentSources
      .createAlias('milestones__source_id__payment_sources__id');

  $$PaymentSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$PaymentSourcesTableTableManager(
      $_db,
      $_db.paymentSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$PayTrailDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'milestones__id__payments__milestone_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.milestoneId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IngestEventsTable, List<IngestEventRow>>
  _ingestEventsRefsTable(_$PayTrailDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ingestEvents,
        aliasName: 'milestones__id__ingest_events__matched_milestone_id',
      );

  $$IngestEventsTableProcessedTableManager get ingestEventsRefs {
    final manager = $$IngestEventsTableTableManager($_db, $_db.ingestEvents)
        .filter(
          (f) => f.matchedMilestoneId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_ingestEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderLogTable, List<ReminderLogRow>>
  _reminderLogRefsTable(_$PayTrailDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderLog,
    aliasName: 'milestones__id__reminder_log__milestone_id',
  );

  $$ReminderLogTableProcessedTableManager get reminderLogRefs {
    final manager = $$ReminderLogTableTableManager(
      $_db,
      $_db.reminderLog,
    ).filter((f) => f.milestoneId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MilestonesTableFilterComposer
    extends Composer<_$PayTrailDatabase, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossAmountMinor => $composableBuilder(
    column: $table.grossAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commissionRateBps => $composableBuilder(
    column: $table.commissionRateBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tdsRateBps => $composableBuilder(
    column: $table.tdsRateBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MilestoneStage, MilestoneStage, String>
  get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get invoiceRef => $composableBuilder(
    column: $table.invoiceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invoicedAt => $composableBuilder(
    column: $table.invoicedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentSourcesTableFilterComposer get sourceId {
    final $$PaymentSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.paymentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSourcesTableFilterComposer(
            $db: $db,
            $table: $db.paymentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ingestEventsRefs(
    Expression<bool> Function($$IngestEventsTableFilterComposer f) f,
  ) {
    final $$IngestEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingestEvents,
      getReferencedColumn: (t) => t.matchedMilestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngestEventsTableFilterComposer(
            $db: $db,
            $table: $db.ingestEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderLogRefs(
    Expression<bool> Function($$ReminderLogTableFilterComposer f) f,
  ) {
    final $$ReminderLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLog,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogTableFilterComposer(
            $db: $db,
            $table: $db.reminderLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilestonesTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossAmountMinor => $composableBuilder(
    column: $table.grossAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commissionRateBps => $composableBuilder(
    column: $table.commissionRateBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tdsRateBps => $composableBuilder(
    column: $table.tdsRateBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceRef => $composableBuilder(
    column: $table.invoiceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invoicedAt => $composableBuilder(
    column: $table.invoicedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentSourcesTableOrderingComposer get sourceId {
    final $$PaymentSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.paymentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.paymentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get grossAmountMinor => $composableBuilder(
    column: $table.grossAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get commissionRateBps => $composableBuilder(
    column: $table.commissionRateBps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tdsRateBps => $composableBuilder(
    column: $table.tdsRateBps,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MilestoneStage, String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get invoiceRef => $composableBuilder(
    column: $table.invoiceRef,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get invoicedAt => $composableBuilder(
    column: $table.invoicedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentSourcesTableAnnotationComposer get sourceId {
    final $$PaymentSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.paymentSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ingestEventsRefs<T extends Object>(
    Expression<T> Function($$IngestEventsTableAnnotationComposer a) f,
  ) {
    final $$IngestEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ingestEvents,
      getReferencedColumn: (t) => t.matchedMilestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngestEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingestEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderLogRefs<T extends Object>(
    Expression<T> Function($$ReminderLogTableAnnotationComposer a) f,
  ) {
    final $$ReminderLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderLog,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderLogTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilestonesTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $MilestonesTable,
          MilestoneRow,
          $$MilestonesTableFilterComposer,
          $$MilestonesTableOrderingComposer,
          $$MilestonesTableAnnotationComposer,
          $$MilestonesTableCreateCompanionBuilder,
          $$MilestonesTableUpdateCompanionBuilder,
          (MilestoneRow, $$MilestonesTableReferences),
          MilestoneRow,
          PrefetchHooks Function({
            bool projectId,
            bool sourceId,
            bool paymentsRefs,
            bool ingestEventsRefs,
            bool reminderLogRefs,
          })
        > {
  $$MilestonesTableTableManager(_$PayTrailDatabase db, $MilestonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> grossAmountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<int> commissionRateBps = const Value.absent(),
                Value<int> tdsRateBps = const Value.absent(),
                Value<MilestoneStage> stage = const Value.absent(),
                Value<String?> invoiceRef = const Value.absent(),
                Value<DateTime?> invoicedAt = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion(
                id: id,
                projectId: projectId,
                title: title,
                grossAmountMinor: grossAmountMinor,
                currency: currency,
                dueDate: dueDate,
                sourceId: sourceId,
                commissionRateBps: commissionRateBps,
                tdsRateBps: tdsRateBps,
                stage: stage,
                invoiceRef: invoiceRef,
                invoicedAt: invoicedAt,
                paidAt: paidAt,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String title,
                required int grossAmountMinor,
                required String currency,
                required DateTime dueDate,
                required String sourceId,
                Value<int> commissionRateBps = const Value.absent(),
                Value<int> tdsRateBps = const Value.absent(),
                required MilestoneStage stage,
                Value<String?> invoiceRef = const Value.absent(),
                Value<DateTime?> invoicedAt = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion.insert(
                id: id,
                projectId: projectId,
                title: title,
                grossAmountMinor: grossAmountMinor,
                currency: currency,
                dueDate: dueDate,
                sourceId: sourceId,
                commissionRateBps: commissionRateBps,
                tdsRateBps: tdsRateBps,
                stage: stage,
                invoiceRef: invoiceRef,
                invoicedAt: invoicedAt,
                paidAt: paidAt,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilestonesTable, MilestoneRow>(table),
                  $$MilestonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                sourceId = false,
                paymentsRefs = false,
                ingestEventsRefs = false,
                reminderLogRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsRefs) db.payments,
                    if (ingestEventsRefs) db.ingestEvents,
                    if (reminderLogRefs) db.reminderLog,
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$MilestonesTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn:
                                        $$MilestonesTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable: $$MilestonesTableReferences
                                        ._sourceIdTable(db),
                                    referencedColumn:
                                        $$MilestonesTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          MilestoneRow,
                          $MilestonesTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$MilestonesTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MilestonesTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.milestoneId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ingestEventsRefs)
                        await $_getPrefetchedData<
                          MilestoneRow,
                          $MilestonesTable,
                          IngestEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$MilestonesTableReferences
                              ._ingestEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MilestonesTableReferences(
                                db,
                                table,
                                p0,
                              ).ingestEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.matchedMilestoneId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderLogRefs)
                        await $_getPrefetchedData<
                          MilestoneRow,
                          $MilestonesTable,
                          ReminderLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$MilestonesTableReferences
                              ._reminderLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MilestonesTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.milestoneId == item.id,
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

typedef $$MilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $MilestonesTable,
      MilestoneRow,
      $$MilestonesTableFilterComposer,
      $$MilestonesTableOrderingComposer,
      $$MilestonesTableAnnotationComposer,
      $$MilestonesTableCreateCompanionBuilder,
      $$MilestonesTableUpdateCompanionBuilder,
      (MilestoneRow, $$MilestonesTableReferences),
      MilestoneRow,
      PrefetchHooks Function({
        bool projectId,
        bool sourceId,
        bool paymentsRefs,
        bool ingestEventsRefs,
        bool reminderLogRefs,
      })
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String milestoneId,
      required int amountMinor,
      required String currency,
      required DateTime receivedAt,
      required PaymentMethod method,
      Value<String?> reference,
      Value<String?> externalTxnId,
      required IngestSource ingestSource,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> milestoneId,
      Value<int> amountMinor,
      Value<String> currency,
      Value<DateTime> receivedAt,
      Value<PaymentMethod> method,
      Value<String?> reference,
      Value<String?> externalTxnId,
      Value<IngestSource> ingestSource,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$PayTrailDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MilestonesTable _milestoneIdTable(_$PayTrailDatabase db) =>
      db.milestones.createAlias('payments__milestone_id__milestones__id');

  $$MilestonesTableProcessedTableManager get milestoneId {
    final $_column = $_itemColumn<String>('milestone_id')!;

    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_milestoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$PayTrailDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalTxnId => $composableBuilder(
    column: $table.externalTxnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IngestSource, IngestSource, String>
  get ingestSource => $composableBuilder(
    column: $table.ingestSource,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MilestonesTableFilterComposer get milestoneId {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalTxnId => $composableBuilder(
    column: $table.externalTxnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingestSource => $composableBuilder(
    column: $table.ingestSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MilestonesTableOrderingComposer get milestoneId {
    final $$MilestonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableOrderingComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get externalTxnId => $composableBuilder(
    column: $table.externalTxnId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IngestSource, String> get ingestSource =>
      $composableBuilder(
        column: $table.ingestSource,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MilestonesTableAnnotationComposer get milestoneId {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool milestoneId})
        > {
  $$PaymentsTableTableManager(_$PayTrailDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> milestoneId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<PaymentMethod> method = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> externalTxnId = const Value.absent(),
                Value<IngestSource> ingestSource = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                milestoneId: milestoneId,
                amountMinor: amountMinor,
                currency: currency,
                receivedAt: receivedAt,
                method: method,
                reference: reference,
                externalTxnId: externalTxnId,
                ingestSource: ingestSource,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String milestoneId,
                required int amountMinor,
                required String currency,
                required DateTime receivedAt,
                required PaymentMethod method,
                Value<String?> reference = const Value.absent(),
                Value<String?> externalTxnId = const Value.absent(),
                required IngestSource ingestSource,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                milestoneId: milestoneId,
                amountMinor: amountMinor,
                currency: currency,
                receivedAt: receivedAt,
                method: method,
                reference: reference,
                externalTxnId: externalTxnId,
                ingestSource: ingestSource,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, PaymentRow>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({milestoneId = false}) {
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
                    if (milestoneId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.milestoneId,
                                referencedTable: $$PaymentsTableReferences
                                    ._milestoneIdTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._milestoneIdTable(db)
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool milestoneId})
    >;
typedef $$IngestEventsTableCreateCompanionBuilder =
    IngestEventsCompanion Function({
      required String id,
      required String sourceId,
      required IngestSource channel,
      required int grossAmountMinor,
      Value<int?> netAmountMinor,
      required String currency,
      required DateTime occurredAt,
      Value<String?> externalTxnId,
      Value<String?> clientHint,
      Value<String?> projectHint,
      Value<String?> description,
      required String raw,
      required String dedupeKey,
      required IngestStatus status,
      Value<String?> matchedMilestoneId,
      Value<String?> importedPaymentId,
      required DateTime createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$IngestEventsTableUpdateCompanionBuilder =
    IngestEventsCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<IngestSource> channel,
      Value<int> grossAmountMinor,
      Value<int?> netAmountMinor,
      Value<String> currency,
      Value<DateTime> occurredAt,
      Value<String?> externalTxnId,
      Value<String?> clientHint,
      Value<String?> projectHint,
      Value<String?> description,
      Value<String> raw,
      Value<String> dedupeKey,
      Value<IngestStatus> status,
      Value<String?> matchedMilestoneId,
      Value<String?> importedPaymentId,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

final class $$IngestEventsTableReferences
    extends
        BaseReferences<_$PayTrailDatabase, $IngestEventsTable, IngestEventRow> {
  $$IngestEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MilestonesTable _matchedMilestoneIdTable(_$PayTrailDatabase db) => db
      .milestones
      .createAlias('ingest_events__matched_milestone_id__milestones__id');

  $$MilestonesTableProcessedTableManager? get matchedMilestoneId {
    final $_column = $_itemColumn<String>('matched_milestone_id');
    if ($_column == null) return null;
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchedMilestoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IngestEventsTableFilterComposer
    extends Composer<_$PayTrailDatabase, $IngestEventsTable> {
  $$IngestEventsTableFilterComposer({
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

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IngestSource, IngestSource, String>
  get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get grossAmountMinor => $composableBuilder(
    column: $table.grossAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netAmountMinor => $composableBuilder(
    column: $table.netAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalTxnId => $composableBuilder(
    column: $table.externalTxnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientHint => $composableBuilder(
    column: $table.clientHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectHint => $composableBuilder(
    column: $table.projectHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IngestStatus, IngestStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get importedPaymentId => $composableBuilder(
    column: $table.importedPaymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MilestonesTableFilterComposer get matchedMilestoneId {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchedMilestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngestEventsTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $IngestEventsTable> {
  $$IngestEventsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossAmountMinor => $composableBuilder(
    column: $table.grossAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netAmountMinor => $composableBuilder(
    column: $table.netAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalTxnId => $composableBuilder(
    column: $table.externalTxnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientHint => $composableBuilder(
    column: $table.clientHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectHint => $composableBuilder(
    column: $table.projectHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importedPaymentId => $composableBuilder(
    column: $table.importedPaymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MilestonesTableOrderingComposer get matchedMilestoneId {
    final $$MilestonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchedMilestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableOrderingComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngestEventsTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $IngestEventsTable> {
  $$IngestEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IngestSource, String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<int> get grossAmountMinor => $composableBuilder(
    column: $table.grossAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netAmountMinor => $composableBuilder(
    column: $table.netAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalTxnId => $composableBuilder(
    column: $table.externalTxnId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientHint => $composableBuilder(
    column: $table.clientHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectHint => $composableBuilder(
    column: $table.projectHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IngestStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get importedPaymentId => $composableBuilder(
    column: $table.importedPaymentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  $$MilestonesTableAnnotationComposer get matchedMilestoneId {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchedMilestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IngestEventsTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $IngestEventsTable,
          IngestEventRow,
          $$IngestEventsTableFilterComposer,
          $$IngestEventsTableOrderingComposer,
          $$IngestEventsTableAnnotationComposer,
          $$IngestEventsTableCreateCompanionBuilder,
          $$IngestEventsTableUpdateCompanionBuilder,
          (IngestEventRow, $$IngestEventsTableReferences),
          IngestEventRow,
          PrefetchHooks Function({bool matchedMilestoneId})
        > {
  $$IngestEventsTableTableManager(
    _$PayTrailDatabase db,
    $IngestEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngestEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngestEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngestEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<IngestSource> channel = const Value.absent(),
                Value<int> grossAmountMinor = const Value.absent(),
                Value<int?> netAmountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> externalTxnId = const Value.absent(),
                Value<String?> clientHint = const Value.absent(),
                Value<String?> projectHint = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> raw = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<IngestStatus> status = const Value.absent(),
                Value<String?> matchedMilestoneId = const Value.absent(),
                Value<String?> importedPaymentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngestEventsCompanion(
                id: id,
                sourceId: sourceId,
                channel: channel,
                grossAmountMinor: grossAmountMinor,
                netAmountMinor: netAmountMinor,
                currency: currency,
                occurredAt: occurredAt,
                externalTxnId: externalTxnId,
                clientHint: clientHint,
                projectHint: projectHint,
                description: description,
                raw: raw,
                dedupeKey: dedupeKey,
                status: status,
                matchedMilestoneId: matchedMilestoneId,
                importedPaymentId: importedPaymentId,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required IngestSource channel,
                required int grossAmountMinor,
                Value<int?> netAmountMinor = const Value.absent(),
                required String currency,
                required DateTime occurredAt,
                Value<String?> externalTxnId = const Value.absent(),
                Value<String?> clientHint = const Value.absent(),
                Value<String?> projectHint = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String raw,
                required String dedupeKey,
                required IngestStatus status,
                Value<String?> matchedMilestoneId = const Value.absent(),
                Value<String?> importedPaymentId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngestEventsCompanion.insert(
                id: id,
                sourceId: sourceId,
                channel: channel,
                grossAmountMinor: grossAmountMinor,
                netAmountMinor: netAmountMinor,
                currency: currency,
                occurredAt: occurredAt,
                externalTxnId: externalTxnId,
                clientHint: clientHint,
                projectHint: projectHint,
                description: description,
                raw: raw,
                dedupeKey: dedupeKey,
                status: status,
                matchedMilestoneId: matchedMilestoneId,
                importedPaymentId: importedPaymentId,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IngestEventsTable, IngestEventRow>(table),
                  $$IngestEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({matchedMilestoneId = false}) {
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
                    if (matchedMilestoneId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.matchedMilestoneId,
                                referencedTable: $$IngestEventsTableReferences
                                    ._matchedMilestoneIdTable(db),
                                referencedColumn: $$IngestEventsTableReferences
                                    ._matchedMilestoneIdTable(db)
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

typedef $$IngestEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $IngestEventsTable,
      IngestEventRow,
      $$IngestEventsTableFilterComposer,
      $$IngestEventsTableOrderingComposer,
      $$IngestEventsTableAnnotationComposer,
      $$IngestEventsTableCreateCompanionBuilder,
      $$IngestEventsTableUpdateCompanionBuilder,
      (IngestEventRow, $$IngestEventsTableReferences),
      IngestEventRow,
      PrefetchHooks Function({bool matchedMilestoneId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$PayTrailDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<
              _$PayTrailDatabase,
              $AppSettingsTable,
              AppSettingRow
            >,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$PayTrailDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$PayTrailDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$PayTrailDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$ReminderLogTableCreateCompanionBuilder =
    ReminderLogCompanion Function({
      required String id,
      required String milestoneId,
      required String clientId,
      required ReminderTone tone,
      required String subject,
      Value<String?> body,
      Value<String?> recipient,
      required DateTime sentAt,
      Value<int> rowid,
    });
typedef $$ReminderLogTableUpdateCompanionBuilder =
    ReminderLogCompanion Function({
      Value<String> id,
      Value<String> milestoneId,
      Value<String> clientId,
      Value<ReminderTone> tone,
      Value<String> subject,
      Value<String?> body,
      Value<String?> recipient,
      Value<DateTime> sentAt,
      Value<int> rowid,
    });

final class $$ReminderLogTableReferences
    extends
        BaseReferences<_$PayTrailDatabase, $ReminderLogTable, ReminderLogRow> {
  $$ReminderLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MilestonesTable _milestoneIdTable(_$PayTrailDatabase db) =>
      db.milestones.createAlias('reminder_log__milestone_id__milestones__id');

  $$MilestonesTableProcessedTableManager get milestoneId {
    final $_column = $_itemColumn<String>('milestone_id')!;

    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_milestoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClientsTable _clientIdTable(_$PayTrailDatabase db) =>
      db.clients.createAlias('reminder_log__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderLogTableFilterComposer
    extends Composer<_$PayTrailDatabase, $ReminderLogTable> {
  $$ReminderLogTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ReminderTone, ReminderTone, String> get tone =>
      $composableBuilder(
        column: $table.tone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MilestonesTableFilterComposer get milestoneId {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderLogTableOrderingComposer
    extends Composer<_$PayTrailDatabase, $ReminderLogTable> {
  $$ReminderLogTableOrderingComposer({
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

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MilestonesTableOrderingComposer get milestoneId {
    final $$MilestonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableOrderingComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderLogTableAnnotationComposer
    extends Composer<_$PayTrailDatabase, $ReminderLogTable> {
  $$ReminderLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderTone, String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  $$MilestonesTableAnnotationComposer get milestoneId {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderLogTableTableManager
    extends
        RootTableManager<
          _$PayTrailDatabase,
          $ReminderLogTable,
          ReminderLogRow,
          $$ReminderLogTableFilterComposer,
          $$ReminderLogTableOrderingComposer,
          $$ReminderLogTableAnnotationComposer,
          $$ReminderLogTableCreateCompanionBuilder,
          $$ReminderLogTableUpdateCompanionBuilder,
          (ReminderLogRow, $$ReminderLogTableReferences),
          ReminderLogRow,
          PrefetchHooks Function({bool milestoneId, bool clientId})
        > {
  $$ReminderLogTableTableManager(_$PayTrailDatabase db, $ReminderLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> milestoneId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<ReminderTone> tone = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> recipient = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderLogCompanion(
                id: id,
                milestoneId: milestoneId,
                clientId: clientId,
                tone: tone,
                subject: subject,
                body: body,
                recipient: recipient,
                sentAt: sentAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String milestoneId,
                required String clientId,
                required ReminderTone tone,
                required String subject,
                Value<String?> body = const Value.absent(),
                Value<String?> recipient = const Value.absent(),
                required DateTime sentAt,
                Value<int> rowid = const Value.absent(),
              }) => ReminderLogCompanion.insert(
                id: id,
                milestoneId: milestoneId,
                clientId: clientId,
                tone: tone,
                subject: subject,
                body: body,
                recipient: recipient,
                sentAt: sentAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReminderLogTable, ReminderLogRow>(table),
                  $$ReminderLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({milestoneId = false, clientId = false}) {
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
                    if (milestoneId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.milestoneId,
                                referencedTable: $$ReminderLogTableReferences
                                    ._milestoneIdTable(db),
                                referencedColumn: $$ReminderLogTableReferences
                                    ._milestoneIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (clientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.clientId,
                                referencedTable: $$ReminderLogTableReferences
                                    ._clientIdTable(db),
                                referencedColumn: $$ReminderLogTableReferences
                                    ._clientIdTable(db)
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

typedef $$ReminderLogTableProcessedTableManager =
    ProcessedTableManager<
      _$PayTrailDatabase,
      $ReminderLogTable,
      ReminderLogRow,
      $$ReminderLogTableFilterComposer,
      $$ReminderLogTableOrderingComposer,
      $$ReminderLogTableAnnotationComposer,
      $$ReminderLogTableCreateCompanionBuilder,
      $$ReminderLogTableUpdateCompanionBuilder,
      (ReminderLogRow, $$ReminderLogTableReferences),
      ReminderLogRow,
      PrefetchHooks Function({bool milestoneId, bool clientId})
    >;

class $PayTrailDatabaseManager {
  final _$PayTrailDatabase _db;
  $PayTrailDatabaseManager(this._db);
  $$PaymentSourcesTableTableManager get paymentSources =>
      $$PaymentSourcesTableTableManager(_db, _db.paymentSources);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$MilestonesTableTableManager get milestones =>
      $$MilestonesTableTableManager(_db, _db.milestones);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$IngestEventsTableTableManager get ingestEvents =>
      $$IngestEventsTableTableManager(_db, _db.ingestEvents);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ReminderLogTableTableManager get reminderLog =>
      $$ReminderLogTableTableManager(_db, _db.reminderLog);
}
