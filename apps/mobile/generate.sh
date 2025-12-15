#!/bin/bash

echo "Génération des fichiers de code..."

# Nettoyage des anciens fichiers générés
flutter packages pub run build_runner clean

# Génération des nouveaux fichiers
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "Génération terminée !"
echo "Vous pouvez maintenant exécuter 'flutter run'"
