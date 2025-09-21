# Global Theme System Documentation

## Overview
This project now has a comprehensive global color theme system that ensures consistency across all pages. The theme system is built around a centralized color palette and provides reusable components and styles.

## File Structure
```
lib/
├── theme/
│   ├── app_theme.dart        # Main theme configuration
│   └── theme_helpers.dart    # Helper widgets and utilities
├── main.dart                 # Updated to use global theme
└── views/                    # Updated pages using the theme
```

## Color Palette

### Primary Colors
- **Primary Color**: `Color.fromARGB(255, 227, 41, 178)` - Main brand color (bright pink)
- **Primary Variant**: `Color.fromARGB(255, 213, 108, 240)` - Lighter pink/purple
- **Secondary Color**: `Color.fromARGB(255, 228, 167, 187)` - Soft pink
- **Secondary Variant**: `Color.fromARGB(255, 240, 128, 166)` - Light pink

### Accent Colors (for buttons and interactive elements)
- **Accent Blue**: `Color.fromARGB(255, 58, 150, 242)` - For "Add" actions
- **Accent Orange**: `Color.fromARGB(255, 225, 142, 59)` - For "View" actions
- **Accent Teal**: `Color.fromARGB(255, 36, 225, 203)` - For "Edit" actions
- **Accent Purple**: `Color.fromARGB(255, 203, 30, 212)` - For "Delete" actions
- **Accent Violet**: `Color.fromARGB(255, 179, 71, 225)` - For "Analysis" actions

### Background Colors
- **Card Background**: `Color.fromARGB(255, 235, 171, 222)` - Semi-transparent card overlay
- **Surface Color**: `Colors.white` - Clean surface background
- **Background Color**: `Color.fromARGB(255, 250, 248, 255)` - Very light purple background

### Text Colors
- **Text Primary**: `Color(0xFF2D2D2D)` - Main text color
- **Text Secondary**: `Color(0xFF6B6B6B)` - Secondary text color
- **Text on Primary**: `Colors.white` - Text on colored backgrounds

## Using the Theme System

### 1. Importing the Theme
```dart
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';
```

### 2. Basic Components

#### Gradient Backgrounds
```dart
// Primary gradient (pink to light pink)
ThemeHelpers.gradientBackground(
  child: YourWidget(),
)

// Dashboard gradient (purple variant)
ThemeHelpers.dashboardBackground(
  child: YourWidget(),
)
```

#### Themed Cards
```dart
ThemeHelpers.themedCard(
  child: YourContent(),
  padding: EdgeInsets.all(24.0), // Optional
  margin: EdgeInsets.symmetric(horizontal: 24), // Optional
)
```

#### Themed Buttons
```dart
// Primary button (uses theme primary color)
ThemeHelpers.themedButton(
  text: 'Submit',
  onPressed: () {},
)

// Colored dashboard buttons
ThemeHelpers.dashboardButton(
  text: 'Add Student',
  backgroundColor: AppTheme.accentBlue,
  onPressed: () {},
)
```

#### Pre-styled Button Styles
```dart
ElevatedButton(
  style: AppButtonStyles.blueButton,    // Blue accent
  style: AppButtonStyles.orangeButton,  // Orange accent
  style: AppButtonStyles.tealButton,    // Teal accent
  style: AppButtonStyles.purpleButton,  // Purple accent
  style: AppButtonStyles.violetButton,  // Violet accent
  style: AppButtonStyles.errorButton,   // Red for dangerous actions
  onPressed: () {},
  child: Text('Button Text'),
)
```

#### Text Fields
```dart
ThemeHelpers.themedTextField(
  controller: myController,
  labelText: 'Username',
  obscureText: false, // Optional, default false
)
```

#### Snack Bars
```dart
// Success message
ThemeHelpers.showThemedSnackBar(
  context,
  message: 'Operation successful!',
  backgroundColor: AppTheme.successColor,
);

// Error message
ThemeHelpers.showThemedSnackBar(
  context,
  message: 'Something went wrong!',
  isError: true,
);
```

