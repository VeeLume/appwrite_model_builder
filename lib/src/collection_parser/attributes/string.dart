import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:code_builder/code_builder.dart';

class AttributeInfoString extends AttributeInfo {
  /// The size of the string.
  final int size;

  AttributeInfoString({
    required super.raw,
    required super.packageName,
    required this.size,
  });

  @override
  Reference get typeReference => refer('String', 'dart:core');
}
