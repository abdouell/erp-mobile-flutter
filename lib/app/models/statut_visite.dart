import 'package:flutter/material.dart';

enum StatutVisite {
  NON_VISITE,
  VISITE_EN_COURS,
  VISITE_TERMINEE,
  COMMANDE_CREEE;

  String get label {
    switch (this) {
      case StatutVisite.NON_VISITE:
        return 'Non visité';
      case StatutVisite.VISITE_EN_COURS:
        return 'En cours';
      case StatutVisite.VISITE_TERMINEE:
        return 'Terminé';
      case StatutVisite.COMMANDE_CREEE:
        return 'Commande créée';
    }
  }

  String get serverValue {
    return name; // NON_VISITE, VISITE_EN_COURS, etc.
  }

  static StatutVisite fromString(String value) {
    switch (value.toUpperCase()) {
      case 'NON_VISITE':
        return StatutVisite.NON_VISITE;
      case 'VISITE_EN_COURS':
        return StatutVisite.VISITE_EN_COURS;
      case 'VISITE_TERMINEE':
        return StatutVisite.VISITE_TERMINEE;
      case 'COMMANDE_CREEE':
        return StatutVisite.COMMANDE_CREEE;
      default:
        return StatutVisite.NON_VISITE;
    }
  }

  // Méthodes utilitaires
  bool get isVisited => this != StatutVisite.NON_VISITE;
  
  bool get isInProgress => this == StatutVisite.VISITE_EN_COURS;
  
  bool get isCompleted => this == StatutVisite.VISITE_TERMINEE || this == StatutVisite.COMMANDE_CREEE;

  // Validation des transitions
  bool canTransitionTo(StatutVisite newStatus) {
    switch (this) {
      case StatutVisite.NON_VISITE:
        return newStatus == StatutVisite.VISITE_EN_COURS;
      case StatutVisite.VISITE_EN_COURS:
        return newStatus == StatutVisite.VISITE_TERMINEE || newStatus == StatutVisite.COMMANDE_CREEE;
      case StatutVisite.VISITE_TERMINEE:
      case StatutVisite.COMMANDE_CREEE:
        return false; // États finaux
    }
  }

  // Couleurs pour l'UI
  Color get color {
    switch (this) {
      case StatutVisite.NON_VISITE:
        return Colors.grey;
      case StatutVisite.VISITE_EN_COURS:
        return Colors.orange;
      case StatutVisite.VISITE_TERMINEE:
        return Colors.blue;
      case StatutVisite.COMMANDE_CREEE:
        return Colors.green;
    }
  }

  // Icônes pour l'UI
  IconData get icon {
    switch (this) {
      case StatutVisite.NON_VISITE:
        return Icons.radio_button_unchecked;
      case StatutVisite.VISITE_EN_COURS:
        return Icons.access_time;
      case StatutVisite.VISITE_TERMINEE:
        return Icons.check_circle_outline;
      case StatutVisite.COMMANDE_CREEE:
        return Icons.shopping_cart;
    }
  }
}