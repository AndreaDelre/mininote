# Gemini Agent Context for MiniNote

You are an expert macOS and Swift developer acting as the dedicated agent for the 'MiniNote' project.
Your goal is to help develop, debug, and improve this application while strictly adhering to its architecture and style guidelines.

## Project Documentation

### Content of PROJECT_SUMMARY.md
```markdown
# 🗒️ MiniNote - Project Summary

## 📋 Overview

**MiniNote** est une application macOS native élégante qui affiche une note markdown en pointant la souris dans le coin inférieur droit de l'écran.

```
Déplacer la souris → Coin inférieur droit → Note apparaît → Éditer en markdown → Note se cache
```

## ✨ Fonctionnalités principales

| Fonctionnalité | Description | Statut |
|----------------|-------------|--------|
| **Hot Corner** | Affichage/masquage au coin inférieur droit | ✅ Implémenté |
| **Markdown Live** | Rendu en temps réel pendant l'édition | ✅ Implémenté |
| **Tasks Interactives** | Cases à cocher cliquables | ✅ Implémenté |
| **Auto-save** | Sauvegarde automatique avec debouncing | ✅ Implémenté |
| **Persistance** | Stockage dans Application Support | ✅ Implémenté |
| **Native macOS** | Intégration système complète | ✅ Implémenté |

## 📦 Structure du projet

```
mininote/
├── 📁 Sources/
│   ├── 🚀 MiniNoteApp.swift         (Entry point)
│   ├── 📁 Models/
│   │   ├── Note.swift               (Data model)
│   │   └── NoteStore.swift          (State & persistence)
│   ├── 📁 Managers/
│   │   └── HotCornerManager.swift   (Hot corner logic)
│   └── 📁 Views/
│       ├── NoteEditorView.swift     (Main view)
│       └── MarkdownEditorView.swift (Custom editor)
│
├── 📚 Documentation/
│   ├── README.md              (Main documentation)
│   ├── QUICKSTART.md          (Getting started)
│   ├── ARCHITECTURE.md        (Technical design)
│   ├── DEVELOPMENT.md         (Dev workflow)
│   ├── CHANGELOG.md           (Version history)
│   └── PROJECT_STATS.md       (Statistics)
│
├── ⚙️ Configuration/
│   ├── Package.swift          (Swift Package Manager)
│   ├── Info.plist            (App metadata)
│   ├── Makefile              (Build commands)
│   └── .editorconfig         (Code style)
│
└── 🐙 GitHub/
    ├── .github/FUNDING.yml
    ├── ISSUE_TEMPLATE/
    └── pull_request_template.md
```

## 🛠️ Stack technique

### Langages & Frameworks
- **Swift 5.9+** - Langage principal
- **SwiftUI** - Interface utilisateur moderne
- **AppKit** - Intégration système native
- **Combine** - Programmation réactive

### Patterns & Architecture
- **MVVM** - Model-View-ViewModel
- **Reactive Programming** - État réactif avec Combine
- **Dependency Injection** - Via EnvironmentObject
- **Coordinator Pattern** - Pour les delegates

### Outils & Build
- **Swift Package Manager** - Gestion des dépendances
- **Makefile** - Automatisation du build
- **Git** - Contrôle de version
- **Xcode** - IDE (optionnel)

## 📊 Statistiques du code

```
Total Files:     23 fichiers
Swift Code:      ~536 lignes
Documentation:   ~800+ lignes
Configuration:   ~100 lignes
Binary Size:     239 KB (optimisé)
Memory Usage:    2-3 MB (idle)
```

## 🎯 Markdown supporté

| Syntaxe | Exemple | Rendu |
|---------|---------|-------|
| **H1** | `# Titre` | Grand titre en gras |
| **H2** | `## Titre` | Titre moyen en gras |
| **H3** | `### Titre` | Petit titre en gras |
| **Liste** | `- Item` | • Item |
| **Tâche** | `- [ ] Todo` | ☐ Todo |
| **Tâche cochée** | `- [x] Done` | ☑ ~~Done~~ |
| **Gras** | `**texte**` | **texte** |
| **Italique** | `*texte*` | *texte* |
| **Code** | `` `code` `` | `code` |

## 🚀 Quick Start (3 étapes)

### 1. Build
```bash
cd /Users/andreadelre/Work/custom-apps/mininote
make release
```

### 2. Launch
```bash
.build/release/MiniNote
```

### 3. Grant Permissions
**Réglages Système** → **Confidentialité** → **Accessibilité** → Activer **MiniNote**