#### Dialogs
```dart
ThemeHelpers.showThemedDialog(
  context: context,
  title: 'Confirmation',
  content: 'Are you sure?',
  cancelText: 'Cancel',
  confirmText: 'Proceed',
  onConfirm: () {
    // Handle confirmation
  },
);
```

### 3. Pre-built Widgets

#### Themed Avatars
```dart
// Default wellness avatar (brain icon)
ThemeHelpers.themedAvatar()

// Custom size and icon
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.account_circle_outlined, // Login avatar
)

// Admin avatar
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.admin_panel_settings,
)

// Academic avatar
ThemeHelpers.themedAvatar(
  size: 40,
  icon: Icons.school_outlined,
)

// Different wellness icons
ThemeHelpers.themedAvatar(
  size: 120,
  icon: Icons.favorite, // Health/heart
)

ThemeHelpers.themedAvatar(
  size: 120,
  icon: Icons.spa, // Relaxation/wellness
)
```

#### App Logo (Now Uses Themed Avatar)
```dart
ThemedWidgets.appLogo(height: 80) // Optional height parameter
```

#### App Title
```dart
ThemedWidgets.appTitle(
  title: 'YOUR APP TITLE', // Optional, has default
  textAlign: TextAlign.center,
)
```

#### Loading Indicator
```dart
ThemedWidgets.loadingIndicator(
  message: 'Loading...', // Optional message
)
```

#### Empty State
```dart
ThemedWidgets.emptyState(
  title: 'No Data Found',
  subtitle: 'Try adding some items first',
  icon: Icons.inbox,
  action: ElevatedButton(...), // Optional action button
)
```

### 4. Direct Color Usage
When you need to use theme colors directly:
```dart
Container(
  color: AppTheme.primaryColor,
  // or
  decoration: AppDecorations.primaryGradientDecoration,
  // or
  decoration: AppDecorations.cardDecoration,
)
```

### 5. Accessing Theme Data
The theme is automatically applied to your app via `MaterialApp`. You can also access theme data in your widgets:
```dart
Theme.of(context).textTheme.headlineLarge
Theme.of(context).colorScheme.primary
```

## Implementation Examples

### Updated Login Page
The login page now uses:
- `ThemeHelpers.gradientBackground()` for the background
- `ThemeHelpers.themedCard()` for the login form
- `ThemeHelpers.themedTextField()` for input fields
- `ThemeHelpers.themedButton()` for the login button
- `ThemeHelpers.showThemedSnackBar()` for notifications

### Updated Admin Dashboard
The admin dashboard now uses:
- `ThemeHelpers.dashboardBackground()` for the gradient background
- `ThemeHelpers.dashboardButton()` for all action buttons with consistent colors
- `ThemeHelpers.showThemedDialog()` for the logout confirmation

## Benefits of This System

1. **Consistency**: All pages use the same color palette and styling
2. **Maintainability**: Change colors in one place to update the entire app
3. **Reusability**: Pre-built components reduce code duplication
4. **Flexibility**: Easy to add new themed components
5. **Scalability**: Simple to extend with new colors or styles

## Customization

### Adding New Colors
Add new colors to `AppTheme` class in `app_theme.dart`:
```dart
static const Color newAccentColor = Color(0xFF123456);
```

### Adding New Button Styles
Add new button styles to `AppButtonStyles` class:
```dart
static ButtonStyle newButton = ElevatedButton.styleFrom(
  backgroundColor: AppTheme.newAccentColor,
  // ... other properties
);
```

### Creating New Helper Methods
Add new helper methods to `ThemeHelpers` class in `theme_helpers.dart`.

## Migration Guide

To update existing pages to use the global theme:

1. Import the theme files
2. Replace hardcoded colors with theme colors
3. Replace custom gradients with theme gradients
4. Use themed components instead of custom styled widgets
5. Replace manual snackbars with `ThemeHelpers.showThemedSnackBar()`
6. Replace manual dialogs with `ThemeHelpers.showThemedDialog()`

This system ensures your entire app maintains a consistent, professional appearance while making it easy to make global design changes.