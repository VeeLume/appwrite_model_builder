import 'package:code_builder/code_builder.dart';

extension Nullable on Reference {
  Reference get nullable {
    if (this is TypeReference) {
      return TypeReference(
        (b) =>
            b
              ..symbol = symbol
              ..url = url
              ..isNullable = true
              ..types.addAll((this as TypeReference).types),
      );
    } else {
      return refer('$symbol?', url);
    }
  }
}

enum RelationType { oneToOne, manyToOne, oneToMany, manyToMany }

enum RelationOnDelete { setNull, cascade, restrict }

enum RelationSide { parent, child }

class AttributeInfoRaw {
  final String key;
  final bool required;
  final bool array;
  final dynamic defaultValue;

  AttributeInfoRaw({
    required this.key,
    required this.required,
    required this.array,
    required this.defaultValue,
  });
}

class AttributeInfo {
  final AttributeInfoRaw raw;

  String get name => raw.key;
  bool get required => raw.required;
  bool get array => raw.array;
  Reference get typeReference => refer('dynamic');
  Code get defaultTo => Code(raw.defaultValue.toString());
  Reference get reference =>
      array ? refer('List<${typeReference.symbol}>') : typeReference;
  String packageName;

  AttributeInfo({required this.raw, required this.packageName});

  List<Field> get fields => [
    Field((b) {
      b.name = name;
      b.modifier = FieldModifier.final$;

      if (required || array) {
        b.type = reference;
      } else {
        b.type = reference.nullable;
      }
    }),
  ];

  Parameter get getConstructorParameter => Parameter((b) {
    b.name = name;
    b.named = true;
    b.toThis = true;
    b.defaultTo = defaultTo;
    b.required = required || array;
  });

  Code get toJson => Code("'$name': $name");
  Expression get toAppwrite =>
      refer('data').index(literalString(name)).assign(refer(name));

  Expression get fromAppwrite {
    if (array) {
      return refer('List').property('unmodifiable').call([
        refer('doc')
            .property('data')
            .index(literalString(name))
            .ifNullThen(literalList([])),
      ]);
    } else {
      return refer('doc').property('data').index(literalString(name));
    }
  }
}
