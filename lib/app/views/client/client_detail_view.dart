import 'package:erp_mobile/app/controllers/tournee_controller.dart';
import 'package:erp_mobile/app/controllers/auth_controller.dart';

import 'package:erp_mobile/app/models/client_tournee.dart';
import 'package:erp_mobile/app/models/statut_visite.dart';
import 'package:erp_mobile/app/models/visite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<Map<String, String>> MOTIFS_VISITE = [
  {'code': 'VISITE', 'libelle': 'Visite / Présentation'},
  {'code': 'RELANCE', 'libelle': 'Relance'},
  {'code': 'ABSENT', 'libelle': 'Absent / Fermé'},
  {'code': 'PAS_DE_BESOIN', 'libelle': 'Pas de besoin'},
  {'code': 'AUTRE', 'libelle': 'Autre'},
];

class ClientDetailView extends GetView<TourneeController> {
  @override
  Widget build(BuildContext context) {
    // ✅ CHANGEMENT MAJEUR : Récupérer SEULEMENT l'ID depuis les arguments
    final int clientTourneeId = Get.arguments['clientTourneeId'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails Client'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        // ✅ SINGLE SOURCE OF TRUTH : Toujours récupérer depuis le controller
        final client = controller.tourneeToday.value?.clients
            .firstWhereOrNull((c) => c.id == clientTourneeId);

        // 🔍 DEBUG : Logs détaillés
        print('🔍 DEBUG CLIENT DETAIL VIEW:');
        print('  clientTourneeId cherché: $clientTourneeId');
        print('  tourneeToday existe: ${controller.tourneeToday.value != null}');
        if (controller.tourneeToday.value != null) {
          print('  Nombre de clients dans tournée: ${controller.tourneeToday.value!.clients.length}');
          for (var c in controller.tourneeToday.value!.clients) {
            print('    - Client ID=${c.id}, visites=${c.visites.length}');
          }
        }
        print('  Client trouvé: ${client != null}');
        if (client != null) {
          print('  Client name: ${client.customerName}');
          print('  Nombre de visites: ${client.visites.length}');
          print('  Statut visite: ${client.statutVisite}');
        }

        // ✅ Si client pas encore chargé → afficher loader
        if (client == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des informations client...'),
              ],
            ),
          );
        }

        // ✅ Client trouvé → afficher l'interface
        return Column(
          children: [
            // Contenu principal avec scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildClientHeader(client),
                    _buildCurrentVisitSection(client),
                    _buildVisitHistorySection(client),
                  ],
                ),
              ),
            ),
            
            // Actions en bas (sticky)
            _buildActionButtons(context, client),
          ],
        );
      }),
    );
  }

  // ========================================
  // HEADER CLIENT
  // ========================================

  Widget _buildClientHeader(ClientTournee client) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.customerName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            client.customerAddress,
                            style: TextStyle(color: Colors.grey.shade700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (client.customerRc.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.business, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'RC: ${client.customerRc}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Statistiques du client
          if (client.hasVisits) ...[
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.history,
                  '${client.visitCount}',
                  'Visite${client.visitCount > 1 ? 's' : ''}',
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.shopping_cart,
                  '${client.orderCount}',
                  'Commande${client.orderCount > 1 ? 's' : ''}',
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.access_time,
                  '${client.totalVisitDuration}',
                  'min totales',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ========================================
  // VISITE COURANTE
  // ========================================

  Widget _buildCurrentVisitSection(ClientTournee client) {
    final currentVisite = client.currentVisite;

    if (currentVisite == null) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          color: Colors.grey.shade50,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.assignment, size: 48, color: Colors.grey.shade400),
                SizedBox(height: 12),
                Text(
                  'Aucune visite en cours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Démarrez une nouvelle visite',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 12, color: currentVisite.statutVisite.color),
                  SizedBox(width: 8),
                  Text(
                    'Visite en cours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      currentVisite.statutVisite.label,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: currentVisite.statutVisite.color,
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              if (currentVisite.checkinAt != null) ...[
                _buildInfoRow(
                  Icons.login,
                  'Check-in',
                  _formatDateTime(currentVisite.checkinAt!),
                  Colors.green,
                ),
                SizedBox(height: 8),
              ],
              
              if (currentVisite.checkoutAt != null) ...[
                _buildInfoRow(
                  Icons.logout,
                  'Check-out',
                  _formatDateTime(currentVisite.checkoutAt!),
                  Colors.red,
                ),
                SizedBox(height: 8),
              ],
              
              if (currentVisite.formattedDuration.isNotEmpty) ...[
                _buildInfoRow(
                  Icons.timer,
                  'Durée',
                  currentVisite.formattedDuration,
                  Colors.blue,
                ),
                SizedBox(height: 8),
              ],
              
              if (currentVisite.motifVisite != null && currentVisite.motifVisite!.isNotEmpty) ...[
                _buildInfoRow(
                  Icons.info_outline,
                  'Motif',
                  currentVisite.motifVisite!,
                  Colors.orange,
                ),
                SizedBox(height: 8),
              ],
              
              if (currentVisite.noteVisite != null && currentVisite.noteVisite!.isNotEmpty) ...[
                Divider(),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentVisite.noteVisite!,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  // ========================================
  // HISTORIQUE DES VISITES
  // ========================================

  Widget _buildVisitHistorySection(ClientTournee client) {
    final visites = client.visites;

    if (visites.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historique des visites',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          ...visites.map((visite) => _buildVisiteCard(visite)).toList(),
        ],
      ),
    );
  }

  Widget _buildVisiteCard(Visite visite) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  visite.statutVisite.icon,
                  color: visite.statutVisite.color,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  visite.statutVisite.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: visite.statutVisite.color,
                  ),
                ),
                Spacer(),
                if (visite.formattedDuration.isNotEmpty)
                  Chip(
                    label: Text(
                      visite.formattedDuration,
                      style: TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (visite.checkinAt != null)
              Text(
                'Check-in: ${_formatDateTime(visite.checkinAt!)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            if (visite.checkoutAt != null)
              Text(
                'Check-out: ${_formatDateTime(visite.checkoutAt!)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            if (visite.motifVisite != null && visite.motifVisite!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                'Motif: ${visite.motifVisite}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========================================
  // BOUTONS D'ACTION
  // ========================================

  Widget _buildActionButtons(BuildContext context, ClientTournee client) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildActionButtonsContent(context, client),
      ),
    );
  }

  Widget _buildActionButtonsContent(BuildContext context, ClientTournee client) {
    // CAS 1: Aucune visite ou visite terminée → Bouton "Démarrer visite"
    if (!client.hasVisitInProgress) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => _handleStartVisit(client),
          icon: Icon(Icons.play_arrow),
          label: Text('Démarrer une visite'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // CAS 2: Visite en cours → Boutons selon permissions utilisateur
    final authController = Get.find<AuthController>();
    final user = authController.user.value;

    final canCreateOrder = user?.hasPermission('CREER_COMMANDE_MOBILE') ?? false;
    final canCreateBL = user?.hasPermission('CREER_BL_MOBILE') ?? false;

    List<Widget> buttons = [];

    if (canCreateOrder) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _handleCreateOrder(client, initialSaleType: 'ORDER'),
            icon: Icon(Icons.shopping_cart),
            label: Text('Créer une commande'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    if (canCreateBL) {
      if (buttons.isNotEmpty) {
        buttons.add(SizedBox(height: 8));
      }
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _handleCreateOrder(client, initialSaleType: 'BL'),
            icon: Icon(Icons.document_scanner),
            label: Text('Créer un BL'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    // Si aucune permission de création, masquer les boutons de création et laisser seulement "Terminer sans vente"
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (buttons.isNotEmpty) ...[
          ...buttons,
          SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _handleEndWithoutSale(client),
            icon: Icon(Icons.cancel),
            label: Text('Terminer sans vente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // ACTIONS
  // ========================================

  void _handleStartVisit(ClientTournee client) async {
    try {
      Get.dialog(
        AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Démarrage de la visite...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      await controller.checkinClient(client.id!);

      Get.back(); // Fermer le dialog

      Get.snackbar(
        'Visite démarrée',
        'La visite de ${client.customerName} a été démarrée',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Erreur',
        'Impossible de démarrer la visite: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleCreateOrder(ClientTournee client, {String initialSaleType = 'ORDER'}) async {
    // Naviguer vers la création de commande avec le scénario choisi (ORDER ou BL)
    await Get.toNamed('/order-create', arguments: {
      'client': client,
      'saleType': initialSaleType,
    });
    
    // Après retour, rafraîchir
    await controller.refresh();
  }

  void _handleEndWithoutSale(ClientTournee client) {
    String? selectedMotif;
    String? note;

    Get.dialog(
      AlertDialog(
        title: Text('Terminer sans vente'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Motif *', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...MOTIFS_VISITE.map((motif) {
                    return RadioListTile<String>(
                      title: Text(motif['libelle']!),
                      value: motif['code']!,
                      groupValue: selectedMotif,
                      onChanged: (value) {
                        setState(() => selectedMotif = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  SizedBox(height: 16),
                  Text('Note (optionnel)', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ajouter une note...',
                    ),
                    maxLines: 3,
                    onChanged: (value) => note = value,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedMotif == null) {
                Get.snackbar(
                  'Erreur',
                  'Veuillez sélectionner un motif',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back();
              _executeEndWithoutSale(client, selectedMotif!, note);
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _executeEndWithoutSale(ClientTournee client, String motif, String? note) async {
    try {
      Get.dialog(
        AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Clôture en cours...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Récupérer la visite courante ID
      final visiteId = client.currentVisite?.id;
      if (visiteId == null) {
        throw Exception('Aucune visite en cours');
      }

      await controller.checkoutWithoutOrder(visiteId, motif, note);

      Get.back(); // Fermer le dialog
      Get.back(); // Retour à la liste des clients

      Get.snackbar(
        'Visite terminée',
        'La visite a été clôturée sans vente',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Erreur',
        'Impossible de terminer la visite: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========================================
  // HELPERS
  // ========================================

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = "Aujourd'hui";
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr à $timeStr';
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
}