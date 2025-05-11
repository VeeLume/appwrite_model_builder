import 'package:appwrite_model_builder/src/collection_parser/attribute_info.dart';
import 'package:code_builder/code_builder.dart';

class AttributeInfoDouble extends AttributeInfo {
  /// The minimum value of the double.
  final double min;

  /// The maximum value of the double.
  final double max;

  AttributeInfoDouble({
    required super.raw,
    required this.min,
    required this.max,
    required super.packageName,
  });

  @override
  Reference get typeReference => refer('double', 'dart:core');
}
