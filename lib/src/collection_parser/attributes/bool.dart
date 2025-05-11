import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:code_builder/code_builder.dart';

class AttributeInfoBool extends AttributeInfo {
  AttributeInfoBool({required super.raw, required super.packageName});

  @override
  Reference get typeReference => refer('bool', 'dart:core');
}