**C'est tout !** Déplacez votre souris au coin inférieur droit 🎉

## 📝 Exemples d'utilisation

### Exemple 1 : Todo list
```markdown
# Ma Todo List

- [x] Créer l'application MiniNote
- [x] Tester le hot corner
- [ ] Ajouter de nouvelles features
- [ ] Partager avec la communauté
```

### Exemple 2 : Notes de meeting
```markdown
## Meeting 03/01/2026

**Participants**: Alice, Bob, Charlie

### Points discutés
- Architecture de l'app
- Choix du stack technique
- Roadmap Q1 2026

### Actions
- [ ] Alice: Review le code
- [ ] Bob: Tests utilisateurs
- [ ] Charlie: Documentation
```

### Exemple 3 : Snippets de code
```markdown
# Code Snippets

## Swift Array Filter
`array.filter { $0 > 10 }`

## Git Commands
- `git status` - Check status
- `git commit -am "message"` - Commit all
```

## 🏆 Points forts du projet

### ✅ Architecture
- **Clean Code** : Organisation claire et maintenable
- **Best Practices** : Suit les guidelines Apple
- **Modular** : Facile à étendre
- **Testable** : Architecture MVVM testable

### ✅ Documentation
- **Comprehensive** : 6+ fichiers de documentation
- **Clear** : Exemples et guides détaillés
- **Up-to-date** : Synchronisé avec le code
- **Multilevel** : User + Developer docs

### ✅ Performance
- **Lightweight** : 2-3 MB de RAM
- **Fast** : Rendu markdown temps réel
- **Optimized** : Binary de 239 KB
- **Efficient** : Debouncing et lazy loading

### ✅ User Experience
- **Native** : Intégration macOS parfaite
- **Intuitive** : Hot corner naturel
- **Responsive** : Feedback immédiat
- **Persistent** : Auto-save automatique

## 🔮 Roadmap

### Version 1.1 (Q1 2026)
- [ ] Tests unitaires complets
- [ ] Support de plus de syntaxe markdown
- [ ] Thèmes personnalisables
- [ ] Raccourcis clavier

### Version 2.0 (Q2 2026)
- [ ] Notes multiples
- [ ] Synchronisation iCloud
- [ ] Export PDF/HTML
- [ ] Search & Tags

### Long terme
- [ ] iOS companion app
- [ ] Collaboration en temps réel
- [ ] Plugins système
- [ ] App Store distribution

## 🤝 Contribution

Le projet est prêt pour les contributions :
- ✅ Code bien structuré
- ✅ Documentation complète
- ✅ Guidelines claires
- ✅ Templates GitHub prêts

Voir [DEVELOPMENT.md](DEVELOPMENT.md) pour contribuer.

## 📄 Licence

**MIT License** - Libre d'utilisation et modification.

Voir [LICENSE](LICENSE) pour les détails.

## 🙏 Crédits

**Développé avec :**
- Swift & SwiftUI par Apple
- Claude Code par Anthropic
- Amour du code et des notes markdown ❤️

---

## 📞 Contact & Support

- 📖 Documentation : Voir les fichiers `.md` du projet
- 🐛 Bugs : Utiliser les GitHub Issues
- 💡 Features : Proposer via Pull Requests
- 📧 Questions : Consulter [DEVELOPMENT.md](DEVELOPMENT.md)

---

**MiniNote v1.0.0** - Une application macOS native pour prendre des notes en markdown avec style 🎨

*Créé avec passion et best practices* 🚀
```

### Content of ARCHITECTURE.md
```markdown
# Architecture de MiniNote

Ce document explique les décisions architecturales et les best practices utilisées dans MiniNote.

## Vue d'ensemble

MiniNote est une application macOS native construite avec SwiftUI et AppKit, suivant les principes SOLID et les patterns recommandés par Apple.

## Structure du projet

```
MiniNote/
├── Sources/
│   ├── MiniNoteApp.swift          # Entry point & app lifecycle
│   ├── Models/                     # Data layer
│   │   ├── Note.swift             # Domain model
│   │   └── NoteStore.swift        # State management & persistence
│   ├── Managers/                   # Business logic layer
│   │   └── HotCornerManager.swift # Hot corner detection & window management
│   └── Views/                      # Presentation layer
│       ├── NoteEditorView.swift   # Main view composition
│       └── MarkdownEditorView.swift # Custom markdown editor
├── Info.plist                      # App configuration & permissions
└── Package.swift                   # Swift Package Manager manifest
```

