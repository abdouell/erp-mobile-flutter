import 'package:erp_mobile/app/controllers/tournee_controller.dart';
import 'package:erp_mobile/app/models/client_tournee.dart';
import 'package:erp_mobile/app/models/order.dart';
import 'package:erp_mobile/app/models/statut_visite.dart';
import 'package:erp_mobile/app/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/tournee.dart';

class ClientsView extends GetView<TourneeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Clients'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            final tournee = controller.tourneeToday.value;
            if (tournee == null) return SizedBox.shrink();
            
            return Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${tournee.clientsVisites}/${tournee.nombreClients}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() => _buildBody()),
    );
  }
  
  Widget _buildBody() {
    final tournee = controller.tourneeToday.value;
    
    if (tournee == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erreur: Aucune tournée sélectionnée'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () => Get.back(), child: Text('Retour')),
          ],
        ),
      );
    }
    
    if (tournee.clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text('Aucun client dans cette tournée', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('La tournée ne contient pas de clients', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        _buildTourneeHeader(tournee),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tournee.clients.length,
              itemBuilder: (context, index) => _buildClientCard(tournee.clients[index], index + 1),
            ),
          ),
        ),
        if (tournee.statut != Tournee.TERMINEE) _buildClotureTourneeButton(tournee),
      ],
    );
  }

  Widget _buildTourneeHeader(Tournee tournee) {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tournée du ${_formatDate(tournee.date)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.route, size: 16, color: Colors.blue),
              SizedBox(width: 4),
              Text('${tournee.nombreClients} clients'),
              SizedBox(width: 16),
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              SizedBox(width: 4),
              Text('${tournee.clientsVisites} visités'),
              SizedBox(width: 16),
              Icon(Icons.schedule, size: 16, color: Colors.orange),
              SizedBox(width: 4),
              Text('${tournee.clientsNonVisites} restants'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildClientCard(ClientTournee clientTournee, int position) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: clientTournee.statutVisite.color,
          child: Icon(clientTournee.statutVisite.icon, color: Colors.white, size: 20),
        ),
        title: Text(clientTournee.customerName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(child: Text(clientTournee.customerAddress, style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
            if (clientTournee.customerRc.isNotEmpty) ...[
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.business, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('RC: ${clientTournee.customerRc}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
            if (clientTournee.isInProgress && clientTournee.checkinAt != null) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text('En cours depuis ${_formatDuration(DateTime.now().difference(clientTournee.checkinAt!))}', style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
                ],
              ),
            ],
            if (clientTournee.isCompleted && clientTournee.formattedDuration.isNotEmpty) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Durée: ${clientTournee.formattedDuration}', style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                ],
              ),
            ],
            if (clientTournee.commentaire != null && clientTournee.commentaire!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(clientTournee.commentaire!, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            ],
            SizedBox(height: 6),
            _buildStatutChip(clientTournee.statutVisite),
          ],
        ),
        trailing: _buildClientActions(clientTournee),
        onTap: () => _showClientActions(clientTournee),
      ),
    );
  }

  Widget _buildStatutChip(StatutVisite statut) {
    return Chip(
      label: Text(statut.label, style: TextStyle(color: Colors.white, fontSize: 11)),
      backgroundColor: statut.color,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildClientActions(ClientTournee clientTournee) {
    switch (clientTournee.statutVisite) {
      case StatutVisite.NON_VISITE:
        return Icon(Icons.touch_app, color: Colors.blue.shade300);
      case StatutVisite.VISITE_EN_COURS:
        return Icon(Icons.shopping_cart, color: Colors.orange.shade600);
      case StatutVisite.VISITE_TERMINEE:
      case StatutVisite.COMMANDE_CREEE:
        return PopupMenuButton<String>(
          onSelected: (value) => _handleClientAction(value, clientTournee),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'history', child: Row(children: [Icon(Icons.history, color: Colors.purple), SizedBox(width: 8), Text('Historique commandes')])),
            PopupMenuItem(value: 'call', child: Row(children: [Icon(Icons.phone, color: Colors.orange), SizedBox(width: 8), Text('Appeler')])),
          ],
        );
    }
  }

  void _handleClientAction(String action, ClientTournee client) {
    if (action == 'history') _showOrderHistory(client);
    if (action == 'call') _callClient(client);
  }

  void _showOrderHistory(ClientTournee client) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  Icon(Icons.history, color: Get.theme.primaryColor),
                  SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Historique commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(client.customerName, style: TextStyle(color: Colors.grey.shade600)),
                  ])),
                  IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: Get.find<CustomerService>().getCustomerOrders(client.customerId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  
                  final orders = snapshot.data ?? [];
                  
                  if (orders.isEmpty) {
                    return Center(child: Text('Aucune commande'));
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        child: ListTile(
                          title: Text('Commande #${order.id}'),
                          subtitle: Text('${order.formattedDate} • ${order.itemCount} articles'),
                          trailing: Text(order.formattedTotal, style: TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {
                            Get.back();
                            Get.toNamed('/order-details/${order.id}');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _callClient(ClientTournee client) {
    Get.snackbar('Appel client', 'Appel de ${client.customerName}', backgroundColor: Colors.orange, colorText: Colors.white);
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'aujourd\'hui';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  Widget _buildClotureTourneeButton(Tournee tournee) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _handleClotureTournee(tournee),
            icon: Icon(Icons.check_circle),
            label: Text('Terminer la tournée'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ),
      ),
    );
  }

  void _handleClotureTournee(Tournee tournee) {
    final clientsNonVisites = tournee.clients.where((c) => c.statutVisite == StatutVisite.NON_VISITE).length;
    final clientsEnCours = tournee.clients.where((c) => c.statutVisite == StatutVisite.VISITE_EN_COURS).length;
    
    if (clientsEnCours > 0) {
      Get.dialog(AlertDialog(
        title: Text('Impossible de clôturer'),
        content: Text('Vous avez $clientsEnCours client(s) en cours de visite.'),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('OK'))],
      ));
      return;
    }
    
    if (clientsNonVisites > 0) {
      Get.dialog(AlertDialog(
        title: Text('Clôture de tournée'),
        content: Text('Il reste $clientsNonVisites client(s) non visité(s).\n\nVoulez-vous vraiment clôturer la tournée ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Annuler')),
          ElevatedButton(onPressed: () { Get.back(); _executeClotureTournee(tournee); }, child: Text('Clôturer quand même')),
        ],
      ));
    } else {
      _executeClotureTournee(tournee);
    }
  }

  void _executeClotureTournee(Tournee tournee) async {
    try {
      Get.dialog(AlertDialog(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Clôture en cours...')])), barrierDismissible: false);
      
      await controller.cloturerTournee(tournee.id);
      
      Get.back();
      Get.back();
      
      Get.snackbar('Tournée terminée', 'La tournée a été clôturée avec succès', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar('Erreur', 'Impossible de clôturer la tournée: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showClientActions(ClientTournee client) {
  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: client.statutVisite.color,
                  child: Icon(client.statutVisite.icon, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.customerName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(client.customerAddress, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
              ],
            ),
          ),
          
          // Actions selon le statut
          ...(_buildClientActionButtons(client)),
          
          SizedBox(height: 16),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

List<Widget> _buildClientActionButtons(ClientTournee client) {
  switch (client.statutVisite) {
    case StatutVisite.NON_VISITE:
      return [
        ListTile(
          leading: Icon(Icons.play_circle, color: Colors.green),
          title: Text('Démarrer la visite'),
          onTap: () => _handleCheckin(client),
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue),
          title: Text('Voir les détails'),
          onTap: () {
            Get.back();
            Get.toNamed('/client-details', arguments: {'client': client});
          },
        ),
      ];
      
    case StatutVisite.VISITE_EN_COURS:
      return [
        ListTile(
          leading: Icon(Icons.shopping_cart, color: Colors.blue),
          title: Text('Créer une commande'),
          onTap: () => _handleCreateOrder(client),
        ),
        ListTile(
          leading: Icon(Icons.cancel, color: Colors.orange),
          title: Text('Terminer sans commande'),
          onTap: () => _handleCheckoutNoSale(client),
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.grey),
          title: Text('Voir les détails'),
          onTap: () {
            Get.back();
            Get.toNamed('/client-details', arguments: {'client': client});
          },
        ),
      ];
      
    case StatutVisite.VISITE_TERMINEE:
    case StatutVisite.COMMANDE_CREEE:
      return [
        ListTile(
          leading: Icon(Icons.history, color: Colors.purple),
          title: Text('Historique commandes'),
          onTap: () {
            Get.back();
            _showOrderHistory(client);
          },
        ),
        ListTile(
          leading: Icon(Icons.phone, color: Colors.orange),
          title: Text('Appeler le client'),
          onTap: () {
            Get.back();
            _callClient(client);
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue),
          title: Text('Voir les détails'),
          onTap: () {
            Get.back();
            Get.toNamed('/client-details', arguments: {'client': client});
          },
        ),
      ];
  }
}

// Check-in
void _handleCheckin(ClientTournee client) async {
  Get.back();
  try {
    Get.dialog(AlertDialog(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Check-in...')])), barrierDismissible: false);
    await controller.checkinClient(client.id!);
    Get.back();
    
    // ✅ Naviguer vers la page de détail client après le démarrage
    Get.toNamed('/client-details', arguments: {'client': client});
  } catch (e) {
    Get.back();
    Get.snackbar('Erreur', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
  }
}

// Créer commande
void _handleCreateOrder(ClientTournee client) {
  Get.back();
  Get.toNamed('/order-create', arguments: {'client': client});
}

// Checkout sans vente
void _handleCheckoutNoSale(ClientTournee client) {
  Get.back();
  // Dialog pour motif
  Get.dialog(AlertDialog(
    title: Text('Visite sans commande'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: Text('Client absent'), onTap: () => _executeCheckoutNoSale(client, 'CLIENT_ABSENT')),
        ListTile(title: Text('Pas de besoin'), onTap: () => _executeCheckoutNoSale(client, 'PAS_DE_BESOIN')),
        ListTile(title: Text('Fermé'), onTap: () => _executeCheckoutNoSale(client, 'FERME')),
      ],
    ),
  ));
}

void _executeCheckoutNoSale(ClientTournee client, String motif) async {
  Get.back();
  try {
    Get.dialog(AlertDialog(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Enregistrement...')])), barrierDismissible: false);
    await controller.checkoutWithoutOrder(client.id!, motif, null);
    Get.back();
    Get.snackbar('Visite terminée', 'Check-out effectué', backgroundColor: Colors.blue, colorText: Colors.white);
  } catch (e) {
    Get.back();
    Get.snackbar('Erreur', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
  }
}

}