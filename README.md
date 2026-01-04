# MiniNote

Une application macOS native élégante qui affiche une note markdown en pointant la souris dans le coin inférieur droit de l'écran.

## Fonctionnalités

- **Éditeur par Blocs** : Architecture moderne par blocs (texte, tâches, code)
- **Hot Corner** : Pointez votre souris dans le coin inférieur droit pour afficher/cacher la note
- **Menu Bar Icon** : Icône dans la barre de menu pour accès rapide
- **Markdown Live** : Parsing AST avec swift-markdown pour un rendu robuste
- **Tâches Interactives** : Checkboxes natives SwiftUI intégrées
- **Code Blocks** : Multi-ligne avec syntax highlighting (Swift, Python, JS, etc.)
- **Navigation Fluide** : Déplacement entre blocs avec les flèches haut/bas
- **Persistance** : Auto-sauvegarde automatique de vos notes
- **Native macOS** : Écrit en Swift avec SwiftUI, suivant les best practices Apple

## Support Markdown

L'éditeur supporte (via swift-markdown) :
- Titres (`#`, `##`, `###`) avec tailles et couleurs adaptées
- Listes à puces (`-`, `*`, `+`)
- Tâches avec cases à cocher (`- [ ]`, `- [x]`)
- Blocs de code (` ```language ... ``` `) avec syntax highlighting
- Texte en gras (`**texte**`)
- Texte en italique (`*texte*`)
- Code inline (`` `code` ``) avec background et couleur
- Citations (`> texte`)
- Liens (`[text](url)`) cliquables et soulignés

## Types de Blocs

### Tâches
- Tapez `- [ ] ` pour créer une nouvelle tâche
- Checkbox native SwiftUI apparaît automatiquement
- Cliquez sur la case pour cocher/décocher
- Le texte des tâches cochées apparaît barré et grisé
- Backspace au début convertit en bloc texte normal

### Code Blocks
- Commencez avec ` ``` ` (avec langage optionnel: ` ```swift `)
- Écrivez du code sur plusieurs lignes (Enter ne crée pas de nouveau bloc)
- Terminez avec ` ``` ` pour fermer le bloc
- Syntax highlighting automatique (Swift, Python, JavaScript, etc.)
- Une fois fermé, Enter crée un nouveau bloc

### Blocs Texte
- Texte normal avec markdown styling en temps réel
- Enter crée un nouveau bloc
- Backspace au début fusionne avec le bloc précédent
- Arrow Up/Down navigue entre blocs

## Installation

### Prérequis

- macOS 13.0 (Ventura) ou supérieur
- Swift 5.9 ou supérieur
- Xcode 15 ou supérieur

### Build depuis les sources

```bash
cd /path/to/mininote
make build
pkill MiniNote || true; sleep 2; .build/debug/MiniNote &
```

L'exécutable sera créé dans `.build/debug/MiniNote`

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
│   ├── NoteStore.swift        # État et persistance
│   └── SimpleBlock.swift      # Modèle de bloc (text, task, code)
├── Managers/
│   ├── HotCornerManager.swift # Détection du hot corner
│   └── MenuBarManager.swift   # Icône barre de menu
├── Utilities/
│   ├── MarkdownParser.swift   # Parser AST markdown
│   └── CodeSyntaxHighlighter.swift # Highlighting via Splash
└── Views/
    ├── NoteEditorView.swift   # Vue principale
    └── SimpleBlockEditor.swift # Éditeur par blocs
```

### Patterns utilisés

- **MVVM** : Séparation claire entre modèles, vues et logique
- **Reactive Programming** : Utilisation de Combine pour la réactivité
- **SwiftUI + AppKit** : Intégration des composants natifs
- **Dependency Injection** : Via les EnvironmentObject
- **Single Responsibility** : Chaque classe a une responsabilité unique

### Techniques avancées

- Architecture par blocs avec UUID pour identification
- AST Walker pattern pour le parsing markdown (swift-markdown)
- NSViewRepresentable pour l'intégration AppKit/SwiftUI
- NSTextView personnalisé par bloc avec rendu markdown temps réel
- Gestion des opérations split/merge avec préservation du curseur
- Navigation inter-blocs avec arrow keys
- Détection intelligente de closure pour code blocks
- Debouncing pour la sauvegarde automatique
- Crash protection avec try-catch sur parsing
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

Dans [MarkdownParser.swift](Sources/Utilities/MarkdownParser.swift), modifiez le `Theme` :

```swift
struct Theme {
    let baseFont: NSFont
    let h1Font: NSFont
    let textColor: NSColor
    let accentColor: NSColor
    // ...
}
```

## Roadmap

Fonctionnalités potentielles à ajouter :
- Support de tableaux markdown
- Thèmes personnalisables (clair/sombre)
- Synchronisation iCloud
- Raccourcis clavier personnalisables
- Export en PDF/HTML
- Notes multiples avec navigation
- Images inline
- Nouveaux types de blocs (quotes, dividers, etc.)

## Licence

Projet personnel. Libre d'utilisation et de modification.
