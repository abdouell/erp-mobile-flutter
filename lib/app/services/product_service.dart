import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Cache pour éviter les appels répétés
  List<Product>? _cachedProducts;
  
  /// Récupérer tous les produits
  Future<List<Product>> getAllProducts() async {
    try {
      print('=== RÉCUPÉRATION PRODUITS ===');
      
      // Utiliser le cache si disponible
      if (_cachedProducts != null) {
        print('📦 Utilisation du cache produits (${_cachedProducts!.length} produits)');
        return _cachedProducts!;
      }
      
      final response = await _apiService.dio.get('/api/product');
      print('✅ Réponse API: ${response.data?.length ?? 0} produits');
      
      final List<dynamic> productsJson = response.data ?? [];
      final products = productsJson.map((json) => Product.fromJson(json)).toList();
      
      // Mise en cache
      _cachedProducts = products;
      
      print('📝 Produits parsés: ${products.length}');
      return products;
      
    } on DioException catch (e) {
      print('❌ Erreur Dio récupération produits: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé : permissions insuffisantes pour voir les produits');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Endpoint produits non trouvé');
      } else {
        throw Exception('Erreur serveur lors de la récupération des produits');
      }
    } catch (e) {
      print('❌ Erreur générale produits: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }
  
  /// Obtenir les catégories disponibles
  Future<List<String>> getAvailableCategories() async {
    try {
      final products = await getAllProducts();
      
      final categories = products
          .map((p) => p.productCategoryCode)
          .toSet()
          .toList();
      
      categories.sort(); // Tri alphabétique
      
      print('📂 Catégories disponibles: ${categories.length}');
      return categories;
      
    } catch (e) {
      print('❌ Erreur récupération catégories: $e');
      throw Exception('Erreur lors de la récupération des catégories');
    }
  }
  
  /// Vider le cache
  void clearCache() {
    print('🗑️ Nettoyage cache produits');
    _cachedProducts = null;
  }
}