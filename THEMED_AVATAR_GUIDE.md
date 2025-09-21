# Themed Avatar Quick Reference Guide

## Overview
The `ThemeHelpers.themedAvatar()` method provides consistent, beautiful circular avatars throughout your app using your global pink gradient theme.

## Implementation Examples

### 1. **Login Page Avatar**
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.account_circle_outlined, // User login icon
)
```
**Use Case**: Login/authentication screens, user account related pages

### 2. **Admin Dashboard Avatar** 
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.admin_panel_settings, // Admin management icon
)
```
**Use Case**: Admin areas, management dashboards, settings pages

### 3. **Student Dashboard Avatar**
```dart
ThemeHelpers.themedAvatar(
  size: 120,
  icon: Icons.psychology_outlined, // Brain/wellness icon
)
```
**Use Case**: Main student interface, wellness focus, mental health

### 4. **Academic Pages Avatar**
```dart
ThemeHelpers.themedAvatar(
  size: 40,
  icon: Icons.school_outlined, // Education icon
)
```
**Use Case**: AppBar icons, academic data pages, educational content

### 5. **Health/Wellness Focus**
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.favorite, // Heart icon for health
)
```
**Use Case**: Health monitoring, wellness tracking, heart rate features

### 6. **Relaxation/Spa Features**
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.spa, // Relaxation icon
)
```
**Use Case**: Meditation features, relaxation exercises, stress management

### 7. **Learning/Ideas**
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.emoji_objects, // Light bulb for ideas
)
```
**Use Case**: Learning modules, tips sections, idea generation

### 8. **Physical Fitness**
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.fitness_center, // Gym/fitness icon
)
```
**Use Case**: Exercise tracking, physical wellness, workout recommendations

### 9. **Personal Growth**
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.self_improvement, // Personal development icon
)
```
**Use Case**: Goal setting, personal development, progress tracking

### 10. **Small AppBar Icons**
```dart
ThemeHelpers.themedAvatar(
  size: 32,
  icon: Icons.notifications_outlined, // Notification icon
)
```
**Use Case**: Small icons in app bars, navigation, compact displays

## Color Variations

### Using Different Gradients
```dart
ThemeHelpers.themedAvatar(
  size: 100,
  icon: Icons.psychology_outlined,
  gradient: LinearGradient(
    colors: [AppTheme.accentBlue, AppTheme.accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
)
```

## Best Practices

### ✅ **DO:**
- Use consistent sizing for similar contexts (120px for main dashboards, 40px for app bars)
- Choose icons that match the page/feature context
- Use the default gradient for consistency
- Keep icon choices intuitive and recognizable

### ❌ **DON'T:**
- Mix too many different avatar sizes on the same page
- Use unclear or confusing icons
- Override the gradient unless there's a specific design reason
- Use extremely large sizes (>150px) as it may look overwhelming

## Icon Categories by Use Case

### **User/Account Related**
- `Icons.account_circle_outlined` - Login, profile
- `Icons.person_outline` - User account, personal info
- `Icons.badge_outlined` - Credentials, achievements

### **Admin/Management**
- `Icons.admin_panel_settings` - Admin dashboard
- `Icons.manage_accounts` - User management
- `Icons.settings_outlined` - Settings pages

### **Education/Academic**
- `Icons.school_outlined` - Academic data, education
- `Icons.book_outlined` - Study materials, courses
- `Icons.quiz_outlined` - Tests, assessments

### **Health/Wellness**
- `Icons.psychology_outlined` - Mental health, brain wellness
- `Icons.favorite` - Heart health, physical wellness
- `Icons.spa` - Relaxation, stress relief
- `Icons.health_and_safety` - Overall health monitoring

### **Activity/Progress**
- `Icons.fitness_center` - Physical exercise
- `Icons.trending_up` - Progress tracking
- `Icons.emoji_objects` - Learning, ideas
- `Icons.self_improvement` - Personal development

## Page-Specific Recommendations

| Page Type | Recommended Icon | Size | Context |
|-----------|------------------|------|---------|
| Login | `account_circle_outlined` | 100 | User authentication |
| Admin Dashboard | `admin_panel_settings` | 100 | Administrative control |
| Student Dashboard | `psychology_outlined` | 120 | Wellness focus |
| Academic Forms | `school_outlined` | 40-60 | Educational context |
| Profile Pages | `person_outline` | 80-100 | Personal information |
| Settings | `settings_outlined` | 40-60 | Configuration |
| Health Tracking | `favorite` | 100 | Health monitoring |
| Study Pages | `book_outlined` | 60-80 | Learning materials |

This system ensures visual consistency while providing meaningful iconography that users can easily understand and associate with different app functions.