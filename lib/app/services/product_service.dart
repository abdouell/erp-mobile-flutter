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

  /// Récupérer les produits disponibles en stock pour un emplacement
/// Utilisé pour les vendeurs conventionnels
Future<List<Product>> getProductsByEmplacement(String emplacementCode) async {
  try {
    print('=== RÉCUPÉRATION PRODUITS PAR EMPLACEMENT ===');
    print('Emplacement: $emplacementCode');
    
    final response = await _apiService.dio.get(
      '/api/product/emplacement/$emplacementCode/stock',
    );
    
    print('✅ Réponse API: ${response.data?.length ?? 0} produits en stock');
    
    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    print('📦 Produits en stock parsés: ${products.length}');
    return products;
    
  } on DioException catch (e) {
    print('❌ Erreur Dio récupération produits emplacement: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    
    if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé : permissions insuffisantes');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Emplacement non trouvé');
    } else {
      throw Exception('Erreur serveur lors de la récupération des produits');
    }
  } catch (e) {
    print('❌ Erreur générale produits emplacement: $e');
    throw Exception('Erreur inattendue: $e');
  }
}

/// Récupérer les produits avec tarification client personnalisée
/// Affiche prix catalogue + prix client + % remise
Future<List<Product>> getProductsForCustomer(int customerId) async {
  try {
    print('=== RÉCUPÉRATION PRODUITS AVEC TARIFICATION CLIENT ===');
    print('Customer ID: $customerId');
    
    final response = await _apiService.dio.get('/api/product/customer/$customerId/pricing');
    print('✅ Réponse API: ${response.data?.length ?? 0} produits avec tarification');
    
    final List<dynamic> productsJson = response.data ?? [];
    final products = productsJson.map((json) => Product.fromJson(json)).toList();
    
    print('📦 Produits parsés avec tarification: ${products.length}');
    
    // Compter combien ont des prix spéciaux
    final withDiscount = products.where((p) => p.hasDiscount).length;
    print('💰 Produits avec remise: $withDiscount');
    
    return products;
    
  } on DioException catch (e) {
    print('❌ Erreur Dio récupération produits client: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    
    if (e.response?.statusCode == 403) {
      throw Exception('Accès refusé : permissions insuffisantes pour voir les produits');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Client non trouvé');
    } else {
      throw Exception('Erreur serveur lors de la récupération des produits');
    }
  } catch (e) {
    print('❌ Erreur générale produits client: $e');
    throw Exception('Erreur inattendue: $e');
  }
}

}