## Patterns architecturaux

### 1. MVVM (Model-View-ViewModel)

L'application suit le pattern MVVM natif de SwiftUI :

- **Models** : `Note` (données brutes)
- **ViewModels** : `NoteStore`, `HotCornerManager` (logique métier et état)
- **Views** : `NoteEditorView`, `MarkdownEditorView` (présentation)

### 2. Reactive Programming avec Combine

Utilisation extensive de Combine pour la réactivité :

```swift
@Published var note: Note  // Auto-notifie les vues des changements
```

Le `NoteStore` utilise un debouncer pour éviter des sauvegardes trop fréquentes :

```swift
saveDebouncer
    .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
    .sink { [weak self] _ in
        self?.saveNote()
    }
```

### 3. Singleton avec AppState

`AppState` est un singleton léger qui sert de pont entre SwiftUI et AppKit :

```swift
class AppState {
    static let shared = AppState()
    var noteStore: NoteStore?
    var hotCornerManager: HotCornerManager?
}
```

**Pourquoi ?** SwiftUI et AppKit ont des cycles de vie différents. AppState permet de partager l'état entre les deux mondes sans créer de couplage fort.

### 4. Dependency Injection via EnvironmentObject

Les dépendances sont injectées via `@EnvironmentObject` :

```swift
struct NoteEditorView: View {
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var hotCornerManager: HotCornerManager
}
```

**Avantages** :
- Testabilité : facile de mock les dépendances
- Flexibilité : pas de références hardcodées
- Conformité aux guidelines SwiftUI

## Composants clés

### MiniNoteApp

Point d'entrée de l'application. Responsabilités :
- Initialisation des stores
- Configuration de l'application comme accessory (pas d'icône dans le Dock)
- Injection des dépendances dans AppState

```swift
NSApp.setActivationPolicy(.accessory)  // Pas d'icône Dock
```

### NoteStore

Gère l'état de la note et sa persistance. Utilise :
- **UserDefaults ?** Non, trop limitant
- **CoreData ?** Trop complexe pour une seule note
- **File system** : JSON dans Application Support ✓

```swift
let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
```

**Debouncing** : Évite de sauvegarder à chaque frappe de touche.

### HotCornerManager

Détecte la position de la souris et gère l'affichage de la fenêtre.

#### Détection du hot corner

Utilise un `Timer` au lieu de `NSEvent.addGlobalMonitorForEvents` car :
- Plus fiable pour la position de la souris
- Pas besoin de permissions supplémentaires
- 0.1s d'intervalle = bon équilibre performance/réactivité

```swift
let distance = sqrt(
    pow(mouseLocation.x - bottomRight.x, 2) +
    pow(mouseLocation.y - bottomRight.y, 2)
)
```

#### Gestion de la fenêtre

- `isReleasedWhenClosed = false` : La fenêtre reste en mémoire quand fermée
- Réutilisation de la fenêtre existante au lieu d'en créer une nouvelle
- WindowDelegate stocké dans une propriété pour éviter la deallocation

### MarkdownEditorView

Éditeur markdown personnalisé utilisant `NSViewRepresentable`.

#### Pourquoi NSTextView au lieu de TextEditor ?

- TextEditor SwiftUI est trop limité
- NSTextView permet le contrôle total sur le rendu
- Permet d'ajouter des GestureRecognizers personnalisés

#### Rendu markdown en temps réel

Le rendu se fait via `NSAttributedString` :

```swift
storage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 24), range: lineRange)
```

**Stratégie** :
1. Parser ligne par ligne (évite les regex complexes)
2. Appliquer les styles via NSTextStorage
3. Rendering incrémental (pas de re-render complet)

#### Interaction avec les checkboxes

```swift
@objc func handleClick(_ recognizer: NSClickGestureRecognizer)
```

- Détecte le clic sur une checkbox (caractères 0-6 de la ligne)
- Modifie directement le contenu markdown
- Trigger le re-render automatiquement

## Performance

### Optimisations appliquées

1. **Debouncing des sauvegardes** : 500ms
2. **Lazy rendering** : Seulement ce qui est visible
3. **Réutilisation de la fenêtre** : Pas de création/destruction répétée
4. **Weak references** : Évite les retain cycles

### Mémoire

- Application légère (~2-3 MB RAM)
- Pas de fuites mémoire grâce aux weak refs
- Timer correctement invalidé dans `deinit`

## Sécurité

