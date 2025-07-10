import 'package:erp_mobile/app/controllers/tournee_controller.dart';
import 'package:erp_mobile/app/models/tournee.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TourneeView extends GetView<TourneeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tournées'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Bouton refresh
          IconButton(
            onPressed: () => controller.refresh(),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        // État loading
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement de votre tournée...'),
              ],
            ),
          );
        }
        
        // État erreur
        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erreur',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.refresh(),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Contenu principal
        return _buildTourneeContent();
      }),
    );
  }
  
  Widget _buildTourneeContent() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info vendeur
          _buildVendeurCard(),
          
          SizedBox(height: 16),
          
          // Tournée du jour
          _buildTourneeCard(),
        ],
      ),
    );
  }
  
  Widget _buildVendeurCard() {
    final vendeur = controller.vendeur.value;
    if (vendeur == null) return SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar vendeur
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                vendeur.initiales,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            
            // Info vendeur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendeur.nomComplet,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Code: ${vendeur.code}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTourneeCard() {
    final tournee = controller.tourneeToday.value;
    
    // Pas de tournée aujourd'hui
    if (tournee == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                'Pas de tournée aujourd\'hui',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Aucune tournée planifiée pour aujourd\'hui',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Tournée disponible
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tournée
            Row(
              children: [
                Icon(Icons.route, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Tournée du jour',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                _buildStatutChip(tournee.statut),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Infos tournée
            _buildTourneeInfo(tournee),
            
            SizedBox(height: 20),
            
            // Bouton action
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => controller.goToClients(),
                icon: Icon(Icons.people),
                label: Text('Voir mes clients'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatutChip(String statut) {
    Color couleur;
    IconData icone;
    
    switch (statut) {
      case 'PLANIFIEE':
        couleur = Colors.orange;
        icone = Icons.schedule;
        break;
      case 'EN_COURS':
        couleur = Colors.green;
        icone = Icons.play_arrow;
        break;
      case 'TERMINEE':
        couleur = Colors.grey;
        icone = Icons.check_circle;
        break;
      default:
        couleur = Colors.blue;
        icone = Icons.info;
    }
    
    return Chip(
      avatar: Icon(icone, size: 16, color: Colors.white),
      label: Text(
        statut,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: couleur,
    );
  }
  
Widget _buildTourneeInfo(Tournee tournee) {
  return Column(
    children: [
      _buildInfoRow(Icons.date_range, 'Date', _formatDate(tournee.date)),
      SizedBox(height: 8),
      _buildInfoRow(Icons.tag, 'ID Tournée', '#${tournee.id}'),
      SizedBox(height: 8),
      // ✅ Nouvelles statistiques clients
      _buildInfoRow(Icons.people, 'Clients', '${tournee.nombreClients} clients'),
      SizedBox(height: 8),
      _buildProgressRow(tournee),
    ],
  );
}

// ✅ Nouvelle méthode pour afficher la progression
Widget _buildProgressRow(Tournee tournee) {
  final progression = tournee.progressionPourcentage;
  
  return Row(
    children: [
      Icon(Icons.task_alt, size: 20, color: Colors.grey.shade600),
      SizedBox(width: 8),
      Text(
        'Progression: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tournee.clientsVisites}/${tournee.nombreClients} visités'),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: progression / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progression == 100 ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 8),
      Text(
        '${progression.toStringAsFixed(0)}%',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Aujourd\'hui';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}