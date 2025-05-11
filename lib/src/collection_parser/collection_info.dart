import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:appwrite_model_builder/src/collection_parser/resolver.dart';
import 'package:appwrite_model_builder/src/model.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

class CollectionInfo {
  final String $id;
  final List<String> $permissions;
  final String databaseId;
  final String name;
  final bool enabled;
  final bool documentSecurity;
  final List<AttributeInfo> attributes;
  final String packageName;

  Reference get reference => refer(
    name.capitalizeFirstLetter,
    'package:$packageName/models/${moduleName(name)}.dart',
  );

  CollectionInfo({
    required this.$id,
    required this.$permissions,
    required this.databaseId,
    required this.name,
    required this.enabled,
    required this.documentSecurity,
    required this.attributes,
    required this.packageName,
  });

  factory CollectionInfo.fromMap(
    Map<String, dynamic> map,
    Map<String, String> collectionIdToName,
    String packageName,
  ) {
    return CollectionInfo(
      $id: map['\$id'],
      $permissions: List.unmodifiable(map['\$permissions']),
      databaseId: map['databaseId'],
      name: map['name'],
      enabled: map['enabled'],
      documentSecurity: map['documentSecurity'],
      attributes:
          (map['attributes'] as List<dynamic>)
              .map(
                (e) => resolveAttributeInfo(
                  e as Map<String, dynamic>,
                  refer((map['name'] as String).capitalizeFirstLetter),
                  collectionIdToName,
                  packageName,
                ),
              )
              .toList(),
      packageName: packageName,
    );
  }
}
