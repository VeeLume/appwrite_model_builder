import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/bool.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/datetime.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/double.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/email.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/enum.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/int.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/relationship.dart';
import 'package:appwrite_model_builder/src/collection_parser/attributes/string.dart';
import 'package:appwrite_model_builder/src/model.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

AttributeInfo resolveAttributeInfo(
  Map<String, dynamic> attribute,
  Reference classReference,
  Map<String, String> collectionIdToName,
  String packageName,
) {
  final key = attribute['key'] as String;
  final required = attribute['required'] as bool;
  final array = attribute['array'] as bool;
  final defaultValue = attribute['default'];
  final format = attribute['format'] as String?;

  if (format == 'email') {
    return AttributeInfoEmail(
      packageName: packageName,
      raw: AttributeInfoRaw(
        key: key,
        required: required,
        array: array,
        defaultValue: defaultValue,
      ),
    );
  }

  if (format == 'enum') {
    return AttributeInfoEnum(
      packageName: packageName,
      raw: AttributeInfoRaw(
        key: key,
        required: required,
        array: array,
        defaultValue: defaultValue,
      ),
      values: (attribute['elements'] as List<dynamic>).cast<String>(),
      classReference: classReference,
    );
  }

  switch (attribute['type'] as String) {
    case 'string':
      return AttributeInfoString(
        packageName: packageName,
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
        size: attribute['size'] as int,
      );
    case 'integer':
      return AttributeInfoInt(
        packageName: packageName,
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
        min: attribute['min'] as int,
        max: attribute['max'] as int,
      );
    case 'double':
      return AttributeInfoDouble(
        packageName: packageName,
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
        min: attribute['min'] as double,
        max: attribute['max'] as double,
      );
    case 'boolean':
      return AttributeInfoBool(
        packageName: packageName,
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
      );
    case 'datetime':
      return AttributeInfoDateTime(
        packageName: packageName,
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
      );
    case 'relationship':
      return AttributeInfoRelation(
        packageName: packageName,
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
        relationType: RelationType.values.byName(
          attribute['relationType'] as String,
        ),
        onDelete: RelationOnDelete.values.byName(
          attribute['onDelete'] as String,
        ),
        side: RelationSide.values.byName(attribute['side'] as String),
        relatedCollection: attribute['relatedCollection'] as String,
        twoWay: attribute['twoWay'] as bool,
        twoWayKey: attribute['twoWayKey'] as String?,
        relatedClassReference: refer(
          collectionIdToName[attribute['relatedCollection'] as String]!
              .capitalizeFirstLetter,
          'package:$packageName/models/${moduleName(collectionIdToName[attribute['relatedCollection'] as String]!)}.dart',
        ),
      );
    default:
      throw Exception('Unknown attribute type');
  }
}
