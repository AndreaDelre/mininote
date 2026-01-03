# MiniNote

Une application macOS native élégante qui affiche une note markdown en pointant la souris dans le coin inférieur droit de l'écran.

## Fonctionnalités

- **Hot Corner** : Pointez votre souris dans le coin inférieur droit pour afficher/cacher la note
- **Markdown Live** : Écrivez en markdown avec rendu en temps réel (comme Obsidian)
- **Tâches Interactives** : Cases à cocher cliquables qui modifient automatiquement le markdown
- **Persistance** : Vos notes sont automatiquement sauvegardées
- **Native macOS** : Écrit en Swift avec SwiftUI, suivant les best practices Apple

## Support Markdown

L'éditeur supporte :
- Titres (`#`, `##`, `###`)
- Listes à puces (`-`, `*`, `+`)
- Tâches avec cases à cocher (`- [ ]`, `- [x]`)
- Texte en gras (`**texte**`)
- Texte en italique (`*texte*`)
- Code inline (`` `code` ``)
- Liens (détection automatique)

## Tâches

Les tâches sont particulièrement bien intégrées :
- Tapez `- [ ] ` pour créer une nouvelle tâche
- Cliquez sur la case pour cocher/décocher
- Le markdown est automatiquement mis à jour
- Les tâches cochées apparaissent barrées

## Installation

### Prérequis

- macOS 13.0 (Ventura) ou supérieur
- Swift 5.9 ou supérieur
- Xcode 15 ou supérieur

### Build depuis les sources

```bash
cd /path/to/mininote
swift build -c release
```

L'exécutable sera créé dans `.build/release/MiniNote`

### Permissions

Au premier lancement, l'application demandera l'accès aux fonctionnalités d'accessibilité pour détecter la position de la souris. Vous devrez :

1. Aller dans **Réglages Système** > **Confidentialité et sécurité** > **Accessibilité**
2. Activer MiniNote dans la liste des applications autorisées

## Utilisation

1. Lancez l'application (elle apparaîtra dans la barre de menu)
2. Déplacez votre souris dans le coin inférieur droit de l'écran
3. La fenêtre de note apparaîtra
4. Écrivez en markdown
5. Pour fermer, repassez la souris dans le coin inférieur droit

## Architecture

L'application suit les best practices Swift et SwiftUI :

### Structure du projet

```
Sources/
├── MiniNoteApp.swift          # Point d'entrée de l'application
├── Models/
│   ├── Note.swift             # Modèle de données
│   └── NoteStore.swift        # État et persistance
├── Managers/
│   └── HotCornerManager.swift # Détection du hot corner
└── Views/
    ├── NoteEditorView.swift   # Vue principale
    └── MarkdownEditorView.swift # Éditeur markdown personnalisé
```

### Patterns utilisés

- **MVVM** : Séparation claire entre modèles, vues et logique
- **Reactive Programming** : Utilisation de Combine pour la réactivité
- **SwiftUI + AppKit** : Intégration des composants natifs
- **Dependency Injection** : Via les EnvironmentObject
- **Single Responsibility** : Chaque classe a une responsabilité unique

### Techniques avancées

- Debouncing pour la sauvegarde automatique
- NSViewRepresentable pour l'intégration AppKit
- NSTextView personnalisé avec rendu markdown en temps réel
- Détection de gestes pour les interactions avec les checkboxes
- Gestion des permissions système

## Personnalisation

### Modifier la distance du hot corner

Dans [HotCornerManager.swift:10](Sources/Managers/HotCornerManager.swift#L10), changez `cornerThreshold` :

```swift
private let cornerThreshold: CGFloat = 10 // pixels
```

### Modifier la fréquence de vérification de la souris

Dans [HotCornerManager.swift:32](Sources/Managers/HotCornerManager.swift#L32), changez l'intervalle :

```swift
checkTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
```

### Changer les styles markdown

Dans [MarkdownEditorView.swift](Sources/Views/MarkdownEditorView.swift), modifiez les attributs dans la méthode `updateRendering()`.

## Roadmap

Fonctionnalités potentielles à ajouter :
- Support de plus de syntaxe markdown (tableaux, citations, etc.)
- Thèmes (clair/sombre)
- Synchronisation iCloud
- Raccourcis clavier personnalisables
- Export en PDF/HTML
- Notes multiples avec navigation

## Licence

Projet personnel. Libre d'utilisation et de modification.
