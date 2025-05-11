import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:code_builder/code_builder.dart';

class AttributeInfoDateTime extends AttributeInfo {
  AttributeInfoDateTime({required super.raw, required super.packageName});

  @override
  Reference get typeReference => refer('DateTime', 'dart:core');

  @override
  Code get toJson =>
      array
          ? Code("'$name': $name.map((e) => e.toIso8601String()).toList()")
          : Code("'$name': $name${required ? '' : '?'}.toIso8601String()");

  @override
  Expression get toAppwrite =>
      array
          ? refer('data')
              .index(literalString(name))
              .assign(
                refer(name)
                    .property('map')
                    .call([
                      Method(
                        (b) =>
                            b
                              ..lambda = true
                              ..requiredParameters.add(
                                Parameter((p) => p..name = 'e'),
                              )
                              ..body =
                                  refer('e').property('toIso8601String').code,
                      ).closure,
                    ])
                    .property('toList')
                    .call([]),
              )
          : refer('data')
              .index(literalString(name))
              .assign(refer(name).property('toIso8601String'));

  @override
  Expression get fromAppwrite =>
      array
          ? TypeReference(
            (p) =>
                p
                  ..symbol = 'List'
                  ..types.add(typeReference),
          ).newInstanceNamed('unmodifiable', [
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
                          ..body = refer('DateTime.parse(e)').code,
                  ).closure,
                ])
                .ifNullThen(literalList([], typeReference)),
          ])
          : required
          ? typeReference.property('parse').call([
            refer('doc').property('data').index(literalString(name)),
          ])
          : refer('doc')
              .property('data')
              .index(literalString(name))
              .notEqualTo(literalNull)
              .conditional(
                refer('DateTime.parse').call([
                  refer('doc').property('data').index(literalString(name)),
                ]),
                literalNull,
              );
}
