import 'package:code_builder/code_builder.dart';

Class relation() {
  return Class((c) {
    c.annotations.add(refer('immutable', 'package:flutter/foundation.dart'));
    c.name = 'Relation';
    c.fields.addAll([
      Field(
        (f) =>
            f
              ..name = 'required'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'array'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'relatedCollection'
              ..type = refer('String')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'relationType'
              ..type = refer('RelationType')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'twoWay'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'twoWayKey'
              ..type = refer('String?')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'onDelete'
              ..type = refer('RelationOnDelete')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'side'
              ..type = refer('RelationSide')
              ..modifier = FieldModifier.final$,
      ),
    ]);

    c.constructors.add(
      Constructor((b) {
        b.constant = true;
        b.optionalParameters.addAll([
          Parameter(
            (b) =>
                b
                  ..name = 'required'
                  ..named = true
                  ..defaultTo = const Code('false')
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'array'
                  ..named = true
                  ..defaultTo = const Code('false')
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'relatedCollection'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'relationType'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'twoWay'
                  ..named = true
                  ..defaultTo = const Code('false')
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'twoWayKey'
                  ..named = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'onDelete'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'side'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
        ]);
      }),
    );
  });
}

Class collectionInfo() {
  return Class((c) {
    c.annotations.add(refer('immutable', 'package:flutter/foundation.dart'));
    c.name = 'CollectionInfo';
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
              ..name = '\$permissions'
              ..type = refer('List<String>')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'databaseId'
              ..type = refer('String')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'name'
              ..type = refer('String')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'enabled'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$,
      ),
      Field(
        (f) =>
            f
              ..name = 'documentSecurity'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$,
      ),
    ]);

    c.constructors.add(
      Constructor((b) {
        b.constant = true;
        b.optionalParameters.addAll([
          Parameter(
            (b) =>
                b
                  ..name = '\$id'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = '\$permissions'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'databaseId'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'name'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'enabled'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
          Parameter(
            (b) =>
                b
                  ..name = 'documentSecurity'
                  ..named = true
                  ..required = true
                  ..toThis = true,
          ),
        ]);
      }),
    );
  });
}

List<Enum> relationEnums() {
  return [
    Enum((b) {
      b.name = 'RelationType';
      b.values.addAll([
        EnumValue((b) => b..name = 'oneToOne'),
        EnumValue((b) => b..name = 'oneToMany'),
        EnumValue((b) => b..name = 'manyToOne'),
        EnumValue((b) => b..name = 'manyToMany'),
      ]);
    }),
    Enum((b) {
      b.name = 'RelationOnDelete';
      b.values.addAll([
        EnumValue((b) => b..name = 'cascade'),
        EnumValue((b) => b..name = 'setNull'),
        EnumValue((b) => b..name = 'restrict'),
      ]);
    }),
    Enum((b) {
      b.name = 'RelationSide';
      b.values.addAll([
        EnumValue((b) => b..name = 'parent'),
        EnumValue((b) => b..name = 'child'),
      ]);
    }),
  ];
}

Class relationContext() {
  return Class(
    (b) =>
        b
          ..name = 'RelationContext'
          ..annotations.add(
            refer('immutable', 'package:flutter/foundation.dart'),
          )
          ..fields.addAll([
            Field(
              (b) =>
                  b
                    ..name = 'children'
                    ..type = refer('Map<String, RelationContext>?')
                    ..modifier = FieldModifier.final$,
            ),
            Field(
              (b) =>
                  b
                    ..name = 'includeId'
                    ..type = refer('bool')
                    ..modifier = FieldModifier.final$,
            ),
            Field(
              (b) =>
                  b
                    ..name = 'includeData'
                    ..type = refer('bool')
                    ..modifier = FieldModifier.final$,
            ),
          ])
          ..constructors.add(
            Constructor(
              (b) =>
                  b
                    ..constant = true
                    ..optionalParameters.addAll([
                      Parameter(
                        (b) =>
                            b
                              ..name = 'children'
                              ..named = true
                              ..toThis = true,
                      ),
                      Parameter(
                        (b) =>
                            b
                              ..name = 'includeId'
                              ..defaultTo = Code('true')
                              ..named = true
                              ..toThis = true,
                      ),
                      Parameter(
                        (b) =>
                            b
                              ..name = 'includeData'
                              ..defaultTo = Code('true')
                              ..named = true
                              ..toThis = true,
                      ),
                    ]),
            ),
          )
          ..methods.add(
            Method(
              (b) =>
                  b
                    ..returns = refer('RelationContext?')
                    ..name = 'operator []'
                    ..requiredParameters.add(
                      Parameter(
                        (b) =>
                            b
                              ..name = 'key'
                              ..type = refer('String'),
                      ),
                    )
                    ..lambda = true
                    ..body = Code('children?[key]'),
            ),
          ),
  );
}
