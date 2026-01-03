# MiniNote - Quick Start Guide

## Installation en 2 minutes

### Étape 1 : Build l'application

```bash
cd /Users/andreadelre/Work/custom-apps/mininote
make release
```

### Étape 2 : Lancer l'application

```bash
.build/release/MiniNote
```

Ou installer dans /Applications :

```bash
make install
/Applications/MiniNote
```

### Étape 3 : Accorder les permissions

Quand l'application démarre, elle demandera les permissions d'accessibilité.

1. Cliquer sur "Open System Preferences"
2. Ou aller manuellement : **Réglages Système** → **Confidentialité et sécurité** → **Accessibilité**
3. Activer **MiniNote** dans la liste
4. Relancer l'application

## Utilisation

### Afficher la note

Déplacez votre souris dans le **coin inférieur droit** de l'écran (à moins de 10 pixels du coin).

### Cacher la note

Repassez la souris dans le **coin inférieur droit**.

### Écrire en markdown

L'éditeur supporte :

```markdown
# Titre niveau 1
## Titre niveau 2
### Titre niveau 3

- Liste à puces
- Autre item

- [ ] Tâche non cochée
- [x] Tâche cochée

**Texte en gras**
*Texte en italique*
`Code inline`
```

### Cocher une tâche

Cliquez directement sur la case ☐ ou ☑ dans l'éditeur. Le markdown sera automatiquement mis à jour.

## Commandes utiles

```bash
make build     # Build debug
make release   # Build optimisé
make run       # Lancer l'app
make clean     # Nettoyer
make install   # Installer dans /Applications
```

## Où sont mes notes ?

Les notes sont sauvegardées automatiquement dans :

```
~/Library/Application Support/MiniNote/note.json
```

## Troubleshooting rapide

### L'app ne détecte pas ma souris

- Vérifier que les permissions Accessibilité sont activées
- Relancer l'application
- Vérifier que vous allez bien dans le coin inférieur **droit**

### La note ne s'ouvre pas

- Vérifier la console : `Console.app` → filtrer "MiniNote"
- Vérifier que l'app est lancée (pas d'icône dans le Dock, c'est normal !)
- Utiliser Activity Monitor pour confirmer que le process tourne

### La note ne se sauvegarde pas

```bash
ls -la ~/Library/Application\ Support/MiniNote/
```

Si le dossier n'existe pas, il sera créé au premier lancement.

## Personnalisation

### Changer la distance du hot corner

Éditer [Sources/Managers/HotCornerManager.swift:11](Sources/Managers/HotCornerManager.swift#L11) :

```swift
private let cornerThreshold: CGFloat = 20  // Au lieu de 10
```

### Changer la note par défaut

Éditer [Sources/Models/NoteStore.swift](Sources/Models/NoteStore.swift) :

```swift
return Note(content: "# Ma note personnalisée\n\n- [ ] Ma première tâche")
```

## Désinstallation

```bash
rm /Applications/MiniNote
rm -rf ~/Library/Application\ Support/MiniNote
```

Et retirer les permissions dans Réglages Système → Accessibilité.

## Besoin d'aide ?

- Lire [README.md](README.md) pour plus de détails
- Consulter [ARCHITECTURE.md](ARCHITECTURE.md) pour comprendre le code
- Voir [DEVELOPMENT.md](DEVELOPMENT.md) pour contribuer

## Enjoy! 🎉
