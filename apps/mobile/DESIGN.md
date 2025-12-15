# 🎨 Guide de Design - Livemory Mobile

## Vision du Design

L'application **Livemory** combine l'esthétique épurée de **WhatsApp** avec le professionnalisme de **LinkedIn** pour offrir une expérience utilisateur moderne, intuitive et élégante.

## Principes de Design

### 1. **Clarté et Minimalisme** (WhatsApp)
- Beaucoup d'espaces blancs
- Hiérarchie visuelle claire
- Focus sur le contenu essentiel
- Animations subtiles et fluides

### 2. **Professionnalisme** (LinkedIn)
- Design structuré et organisé
- Typographie soignée
- Cards avec ombres légères
- Interactions claires et prévisibles

### 3. **Modernité**
- Material Design 3
- Bottom navigation bar
- Icônes outlined/filled
- Transitions douces

## Palette de Couleurs

### Couleurs Principales

```dart
Primary (LinkedIn Blue): #0A66C2
Primary Light: #378FE9
Primary Dark: #004182

Secondary (WhatsApp Green): #25D366
Secondary Light: #64E986
Secondary Dark: #1DA851
```

### Couleurs Neutres

```dart
Background: #F5F7FA (Gris très clair)
Surface: #FFFFFF (Blanc)
Surface Variant: #EFF2F5 (Gris clair)
```

### Couleurs de Texte

```dart
Text Primary: #1C1E21 (Noir doux)
Text Secondary: #65676B (Gris moyen)
Text Tertiary: #B0B3B8 (Gris clair)
```

### Couleurs d'État

```dart
Success: #25D366 (Vert)
Error: #ED4956 (Rouge)
Warning: #FFA500 (Orange)
Info: #0095F6 (Bleu ciel)
```

## Typographie

### Hiérarchie des Textes

| Style | Taille | Poids | Usage |
|-------|--------|-------|-------|
| Display Large | 32px | Bold | Titres majeurs |
| Display Medium | 28px | Bold | Titres de sections |
| Display Small | 24px | Semi-Bold | Sous-titres |
| Headline Medium | 20px | Semi-Bold | Titres de cards |
| Title Large | 18px | Semi-Bold | Titres d'éléments |
| Title Medium | 16px | Medium | Sous-titres |
| Body Large | 16px | Regular | Corps de texte |
| Body Medium | 14px | Regular | Texte secondaire |
| Body Small | 12px | Regular | Annotations |

### Caractéristiques
- Police système (San Francisco sur iOS, Roboto sur Android)
- Letter-spacing négatif (-0.5px) pour les grands titres
- Line-height généreux pour la lisibilité
- Pas d'usage excessif du gras

## Composants UI

### 1. Cards

**Style LinkedIn avec touches WhatsApp**

```dart
- Background: Surface (#FFFFFF)
- Border Radius: 12px
- Shadow: Légère (blur: 8, offset: 0,2, opacity: 0.04)
- Padding: 16px
- Margin: 16px horizontal, 6px vertical
```

### 2. Boutons

