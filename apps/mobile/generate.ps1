# Script pour générer les fichiers de code
# Exécutez ce script pour générer les fichiers .g.dart nécessaires

Write-Host "Génération des fichiers de code..." -ForegroundColor Green

# Nettoyage des anciens fichiers générés
flutter packages pub run build_runner clean

# Génération des nouveaux fichiers
flutter packages pub run build_runner build --delete-conflicting-outputs

Write-Host "Génération terminée !" -ForegroundColor Green
Write-Host "Vous pouvez maintenant exécuter 'flutter run'" -ForegroundColor Cyan
