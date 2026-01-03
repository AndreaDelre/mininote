# GEMINI.md - Consolidated Project Documentation

This file contains a concatenation of all markdown documentation files in the repository.
It is intended to provide a comprehensive context for the Gemini agent.

---

## 1. PROJECT_SUMMARY.md

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
- `git commit -am 