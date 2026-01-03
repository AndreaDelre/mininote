# RFC: Architecture du Moteur Markdown pour MiniNote

## 1. Contexte
Actuellement, MiniNote utilise un système de rendu basé sur des expressions régulières (Regex) appliquées ligne par ligne dans un `NSTextView`.
Bien que performante pour des besoins basiques, cette approche montre vite ses limites :
- **Fragilité** : Les regex complexes (ex: imbrication gras/italique) sont dures à maintenir.
- **Limites structurelles** : Impossible de gérer proprement des blocs multi-lignes (tableaux, code blocks) ou du stateful parsing (listes imbriquées).
- **Pas d'AST** : Le code ne "comprend" pas la structure du document, il ne fait que colorier des motifs.

Ce document explore trois architectures pour passer à un éditeur de niveau professionnel (type Obsidian/Bear).

---

## 2. Options d'Architecture

### Option A : Native Hardcore (TextKit + AST Parser)
*L'approche retenue pour le prototypage immédiat.*

**Concept :**
On conserve `NSTextView` (AppKit) mais on remplace les Regex par un vrai parser Markdown (Apple `swift-markdown`) qui génère un Arbre Syntaxique Abstrait (AST).

**Fonctionnement :**
1. L'utilisateur tape du texte.
2. Le parser analyse le texte complet (ou le paragraphe modifié) et génère un AST.
3. On parcourt l'AST (Visitor Pattern) pour générer des attributs `NSAttributedString` (font, color, paragraph style).
4. On applique ces attributs au `NSTextStorage` de la vue.

**Avantages :**
- 🚀 **Performance native** : Pas de bridge JS, scroll infini fluide, faible RAM.
- 🍏 **100% macOS** : Sensation native (curseur, dictée, corrections système).
- 🛠 **Robuste** : Gère parfaitement l'imbrication (`**gras et _italique_**`).

**Inconvénients :**
- **Complexité** : Mapper les ranges Swift (String.Index) vers Objective-C (NSRange) est fastidieux.
- **Fonctions avancées** : Les images et tableaux demandent de manipuler `NSTextAttachment` qui est complexe.

---

### Option B : Web Hybrid (Embedded Editor)

**Concept :**
Utiliser une `WKWebView` invisible chargée avec un éditeur web moderne (CodeMirror 6, Milkdown, ou TipTap).

**Fonctionnement :**
- L'UI est en SwiftUI.
- La zone de texte est une page web locale.
- Communication via `JavaScriptBridge`.

**Avantages :**
- ✨ **Features gratuites** : Tableaux, images, drag & drop, plugins sont déjà gérés par ces librairies.
- 🎨 **Rendu parfait** : CSS pour le styling, très flexible.

**Inconvénients :**
- **Lourdeur** : Chaque note lance un processus WebKit (RAM++).
- **Ressenti** : Le curseur et le scrolling peuvent sembler "non-natifs".
- **Délais** : Temps de chargement à l'initialisation.

---

### Option C : Swift Library Wrapper

**Concept :**
Utiliser un framework tiers existant qui a déjà résolu les problèmes de l'Option A.
Exemple : `Runestone` (utilisé par l'app éponyme) ou `ProseMirror` (wrapper Swift).

**Avantages :**
- Gain de temps immédiat.

**Inconvénients :**
- Dépendance forte à une librairie tierce.
- Moins de contrôle sur le rendu exact.

---

## 3. Recommandation : Option A (Native Hardcore)

Pour MiniNote, qui se veut "léger" et "natif", l'**Option A** est la seule qui respecte la philosophie du projet.

### Plan d'implémentation (Phase 1 - Texte & Preview)

1. **Intégration** : Ajouter `apple/swift-markdown` via SPM.
2. **Parsing** : Créer un service `MarkdownParser` qui prend une `String` et retourne une liste de tokens ou d'attributs.
3. **Rendering** : Modifier `MarkdownEditorView` pour appliquer ces attributs au lieu des regex.
4. **Styling** : Définir un thème centralisé pour les polices et couleurs (H1, H2, Blockquote, Code).

### Ce qu'on laisse de côté pour l'instant (Phase 2)
- Les images (NSTextAttachment).
- Les tableaux (LayoutManager custom).
- Le masquage des caractères markdown (ex: cacher les `**` quand le curseur n'est pas dessus).

---
