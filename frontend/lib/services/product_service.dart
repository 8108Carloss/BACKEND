import 'package:flutter/material.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  int _total = 0;
  int _currentPage = 1;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get total => _total;

  Future<void> fetchProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final path = '/products${queryString.isNotEmpty ? '?$queryString' : ''}';
      final data = await ApiClient.get(path);

      if (page == 1) {
        _products = (data['products'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
      } else {
        _products.addAll(
          (data['products'] as List).map((p) => Product.fromJson(p)),
        );
      }
      _total = data['total'] ?? 0;
      _currentPage = page;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> fetchProduct(String id) async {
    try {
      final data = await ApiClient.get('/products/$id');
      return Product.fromJson(data['product']);
    } catch (_) {
      return null;
    }
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await ApiClient.post('/products', data);
    final product = Product.fromJson(response['product']);
    _products.insert(0, product);
    notifyListeners();
    return product;
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/products/$id', data);
    final updated = Product.fromJson(response['product']);
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updated;
      notifyListeners();
    }
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    await ApiClient.delete('/products/$id');
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
