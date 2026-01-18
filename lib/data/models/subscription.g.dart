// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubscriptionCollection on Isar {
  IsarCollection<Subscription> get subscriptions => this.collection();
}

const SubscriptionSchema = CollectionSchema(
  name: r'Subscription',
  id: -3426239935225026138,
  properties: {
    r'categoryId': PropertySchema(
      id: 0,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'customIntervalDays': PropertySchema(
      id: 1,
      name: r'customIntervalDays',
      type: IsarType.long,
    ),
    r'daysUntilExpiry': PropertySchema(
      id: 2,
      name: r'daysUntilExpiry',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'documentPhotos': PropertySchema(
      id: 4,
      name: r'documentPhotos',
      type: IsarType.stringList,
    ),
    r'expiryDate': PropertySchema(
      id: 5,
      name: r'expiryDate',
      type: IsarType.dateTime,
    ),
    r'hasDocuments': PropertySchema(
      id: 6,
      name: r'hasDocuments',
      type: IsarType.bool,
    ),
    r'isActive': PropertySchema(
      id: 7,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDocumentOnly': PropertySchema(
      id: 8,
      name: r'isDocumentOnly',
      type: IsarType.bool,
    ),
    r'isExpired': PropertySchema(
      id: 9,
      name: r'isExpired',
      type: IsarType.bool,
    ),
    r'isExpiringToday': PropertySchema(
      id: 10,
      name: r'isExpiringToday',
      type: IsarType.bool,
    ),
    r'isFolder': PropertySchema(
      id: 11,
      name: r'isFolder',
      type: IsarType.bool,
    ),
    r'linkedTaskId': PropertySchema(
      id: 12,
      name: r'linkedTaskId',
      type: IsarType.long,
    ),
    r'linkedTaskIds': PropertySchema(
      id: 13,
      name: r'linkedTaskIds',
      type: IsarType.longList,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'otherDocuments': PropertySchema(
      id: 15,
      name: r'otherDocuments',
      type: IsarType.stringList,
    ),
    r'parentFolderId': PropertySchema(
      id: 16,
      name: r'parentFolderId',
      type: IsarType.long,
    ),
    r'parentSubscriptionId': PropertySchema(
      id: 17,
      name: r'parentSubscriptionId',
      type: IsarType.long,
    ),
    r'pdfDocuments': PropertySchema(
      id: 18,
      name: r'pdfDocuments',
      type: IsarType.stringList,
    ),
    r'recurrenceLabel': PropertySchema(
      id: 19,
      name: r'recurrenceLabel',
      type: IsarType.string,
    ),
    r'recurrenceType': PropertySchema(
      id: 20,
      name: r'recurrenceType',
      type: IsarType.byte,
      enumMap: _SubscriptionrecurrenceTypeEnumValueMap,
    ),
    r'reminderDate': PropertySchema(
      id: 21,
      name: r'reminderDate',
      type: IsarType.dateTime,
    ),
    r'reminderDays': PropertySchema(
      id: 22,
      name: r'reminderDays',
      type: IsarType.long,
    ),
    r'totalFileCount': PropertySchema(
      id: 23,
      name: r'totalFileCount',
      type: IsarType.long,
    )
  },
  estimateSize: _subscriptionEstimateSize,
  serialize: _subscriptionSerialize,
  deserialize: _subscriptionDeserialize,
  deserializeProp: _subscriptionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _subscriptionGetId,
  getLinks: _subscriptionGetLinks,
  attach: _subscriptionAttach,
  version: '3.1.0+1',
);

int _subscriptionEstimateSize(
  Subscription object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.documentPhotos.length * 3;
  {
    for (var i = 0; i < object.documentPhotos.length; i++) {
      final value = object.documentPhotos[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.linkedTaskIds.length * 8;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.otherDocuments.length * 3;
  {
    for (var i = 0; i < object.otherDocuments.length; i++) {
      final value = object.otherDocuments[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.pdfDocuments.length * 3;
  {
    for (var i = 0; i < object.pdfDocuments.length; i++) {
      final value = object.pdfDocuments[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.recurrenceLabel.length * 3;
  return bytesCount;
}

void _subscriptionSerialize(
  Subscription object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryId);
  writer.writeLong(offsets[1], object.customIntervalDays);
  writer.writeLong(offsets[2], object.daysUntilExpiry);
  writer.writeString(offsets[3], object.description);
  writer.writeStringList(offsets[4], object.documentPhotos);
  writer.writeDateTime(offsets[5], object.expiryDate);
  writer.writeBool(offsets[6], object.hasDocuments);
  writer.writeBool(offsets[7], object.isActive);
  writer.writeBool(offsets[8], object.isDocumentOnly);
  writer.writeBool(offsets[9], object.isExpired);
  writer.writeBool(offsets[10], object.isExpiringToday);
  writer.writeBool(offsets[11], object.isFolder);
  writer.writeLong(offsets[12], object.linkedTaskId);
  writer.writeLongList(offsets[13], object.linkedTaskIds);
  writer.writeString(offsets[14], object.name);
  writer.writeStringList(offsets[15], object.otherDocuments);
  writer.writeLong(offsets[16], object.parentFolderId);
  writer.writeLong(offsets[17], object.parentSubscriptionId);
  writer.writeStringList(offsets[18], object.pdfDocuments);
  writer.writeString(offsets[19], object.recurrenceLabel);
  writer.writeByte(offsets[20], object.recurrenceType.index);
  writer.writeDateTime(offsets[21], object.reminderDate);
  writer.writeLong(offsets[22], object.reminderDays);
  writer.writeLong(offsets[23], object.totalFileCount);
}

Subscription _subscriptionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Subscription();
  object.categoryId = reader.readLong(offsets[0]);
  object.customIntervalDays = reader.readLong(offsets[1]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.documentPhotos = reader.readStringList(offsets[4]) ?? [];
  object.expiryDate = reader.readDateTimeOrNull(offsets[5]);
  object.id = id;
  object.isActive = reader.readBool(offsets[7]);
  object.isFolder = reader.readBool(offsets[11]);
  object.linkedTaskId = reader.readLongOrNull(offsets[12]);
  object.linkedTaskIds = reader.readLongList(offsets[13]) ?? [];
  object.name = reader.readString(offsets[14]);
  object.otherDocuments = reader.readStringList(offsets[15]) ?? [];
  object.parentFolderId = reader.readLongOrNull(offsets[16]);
  object.parentSubscriptionId = reader.readLongOrNull(offsets[17]);
  object.pdfDocuments = reader.readStringList(offsets[18]) ?? [];
  object.recurrenceType = _SubscriptionrecurrenceTypeValueEnumMap[
          reader.readByteOrNull(offsets[20])] ??
      RecurrenceType.once;
  object.reminderDays = reader.readLong(offsets[22]);
  return object;
}

P _subscriptionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readLongList(offset) ?? []) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readStringList(offset) ?? []) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (_SubscriptionrecurrenceTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          RecurrenceType.once) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SubscriptionrecurrenceTypeEnumValueMap = {
  'once': 0,
  'monthly': 1,
  'yearly': 2,
  'custom': 3,
};
const _SubscriptionrecurrenceTypeValueEnumMap = {
  0: RecurrenceType.once,
  1: RecurrenceType.monthly,
  2: RecurrenceType.yearly,
  3: RecurrenceType.custom,
};

Id _subscriptionGetId(Subscription object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subscriptionGetLinks(Subscription object) {
  return [];
}

void _subscriptionAttach(
    IsarCollection<dynamic> col, Id id, Subscription object) {
  object.id = id;
}

extension SubscriptionQueryWhereSort
    on QueryBuilder<Subscription, Subscription, QWhere> {
  QueryBuilder<Subscription, Subscription, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubscriptionQueryWhere
    on QueryBuilder<Subscription, Subscription, QWhereClause> {
  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubscriptionQueryFilter
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {
  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      categoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      categoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      categoryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      categoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      customIntervalDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      customIntervalDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      customIntervalDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      customIntervalDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customIntervalDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      daysUntilExpiryEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysUntilExpiry',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      daysUntilExpiryGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysUntilExpiry',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      daysUntilExpiryLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysUntilExpiry',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      daysUntilExpiryBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysUntilExpiry',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentPhotos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentPhotos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentPhotos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentPhotos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentPhotos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentPhotos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentPhotos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentPhotos',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentPhotos',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentPhotos',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPhotos',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPhotos',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPhotos',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPhotos',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPhotos',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      documentPhotosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPhotos',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      expiryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expiryDate',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      expiryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expiryDate',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      expiryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      expiryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      expiryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      expiryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      hasDocumentsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasDocuments',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      isDocumentOnlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDocumentOnly',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      isExpiredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isExpired',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      isExpiringTodayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isExpiringToday',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      isFolderEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFolder',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedTaskId',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedTaskId',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedTaskId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedTaskId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedTaskId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedTaskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedTaskIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedTaskIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedTaskIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedTaskIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedTaskIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedTaskIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedTaskIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedTaskIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedTaskIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      linkedTaskIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedTaskIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'otherDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'otherDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'otherDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'otherDocuments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'otherDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'otherDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'otherDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'otherDocuments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'otherDocuments',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'otherDocuments',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'otherDocuments',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'otherDocuments',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'otherDocuments',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'otherDocuments',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'otherDocuments',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      otherDocumentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'otherDocuments',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentFolderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentFolderId',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentFolderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentFolderId',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentFolderIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentFolderId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentFolderIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentFolderId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentFolderIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentFolderId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentFolderIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentFolderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentSubscriptionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentSubscriptionId',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentSubscriptionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentSubscriptionId',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentSubscriptionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentSubscriptionId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentSubscriptionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentSubscriptionId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentSubscriptionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentSubscriptionId',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      parentSubscriptionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentSubscriptionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pdfDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pdfDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pdfDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pdfDocuments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pdfDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pdfDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pdfDocuments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pdfDocuments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pdfDocuments',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pdfDocuments',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pdfDocuments',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pdfDocuments',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pdfDocuments',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pdfDocuments',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pdfDocuments',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      pdfDocumentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pdfDocuments',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrenceLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrenceLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrenceLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recurrenceLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recurrenceLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recurrenceLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recurrenceLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recurrenceLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceTypeEqualTo(RecurrenceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceType',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceTypeGreaterThan(
    RecurrenceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrenceType',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceTypeLessThan(
    RecurrenceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrenceType',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      recurrenceTypeBetween(
    RecurrenceType lower,
    RecurrenceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrenceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderDate',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderDate',
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      reminderDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      totalFileCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFileCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      totalFileCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFileCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      totalFileCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFileCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
      totalFileCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFileCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubscriptionQueryObject
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {}

extension SubscriptionQueryLinks
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {}

extension SubscriptionQuerySortBy
    on QueryBuilder<Subscription, Subscription, QSortBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByCustomIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByCustomIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByDaysUntilExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilExpiry', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByDaysUntilExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilExpiry', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByHasDocuments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDocuments', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByHasDocumentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDocuments', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByIsDocumentOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDocumentOnly', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByIsDocumentOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDocumentOnly', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByIsExpiringToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpiringToday', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByIsExpiringTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpiringToday', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsFolder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFolder', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsFolderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFolder', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByLinkedTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByLinkedTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByParentFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByParentFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByParentSubscriptionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSubscriptionId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByParentSubscriptionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSubscriptionId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByRecurrenceLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceLabel', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByRecurrenceLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceLabel', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByRecurrenceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByRecurrenceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByReminderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDate', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByReminderDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDate', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByReminderDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDays', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByReminderDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDays', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByTotalFileCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFileCount', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      sortByTotalFileCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFileCount', Sort.desc);
    });
  }
}

extension SubscriptionQuerySortThenBy
    on QueryBuilder<Subscription, Subscription, QSortThenBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByCustomIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByCustomIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByDaysUntilExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilExpiry', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByDaysUntilExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilExpiry', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByHasDocuments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDocuments', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByHasDocumentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDocuments', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByIsDocumentOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDocumentOnly', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByIsDocumentOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDocumentOnly', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByIsExpiringToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpiringToday', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByIsExpiringTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpiringToday', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsFolder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFolder', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsFolderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFolder', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByLinkedTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByLinkedTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTaskId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByParentFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByParentFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByParentSubscriptionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSubscriptionId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByParentSubscriptionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSubscriptionId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByRecurrenceLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceLabel', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByRecurrenceLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceLabel', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByRecurrenceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByRecurrenceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByReminderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDate', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByReminderDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDate', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByReminderDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDays', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByReminderDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDays', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByTotalFileCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFileCount', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
      thenByTotalFileCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFileCount', Sort.desc);
    });
  }
}

extension SubscriptionQueryWhereDistinct
    on QueryBuilder<Subscription, Subscription, QDistinct> {
  QueryBuilder<Subscription, Subscription, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByCustomIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customIntervalDays');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByDaysUntilExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysUntilExpiry');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByDocumentPhotos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentPhotos');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiryDate');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByHasDocuments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasDocuments');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByIsDocumentOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDocumentOnly');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isExpired');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByIsExpiringToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isExpiringToday');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByIsFolder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFolder');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByLinkedTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedTaskId');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByLinkedTaskIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedTaskIds');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByOtherDocuments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'otherDocuments');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByParentFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentFolderId');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByParentSubscriptionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentSubscriptionId');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByPdfDocuments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pdfDocuments');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByRecurrenceLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceLabel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByRecurrenceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceType');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByReminderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderDate');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByReminderDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderDays');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
      distinctByTotalFileCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFileCount');
    });
  }
}

