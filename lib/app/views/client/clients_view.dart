import 'package:erp_mobile/app/models/client_tournee.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/tournee.dart';
import '../../models/vendeur.dart';

class ClientsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Récupérer les données passées depuis TourneeView
    final Map<String, dynamic> args = Get.arguments ?? {};
    final Tournee? tournee = args['tournee'];
    final Vendeur? vendeur = args['vendeur'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Clients'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Stats dans l'AppBar
          if (tournee != null)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${tournee.clientsVisites}/${tournee.nombreClients}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(tournee, vendeur),
    );
  }
  
  Widget _buildBody(Tournee? tournee, Vendeur? vendeur) {
    // Vérification des données
    if (tournee == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erreur: Aucune tournée sélectionnée'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('Retour'),
            ),
          ],
        ),
      );
    }
    
    // Pas de clients dans la tournée
    if (tournee.clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Aucun client dans cette tournée',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'La tournée ne contient pas de clients',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    // Liste des clients
    return Column(
      children: [
        // Header info tournée
        _buildTourneeHeader(tournee),
        
        // Liste clients
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tournee.clients.length,
            itemBuilder: (context, index) {
              final clientTournee = tournee.clients[index];
              return _buildClientCard(clientTournee, index + 1);
            },
          ),
        ),
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
          Text(
            'Tournée du ${_formatDate(tournee.date)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
        // Avatar avec numéro d'ordre
        leading: CircleAvatar(
          backgroundColor: clientTournee.visite ? Colors.green : Colors.blue,
          child: Text(
            '${clientTournee.ordre ?? position}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        
        // ✅ Info client enrichie
        title: Text(
          clientTournee.customerName,  // ← Vrai nom au lieu de "Client #152"
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Adresse client
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    clientTournee.customerAddress,
                    style: TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // ✅ RC si disponible
            if (clientTournee.customerRc.isNotEmpty) ...[
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.business, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'RC: ${clientTournee.customerRc}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
            
            // Commentaire si présent
            if (clientTournee.commentaire != null && clientTournee.commentaire!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                clientTournee.commentaire!,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
            
            // Statut
            SizedBox(height: 6),
            _buildStatutChip(clientTournee.visite),
          ],
        ),
        
        // Actions
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleClientAction(value, clientTournee),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'visit',
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Marquer visité'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'order',
              child: Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Créer commande'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('Historique commandes'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'call',
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Appeler'),
                ],
              ),
            ),
          ],
        ),
        
        // Clic sur la carte → Créer commande directement
        onTap: () => _createOrderForClient(clientTournee),
      ),
    );
  }
  
  Widget _buildStatutChip(bool visite) {
    return Chip(
      label: Text(
        visite ? 'Visité' : 'À visiter',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: visite ? Colors.green : Colors.orange,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
  
  void _handleClientAction(String action, ClientTournee client) {
    switch (action) {
      case 'visit':
        _markClientAsVisited(client);
        break;
      case 'order':
        _createOrderForClient(client);
        break;
      case 'history':
        _showOrderHistory(client);
        break;
      case 'call':
        _callClient(client);
        break;
    }
  }
  
  /// ✅ MARQUER CLIENT COMME VISITÉ
  void _markClientAsVisited(ClientTournee client) {
    // TODO: Implémenter avec le backend
    Get.snackbar(
      'Client visité',
      '${client.customerName} marqué comme visité',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      duration: Duration(seconds: 2),
    );
  }
  
  /// 🛒 CRÉER COMMANDE POUR CLIENT
  void _createOrderForClient(ClientTournee client) {
    print('🛒 Création commande pour client: ${client.customerName}');
    
    // ✅ Vérification avant navigation
    if (client.customerId <= 0) {
      Get.snackbar(
        'Erreur',
        'Client invalide: ID manquant',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // ✅ Debug des données passées
    print('📤 Navigation avec client: ID=${client.customerId}, Nom=${client.customerName}');
    
    Get.toNamed('/order-create', arguments: {
      'client': client,
    });
  }
  
  /// 📋 AFFICHER HISTORIQUE COMMANDES
  void _showOrderHistory(ClientTournee client) {
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
                  Icon(Icons.history, color: Theme.of(Get.context!).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Historique commandes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Contenu
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Historique des commandes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pour ${client.customerName}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fonctionnalité à implémenter',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Fermer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 📞 APPELER CLIENT
  void _callClient(ClientTournee client) {
    // TODO: Implémenter avec url_launcher pour appeler
    Get.snackbar(
      'Appel client',
      'Appel de ${client.customerName} - À implémenter',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: Icon(Icons.phone, color: Colors.white),
    );
  }
  
  void _showClientDetail(ClientTournee client) {
    // Navigation vers détail client ou création commande
    _createOrderForClient(client);
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'aujourd\'hui';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}