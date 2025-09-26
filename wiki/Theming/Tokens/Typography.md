# Typography System Documentation

This document covers the complete typography system including primitive tokens and semantic styles defined in TypographyTokens.qml.

## Table of Contents
- [Primitive Tokens](#primitive-tokens)
- [Semantic Styles](#semantic-styles)
- [Usage Patterns](#usage-patterns)
- [Best Practices](#best-practices)

## Primitive Tokens

These are the foundational typography tokens that can be used individually or combined to create custom text styles.

### Font Families

```qml
// PP Fraktion Sans - Used for UI text, headings, body content
font.family: Theme.typography.familySans

// PP Fraktion Mono - Used for code, data, technical content
font.family: Theme.typography.familyMono
```

### Font Sizes

Systematic size scale from 8px to 72px:

```qml
font.pixelSize: Theme.typography.fontSize100   // 8px
font.pixelSize: Theme.typography.fontSize125   // 10px
font.pixelSize: Theme.typography.fontSize150   // 12px
font.pixelSize: Theme.typography.fontSize175   // 14px
font.pixelSize: Theme.typography.fontSize200   // 18px
font.pixelSize: Theme.typography.fontSize250   // 20px
font.pixelSize: Theme.typography.fontSize300   // 24px
font.pixelSize: Theme.typography.fontSize400   // 32px
font.pixelSize: Theme.typography.fontSize500   // 40px
font.pixelSize: Theme.typography.fontSize600   // 48px
font.pixelSize: Theme.typography.fontSize800   // 64px
font.pixelSize: Theme.typography.fontSize900   // 72px
```

### Font Weights

Design system weight values:

```qml
font.weight: Theme.typography.weightLight      // 300
font.weight: Theme.typography.weightRegular    // 390
font.weight: Theme.typography.weightMedium     // 450
font.weight: Theme.typography.weightSemibold   // 560
font.weight: Theme.typography.weightBold       // 645
```

### Line Heights

Font-family specific line heights:

```qml
// For Sans fonts (PP Fraktion Sans)
lineHeight: Theme.typography.lineHeightSans    // 1.22 (122%)
lineHeightMode: Text.ProportionalHeight

// For Mono fonts (PP Fraktion Mono)
lineHeight: Theme.typography.lineHeightMono    // 1.31 (131%)
lineHeightMode: Text.ProportionalHeight
```

### Text Properties

Additional text styling options:

```qml
// Letter spacing
font.letterSpacing: Theme.typography.letterSpacingTighter  // -0.5
font.letterSpacing: Theme.typography.letterSpacingTight    // -0.25
font.letterSpacing: Theme.typography.letterSpacingNormal   // 0.0
font.letterSpacing: Theme.typography.letterSpacingWide     // 0.25
font.letterSpacing: Theme.typography.letterSpacingWider    // 0.5
font.letterSpacing: Theme.typography.letterSpacingWidest   // 1.0

// Word spacing
font.wordSpacing: Theme.typography.wordSpacingTight        // -1.0
font.wordSpacing: Theme.typography.wordSpacingNormal       // 0.0
font.wordSpacing: Theme.typography.wordSpacingWide         // 1.0
font.wordSpacing: Theme.typography.wordSpacingWider        // 2.0

// Text capitalization
font.capitalization: Theme.typography.transformNone        // Font.MixedCase
font.capitalization: Theme.typography.transformUppercase   // Font.AllUppercase
font.capitalization: Theme.typography.transformLowercase   // Font.AllLowercase
font.capitalization: Theme.typography.transformCapitalize  // Font.Capitalize
font.capitalization: Theme.typography.transformSmallCaps   // Font.SmallCaps

// Text wrapping
wrapMode: Theme.typography.wrapNoWrap                      // Text.NoWrap
wrapMode: Theme.typography.wrapWord                        // Text.WordWrap
wrapMode: Theme.typography.wrapAnywhere                    // Text.WrapAnywhere
wrapMode: Theme.typography.wrapAtWordBoundaryOrAnywhere    // Text.WrapAtWordBoundaryOrAnywhere

// Text eliding (ellipsis)
elide: Theme.typography.elideNone                          // Text.ElideNone
elide: Theme.typography.elideLeft                          // Text.ElideLeft
elide: Theme.typography.elideRight                         // Text.ElideRight
elide: Theme.typography.elideMiddle                        // Text.ElideMiddle
```

## Semantic Styles

Pre-defined combinations of primitive tokens for common use cases.

### Usage Pattern

All semantic typography styles follow this consistent pattern:

```qml
Text {
    // Use semantic style properties
    font.family: Theme.typography.[STYLE]Family
    font.pixelSize: Theme.typography.[STYLE]Size  
    font.weight: Theme.typography.[STYLE]Weight
    
    // Add appropriate line height based on font family
    lineHeight: Theme.typography.lineHeightSans  // For Sans fonts
    // OR
    lineHeight: Theme.typography.lineHeightMono  // For Mono fonts
    lineHeightMode: Text.ProportionalHeight
    
    color: Theme.colors.text
    text: "Your content here"
}
```

### Heading Styles

#### heading-100
**Usage**: Medium-sized headings, section titles
```qml
Text {
    text: "Section Title"
    font.family: Theme.typography.heading100Family    // familySans
    font.pixelSize: Theme.typography.heading100Size   // fontSize250 (20px)
    font.weight: Theme.typography.heading100Weight    // weightMedium (450)
    lineHeight: Theme.typography.lineHeightSans       // 1.22
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

#### heading-150
**Usage**: Large headings, page titles
```qml
Text {
    text: "Page Title"
    font.family: Theme.typography.heading150Family    // familySans
    font.pixelSize: Theme.typography.heading150Size   // fontSize400 (32px)
    font.weight: Theme.typography.heading150Weight    // weightMedium (450)
    lineHeight: Theme.typography.lineHeightSans       // 1.22
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

#### heading-200
**Usage**: Extra large headings, main titles
```qml
Text {
    text: "Main Title"
    font.family: Theme.typography.heading200Family    // familySans
    font.pixelSize: Theme.typography.heading200Size   // fontSize500 (40px)
    font.weight: Theme.typography.heading200Weight    // weightMedium (450)
    lineHeight: Theme.typography.lineHeightSans       // 1.22
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

### Body Sans Styles

#### bodySans100
**Usage**: Standard body text, paragraphs
```qml
Text {
    text: "This is regular body text for reading content."
    font.family: Theme.typography.bodySans100Family   // familySans
    font.pixelSize: Theme.typography.bodySans100Size  // fontSize200 (18px)
    font.weight: Theme.typography.bodySans100Weight   // weightRegular (390)
    lineHeight: Theme.typography.lineHeightSans       // 1.22
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

#### bodySans100Strong
**Usage**: Emphasized body text, important information
```qml
Text {
    text: "Important information that needs emphasis."
    font.family: Theme.typography.bodySans100StrongFamily   // familySans
    font.pixelSize: Theme.typography.bodySans100StrongSize  // fontSize200 (18px)
    font.weight: Theme.typography.bodySans100StrongWeight   // weightMedium (450)
    lineHeight: Theme.typography.lineHeightSans             // 1.22
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

#### All Body Sans Variants
Available body sans styles with different size and weight combinations:

- `bodySans15`, `bodySans15Strong` (fontSize125 - 10px)
- `bodySans25Light`, `bodySans25`, `bodySans25Strong` (fontSize150 - 12px)
- `bodySans50Light`, `bodySans50`, `bodySans50Strong` (fontSize175 - 14px)
- `bodySans100Light`, `bodySans100`, `bodySans100Strong` (fontSize200 - 18px)
- `bodySans150Light`, `bodySans150`, `bodySans150Strong` (fontSize250 - 20px)

### Body Mono Styles

#### bodyMono100
**Usage**: Code blocks, data display, technical content
```qml
Text {
    text: "function calculateTotal() { return price * quantity; }"
    font.family: Theme.typography.bodyMono100Family   // familyMono
    font.pixelSize: Theme.typography.bodyMono100Size  // fontSize200 (18px)
    font.weight: Theme.typography.bodyMono100Weight   // weightRegular (390)
    lineHeight: Theme.typography.lineHeightMono       // 1.31
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

#### All Body Mono Variants
Available mono styles include size variants from 15 to 300:

- `bodyMono15` (fontSize125 - 10px)
- `bodyMono25Light`, `bodyMono25`, `bodyMono25Strong` (fontSize150 - 12px)
- `bodyMono50Light`, `bodyMono50`, `bodyMono50Strong` (fontSize175 - 14px)
- `bodyMono100Light`, `bodyMono100`, `bodyMono100Strong` (fontSize200 - 18px)
- `bodyMono150Light`, `bodyMono150`, `bodyMono150Strong` (fontSize250 - 20px)
- `bodyMono175Light`, `bodyMono175`, `bodyMono175Strong` (fontSize300 - 24px)
- `bodyMono200Light`, `bodyMono200`, `bodyMono200Strong` (fontSize400 - 32px)
- `bodyMono300Light`, `bodyMono300`, `bodyMono300Strong` (fontSize600 - 48px)

### Utility Styles

#### button100
**Usage**: Button text, interactive elements
```qml
Button {
    Text {
        text: "Save Mission"
        font.family: Theme.typography.button100Family    // familySans
        font.pixelSize: Theme.typography.button100Size   // fontSize175 (14px)
        font.weight: Theme.typography.button100Weight    // weightRegular (390)
        lineHeight: Theme.typography.lineHeightSans      // 1.22
        lineHeightMode: Text.ProportionalHeight
        color: Theme.colors.primaryText
    }
}
```

#### Other Utility Styles
- `link25`, `link50`, `link100` - Link text in various sizes
- `kpiTitle100`, `kpiTitle75` - KPI and dashboard titles
- `notificationNumber100` - Notification badges and counters

## Usage Patterns

### When to Use Primitives vs Semantics

**Use Primitive Tokens When:**
- Creating custom typography combinations
- Prototyping new designs
- Building reusable components
- Need fine-grained control

```qml
// Example 1: Custom headline with specific requirements
Text {
    text: "Special Announcement"
    font.family: Theme.typography.familySans
    font.pixelSize: Theme.typography.fontSize300    // 24px
    font.weight: Theme.typography.weightSemibold    // 560
    color: Theme.colors.primary
    lineHeight: Theme.typography.lineHeightSans
    lineHeightMode: Text.ProportionalHeight
}

// Example 2: Small technical label
Text {
    text: "v2.1.0"
    font.family: Theme.typography.familyMono
    font.pixelSize: Theme.typography.fontSize100    // 8px
    font.weight: Theme.typography.weightRegular     // 390
    color: Theme.colors.textMuted
    lineHeight: Theme.typography.lineHeightMono
    lineHeightMode: Text.ProportionalHeight
}

// Example 3: Extra large display text
Text {
    text: "404"
    font.family: Theme.typography.familySans
    font.pixelSize: Theme.typography.fontSize900    // 72px
    font.weight: Theme.typography.weightBold        // 645
    color: Theme.colors.danger
    lineHeight: Theme.typography.lineHeightSans
    lineHeightMode: Text.ProportionalHeight
}
```

**Use Semantic Styles When:**
- Implementing designs that match the design system
- Building production UI components  
- Ensuring consistency across the app
- Following established patterns

```qml
Text {
    font.family: Theme.typography.heading150Family
    font.pixelSize: Theme.typography.heading150Size
    font.weight: Theme.typography.heading150Weight
    lineHeight: Theme.typography.lineHeightSans
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

## Best Practices

### Line Height Rules

**Simple rule**: Choose line height based on font family, not the semantic style:

- **Sans fonts** (familySans): Use `Theme.typography.lineHeightSans` (1.22)
- **Mono fonts** (familyMono): Use `Theme.typography.lineHeightMono` (1.31)

### Color Usage

Always use theme colors for consistency:

```qml
// Good
color: Theme.colors.text
color: Theme.colors.textMuted
color: Theme.colors.primary

// Avoid
color: "#FFFFFF"
color: "white"
```

### Responsive Typography

Use the size scale systematically for responsive design:

```qml
// Mobile
font.pixelSize: Theme.typography.fontSize175

// Tablet
font.pixelSize: Theme.typography.fontSize200

// Desktop
font.pixelSize: Theme.typography.fontSize250
```

### Component Integration

Create reusable text components that encapsulate typography styles:

```qml
// HeadingText.qml
Text {
    property string level: "150" // "100", "150", "200"
    
    font.family: Theme.typography["heading" + level + "Family"]
    font.pixelSize: Theme.typography["heading" + level + "Size"]
    font.weight: Theme.typography["heading" + level + "Weight"]
    lineHeight: Theme.typography.lineHeightSans
    lineHeightMode: Text.ProportionalHeight
    color: Theme.colors.text
}
```

### Design System Mapping

Each semantic style maps to these primitive tokens:

| Style Property | Maps To | Example Value |
|----------------|---------|---------------|
| `[STYLE]Family` | `familySans` or `familyMono` | "PP Fraktion Sans" |
| `[STYLE]Size` | `fontSize100` - `fontSize900` | `fontSize200` (18px) |
| `[STYLE]Weight` | `weightLight` - `weightBold` | `weightRegular` (390) |

This two-tier system ensures consistency while maintaining the flexibility to use either semantic styles or primitive tokens as needed.

## Typography Styles Reference

If you want to achieve the same effect as any typography style, you need to apply the specific combination of family, size, and weight properties that define that style.

### Example: Using heading-100 Style

To get the heading-100 style effect, apply these three properties:
```qml
font.family: Theme.typography.heading100Family    // familySans
font.pixelSize: Theme.typography.heading100Size   // fontSize250
font.weight: Theme.typography.heading100Weight    // weightMedium
```

### Key Style Combinations

Each typography style is defined by these three properties:

| Style | Family Property | Size Property | Weight Property |
|-------|----------------|---------------|-----------------|
| `heading100` | `heading100Family` | `heading100Size` | `heading100Weight` |
| `heading150` | `heading150Family` | `heading150Size` | `heading150Weight` |
| `bodySans100` | `bodySans100Family` | `bodySans100Size` | `bodySans100Weight` |
| `bodySans100Strong` | `bodySans100StrongFamily` | `bodySans100StrongSize` | `bodySans100StrongWeight` |
| `bodyMono100` | `bodyMono100Family` | `bodyMono100Size` | `bodyMono100Weight` |
| `button100` | `button100Family` | `button100Size` | `button100Weight` |
