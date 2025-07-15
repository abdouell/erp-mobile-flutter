import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_item.dart';

class OrderCartView extends GetView<OrderController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  /// 📱 APP BAR
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Mon panier'),
      backgroundColor: Theme.of(Get.context!).primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        Obx(() => Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${controller.cartItemCount.value} article(s)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )),
      ],
    );
  }
  
  /// 📱 BODY PRINCIPAL
  Widget _buildBody() {
    return Obx(() {
      // Panier vide
      if (controller.cartItems.isEmpty) {
        return _buildEmptyCart();
      }
      
      return Column(
        children: [
          // Info client
          _buildClientHeader(),
          
          // Liste des articles
          Expanded(child: _buildCartItemsList()),
          
          // Récapitulatif
          _buildOrderSummary(),
        ],
      );
    });
  }
  
  /// 🛒 PANIER VIDE
  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 24),
            Text(
              'Votre panier est vide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Ajoutez des produits pour créer votre commande',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(Icons.add_shopping_cart),
              label: Text('Ajouter des produits'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 👤 HEADER CLIENT
  Widget _buildClientHeader() {
    return Obx(() {
      final client = controller.selectedClient.value;
      if (client == null) return SizedBox.shrink();
      
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.customerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (client.customerAddress.isNotEmpty)
                    Text(
                      client.customerAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
  
  /// 📦 LISTE DES ARTICLES
  Widget _buildCartItemsList() {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.cartItems.length,
      itemBuilder: (context, index) {
        final item = controller.cartItems[index];
        return _buildCartItemCard(item);
      },
    ));
  }
  
  /// 🛍️ CARD ARTICLE PANIER
  Widget _buildCartItemCard(OrderItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image produit (placeholder)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.product?.hasPhoto == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            item.product!.photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildProductPlaceholder();
                            },
                          ),
                        )
                      : _buildProductPlaceholder(),
                ),
                
                SizedBox(width: 12),
                
                // Info produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ref: ${item.productCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Prix unitaire: ${item.formattedPrice}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bouton supprimer
                IconButton(
                  onPressed: () => _showDeleteConfirmation(item),
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Ligne quantité et total
            Row(
              children: [
                // Contrôles quantité
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => controller.updateCartItemQuantity(
                          item.productId,
                          item.quantity - 1,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.remove, size: 18),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => controller.updateCartItemQuantity(
                          item.productId,
                          item.quantity + 1,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Spacer(),
                
                // Sous-total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.hasDiscount) ...[
                      Text(
                        '${item.subtotalBeforeDiscount.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        '-${item.formattedDiscount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    Text(
                      item.formattedSubtotal,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 📦 PLACEHOLDER PRODUIT
  Widget _buildProductPlaceholder() {
    return Icon(
      Icons.inventory_2_outlined,
      size: 32,
      color: Colors.grey.shade400,
    );
  }
  
  /// 📊 RÉCAPITULATIF COMMANDE
  Widget _buildOrderSummary() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Sous-total
          _buildSummaryRow(
            'Sous-total (${controller.cartItemCount.value} articles)',
            '${controller.cartTotal.value.toStringAsFixed(2)} €',
            isSubtitle: true,
          ),
          
          // Remises (si applicable)
          if (controller.cartItems.any((item) => item.hasDiscount)) ...[
            SizedBox(height: 4),
            _buildSummaryRow(
              'Remises',
              '-${controller.cartItems.fold(0.0, (sum, item) => sum + item.discountAmount).toStringAsFixed(2)} €',
              color: Colors.green.shade600,
              isSubtitle: true,
            ),
          ],
          
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          
          // Total final
          _buildSummaryRow(
            'Total TTC',
            '${controller.cartTotal.value.toStringAsFixed(2)} €',
            isTotal: true,
          ),
        ],
      ),
    ));
  }
  
  /// 📄 LIGNE RÉCAPITULATIF
  Widget _buildSummaryRow(
    String label, 
    String amount, {
    bool isTotal = false,
    bool isSubtitle = false,
    Color? color,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isSubtitle ? Colors.grey.shade700 : Colors.black),
          ),
        ),
        Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isTotal ? Theme.of(Get.context!).primaryColor : Colors.black),
          ),
        ),
      ],
    );
  }
  
  /// 📱 BOTTOM BAR ACTIONS
Widget _buildBottomBar() {
  return Obx(() {
    if (controller.cartItems.isEmpty) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isValidatingOrder.value
              ? null
              : () => controller.validateOrder(),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: controller.isValidatingOrder.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Validation en cours...', style: TextStyle(fontSize: 16)),
                  ],
                )
              : Text(
                  'Valider la commande',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  });
}
  
  /// ❌ CONFIRMATION SUPPRESSION
  void _showDeleteConfirmation(OrderItem item) {
    Get.dialog(
      AlertDialog(
        title: Text('Supprimer l\'article'),
        content: Text('Voulez-vous retirer "${item.productName}" du panier ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeFromCart(item.productId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}