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
# Cycle de dev rapide (recommandé)
pkill MiniNote || true; sleep 2; swift build && .build/debug/MiniNote &

# Ou via Makefile
make build && make run
```

### Méthode de relance fiable
Pour s'assurer que l'application est bien redémarrée avec les dernières modifications :
1. Tuer l'instance existante : `pkill MiniNote || true`
2. Attendre la libération des ressources : `sleep 2`
3. Compiler et lancer le binaire directement : `swift build && .build/debug/MiniNote &`

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
