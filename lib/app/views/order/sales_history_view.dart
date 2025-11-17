import 'dart:html' as html;

import 'package:erp_mobile/app/controllers/order_controller.dart';
import 'package:erp_mobile/app/models/sales_document_history.dart';
import 'package:erp_mobile/app/services/sales_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesHistoryView extends StatefulWidget {
  const SalesHistoryView({super.key});

  @override
  State<SalesHistoryView> createState() => _SalesHistoryViewState();
}

class _SalesHistoryViewState extends State<SalesHistoryView> {
  final OrderController _controller = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    _controller.loadSalesHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des ventes'),
      ),
      body: Obx(() {
        if (_controller.isLoadingHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<SalesDocumentHistory> history = _controller.salesHistory;

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.inbox, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucune vente trouvée'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final doc = history[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: doc.statusColor,
                  child: Icon(doc.typeIcon, color: Colors.white),
                ),
                title: Text(
                  '${doc.typeLabel} ${doc.documentNumber ?? ''}'.trim(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(doc.customerName),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(doc.documentDate),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: doc.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        doc.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: doc.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${doc.totalAmount.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (doc.canEdit)
                          const Icon(Icons.edit, size: 16, color: Colors.blue),
                        if (doc.canDownloadPdf) ...[
                          if (doc.canEdit) const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _downloadPdf(doc),
                            child: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                onTap: () => _onDocumentTap(doc),
              ),
            );
          },
        );
      }),
    );
  }

  void _onDocumentTap(SalesDocumentHistory doc) {
    if (doc.documentType == 'ORDER') {
      // Utiliser la route existante de détails commande
      Get.toNamed('/order-details/${doc.id}');
    } else {
      // Pour BL, pas encore de vue dédiée
      Get.snackbar(
        'Détail BL',
        'Affichage détaillé du BL à implémenter',
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadPdf(SalesDocumentHistory doc) async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Génération du PDF...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final salesService = Get.find<SalesService>();
      final bytes = await salesService.downloadDocumentPdf(
        type: doc.documentType,
        id: doc.id,
      );

      // Flutter Web: déclencher un téléchargement réel dans le navigateur
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'document_${doc.documentType.toLowerCase()}_${doc.id}.pdf')
        ..click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      Get.back();

      Get.snackbar(
        'PDF généré',
        'Le PDF du document ${doc.documentType} #${doc.documentNumber ?? doc.id} a été téléchargé',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();

      Get.snackbar(
        'Erreur',
        'Impossible de générer le PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