### Permissions

L'app nécessite :
- **Accessibility** : Pour `NSEvent.mouseLocation`

Déclarées dans Info.plist :
```xml
<key>NSAccessibilityUsageDescription</key>
<string>MiniNote needs accessibility access...</string>
```

### Sandbox

L'application n'est pas sandboxée pour permettre :
- Accès à l'écran (hot corner)
- Sauvegarde dans Application Support

Pour une distribution sur l'App Store, il faudrait :
1. Activer le sandbox
2. Demander les entitlements appropriés
3. Utiliser les APIs sandboxées

## Extensibilité

### Comment ajouter une nouvelle feature

#### 1. Ajouter un nouveau type de markdown

Dans `MarkdownEditorView.swift`, méthode `renderInlineMarkdown` :

```swift
let newPattern = "~~(.+?)~~"  // Strikethrough
applyPattern(newPattern, in: line, range: range, storage: storage) { matchRange in
    storage.addAttribute(.strikethroughStyle, value: 1, range: matchRange)
}
```

#### 2. Ajouter un nouveau hot corner

Dans `HotCornerManager.swift`, dupliquer la logique :

```swift
private func checkTopLeftCorner() {
    let topLeft = CGPoint(x: screenFrame.minX, y: screenFrame.maxY)
    // ...
}
```

#### 3. Ajouter de nouvelles notes

Modifier `NoteStore` pour gérer un array :

```swift
@Published var notes: [Note] = []
@Published var currentNoteId: UUID?
```

## Tests

### Testabilité

L'architecture MVVM rend le code facilement testable :

```swift
func testNoteStore() {
    let store = NoteStore()
    store.updateContent("# Test")
    XCTAssertEqual(store.note.content, "# Test")
}
```

### Tests à ajouter

1. Unit tests pour `NoteStore`
2. Unit tests pour le parsing markdown
3. UI tests pour l'interaction avec les checkboxes
4. Integration tests pour le hot corner

## Best Practices appliquées

### Swift

- ✓ Utilisation des `guard` pour early returns
- ✓ Optionals correctement gérés
- ✓ Weak references pour éviter retain cycles
- ✓ Immutabilité par défaut (let > var)
- ✓ Extensions pour organiser le code
- ✓ Documentation avec commentaires

### SwiftUI

- ✓ Séparation State/Logic
- ✓ Utilisation de @Published pour la réactivité
- ✓ EnvironmentObject pour DI
- ✓ Préférence pour les structs (Views)

### AppKit

- ✓ Utilisation correcte de NSViewRepresentable
- ✓ Coordinator pattern pour les delegates
- ✓ Gestion propre du cycle de vie

### Architecture

- ✓ Single Responsibility Principle
- ✓ Dependency Inversion
- ✓ Interface Segregation
- ✓ Don't Repeat Yourself

## Améliorations futures

### Performance

- Virtualisation pour très longues notes
- Parsing markdown asynchrone
- Cache de rendu

### Features

- Sync iCloud
- Notes multiples
- Thèmes
- Raccourcis clavier
- Export PDF

### Qualité

- Tests unitaires complets
- CI/CD avec GitHub Actions
- Code coverage > 80%
- SwiftLint pour le style

## Conclusion

MiniNote démontre comment construire une application macOS moderne en suivant les best practices :
- Architecture claire et maintenable
- Code testable et extensible
- Performance optimisée
- Expérience utilisateur native
```

### Content of DEVELOPMENT.md
```markdown
# Guide de développement MiniNote

## Démarrage rapide

### Prérequis

```bash
xcode-select --install  # Si pas déjà installé
swift --version         # Vérifier Swift 5.9+
```

### Commandes essentielles

```bash
make help      # Afficher toutes les commandes disponibles
make build     # Build debug
make release   # Build release (optimisé)
make run       # Build et lancer l'app
make clean     # Nettoyer les artifacts
make install   # Installer dans /Applications
```

## Développement avec Xcode

### Ouvrir le projet

```bash
open Package.swift
```

Xcode générera automatiquement le projet.

### Configuration Xcode

1. Sélectionner le schéma "MiniNote"
2. Choisir "My Mac" comme destination
3. Cmd+R pour build & run

### Debugging

- Points d'arrêt : Cliquer dans la marge gauche
- Console : View > Debug Area > Activate Console
- LLDB : Tous les outils standard Xcode disponibles

## Structure du code

### Ajouter un nouveau fichier

```bash
touch Sources/Views/NewView.swift
```

