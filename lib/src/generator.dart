import 'package:appwrite_model_builder/src/appwrite_client.dart';
import 'package:appwrite_model_builder/src/base.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/enum.dart';
import 'package:appwrite_model_builder/src/collection_parser/collection_info.dart';
import 'package:appwrite_model_builder/src/collections.dart';
import 'package:appwrite_model_builder/src/model.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

final DartFormatter formatter = DartFormatter(
  languageVersion: DartFormatter.latestShortStyleLanguageVersion,
);

List<(String, String)> generateModels(
  List<dynamic> collections,
  String packageName,
) {
  final Map<String, String> collectionIdToName = collections.fold(
    <String, String>{},
    (map, collection) =>
        map
          ..[collection['\$id'] as String] = generateClassName(
            collection['name'] as String,
          ),
  );

  final List<(String, String)> models = [];
  for (final collection in collections) {
    final collectionInfo = CollectionInfo.fromMap(
      collection,
      collectionIdToName,
      packageName,
    );

    final lib = Library((lib) {
      lib.body.addAll([
        if (collectionInfo.attributes.any((e) => e.array))
          Field((b) {
            b.name = '_eq';
            b.modifier = FieldModifier.final$;
            b.assignment =
                refer(
                  'ListEquality',
                  'package:collection/collection.dart',
                ).constInstance([]).property('equals').code;
          }),
        Field((b) {
          b.name = '_hash';
          b.modifier = FieldModifier.final$;
          b.assignment =
              refer(
                'ListEquality',
                'package:collection/collection.dart',
              ).constInstance([]).property('hash').code;
        }),
        Field((b) {
          b.name = '_client';
          b.type = refer(
            'AppwriteClient',
            'package:$packageName/models/appwrite_client.dart',
          );
          b.modifier = FieldModifier.final$;
          b.assignment =
              refer(
                'GetIt',
                'package:get_it/get_it.dart',
              ).newInstanceNamed('I', [], {}, [
                refer(
                  'AppwriteClient',
                  'package:$packageName/models/appwrite_client.dart',
                ),
              ]).code;
        }),

        // Add enums
        for (final attribute in collectionInfo.attributes) ...[
          if (attribute is AttributeInfoEnum)
            Enum((e) {
              e.name = attribute.typeReference.symbol;
              e.values.addAll(
                attribute.values.map(
                  (value) => EnumValue((v) {
                    v.name = value;
                  }),
                ),
              );
            }),
        ],

        // Add Class
        model(collectionInfo, packageName),
      ]);
    });

    models.add((
      moduleName(collectionInfo.name),
      formatter.format(
        '${lib.accept(DartEmitter.scoped(useNullSafetySyntax: true))}',
      ),
    ));
  }

  return models;
}

String generateBaseModelFile(String packageName) {
  final lib = Library((lib) {
    lib.body.addAll([baseModel(packageName)]);
  });

  return formatter.format(
    '${lib.accept(DartEmitter.scoped(useNullSafetySyntax: true))}',
  );
}

String generateCollectionFile() {
  final lib = Library((lib) {
    lib.body.addAll([
      collectionInfo(),
      relation(),
      ...relationEnums(),
      relationContext(),
    ]);
  });

  return formatter.format(
    '${lib.accept(DartEmitter.scoped(useNullSafetySyntax: true))}',
  );
}

String generateAppwriteClient(String packageName) {
  final lib = Library((lib) {
    lib.directives.addAll([
      Directive.import('package:appwrite/appwrite.dart'),
      Directive.import('package:appwrite/models.dart', hide: ["Locale"]),
      Directive.import('package:result_type/result_type.dart'),
      Directive.import('package:$packageName/models/base.dart'),
    ]);

    lib.body.addAll([appwriteClient(packageName)]);
  });
  return formatter.format(
    lib.accept(DartEmitter.scoped(useNullSafetySyntax: true)).toString(),
  );
}
