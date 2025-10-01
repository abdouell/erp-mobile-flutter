import 'package:erp_mobile/app/models/client_tournee.dart';
import 'package:erp_mobile/app/models/order.dart';
import 'package:erp_mobile/app/models/statut_visite.dart';
import 'package:erp_mobile/app/services/customer_service.dart';
import 'package:erp_mobile/app/services/location_service.dart';
import 'package:erp_mobile/app/services/tournee_service.dart'; // ✅ Import ajouté
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/tournee.dart';
import '../../models/vendeur.dart';


const List<Map<String, String>> MOTIFS_VISITE = [
  {'code': 'VISITE', 'libelle': 'Visite / Présentation'},
  {'code': 'RELANCE', 'libelle': 'Relance'},
  {'code': 'ABSENT', 'libelle': 'Absent / Fermé'},
  {'code': 'PAS_DE_BESOIN', 'libelle': 'Pas de besoin'},
  {'code': 'AUTRE', 'libelle': 'Autre'},
];

class ClientsView extends StatefulWidget { // ✅ Changé en StatefulWidget pour gérer l'état local
  @override
  _ClientsViewState createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  late Tournee? tournee;
  late Vendeur? vendeur;

  @override
  void initState() {
    super.initState();
    // Récupérer les données passées depuis TourneeView
    final Map<String, dynamic> args = Get.arguments ?? {};
    tournee = args['tournee'];
    vendeur = args['vendeur'];
  }

  @override
  Widget build(BuildContext context) {
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
                  '${tournee!.clientsVisites}/${tournee!.nombreClients}',
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
      // Avatar avec statut visuel selon StatutVisite
      leading: CircleAvatar(
        backgroundColor: clientTournee.statutVisite.color,
        child: Icon(
          clientTournee.statutVisite.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      
      // Info client enrichie
      title: Text(
        clientTournee.customerName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adresse client
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
          
          // RC si disponible
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
          
          // ✅ NOUVEAU : Affichage durée si en cours ou terminé
          if (clientTournee.isInProgress && clientTournee.checkinAt != null) ...[
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.orange),
                SizedBox(width: 4),
                Text(
                  'En cours depuis ${_formatDuration(DateTime.now().difference(clientTournee.checkinAt!))}',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ],
            ),
          ],
          
          // ✅ NOUVEAU : Affichage durée totale si terminé
          if (clientTournee.isCompleted && clientTournee.formattedDuration.isNotEmpty) ...[
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Durée: ${clientTournee.formattedDuration}',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
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
          _buildStatutChip(clientTournee.statutVisite),
        ],
      ),
      
      // Actions selon le statut
      trailing: _buildClientActions(clientTournee),
      
      // Clic sur la carte
      onTap: () {
        // Permettre la création de commande seulement si pas encore visité ou en cours
        if (clientTournee.statutVisite == StatutVisite.NON_VISITE || 
            clientTournee.statutVisite == StatutVisite.VISITE_EN_COURS) {
          _createOrderForClient(clientTournee);
        } else {
          Get.snackbar(
            'Visite terminée',
            'Ce client a déjà été visité',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }
      },
    ),
  );
}

Widget _buildStatutChip(StatutVisite statut) {
  return Chip(
    label: Text(
      statut.label,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: statut.color,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

// ✅ HELPER : Formatage durée
String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  
  if (hours > 0) {
    return '${hours}h ${minutes}min';
  } else {
    return '${minutes}min';
  }
}
    
Widget _buildClientActions(ClientTournee clientTournee) {
  // Version simplifiée selon le nouveau workflow
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
      );
  }
}

