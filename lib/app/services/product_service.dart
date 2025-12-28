import 'package:get/get.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Cache simple pour les produits
  List<Product>? _cachedProducts;

  /// Obtenir tous les produits
  Future<List<Product>> getAllProducts() async {
    // Utiliser le cache si disponible
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }
    
    final response = await _apiService.dio.get('/api/product');
    
    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    // Mise en cache
    _cachedProducts = products;
    
    return products;
  }
  
  /// Obtenir les catégories disponibles
  Future<List<String>> getAvailableCategories() async {
    final products = await getAllProducts();
    
    final categories = products
        .map((p) => p.productCategoryCode)
        .toSet()
        .toList();
    
    categories.sort(); // Tri alphabétique
    return categories;
  }
  
  /// Obtenir les produits par emplacement
  Future<List<Product>> getProductsByEmplacement(String emplacement) async {
    final response = await _apiService.dio.get('/api/product/emplacement/$emplacement');
    
    final List<dynamic> productsJson = response.data ?? [];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }
  
  /// Obtenir les produits pour un client
  Future<List<Product>> getProductsForCustomer(int customerId) async {
    final response = await _apiService.dio.get('/api/product/customer/$customerId');
    
    final List<dynamic> productsJson = response.data ?? [];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }
  
  /// Vider le cache des produits
  void clearCache() {
    _cachedProducts = null;
  }
}
