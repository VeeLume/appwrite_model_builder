import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/relationship.dart';
import 'package:appwrite_model_builder/src/collection_parser/collection_info.dart';
import 'package:code_builder/code_builder.dart';

String moduleName(String className) {

  final s =
      className
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)}_${match.group(2)}',
      )
      .toLowerCase();

  return s;
}

String toSingularPascalCase(String input) {
  // Split the input string into words
  // Split by underscores, hayphens and uppercase letters
  final words =
      input
          .replaceAll(RegExp(r'[_-]'), ' ')
          .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
          )
          .split(' ')
          .map((word) => word.trim())
          .where((word) => word.isNotEmpty)
          .toList();

  if (words.isEmpty) return '';

  // Plural handling for the last word
  final last = words.removeLast();
  final singular = _toSingular(last);
  final pascalWords = [...words.map(_capitalize), _capitalize(singular)];

  return pascalWords.join();
}

String _capitalize(String word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase();

String _toSingular(String plural) {
  if (plural.endsWith('ies') && plural.length > 3) {
    return '${plural.substring(0, plural.length - 3)}y';
  }
  if (plural.endsWith('ses') ||
      plural.endsWith('xes') ||
      plural.endsWith('zes')) {
    return plural.substring(0, plural.length - 2);
  }
  if (plural.endsWith('s') && plural.length > 1) {
    // Dictonary exceptions
    final exceptions = ['status', 'species'];
    if (exceptions.contains(plural)) {
      return plural;
    }

    return plural.substring(0, plural.length - 1);
  }
  return plural;
}

Class model(CollectionInfo collectionInfo, String packageName) {
  final className = collectionInfo.name;
  final attributes = collectionInfo.attributes;

  return Class((b) {
    b.annotations.add(refer('immutable', 'package:flutter/foundation.dart'));
    b.name = className;
    b.extend = refer(
      'AppwriteModel<$className>',
      'package:$packageName/models/base.dart',
    );

    // Add attributes
    b.fields.add(
      Field((b) {
        b.name = 'collectionInfo';
        b.type = refer(
          'CollectionInfo',
          'package:$packageName/models/collections.dart',
        );
        b.modifier = FieldModifier.constant;
        b.static = true;
        b.assignment =
            refer(
              'CollectionInfo',
              'package:$packageName/models/collections.dart',
            ).newInstance([], {
              '\$id': literalString(collectionInfo.$id),
              '\$permissions': literalList(
                collectionInfo.$permissions
                    .map((e) => literalString(e))
                    .toList(),
              ),
              'databaseId': literalString(collectionInfo.databaseId),
              'name': literalString(collectionInfo.name),
              'enabled': literalBool(collectionInfo.enabled),
              'documentSecurity': literalBool(collectionInfo.documentSecurity),
            }).code;
      }),
    );
    for (final attribute in attributes) {
      b.fields.addAll(attribute.fields);
    }
    // private constructor
    b.constructors.add(
      Constructor((b) {
        b.name = '_';
        b.constant = true;
        b.optionalParameters.addAll(
          attributes.map(
            (attribute) => Parameter((p) {
              p.name = attribute.name;
              p.named = true;
              p.toThis = true;
              p.required = attribute.required || attribute.array;
            }),
          ),
        );

        b.optionalParameters.addAll([
          Parameter(
            (b) =>
                b
                  ..name = '\$id'
                  ..named = true
                  ..required = true
                  ..toSuper = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$collectionId'
                  ..named = true
                  ..required = true
                  ..toSuper = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$databaseId'
                  ..named = true
                  ..required = true
                  ..toSuper = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$createdAt'
                  ..named = true
                  ..required = true
                  ..toSuper = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$updatedAt'
                  ..named = true
                  ..required = true
                  ..toSuper = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$permissions'
                  ..named = true
                  ..required = true
                  ..toSuper = true,
          ),
        ]);
      }),
    );

    // factory constructor
    b.constructors.add(
      Constructor((b) {
        b.factory = true;
        b.optionalParameters.addAll(
          attributes.map(
            (attribute) => Parameter((p) {
              p.name = attribute.name;
              p.named = true;

              p.type =
                  attribute.required || attribute.array
                      ? attribute.reference
                      : attribute.reference.nullable;
              p.required = attribute.required || attribute.array;
              p.defaultTo =
                  attribute.required && attribute.raw.defaultValue != null
                      ? attribute.defaultTo
                      : null;
            }),
          ),
        );
        b.lambda = true;
        b.body =
            refer(className).newInstanceNamed('_', [], {
              for (final attribute in attributes)
                attribute.name: refer(attribute.name),
              '\$id': refer(
                'ID',
                'package:appwrite/appwrite.dart',
              ).property('unique').call([]),
              '\$collectionId': refer('collectionInfo').property('\$id'),
              '\$databaseId': refer('collectionInfo').property('databaseId'),
              '\$createdAt': refer(
                'DateTime',
                'dart:core',
              ).property('now').call([]).property('toUtc').call([]),
              '\$updatedAt': refer(
                'DateTime',
                'dart:core',
              ).property('now').call([]).property('toUtc').call([]),
              '\$permissions': refer(
                'collectionInfo',
              ).property('\$permissions'),
            }).code;
      }),
    );

    // toJson method
    b.methods.add(
      Method((b) {
        b.name = 'toJson';
        b.returns = refer('Map<String, dynamic>');
        b.annotations.add(refer('override'));
        b.lambda = true;
        b.body = Code('''
          {
            ${attributes.map((attribute) => attribute.toJson).join(',\n')},
          }
          ''');
      }),
    );

    // copyWith method
    b.methods.add(
      Method((b) {
        b.name = 'copyWith';
        b.returns = refer(className);
        b.annotations.add(refer('override'));
        b.optionalParameters.addAll(
          attributes.map(
            (attribute) => Parameter((b) {
              b.name = attribute.name;
              b.named = true;
              b.type = FunctionType((b) {
                b.returnType =
                    attribute.required || attribute.array
                        ? attribute.reference
                        : attribute.reference.nullable;
                b.isNullable = true;
              });
            }),
          ),
        );
        b.optionalParameters.addAll([
          Parameter(
            (b) =>
                b
                  ..name = '\$id'
                  ..type = refer('String?'),
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$collectionId'
                  ..type = refer('String?'),
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$databaseId'
                  ..type = refer('String?'),
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$createdAt'
                  ..type = refer('DateTime?'),
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$updatedAt'
                  ..type = refer('DateTime?'),
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$permissions'
                  ..type = refer('List<String>?'),
          ),
        ]);
        b.lambda = true;
        b.body = Code('''
          $className._(
            \$id: \$id ?? this.\$id,
            \$collectionId: \$collectionId ?? this.\$collectionId,
            \$databaseId: \$databaseId ?? this.\$databaseId,
            \$createdAt: \$createdAt ?? this.\$createdAt,
            \$updatedAt: \$updatedAt ?? this.\$updatedAt,
            \$permissions: \$permissions ?? this.\$permissions,
            ${attributes.map((attribute) => '${attribute.name}: ${attribute.name} != null ? ${attribute.name}() : this.${attribute.name},').join('\n')}
          )
        ''');
      }),
    );

    // toAppwrite method
    b.methods.add(
      Method((b) {
        b.name = 'toAppwrite';
        b.returns = refer('Map<String, dynamic>');
        b.annotations.add(refer('override'));
        b.optionalParameters.addAll([
          Parameter(
            (b) =>
                b
                  ..name = 'context'
                  ..type = refer(
                    'RelationContext?',
                    'package:$packageName/models/collections.dart',
                  )
                  ..named = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'includeId'
                  ..type = refer('bool')
                  ..defaultTo = Code('true')
                  ..named = true,
          ),
        ]);
        b.body = Block.of([
          declareFinal(
            'data',
            type: refer('Map<String, dynamic>'),
          ).assign(literalMap({})).statement,
          Code(
            'if (includeId && (context?.includeId ?? true)) data[\'\\\$id\'] = \$id;',
          ),
          Code('if (context?.includeData ?? true) {'),
          for (final attribute in attributes.where(
            (a) => a is! AttributeInfoRelation,
          ))
            attribute.toAppwrite.statement,
          Code('}'),
          for (final attribute
              in attributes.whereType<AttributeInfoRelation>()) ...[
            Code('if (context?[\'${attribute.name}\'] != null) {'),
            attribute.array
                ? Code(
                  'data[\'${attribute.name}\'] = ${attribute.name}.map((e) => e.toAppwrite(context: context?[\'${attribute.name}\'])).toList();',
                )
                : Code(
                  'data[\'${attribute.name}\'] = ${attribute.name}?.toAppwrite(context: context?[\'${attribute.name}\']);',
                ),
            Code('}'),
          ],
          Code('return data;'),
        ]);
      }),
    );

    // operator Equal
    b.methods.add(
      Method((b) {
        b.name = 'operator ==';
        b.returns = refer('bool');
        b.annotations.add(refer('override'));
        b.requiredParameters.add(
          Parameter(
            (b) =>
                b
                  ..name = 'other'
                  ..type = refer('Object'),
          ),
        );
        b.body = Code('''
          if (identical(this, other)) return true;
          if (other is! $className) return false;
          return ${attributes.map((attribute) => attribute.array ? '_eq(${attribute.name}, other.${attribute.name})' : '${attribute.name} == other.${attribute.name}').join(' && ')};
        ''');
      }),
    );

    // operator HashCode
    b.methods.add(
      Method((b) {
        b.name = 'hashCode';
        b.returns = refer('int');
        b.type = MethodType.getter;
        b.annotations.add(refer('override'));
        b.lambda = true;
        b.body = Code('''
          _hash([
          \$id,
          ${attributes.map((e) => e.array ? '...(${e.name}${e.required || e.array ? '' : ' ?? []'})' : e.name).join(',\n')},
        ])
        ''');
      }),
    );

    // Appwrite Section

    // fromAppwriteFactory
    b.constructors.add(
      Constructor((b) {
        b.name = 'fromAppwrite';
        b.factory = true;
        b.requiredParameters.add(
          Parameter(
            (b) =>
                b
                  ..name = 'doc'
                  ..type = refer('Document', 'package:appwrite/models.dart'),
          ),
        );
        b.lambda = true;
        b.body =
            refer(className).newInstanceNamed('_', [], {
              for (final attribute in attributes)
                attribute.name: attribute.fromAppwrite,
              '\$id': refer('doc').property('\$id'),
              '\$collectionId': refer('doc').property('\$collectionId'),
              '\$databaseId': refer('doc').property('\$databaseId'),
              '\$createdAt': refer(
                'DateTime',
              ).property('parse').call([refer('doc').property('\$createdAt')]),
              '\$updatedAt': refer(
                'DateTime',
              ).property('parse').call([refer('doc').property('\$updatedAt')]),
              '\$permissions': refer('doc').property('\$permissions'),
            }).code;
      }),
    );

    // Api Helpers
    b.methods.addAll([
      Method(
        (b) =>
            b
              ..name = 'page'
              ..static = true
              ..modifier = MethodModifier.async
              ..returns = TypeReference(
                (b) =>
                    b
                      ..symbol = 'Future'
                      ..types.add(
                        TypeReference(
                          (b) =>
                              b
                                ..symbol = 'Result'
                                ..url = 'package:result_type/result_type.dart'
                                ..types.addAll([
                                  RecordType(
                                    (b) =>
                                        b
                                          ..positionalFieldTypes.addAll([
                                            refer('int'),
                                            TypeReference(
                                              (b) =>
                                                  b
                                                    ..symbol = 'List'
                                                    ..types.add(
                                                      refer(className),
                                                    ),
                                            ),
                                          ]),
                                  ),
                                  // Second type: AppwriteException
                                  refer(
                                    'AppwriteException',
                                    'package:appwrite/appwrite.dart',
                                  ),
                                ]),
                        ),
                      ),
              )
              ..optionalParameters.addAll([
                Parameter(
                  (b) =>
                      b
                        ..name = 'limit'
                        ..named = true
                        ..type = refer('int')
                        ..defaultTo = Code('25'),
                ),
                Parameter(
                  (b) =>
                      b
                        ..name = 'offset'
                        ..named = true
                        ..type = refer('int?'),
                ),
                Parameter(
                  (b) =>
                      b
                        ..name = 'last'
                        ..named = true
                        ..type = refer('$className?'),
                ),
                Parameter(
                  (b) =>
                      b
                        ..name = 'queries'
                        ..named = true
                        ..type = refer('List<String>?'),
                ),
              ])
              ..lambda = true
              ..body = Code('''
    _client.page<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        limit: limit,
        offset: offset,
        last: last,
        queries: queries,
      )
  '''),
      ),
      Method(
        (b) =>
            b
              ..name = 'list'
              ..modifier = MethodModifier.async
              ..returns = TypeReference(
                (b) =>
                    b
                      ..symbol = 'Future'
                      ..types.add(
                        TypeReference(
                          (b) =>
                              b
                                ..symbol = 'Result'
                                ..url = 'package:result_type/result_type.dart'
                                ..types.addAll([
                                  RecordType(
                                    (b) =>
                                        b
                                          ..positionalFieldTypes.addAll([
                                            refer('int'),
                                            TypeReference(
                                              (b) =>
                                                  b
                                                    ..symbol = 'List'
                                                    ..types.add(
                                                      refer(className),
                                                    ),
                                            ),
                                          ]),
                                  ),
                                  // Second type: AppwriteException
                                  refer(
                                    'AppwriteException',
                                    'package:appwrite/appwrite.dart',
                                  ),
                                ]),
                        ),
                      ),
              )
              ..optionalParameters.addAll([
                Parameter(
                  (b) =>
                      b
                        ..name = 'queries'
                        ..type = refer('List<String>?'),
                ),
              ])
              ..lambda = true
              ..body = Code('''
    _client.list<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        queries: queries,
      )
  '''),
      ),
      Method(
        (b) =>
            b
              ..name = 'get'
              ..static = true
              ..modifier = MethodModifier.async
              ..returns = TypeReference(
                (b) =>
                    b
                      ..symbol = 'Future'
                      ..types.add(
                        TypeReference(
                          (b) =>
                              b
                                ..symbol = 'Result'
                                ..url = 'package:result_type/result_type.dart'
                                ..types.addAll([
                                  refer(className),
                                  refer(
                                    'AppwriteException',
                                    'package:appwrite/appwrite.dart',
                                  ),
                                ]),
                        ),
                      ),
              )
              ..requiredParameters.addAll([
                Parameter(
                  (b) =>
                      b
                        ..name = 'documentId'
                        ..type = refer('String'),
                ),
              ])
              ..optionalParameters.addAll([
                Parameter(
                  (b) =>
                      b
                        ..name = 'queries'
                        ..named = true
                        ..type = refer('List<String>?'),
                ),
              ])
              ..lambda = true
              ..body = Code('''
    _client.get<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        documentId: documentId,
        queries: queries,
      )
  '''),
      ),
      Method(
        (b) =>
            b
              ..name = 'create'
              ..modifier = MethodModifier.async
              ..returns = TypeReference(
                (b) =>
                    b
                      ..symbol = 'Future'
                      ..types.add(
                        TypeReference(
                          (b) =>
                              b
                                ..symbol = 'Result'
                                ..url = 'package:result_type/result_type.dart'
                                ..types.addAll([
                                  refer(className),
                                  refer(
                                    'AppwriteException',
                                    'package:appwrite/appwrite.dart',
                                  ),
                                ]),
                        ),
                      ),
              )
              ..optionalParameters.addAll([
                Parameter(
                  (b) =>
                      b
                        ..name = 'context'
                        ..named = true
                        ..type = TypeReference(
                          (b) =>
                              b
                                ..symbol = 'RelationContext'
                                ..url =
                                    'package:$packageName/models/collections.dart'
                                ..isNullable = true,
                        ),
                ),
              ])
              ..lambda = true
              ..body = Code('''
    _client.create<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        model: this,
        context: context,
        permissions: _eq(\$permissions, collectionInfo.\$permissions)
          ? null
          : \$permissions,
      )
  '''),
      ),
      Method(
        (b) =>
            b
              ..name = 'update'
              ..modifier = MethodModifier.async
              ..returns = TypeReference(
                (b) =>
                    b
                      ..symbol = 'Future'
                      ..types.add(
                        TypeReference(
                          (b) =>
                              b
                                ..symbol = 'Result'
                                ..url = 'package:result_type/result_type.dart'
                                ..types.addAll([
                                  refer(className),
                                  refer(
                                    'AppwriteException',
                                    'package:appwrite/appwrite.dart',
                                  ),
                                ]),
                        ),
                      ),
              )
              ..optionalParameters.addAll([
                Parameter(
                  (b) =>
                      b
                        ..name = 'context'
                        ..type = TypeReference(
                          (b) =>
                              b
                                ..symbol = 'RelationContext'
                                ..url =
                                    'package:$packageName/models/collections.dart'
                                ..isNullable = true,
                        )
                        ..named = true,
                ),
              ])
              ..lambda = true
              ..body = Code('''
    _client.update<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        model: this,
        context: context,
        permissions: _eq(\$permissions, collectionInfo.\$permissions)
          ? null
          : \$permissions,
      )
  '''),
      ),
      Method(
        (b) =>
            b
              ..name = 'delete'
              ..modifier = MethodModifier.async
              ..returns = TypeReference(
                (b) =>
                    b
                      ..symbol = 'Future'
                      ..types.add(
                        TypeReference(
                          (b) =>
                              b
                                ..symbol = 'Result'
                                ..url = 'package:result_type/result_type.dart'
                                ..types.addAll([
                                  refer('void'),
                                  refer(
                                    'AppwriteException',
                                    'package:appwrite/appwrite.dart',
                                  ),
                                ]),
                        ),
                      ),
              )
              ..lambda = true
              ..body = Code('''
    _client.delete(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        documentId: \$id,
      )
  '''),
      ),
    ]);
  });
}
