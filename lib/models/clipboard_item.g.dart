// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClipboardItemCollection on Isar {
  IsarCollection<ClipboardItem> get clipboardItems => this.collection();
}

const ClipboardItemSchema = CollectionSchema(
  name: r'ClipboardItem',
  id: 7228975801377184843,
  properties: {
    r'articleText': PropertySchema(
      id: 0,
      name: r'articleText',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 1,
      name: r'content',
      type: IsarType.string,
    ),
    r'contentType': PropertySchema(
      id: 2,
      name: r'contentType',
      type: IsarType.string,
    ),
    r'contextualImages': PropertySchema(
      id: 3,
      name: r'contextualImages',
      type: IsarType.stringList,
    ),
    r'faviconUrl': PropertySchema(
      id: 4,
      name: r'faviconUrl',
      type: IsarType.string,
    ),
    r'heroImageUrl': PropertySchema(
      id: 5,
      name: r'heroImageUrl',
      type: IsarType.string,
    ),
    r'isSensitive': PropertySchema(
      id: 6,
      name: r'isSensitive',
      type: IsarType.bool,
    ),
    r'isShared': PropertySchema(
      id: 7,
      name: r'isShared',
      type: IsarType.bool,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 9,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _clipboardItemEstimateSize,
  serialize: _clipboardItemSerialize,
  deserialize: _clipboardItemDeserialize,
  deserializeProp: _clipboardItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'content': IndexSchema(
      id: 6193209363630369380,
      name: r'content',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'content',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isShared': IndexSchema(
      id: 325927935090462033,
      name: r'isShared',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isShared',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _clipboardItemGetId,
  getLinks: _clipboardItemGetLinks,
  attach: _clipboardItemAttach,
  version: '3.1.0+1',
);

int _clipboardItemEstimateSize(
  ClipboardItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.articleText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.content.length * 3;
  {
    final value = object.contentType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.contextualImages;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.faviconUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.heroImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _clipboardItemSerialize(
  ClipboardItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.articleText);
  writer.writeString(offsets[1], object.content);
  writer.writeString(offsets[2], object.contentType);
  writer.writeStringList(offsets[3], object.contextualImages);
  writer.writeString(offsets[4], object.faviconUrl);
  writer.writeString(offsets[5], object.heroImageUrl);
  writer.writeBool(offsets[6], object.isSensitive);
  writer.writeBool(offsets[7], object.isShared);
  writer.writeDateTime(offsets[8], object.timestamp);
  writer.writeString(offsets[9], object.title);
}

ClipboardItem _clipboardItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClipboardItem();
  object.articleText = reader.readStringOrNull(offsets[0]);
  object.content = reader.readString(offsets[1]);
  object.contentType = reader.readStringOrNull(offsets[2]);
  object.contextualImages = reader.readStringList(offsets[3]);
  object.faviconUrl = reader.readStringOrNull(offsets[4]);
  object.heroImageUrl = reader.readStringOrNull(offsets[5]);
  object.id = id;
  object.isSensitive = reader.readBool(offsets[6]);
  object.isShared = reader.readBool(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  object.title = reader.readStringOrNull(offsets[9]);
  return object;
}

P _clipboardItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _clipboardItemGetId(ClipboardItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _clipboardItemGetLinks(ClipboardItem object) {
  return [];
}

void _clipboardItemAttach(
    IsarCollection<dynamic> col, Id id, ClipboardItem object) {
  object.id = id;
}

extension ClipboardItemQueryWhereSort
    on QueryBuilder<ClipboardItem, ClipboardItem, QWhere> {
  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhere> anyIsShared() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isShared'),
      );
    });
  }
}

extension ClipboardItemQueryWhere
    on QueryBuilder<ClipboardItem, ClipboardItem, QWhereClause> {
  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause> contentEqualTo(
      String content) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'content',
        value: [content],
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause>
      contentNotEqualTo(String content) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'content',
              lower: [],
              upper: [content],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'content',
              lower: [content],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'content',
              lower: [content],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'content',
              lower: [],
              upper: [content],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause> isSharedEqualTo(
      bool isShared) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isShared',
        value: [isShared],
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterWhereClause>
      isSharedNotEqualTo(bool isShared) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isShared',
              lower: [],
              upper: [isShared],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isShared',
              lower: [isShared],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isShared',
              lower: [isShared],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isShared',
              lower: [],
              upper: [isShared],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ClipboardItemQueryFilter
    on QueryBuilder<ClipboardItem, ClipboardItem, QFilterCondition> {
  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'articleText',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'articleText',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'articleText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'articleText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'articleText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'articleText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'articleText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'articleText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'articleText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'articleText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'articleText',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      articleTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'articleText',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contextualImages',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contextualImages',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextualImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contextualImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contextualImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contextualImages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contextualImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contextualImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contextualImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contextualImages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextualImages',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contextualImages',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextualImages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextualImages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextualImages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextualImages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextualImages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      contextualImagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextualImages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'faviconUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'faviconUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      faviconUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heroImageUrl',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heroImageUrl',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heroImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heroImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      heroImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heroImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
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

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      isSensitiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSensitive',
        value: value,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      isSharedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isShared',
        value: value,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension ClipboardItemQueryObject
    on QueryBuilder<ClipboardItem, ClipboardItem, QFilterCondition> {}

extension ClipboardItemQueryLinks
    on QueryBuilder<ClipboardItem, ClipboardItem, QFilterCondition> {}

extension ClipboardItemQuerySortBy
    on QueryBuilder<ClipboardItem, ClipboardItem, QSortBy> {
  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByArticleText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleText', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByArticleTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleText', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByHeroImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByHeroImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByIsSensitive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByIsSensitiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByIsShared() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShared', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByIsSharedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShared', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ClipboardItemQuerySortThenBy
    on QueryBuilder<ClipboardItem, ClipboardItem, QSortThenBy> {
  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByArticleText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleText', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByArticleTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleText', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByHeroImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByHeroImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByIsSensitive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByIsSensitiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByIsShared() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShared', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByIsSharedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShared', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ClipboardItemQueryWhereDistinct
    on QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> {
  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByArticleText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'articleText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByContentType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct>
      distinctByContextualImages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextualImages');
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByFaviconUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'faviconUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByHeroImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heroImageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct>
      distinctByIsSensitive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSensitive');
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByIsShared() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isShared');
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<ClipboardItem, ClipboardItem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension ClipboardItemQueryProperty
    on QueryBuilder<ClipboardItem, ClipboardItem, QQueryProperty> {
  QueryBuilder<ClipboardItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ClipboardItem, String?, QQueryOperations> articleTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'articleText');
    });
  }

  QueryBuilder<ClipboardItem, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<ClipboardItem, String?, QQueryOperations> contentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentType');
    });
  }

  QueryBuilder<ClipboardItem, List<String>?, QQueryOperations>
      contextualImagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextualImages');
    });
  }

  QueryBuilder<ClipboardItem, String?, QQueryOperations> faviconUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'faviconUrl');
    });
  }

  QueryBuilder<ClipboardItem, String?, QQueryOperations>
      heroImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heroImageUrl');
    });
  }

  QueryBuilder<ClipboardItem, bool, QQueryOperations> isSensitiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSensitive');
    });
  }

  QueryBuilder<ClipboardItem, bool, QQueryOperations> isSharedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isShared');
    });
  }

  QueryBuilder<ClipboardItem, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<ClipboardItem, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
