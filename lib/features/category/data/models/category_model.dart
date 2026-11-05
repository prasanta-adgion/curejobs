import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: JsonParser.string(json['id']),
      name: JsonParser.string(json['name']),
      slug: JsonParser.string(json['slug']),
      description: JsonParser.nullableString(json['description']),
      sortOrder: JsonParser.integer(json['sortOrder']),
    );
  }

  /// Reads `{data: {items: [...]}}`, in `sortOrder` order.
  static List<CategoryModel> listFromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    final data = JsonParser.map(root['data']);
    final items = JsonParser.list(data['items']);

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) CategoryModel.fromJson(item),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
