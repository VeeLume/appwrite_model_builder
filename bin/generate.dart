import 'dart:convert';
import 'dart:io';

import 'package:appwrite_model_builder/src/generator.dart';
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

  // Generate model files for all collections in ./models
  // Include the base model in ./models/base.dart
  await Directory('lib/models').create(recursive: true);
  final baseModelOutput = generateBaseModelFile(pubspec['name'] as String);
  await File('lib/models/base.dart').writeAsString(baseModelOutput);
  print('✅ base.dart generated!');
  final modelsOutput = generateModels(
    appwriteJson['collections'] as List<dynamic>,
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

  print('✅ test_model.dart generated!');
}