Swift Package Manager le détectera automatiquement.

### Organisation recommandée

```
Sources/
├── Models/      # Données & logique métier
├── Views/       # Interface utilisateur
├── Managers/    # Services & coordinateurs
└── Utilities/   # Helpers & extensions (si nécessaire)
```

## Workflow de développement

### 1. Feature branches

```bash
git checkout -b feature/nouvelle-fonctionnalite
```

### 2. Développement itératif

```bash
# Cycle de dev rapide
make build && make run

# Ou avec Xcode
# Cmd+B (build) puis Cmd+R (run)
```

### 3. Tests

```bash
swift test  # Quand les tests seront ajoutés
```

### 4. Code review

Vérifier :
- Pas de warnings de compilation
- Code conforme aux patterns existants
- Documentation des fonctions publiques

## Debugging des problèmes courants

### L'app ne détecte pas le hot corner

1. Vérifier les permissions Accessibilité :
   ```
   System Preferences > Privacy & Security > Accessibility
   ```

2. Checker les logs :
   ```swift
   print("Mouse position: \(NSEvent.mouseLocation)")
   ```

### La note ne se sauvegarde pas

1. Vérifier le chemin de sauvegarde :
   ```bash
   ~/Library/Application Support/MiniNote/note.json
   ```

2. Vérifier les permissions du fichier :
   ```bash
   ls -la ~/Library/Application\ Support/MiniNote/
   ```

### Problèmes de rendu markdown

1. Ajouter des logs dans `updateRendering()` :
   ```swift
   print("Rendering line: \(line)")
   ```

2. Vérifier les ranges NSString :
   ```swift
   print("Line range: \(lineRange)")
   ```

## Performance

### Profiling avec Instruments

```bash
make release
open .build/release/MiniNote

# Dans Xcode : Cmd+I pour lancer Instruments
```

Instruments utiles :
- **Time Profiler** : CPU usage
- **Allocations** : Mémoire
- **Leaks** : Fuites mémoire

### Optimisations

1. Mesurer d'abord :
   ```swift
   let start = CFAbsoluteTimeGetCurrent()
   // Code à mesurer
   let elapsed = CFAbsoluteTimeGetCurrent() - start
   print("Elapsed: \(elapsed)s")
   ```

2. Optimiser seulement ce qui est lent

## Code Style

### Swift conventions

```swift
// ✓ Bon
func updateContent(_ newContent: String) {
    note.content = newContent
}

// ✗ Mauvais
func UpdateContent(newContent: String) {
    note.content = newContent
}
```

### Naming

- Classes : `PascalCase`
- Functions : `camelCase`
- Variables : `camelCase`
- Constants : `camelCase`
- Enums : `PascalCase`

### Documentation

```swift
/// Détecte si la souris est dans le coin inférieur droit
/// - Returns: true si dans le coin, false sinon
private func checkMousePosition() -> Bool {
    // Implementation
}
```

## Git workflow

### Commits

```bash
git add .
git commit -m "feat: Add strikethrough markdown support"
```

Préfixes recommandés :
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `refactor:` Refactoring
- `test:` Tests
- `chore:` Maintenance

### Push

```bash
git push origin feature/nouvelle-fonctionnalite
```

## Distribution

### Build release

```bash
make release
```

Binary créé dans : `.build/release/MiniNote`

### Signature du code (pour distribution)

```bash
codesign --sign "Developer ID Application: Your Name" .build/release/MiniNote
```

### Notarisation (pour macOS 10.15+)

```bash
xcrun notarytool submit MiniNote.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --wait
```

## Resources utiles

### Documentation Apple

- [Swift Programming Language](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [AppKit Documentation](https://developer.apple.com/documentation/appkit/)

### Communauté

- [Swift Forums](https://forums.swift.org/)
- [Stack Overflow - Swift](https://stackoverflow.com/questions/tagged/swift)
- [Reddit - r/swift](https://reddit.com/r/swift)

## Troubleshooting

### Réinitialiser complètement

```bash
make clean
rm -rf ~/Library/Application\ Support/MiniNote
swift build
```

### Erreurs de compilation

```bash
swift package reset
swift package update
swift build
```

### Xcode cache issues

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## Support

Pour les questions ou problèmes, consulter :
1. [ARCHITECTURE.md](ARCHITECTURE.md) pour comprendre le design
2. [README.md](README.md) pour l'utilisation générale
3. Le code source avec commentaires inline
```

### Content of README.md
```markdown
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
```