extension SubscriptionQueryProperty
    on QueryBuilder<Subscription, Subscription, QQueryProperty> {
  QueryBuilder<Subscription, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Subscription, int, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<Subscription, int, QQueryOperations>
      customIntervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customIntervalDays');
    });
  }

  QueryBuilder<Subscription, int, QQueryOperations> daysUntilExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysUntilExpiry');
    });
  }

  QueryBuilder<Subscription, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Subscription, List<String>, QQueryOperations>
      documentPhotosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentPhotos');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations> expiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiryDate');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> hasDocumentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasDocuments');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> isDocumentOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDocumentOnly');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> isExpiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isExpired');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> isExpiringTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isExpiringToday');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> isFolderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFolder');
    });
  }

  QueryBuilder<Subscription, int?, QQueryOperations> linkedTaskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedTaskId');
    });
  }

  QueryBuilder<Subscription, List<int>, QQueryOperations>
      linkedTaskIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedTaskIds');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Subscription, List<String>, QQueryOperations>
      otherDocumentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'otherDocuments');
    });
  }

  QueryBuilder<Subscription, int?, QQueryOperations> parentFolderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentFolderId');
    });
  }

  QueryBuilder<Subscription, int?, QQueryOperations>
      parentSubscriptionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentSubscriptionId');
    });
  }

  QueryBuilder<Subscription, List<String>, QQueryOperations>
      pdfDocumentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pdfDocuments');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations>
      recurrenceLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceLabel');
    });
  }

  QueryBuilder<Subscription, RecurrenceType, QQueryOperations>
      recurrenceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceType');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations>
      reminderDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderDate');
    });
  }

  QueryBuilder<Subscription, int, QQueryOperations> reminderDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderDays');
    });
  }

  QueryBuilder<Subscription, int, QQueryOperations> totalFileCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFileCount');
    });
  }
}