**Primary Button (Elevated)**
- Background: Primary (#0A66C2)
- Foreground: White
- Border Radius: 24px (complètement arrondi)
- Padding: 24px horizontal, 12px vertical
- Elevation: 0 (flat design)

**Secondary Button (Outlined)**
- Border: Primary 1.5px
- Foreground: Primary
- Background: Transparent
- Same radius & padding

**Text Button**
- Foreground: Primary
- Padding réduit
- Pas de background

### 3. Bottom Navigation Bar

**Style WhatsApp moderne**
- Background: Surface avec ombre vers le haut
- Icônes: Outlined (inactif) / Filled (actif)
- Selected Color: Primary (#0A66C2)
- Unselected Color: Text Tertiary (#B0B3B8)
- Labels: 12px, Semi-Bold (actif)

### 4. FAB (Floating Action Button)

- Background: Secondary (#25D366) - rappel de WhatsApp
- Foreground: White
- Shape: Circle
- Elevation: 4

### 5. Input Fields

**Style moderne et minimaliste**
- Background: Surface Variant (#EFF2F5)
- Border: None (sans focus)
- Border Focused: Primary 2px
- Border Radius: 12px
- Padding: 16px horizontal, 14px vertical

### 6. Chips

- Background: Surface Variant
- Selected Background: Primary Light (opacity 0.2)
- Border Radius: 16px
- Padding: 12px horizontal, 8px vertical
- Font: 12px, Medium

### 7. Status Badges

- Background: Color with opacity 0.1
- Text: Couleur pleine
- Border Radius: 16px
- Padding: 10px horizontal, 5px vertical
- Font: 11px, Semi-Bold

## Layouts

### 1. Home Screen

**SliverAppBar + ScrollView**
- AppBar expansible (120px)
- Background: Surface
- Sections avec titres clairs
- Quick actions en cards 2 colonnes
- Feature list en cards verticales

### 2. Event List Screen

**Simple AppBar + RefreshIndicator**
- Background: Background (#F5F7FA)
- Cards avec images
- Pull-to-refresh
- FAB pour créer un événement

### 3. Bottom Navigation

**3 onglets principaux**
1. 🏠 Accueil - Dashboard & actions rapides
2. 📅 Événements - Liste des événements
3. 🎁 Offres - Réductions exclusives

## Ombres et Élévations

### Card Shadow
```dart
BoxShadow(
  color: #00000010 (opacity 0.04),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

### Button Shadow (hover/pressed)
```dart
BoxShadow(
  color: #00000020 (opacity 0.08),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

### Bottom Nav Shadow
```dart
BoxShadow(
  color: #0000000D (opacity 0.05),
  blurRadius: 10,
  offset: Offset(0, -2),
)
```

## Espacements

### Padding Standards
- XS: 4px
- S: 8px
- M: 12px
- L: 16px
- XL: 20px
- XXL: 24px

### Marges entre Éléments
- Entre cards: 12px
- Entre sections: 32px
- Entre groupes: 16px
- Padding écran: 20px

## Animations

### Transitions
- Duration: 200-300ms
- Curve: Ease-out pour l'apparition
- Curve: Ease-in pour la disparition

### Interactions
- Ripple effect sur tous les éléments cliquables
- Scale légèrement au press (0.98)
- Feedback visuel immédiat

## Icônes

### Style
- Material Icons (outlined par défaut)
- Filled pour l'état actif
- Taille: 24px (standard), 16px (small)

### Usage
- Toujours accompagnées de texte (accessibilité)
- Couleur cohérente avec le texte adjacent
- Spacing de 6-8px entre icône et texte

## Accessibilité

### Contraste
- Ratio minimum: 4.5:1 pour le texte normal
- Ratio minimum: 3:1 pour le texte large
- Boutons: fond suffisamment contrasté

### Touch Targets
- Taille minimum: 48x48 dp
- Espacement: au moins 8dp entre targets

### Lisibilité
- Taille de texte minimum: 12px
- Line-height: 1.4-1.6 pour le corps de texte
- Éviter les murs de texte

## Bonnes Pratiques

### ✅ À Faire
- Utiliser les couleurs et styles définis dans `AppTheme`
- Respecter les espacements standards
- Ajouter des états de chargement et d'erreur
- Prévoir le mode sombre (TODO)
- Utiliser `const` pour les widgets statiques
- Ajouter des animations de transition

### ❌ À Éviter
- Couleurs hardcodées
- Trop d'élévations/ombres
- Animations trop longues (>500ms)
- Texte trop petit (<12px)
- Boutons trop petits (<40px)
- Mélanger les styles (cohérence!)

## Responsive Design

### Breakpoints
- Mobile: < 600px
- Tablet: 600px - 1024px
- Desktop: > 1024px

### Adaptations
- Augmenter le padding sur tablette/desktop
- Limiter la largeur du contenu (max 800px)
- Passer en layout 2 colonnes sur tablette
- Utiliser drawer au lieu de bottom nav sur desktop

## Mode Sombre (TODO)

Le thème sombre suivra les mêmes principes avec :
- Background: #121212
- Surface: #1E1E1E
- Primary: Légèrement plus clair (#378FE9)
- Contraste inversé pour les textes

---

**Design System créé le 14 décembre 2025**  
**Version: 1.0.0**  
**Inspiré de WhatsApp et LinkedIn**