void _handleClientAction(String action, ClientTournee client) {
  switch (action) {
    case 'visit':
      _markClientAsVisited(client);
      break;
    case 'cloture_sans_visite': // ✅ NOUVEAU CASE
      _showClotureVisiteDialog(client);
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
  
  /// ✅ MARQUER CLIENT COMME VISITÉ - AVEC géolocalisation
void _markClientAsVisited(ClientTournee client) async {
  // Cette méthode devrait être supprimée car on utilise maintenant
  // le check-in automatique dans _createOrderForClient
  // Mais si vous voulez la garder, voici la version corrigée :
  
  if (client.id == null) {
    Get.snackbar('Erreur', 'ID client manquant');
    return;
  }

  try {
    Get.dialog(
      AlertDialog(content: Row(children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Récupération position...'),
      ])),
      barrierDismissible: false,
    );

    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition();
    
    final tourneeService = Get.find<TourneeService>();
    
    // Utiliser les nouvelles méthodes selon le statut actuel
    if (client.statutVisite == StatutVisite.NON_VISITE) {
      await tourneeService.checkinCustomer(
        client.id!,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
    } else if (client.statutVisite == StatutVisite.VISITE_EN_COURS) {
      // On ne peut pas "dé-checker" un client en cours, il faut clôturer
      Get.back();
      Get.snackbar('Action impossible', 'Utilisez la clôture de visite');
      return;
    }

    // Mettre à jour l'état local
    setState(() {
      final index = tournee!.clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        tournee!.clients[index] = client.copyWith(
          statutVisite: StatutVisite.VISITE_EN_COURS,
          checkinAt: DateTime.now(),
          checkinLat: position?.latitude,
          checkinLon: position?.longitude,
        );
      }
    });

    Get.back();
    
    Get.snackbar(
      'Client visité',
      '${client.customerName} marqué comme visité',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Get.snackbar('Erreur', 'Impossible de mettre à jour: $e');
  }
}

  /// 🛒 CRÉER COMMANDE POUR CLIENT
void _createOrderForClient(ClientTournee client) async {
  print('🛒 Création commande pour client: ${client.customerName}');
  
  if (client.customerId <= 0) {
    Get.snackbar('Erreur', 'Client invalide: ID manquant');
    return;
  }

  // ✅ SOLUTION : Créer une copie mise à jour du client
  ClientTournee updatedClient = client;

  // Check-in automatique si nécessaire
  if (client.statutVisite == StatutVisite.NON_VISITE) {
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

      final locationService = Get.find<LocationService>();
      final position = await locationService.getCurrentPosition();
      
      final tourneeService = Get.find<TourneeService>();
      await tourneeService.checkinCustomer(
        client.id!,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      // ✅ CRÉER LA VERSION MISE À JOUR DU CLIENT
      updatedClient = client.copyWith(
        statutVisite: StatutVisite.VISITE_EN_COURS,
        checkinAt: DateTime.now(),
        checkinLat: position?.latitude,
        checkinLon: position?.longitude,
      );

      // Mettre à jour l'état local
      setState(() {
        final index = tournee!.clients.indexWhere((c) => c.id == client.id);
        if (index != -1) {
          tournee!.clients[index] = updatedClient;
        }
      });

      Get.back(); // Fermer loading

      Get.snackbar(
        'Visite démarrée',
        'Visite de ${client.customerName} en cours',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      
      Get.snackbar(
        'Erreur check-in',
        'Impossible de démarrer la visite: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Ne pas naviguer en cas d'erreur
    }
  }

  // ✅ NAVIGATION AVEC LE CLIENT DANS LE BON ÉTAT
  print('📤 Navigation avec client statut: ${updatedClient.statutVisite}');
  
  Get.toNamed('/order-create', arguments: {
    'client': updatedClient, // Passer le client mis à jour
  });
}

  /// 📋 AFFICHER HISTORIQUE COMMANDES
  void _showOrderHistory(ClientTournee client) {
  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: Get.height * 0.8, // 80% de l'écran
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: Theme.of(context).primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historique commandes',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            client.customerName,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Contenu avec FutureBuilder
              Expanded(
                child: FutureBuilder<List<Order>>(
                  future: Get.find<CustomerService>().getCustomerOrders(client.customerId),
                  builder: (context, snapshot) {
                    // Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Chargement des commandes...'),
                          ],
                        ),
                      );
                    }
                    
                    // Erreur
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                'Erreur de chargement',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    final orders = snapshot.data ?? [];
                    
                    // Aucune commande
                    if (orders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune commande',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ce client n\'a pas encore de commandes',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Liste des commandes
                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getOrderStatusColor(order.status),
                              child: Icon(
                                _getOrderStatusIcon(order.status),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Commande #${order.id}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${order.formattedDate} • ${order.itemCount} articles'),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getOrderStatusColor(order.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _getOrderStatusColor(order.status).withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        order.statusDisplay,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _getOrderStatusColor(order.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  order.formattedTotal,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            onTap: () {
                              Get.back(); // Fermer bottom sheet
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
        );
      },
    ),
    isScrollControlled: true,
  );
}

Color _getOrderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.DRAFT:
      return Colors.orange;
    case OrderStatus.VALIDATED:
      return Colors.green;
    case OrderStatus.CANCELLED:
      return Colors.red;
  }
}

IconData _getOrderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.DRAFT:
      return Icons.edit;
    case OrderStatus.VALIDATED:
      return Icons.check_circle;
    case OrderStatus.CANCELLED:
      return Icons.cancel;
  }
}

/// 🔒 DIALOGUE CLÔTURE VISITE SANS VENTE
void _showClotureVisiteDialog(ClientTournee client) {
  String? selectedMotif;
  final TextEditingController noteController = TextEditingController();
  
  Get.dialog(
    StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.assignment_turned_in, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Expanded(child: Text('Clôturer la visite')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client: ${client.customerName}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                
                Text(
                  'Motif de la visite *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMotif,
                      hint: Text('  Sélectionner un motif'),
                      isExpanded: true,
                      items: MOTIFS_VISITE.map((motif) {
                        return DropdownMenuItem<String>(
                          value: motif['code'],
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(motif['libelle']!),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMotif = value;
                        });
                      },
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                Text(
                  'Note (optionnel)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Ajouter une note...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                noteController.dispose();
                Get.back();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedMotif == null 
                  ? null 
                  : () {
                      final note = noteController.text.trim();
                      noteController.dispose();
                      Get.back();
                      _clotureVisiteSansVente(client, selectedMotif!, note.isEmpty ? null : note);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text('Clôturer'),
            ),
          ],
        );
      },
    ),
  );
}


/// 🔒 CLÔTURER VISITE SANS VENTE
void _clotureVisiteSansVente(ClientTournee client, String motif, String? note) async {
  if (client.id == null) {
    Get.snackbar('Erreur', 'ID client manquant');
    return;
  }

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

    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition();
    
    final tourneeService = Get.find<TourneeService>();
    await tourneeService.checkoutCustomerWithoutOrder(  // ✅ CORRIGÉ
      client.id!, 
      motif, 
      note,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    // Mettre à jour l'état local
    setState(() {
      final index = tournee!.clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        tournee!.clients[index] = client.copyWith(
          statutVisite: StatutVisite.VISITE_TERMINEE,  // ✅ CORRIGÉ
          motifVisite: motif,
          noteVisite: note,
          checkoutAt: DateTime.now(),
          checkoutLat: position?.latitude,
          checkoutLon: position?.longitude,
        );
      }
    });

    Get.back();

    final motifLibelle = MOTIFS_VISITE.firstWhere((m) => m['code'] == motif)['libelle'];
    Get.snackbar(
      'Visite clôturée',
      '${client.customerName}\nMotif: $motifLibelle',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );

  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    
    Get.snackbar(
      'Erreur',
      'Impossible de clôturer la visite: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }
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
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'aujourd\'hui';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}