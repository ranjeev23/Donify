// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPreferencesCollection on Isar {
  IsarCollection<UserPreferences> get userPreferences => this.collection();
}

const UserPreferencesSchema = CollectionSchema(
  name: r'UserPreferences',
  id: -7545901164102504045,
  properties: {
    r'onboardingCompleted': PropertySchema(
      id: 0,
      name: r'onboardingCompleted',
      type: IsarType.bool,
    ),
    r'sleepHour': PropertySchema(
      id: 1,
      name: r'sleepHour',
      type: IsarType.long,
    ),
    r'sleepMinute': PropertySchema(
      id: 2,
      name: r'sleepMinute',
      type: IsarType.long,
    ),
    r'sleepTime': PropertySchema(
      id: 3,
      name: r'sleepTime',
      type: IsarType.dateTime,
    ),
    r'wakeUpHour': PropertySchema(
      id: 4,
      name: r'wakeUpHour',
      type: IsarType.long,
    ),
    r'wakeUpMinute': PropertySchema(
      id: 5,
      name: r'wakeUpMinute',
      type: IsarType.long,
    ),
    r'wakeUpTime': PropertySchema(
      id: 6,
      name: r'wakeUpTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _userPreferencesEstimateSize,
  serialize: _userPreferencesSerialize,
  deserialize: _userPreferencesDeserialize,
  deserializeProp: _userPreferencesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userPreferencesGetId,
  getLinks: _userPreferencesGetLinks,
  attach: _userPreferencesAttach,
  version: '3.1.0+1',
);

int _userPreferencesEstimateSize(
  UserPreferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userPreferencesSerialize(
  UserPreferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.onboardingCompleted);
  writer.writeLong(offsets[1], object.sleepHour);
  writer.writeLong(offsets[2], object.sleepMinute);
  writer.writeDateTime(offsets[3], object.sleepTime);
  writer.writeLong(offsets[4], object.wakeUpHour);
  writer.writeLong(offsets[5], object.wakeUpMinute);
  writer.writeDateTime(offsets[6], object.wakeUpTime);
}

UserPreferences _userPreferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPreferences();
  object.id = id;
  object.onboardingCompleted = reader.readBool(offsets[0]);
  object.sleepHour = reader.readLong(offsets[1]);
  object.sleepMinute = reader.readLong(offsets[2]);
  object.wakeUpHour = reader.readLong(offsets[4]);
  object.wakeUpMinute = reader.readLong(offsets[5]);
  return object;
}

P _userPreferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPreferencesGetId(UserPreferences object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPreferencesGetLinks(UserPreferences object) {
  return [];
}

void _userPreferencesAttach(
    IsarCollection<dynamic> col, Id id, UserPreferences object) {
  object.id = id;
}

extension UserPreferencesQueryWhereSort
    on QueryBuilder<UserPreferences, UserPreferences, QWhere> {
  QueryBuilder<UserPreferences, UserPreferences, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPreferencesQueryWhere
    on QueryBuilder<UserPreferences, UserPreferences, QWhereClause> {
  QueryBuilder<UserPreferences, UserPreferences, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<UserPreferences, UserPreferences, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterWhereClause> idBetween(
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

extension UserPreferencesQueryFilter
    on QueryBuilder<UserPreferences, UserPreferences, QFilterCondition> {
  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      onboardingCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      sleepTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeUpHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wakeUpHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wakeUpHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wakeUpHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeUpMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wakeUpMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wakeUpMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wakeUpMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeUpTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wakeUpTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wakeUpTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      wakeUpTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wakeUpTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserPreferencesQueryObject
    on QueryBuilder<UserPreferences, UserPreferences, QFilterCondition> {}

extension UserPreferencesQueryLinks
    on QueryBuilder<UserPreferences, UserPreferences, QFilterCondition> {}

extension UserPreferencesQuerySortBy
    on QueryBuilder<UserPreferences, UserPreferences, QSortBy> {
  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortBySleepHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHour', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortBySleepHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHour', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortBySleepMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinute', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortBySleepMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinute', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortBySleepTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortBySleepTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByWakeUpHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpHour', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByWakeUpHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpHour', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByWakeUpMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpMinute', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByWakeUpMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpMinute', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByWakeUpTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpTime', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      sortByWakeUpTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpTime', Sort.desc);
    });
  }
}

extension UserPreferencesQuerySortThenBy
    on QueryBuilder<UserPreferences, UserPreferences, QSortThenBy> {
  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenBySleepHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHour', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenBySleepHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHour', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenBySleepMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinute', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenBySleepMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinute', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenBySleepTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenBySleepTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTime', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByWakeUpHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpHour', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByWakeUpHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpHour', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByWakeUpMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpMinute', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByWakeUpMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpMinute', Sort.desc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByWakeUpTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpTime', Sort.asc);
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterSortBy>
      thenByWakeUpTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpTime', Sort.desc);
    });
  }
}

extension UserPreferencesQueryWhereDistinct
    on QueryBuilder<UserPreferences, UserPreferences, QDistinct> {
  QueryBuilder<UserPreferences, UserPreferences, QDistinct>
      distinctByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingCompleted');
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QDistinct>
      distinctBySleepHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepHour');
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QDistinct>
      distinctBySleepMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepMinute');
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QDistinct>
      distinctBySleepTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepTime');
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QDistinct>
      distinctByWakeUpHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wakeUpHour');
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QDistinct>
      distinctByWakeUpMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wakeUpMinute');
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QDistinct>
      distinctByWakeUpTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wakeUpTime');
    });
  }
}

extension UserPreferencesQueryProperty
    on QueryBuilder<UserPreferences, UserPreferences, QQueryProperty> {
  QueryBuilder<UserPreferences, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPreferences, bool, QQueryOperations>
      onboardingCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingCompleted');
    });
  }

  QueryBuilder<UserPreferences, int, QQueryOperations> sleepHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepHour');
    });
  }

  QueryBuilder<UserPreferences, int, QQueryOperations> sleepMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepMinute');
    });
  }

  QueryBuilder<UserPreferences, DateTime, QQueryOperations>
      sleepTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepTime');
    });
  }

  QueryBuilder<UserPreferences, int, QQueryOperations> wakeUpHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wakeUpHour');
    });
  }

  QueryBuilder<UserPreferences, int, QQueryOperations> wakeUpMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wakeUpMinute');
    });
  }

  QueryBuilder<UserPreferences, DateTime, QQueryOperations>
      wakeUpTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wakeUpTime');
    });
  }
}
