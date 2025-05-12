import 'dart:convert';
import 'dart:io';

import 'package:appwrite_model_builder/src/collection_parser/collection_info.dart';
import 'package:appwrite_model_builder/src/generator.dart';
import 'package:appwrite_model_builder/src/model.dart';
import 'package:yaml/yaml.dart';

void main() async {
  final file = File('appwrite.json');
  if (!await file.exists()) {
    print('❌ appwrite.json not found');
    exit(1);
  }

  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('❌ pubspec.yaml not found');
    exit(1);
  }

  final appwriteJson =
      jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final pubspec = loadYaml(await pubspecFile.readAsString());

  final Map<String, String> collectionIdToName =
      (appwriteJson['collections'] as List<dynamic>).fold(
        <String, String>{},
        (map, collection) =>
            map
              ..[collection['\$id'] as String] = toSingularPascalCase(
                collection['name'] as String,
              ),
      );

  final collectionInfos =
      (appwriteJson['collections'] as List<dynamic>).map((collection) {
        final collectionInfo = CollectionInfo.fromMap(
          collection as Map<String, dynamic>,
          collectionIdToName,
          pubspec['name'] as String,
        );
        return collectionInfo;
      }).toList();

  // Generate Providers
  await Directory('lib/providers').create(recursive: true);
  final providersOutput = generateProviders(
    collectionInfos,
    pubspec['name'] as String,
  );
  for (final provider in providersOutput) {
    final fileName = provider.$1.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await File('lib/providers/$fileName.dart').writeAsString(provider.$2);
    print('✅ $fileName.dart generated!');
  }

  // Generate model files for all collections in ./models
  // Include the base model in ./models/base.dart
  await Directory('lib/models').create(recursive: true);
  final baseModelOutput = generateBaseModelFile(pubspec['name'] as String);
  await File('lib/models/base.dart').writeAsString(baseModelOutput);
  print('✅ base.dart generated!');
  final modelsOutput = generateModels(
    collectionInfos,
    pubspec['name'] as String,
  );
  for (final model in modelsOutput) {
    final fileName = model.$1.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await File('lib/models/$fileName.dart').writeAsString(model.$2);
    print('✅ $fileName.dart generated!');
  }

  final collectionOutput = generateCollectionFile();
  await File('lib/models/collections.dart').writeAsString(collectionOutput);
  print('✅ collections.dart generated!');

  final appwriteOutput = generateAppwriteClient(pubspec['name'] as String);
  await File('lib/models/appwrite_client.dart').writeAsString(appwriteOutput);
  print('✅ appwrite_client.dart generated!');

  final registerHelperOutput = generateRegisterHelper(
    pubspec['name'] as String,
    collectionInfos,
  );
  await File(
    'lib/providers/register_helper.dart',
  ).writeAsString(registerHelperOutput);
  print('✅ register_helper.dart generated!');
}
