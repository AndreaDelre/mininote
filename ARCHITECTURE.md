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
│   │   ├── NoteStore.swift        # State management & persistence
│   │   └── SimpleBlock.swift      # Block model (text, task, code)
│   ├── Managers/                   # Business logic layer
│   │   ├── HotCornerManager.swift # Hot corner detection & window management
│   │   └── MenuBarManager.swift   # Menu bar icon & menu
│   ├── Utilities/                  # Helpers & parsers
│   │   ├── MarkdownParser.swift   # AST-based markdown parser
│   │   └── CodeSyntaxHighlighter.swift # Code syntax highlighting
│   └── Views/                      # Presentation layer
│       ├── NoteEditorView.swift   # Main view composition
│       └── SimpleBlockEditor.swift # Block-based editor
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

### MenuBarManager

Gère l'icône de la barre des menus et le menu contextuel.

- **Icône système** : Utilise les SF Symbols (`square.and.pencil`) pour une intégration native parfaite qui s'adapte automatiquement aux modes clair et sombre.
- **Menu contextuel** : Permet d'afficher/masquer la note manuellement, d'accéder aux informations "À propos" et de quitter l'application.

#### Gestion de la fenêtre

- `isReleasedWhenClosed = false` : La fenêtre reste en mémoire quand fermée
- Réutilisation de la fenêtre existante au lieu d'en créer une nouvelle
- WindowDelegate stocké dans une propriété pour éviter la deallocation

### SimpleBlockEditor

Éditeur basé sur une architecture de blocs utilisant `NSViewRepresentable`.

#### Pourquoi une architecture par blocs ?

- **Flexibilité** : Chaque bloc peut avoir son propre comportement (texte, tâche, code)
- **Performance** : Seul le bloc édité est re-rendu
- **UX** : Navigation fluide entre blocs avec les flèches
- **Extensibilité** : Facile d'ajouter de nouveaux types de blocs

#### Types de blocs supportés

1. **Text Block** : Texte simple avec markdown styling
2. **Task Block** : Checkbox SwiftUI + texte éditable
3. **Code Block** : Multi-ligne avec syntax highlighting

#### Architecture des blocs

```swift
struct SimpleBlock: Identifiable {
    let id: UUID
    var content: String

    var isTask: Bool { /* détection "- [ ]" */ }
    var isCodeBlock: Bool { /* détection "```" */ }
    var isCodeBlockClosed: Bool { /* vérifie fermeture */ }
}
```

#### Gestion des opérations

- **Split** (Enter) : Crée un nouveau bloc après le curseur
- **Merge** (Backspace) : Fusionne avec le bloc précédent
- **Arrow Up/Down** : Navigation inter-blocs avec préservation de la position du curseur

#### Code blocks spéciaux

Les blocs de code ont un comportement unique :
- Commencent par \`\`\` sur une ligne
- Permettent les retours à la ligne internes (pas de split)
- Ne se divisent que lorsqu'ils sont fermés avec \`\`\` et le curseur à la fin

#### Rendu markdown en temps réel

Utilise `swift-markdown` pour le parsing AST :

```swift
let document = Document(parsing: text)
var walker = AttributedStringWalker(storage: storage, theme: theme)
walker.visit(document)
```

**Avantages** :
1. Parser robuste basé sur CommonMark
2. AST complet pour navigation précise
3. Support natif des éléments markdown complexes
4. Syntax highlighting via Splash pour les code blocks

#### Interaction avec les checkboxes

- Rendu via Toggle SwiftUI natif
- Texte markdown (\`- [ ]\`) caché via `.foregroundColor(.clear)`
- Attribut personnalisé `isCheckbox` pour le positionnement
- Clique sur le Toggle modifie directement le `SimpleBlock.content`

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

#### 1. Ajouter un nouveau type de bloc

Dans `SimpleBlock.swift`, ajouter la détection :

```swift
var isQuoteBlock: Bool {
    content.trimmingCharacters(in: .whitespaces).hasPrefix(">")
}
```

Dans `UnifiedBlockView`, ajouter le rendu spécifique :

```swift
if block.isQuoteBlock {
    // Custom view pour quotes
}
```

#### 2. Ajouter un nouveau style markdown

Dans `MarkdownParser.swift`, ajouter une méthode visitor :

```swift
mutating func visitStrikethrough(_ strikethrough: Strikethrough) {
    if let range = nsRange(from: strikethrough.range) {
        storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
    }
    descendInto(strikethrough)
}
```

#### 3. Ajouter un nouveau hot corner

Dans `HotCornerManager.swift`, dupliquer la logique :

```swift
private func checkTopLeftCorner() {
    let topLeft = CGPoint(x: screenFrame.minX, y: screenFrame.maxY)
    // ...
}
```

#### 4. Ajouter de nouvelles notes

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
