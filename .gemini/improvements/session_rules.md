# Règles de session apprises - 03/01/2026

## Gestion du Cycle de Vie de l'Application

1. **Procédure de Relance Robuste** :
   - TOUJOURS tuer les instances existantes avant de relancer : `pkill MiniNote || true`.
   - TOUJOURS insérer un `sleep 2` après le pkill pour laisser au système le temps de libérer les ports, les descripteurs de fichiers et la mémoire.
   - TOUJOURS compiler (`swift build`) avant de lancer pour s'assurer que les dernières modifications sont incluses.
   - TOUJOURS lancer l'application en utilisant le chemin direct vers le binaire : `.build/debug/MiniNote &`.
   - Éviter d'utiliser `make run` pour les tests itératifs si celui-ci ne gère pas proprement le cycle de vie background/foreground.

2. **Vérification Post-Lancement** :
   - Après un lancement, vérifier systématiquement que le processus tourne réellement avec `ps aux | grep MiniNote`.
   - Ne pas assumer qu'une absence de message d'erreur signifie que l'application tourne.

## UI & Intégration Système (macOS)

3. **Icônes et Visibilité** :
   - Préférer les **SF Symbols** (`NSImage(systemSymbolName:...)`) aux dessins manuels (`NSBezierPath`) pour les éléments d'interface système comme la barre des menus.
   - Les SF Symbols garantissent une visibilité parfaite et une adaptation automatique aux modes clair et sombre de macOS.

## Méthodologie de Travail

4. **Validation des Étapes** :
   - Ne pas marquer une tâche comme terminée dans `_TODO.md` avant d'avoir prouvé que l'application tourne et que la feature a été testée visuellement ou par l'utilisateur.
   - En cas d'échec de lancement ou de bug majeur, savoir faire un `git checkout` pour revenir à un état stable avant de retenter une implémentation.
