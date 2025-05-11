import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:code_builder/code_builder.dart';

class AttributeInfoEmail extends AttributeInfo {
  AttributeInfoEmail({
    required super.raw,
    required super.packageName,
  });

  @override
  Reference get typeReference => refer('String', 'dart:core');
}
