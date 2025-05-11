import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:code_builder/code_builder.dart';

bool isTypeSingle(RelationType type, RelationSide side) {
  return type == RelationType.oneToOne ||
      type == RelationType.oneToMany && side == RelationSide.child ||
      type == RelationType.manyToOne && side == RelationSide.parent;
}

Reference resolveRelationshipType(
  RelationType type,
  RelationSide side,
  Reference relatedCollection,
) {
  if (isTypeSingle(type, side)) {
    return relatedCollection;
  } else {
    return TypeReference(
      (b) =>
          b
            ..symbol = 'List'
            ..types.add(refer(relatedCollection.symbol!, relatedCollection.url))
            ..isNullable = false,
    );
  }
}

class AttributeInfoRelation extends AttributeInfo {
  final RelationType relationType;
  final RelationOnDelete onDelete;
  final RelationSide side;
  final String relatedCollection;
  final bool twoWay;
  final String? twoWayKey;
  final Reference relatedClassReference;
  final Reference _reference;

  AttributeInfoRelation({
    required super.raw,
    required super.packageName,
    required this.relationType,
    required this.onDelete,
    required this.side,
    required this.relatedCollection,
    required this.twoWay,
    required this.twoWayKey,
    required this.relatedClassReference,
  }) : _reference = resolveRelationshipType(
         relationType,
         side,
         relatedClassReference,
       );

  @override
  Reference get typeReference => _reference;

  @override
  Reference get reference => _reference;

  @override
  bool get array => !isTypeSingle(relationType, side);

  @override
  List<Field> get fields {
    return [
      ...super.fields,
      Field(
        (b) =>
            b
              ..modifier = FieldModifier.constant
              ..static = true
              ..name = '${name}Relation'
              ..type = refer(
                'Relation',
                'package:$packageName/models/collections.dart',
              )
              ..assignment =
                  refer(
                    'Relation',
                    'package:$packageName/models/collections.dart',
                  ).call([], {
                    'required': refer('$required'),
                    'array': refer('$array'),
                    'relatedCollection': literalString(relatedCollection),
                    'relationType': refer(
                      'RelationType',
                      'package:$packageName/models/collections.dart',
                    ).property(relationType.name),
                    'twoWay': refer('$twoWay'),
                    'twoWayKey':
                        twoWayKey != null
                            ? literalString(twoWayKey!)
                            : literalNull,
                    'onDelete': refer(
                      'RelationOnDelete',
                      'package:$packageName/models/collections.dart',
                    ).property(onDelete.name),
                    'side': refer(
                      'RelationSide',
                      'package:$packageName/models/collections.dart',
                    ).property(side.name),
                  }).code,
      ),
    ];
  }

  @override
  Code get toJson {
    if (isTypeSingle(relationType, side)) {
      return Code("'$name': $name?.toJson()");
    } else {
      return Code("'$name': $name.map((e) => e.toJson()).toList()");
    }
  }

  @override
  Expression get fromAppwrite {
    if (isTypeSingle(relationType, side)) {
      return required
          ? relatedClassReference.newInstanceNamed('fromAppwrite', [
            refer('Document', 'package:appwrite/model.dart').newInstanceNamed(
              'fromMap',
              [refer('doc').property('data').index(literalString(name))],
            ),
          ])
          : refer('doc')
              .property('data')
              .index(literalString(name))
              .notEqualTo(literalNull)
              .conditional(
                relatedClassReference.newInstanceNamed('fromAppwrite', [
                  refer(
                    'Document',
                    'package:appwrite/models.dart',
                  ).newInstanceNamed('fromMap', [
                    refer('doc').property('data').index(literalString(name)),
                  ]),
                ]),
                literalNull,
              );
    } else {
      return refer('List', 'dart:core').newInstanceNamed('unmodifiable', [
        refer('doc')
            .property('data')
            .index(literalString(name))
            .nullSafeProperty('map')
            .call([
              Method(
                (b) =>
                    b
                      ..requiredParameters.add(Parameter((p) => p..name = 'e'))
                      ..lambda = true
                      ..body =
                          relatedClassReference.property('fromAppwrite').call([
                            refer(
                              'Document',
                              'package:appwrite/models.dart',
                            ).property('fromMap').call([refer('e')]),
                          ]).code,
              ).closure,
            ])
            .ifNullThen(literalList([])),
      ]);
    }
  }
}
