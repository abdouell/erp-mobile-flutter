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
                  Icon(Icons.shopping_cart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Créer commande'),
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
        
        // Clic sur la carte
        onTap: () => _showClientDetail(clientTournee),
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
        Get.snackbar('Info', 'Marquer client ${client.customerName} comme visité - À implémenter');
        break;
      case 'order':
        Get.snackbar('Info', 'Créer commande pour ${client.customerName} - À implémenter');
        break;
      case 'call':
        Get.snackbar('Info', 'Appeler ${client.customerName} - À implémenter');
        break;
    }
  }
  
  void _showClientDetail(ClientTournee client) {
    Get.snackbar('Info', 'Détail ${client.customerName} - À implémenter');
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'aujourd\'hui';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}