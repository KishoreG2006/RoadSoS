// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, experimental_member_use, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionModelCollection on Isar {
  IsarCollection<SessionModel> get sessionModels => this.collection();
}

const SessionModelSchema = CollectionSchema(
  name: r'SessionModel',
  id: 3961338372060081682,
  properties: {
    r'authToken': PropertySchema(
      id: 0,
      name: r'authToken',
      type: IsarType.string,
    ),
    r'isLoggedIn': PropertySchema(
      id: 1,
      name: r'isLoggedIn',
      type: IsarType.bool,
    ),
    r'lastLoginTime': PropertySchema(
      id: 2,
      name: r'lastLoginTime',
      type: IsarType.dateTime,
    ),
    r'lastSyncTime': PropertySchema(
      id: 3,
      name: r'lastSyncTime',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _sessionModelEstimateSize,
  serialize: _sessionModelSerialize,
  deserialize: _sessionModelDeserialize,
  deserializeProp: _sessionModelDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sessionModelGetId,
  getLinks: _sessionModelGetLinks,
  attach: _sessionModelAttach,
  version: '3.1.0+1',
);

int _sessionModelEstimateSize(
  SessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authToken.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _sessionModelSerialize(
  SessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authToken);
  writer.writeBool(offsets[1], object.isLoggedIn);
  writer.writeDateTime(offsets[2], object.lastLoginTime);
  writer.writeDateTime(offsets[3], object.lastSyncTime);
  writer.writeString(offsets[4], object.userId);
}

SessionModel _sessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionModel();
  object.authToken = reader.readString(offsets[0]);
  object.isLoggedIn = reader.readBool(offsets[1]);
  object.isarId = id;
  object.lastLoginTime = reader.readDateTime(offsets[2]);
  object.lastSyncTime = reader.readDateTime(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _sessionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionModelGetId(SessionModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _sessionModelGetLinks(SessionModel object) {
  return [];
}

void _sessionModelAttach(
    IsarCollection<dynamic> col, Id id, SessionModel object) {
  object.isarId = id;
}

extension SessionModelQueryWhereSort
    on QueryBuilder<SessionModel, SessionModel, QWhere> {
  QueryBuilder<SessionModel, SessionModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SessionModelQueryWhere
    on QueryBuilder<SessionModel, SessionModel, QWhereClause> {
  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SessionModelQueryFilter
    on QueryBuilder<SessionModel, SessionModel, QFilterCondition> {
  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authToken',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      authTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authToken',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      isLoggedInEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLoggedIn',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastLoginTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLoginTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastLoginTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastLoginTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastLoginTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastLoginTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastLoginTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastLoginTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastSyncTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastSyncTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastSyncTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      lastSyncTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension SessionModelQueryObject
    on QueryBuilder<SessionModel, SessionModel, QFilterCondition> {}

extension SessionModelQueryLinks
    on QueryBuilder<SessionModel, SessionModel, QFilterCondition> {}

extension SessionModelQuerySortBy
    on QueryBuilder<SessionModel, SessionModel, QSortBy> {
  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> sortByAuthToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> sortByAuthTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> sortByIsLoggedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      sortByIsLoggedInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> sortByLastLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginTime', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      sortByLastLoginTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginTime', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> sortByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      sortByLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SessionModelQuerySortThenBy
    on QueryBuilder<SessionModel, SessionModel, QSortThenBy> {
  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByAuthToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByAuthTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByIsLoggedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      thenByIsLoggedInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByLastLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginTime', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      thenByLastLoginTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginTime', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy>
      thenByLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncTime', Sort.desc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SessionModelQueryWhereDistinct
    on QueryBuilder<SessionModel, SessionModel, QDistinct> {
  QueryBuilder<SessionModel, SessionModel, QDistinct> distinctByAuthToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionModel, SessionModel, QDistinct> distinctByIsLoggedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLoggedIn');
    });
  }

  QueryBuilder<SessionModel, SessionModel, QDistinct>
      distinctByLastLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLoginTime');
    });
  }

  QueryBuilder<SessionModel, SessionModel, QDistinct> distinctByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncTime');
    });
  }

  QueryBuilder<SessionModel, SessionModel, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SessionModelQueryProperty
    on QueryBuilder<SessionModel, SessionModel, QQueryProperty> {
  QueryBuilder<SessionModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SessionModel, String, QQueryOperations> authTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authToken');
    });
  }

  QueryBuilder<SessionModel, bool, QQueryOperations> isLoggedInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLoggedIn');
    });
  }

  QueryBuilder<SessionModel, DateTime, QQueryOperations>
      lastLoginTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLoginTime');
    });
  }

  QueryBuilder<SessionModel, DateTime, QQueryOperations>
      lastSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncTime');
    });
  }

  QueryBuilder<SessionModel, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
