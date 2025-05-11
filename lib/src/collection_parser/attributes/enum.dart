import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:appwrite_model_builder/src/model.dart';
import 'package:code_builder/code_builder.dart';

class AttributeInfoEnum extends AttributeInfo {
  final List<String> values;
  final Reference classReference;

  AttributeInfoEnum({
    required super.raw,
    required super.packageName,
    required this.values,
    required this.classReference,
  });

  @override
  String get name => generateClassName(raw.key);

  @override
  Reference get typeReference =>
      refer('${classReference.symbol}$name');

  @override
  Code get toJson =>
      array
          ? Code("'$name': $name.map((e) => e.name).toList()")
          : Code("'$name': $name.name");

  @override
  Expression get fromAppwrite =>
      array
          ? TypeReference(
            (b) =>
                b
                  ..symbol = 'List'
                  ..types.add(typeReference),
          ).property('unmodifiable').call([
            refer('doc')
                .property('data')
                .index(literalString(name))
                .nullSafeProperty('map')
                .call([
                  Method(
                    (b) =>
                        b
                          ..lambda = true
                          ..requiredParameters.add(
                            Parameter((p) => p..name = 'e'),
                          )
                          ..body =
                              typeReference
                                  .property('values')
                                  .property('byName')
                                  .call([refer('e')])
                                  .code,
                  ).closure,
                ])
                .ifNullThen(literalList([], typeReference)),
          ])
          : required
          ? typeReference.property('values').property('byName').call([
            refer('doc').property('data').index(literalString(name)),
          ])
          : refer('doc')
              .property('data')
              .index(literalString(name))
              .notEqualTo(literalNull)
              .conditional(
                typeReference.property('values').property('byName').call([
                  refer('doc').property('data').index(literalString(name)),
                ]),
                literalNull,
              );
}
