import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:code_builder/code_builder.dart';

class AttributeInfoInt extends AttributeInfo {
  /// The minimum value of the integer.
  final int min;

  /// The maximum value of the integer.
  final int max;

  AttributeInfoInt({
    required super.raw,
    required super.packageName,
    required this.min,
    required this.max,
  });

  @override
  Reference get typeReference => refer('int', 'dart:core');
}
