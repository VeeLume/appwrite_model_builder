import 'package:code_builder/code_builder.dart';

Class baseModel(String packageName) {
  return Class((c) {
    c.annotations.add(refer('immutable', 'package:flutter/foundation.dart'));
    c.name = 'AppwriteModel';
    c.abstract = true;
    c.types.add(refer('T'));

    c.constructors.add(
      Constructor((ctr) {
        ctr.constant = true;
        ctr.optionalParameters.addAll([
          Parameter(
            (p) =>
                p
                  ..name = '\$id'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (p) =>
                p
                  ..name = '\$collectionId'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (p) =>
                p
                  ..name = '\$databaseId'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (p) =>
                p
                  ..name = '\$createdAt'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (p) =>
                p
                  ..name = '\$updatedAt'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (p) =>
                p
                  ..name = '\$permissions'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
        ]);
      }),
    );

    c.fields.addAll([
      Field(
        (f) =>
            f
              ..name = '\$id'
              ..type = refer('String')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = '\$collectionId'
              ..type = refer('String')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = '\$databaseId'
              ..type = refer('String')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = '\$createdAt'
              ..type = refer('DateTime')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = '\$updatedAt'
              ..type = refer('DateTime')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = '\$permissions'
              ..type = refer('List<String>')
              ..modifier = FieldModifier.final$,
      ),
    ]);

    c.methods.addAll([
      Method(
        (m) =>
            m
              ..name = 'canRead'
              ..returns = refer('bool')
              ..lambda = true
              ..body = Code('\$permissions.any((e) => e.contains(\'read\'))'),
      ),
      Method(
        (m) =>
            m
              ..name = 'canUpdate'
              ..returns = refer('bool')
              ..lambda = true
              ..body = Code('\$permissions.any((e) => e.contains(\'update\'))'),
      ),
      Method(
        (m) =>
            m
              ..name = 'canDelete'
              ..returns = refer('bool')
              ..lambda = true
              ..body = Code('\$permissions.any((e) => e.contains(\'delete\'))'),
      ),
      Method(
        (m) =>
            m
              ..name = 'canReadUpdate'
              ..returns = refer('bool')
              ..lambda = true
              ..body = Code('canRead() && canUpdate()'),
      ),
      Method(
        (m) =>
            m
              ..name = 'toJson'
              ..returns = refer('Map<String, dynamic>'),
      ),
      Method(
        (m) =>
            m
              ..name = 'copyWith'
              ..returns = refer('T')
              ..optionalParameters.addAll([
                Parameter(
                  (p) =>
                      p
                        ..name = '\$id'
                        ..type = refer('String?')
                        ..named = true,
                ),
                Parameter(
                  (p) =>
                      p
                        ..name = '\$collectionId'
                        ..type = refer('String?'),
                ),
                Parameter(
                  (p) =>
                      p
                        ..name = '\$databaseId'
                        ..type = refer('String?'),
                ),
                Parameter(
                  (p) =>
                      p
                        ..name = '\$createdAt'
                        ..type = refer('DateTime?'),
                ),
                Parameter(
                  (p) =>
                      p
                        ..name = '\$updatedAt'
                        ..type = refer('DateTime?'),
                ),
                Parameter(
                  (p) =>
                      p
                        ..name = '\$permissions'
                        ..type = refer('List<String>?'),
                ),
              ]),
      ),
      Method(
        (m) =>
            m
              ..name = 'toString'
              ..annotations.add(refer('override'))
              ..lambda = true
              ..returns = refer('String')
              ..body = Code('toJson().toString()'),
      ),
      Method(
        (m) =>
            m
              ..name = 'toAppwrite'
              ..optionalParameters.add(
                Parameter(
                  (b) =>
                      b
                        ..name = 'context'
                        ..named = true
                        ..type = refer(
                          'RelationContext?',
                          'package:$packageName/models/collections.dart',
                        ),
                ),
              )
              ..returns = refer('dynamic'),
      ),
    ]);
  });
}
