# 🪙 Robux Boost - Coin Earning Game App

אפליקציית Flutter מלאה לצבירת מטבעות וירטואליים דרך משחקים, משימות ופרסומות.

## ✨ תכונות עיקריות

### 🎮 6 משחקים מלאים
- **Spin Wheel** - גלגל מזל עם 8 פרסים
- **Scratch Card** - כרטיסי גירוד אינטראקטיביים
- **Tile Match** - משחק התאמת אריחים (Match-3)
- **Memory Match** - משחק זיכרון קלאסי
- **Plinko** - הפלת כדורים לפרסים
- **Rbux Clicker** - משחק לחיצות מהיר

### 💰 מערכות תגמול
- **Daily Rewards** - פרסים יומיים עם Streak
- **Video Dashboard** - צפייה בסרטונים להרוויח מטבעות
- **Trivia** - 10 שאלות טריוויה
- **Treasure Chest** - תיבת אוצר כל 3 שעות
- **Coin Vault** - הכנסה פסיבית עם שדרוגים
- **Invite Friends** - מערכת הפניות

### 📊 מערכות ניהול
- מערכת דרגות (Beginner → Diamond)
- מעקב Streak יומי
- 17 הישגים
- היסטוריית עסקאות
- סטטיסטיקות מפורטות

## 🚀 התקנה והרצה

### דרישות מקדימות
- Flutter SDK (3.9.2 ומעלה)
- Android Studio / VS Code
- Android SDK / iOS SDK

### שלבי התקנה

1. **שכפול הפרויקט**
```bash
cd D:\robux_boost
```

2. **התקנת תלויות**
```bash
flutter pub get
```

3. **הרצת האפליקציה**
```bash
flutter run
```

או עבור מכשיר ספציפי:
```bash
flutter run -d <device-id>
```

## 📁 מבנה הפרויקט

```
lib/
├── main.dart                 # נקודת כניסה ראשית
├── models/                   # מודלים
│   └── user_model.dart
├── services/                 # שירותים
│   ├── storage_service.dart
│   └── user_provider.dart
├── screens/                  # מסכים ראשיים
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── username_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── games_screen.dart
│   ├── earn_screen.dart
│   ├── wallet_screen.dart
│   └── profile_screen.dart
├── games/                    # משחקים
│   ├── spin_wheel_game.dart
│   ├── scratch_card_game.dart
│   ├── tile_match_game.dart
│   ├── memory_match_game.dart
│   ├── plinko_game.dart
│   └── rbux_clicker_game.dart
├── rewards/                  # מערכות תגמול
│   ├── daily_rewards_screen.dart
│   ├── video_dashboard_screen.dart
│   ├── trivia_screen.dart
│   ├── treasure_chest_screen.dart
│   ├── vault_screen.dart
│   └── invite_screen.dart
├── widgets/                  # רכיבים משותפים
│   ├── quick_earn_card.dart
│   ├── small_game_card.dart
│   ├── game_list_card.dart
│   └── earn_task_card.dart
└── utils/                    # כלי עזר
    └── constants.dart
```

## 🎨 עיצוב וצבעים

האפליקציה משתמשת בערכת צבעים כהה ומודרנית:
- **רקע כהה**: #0F0F1E
- **כרטיסים**: #1A1A2E
- **סגול**: #8B5CF6
- **זהב**: #F59E0B
- **ירוק**: #10B981

## 📦 תלויות עיקריות

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2      # אחסון מקומי
  google_mobile_ads: ^5.0.0       # פרסומות
  url_launcher: ^6.2.4            # פתיחת קישורים
  share_plus: ^7.2.2              # שיתוף
  confetti: ^0.7.0                # אנימציות
  flutter_fortune_wheel: ^1.3.1  # גלגל מזל
  scratcher: ^2.5.0               # כרטיסי גירוד
  percent_indicator: ^4.2.3       # אינדיקטורים
  intl: ^0.19.0                   # פורמט תאריכים
  provider: ^6.1.1                # ניהול מצב
```

## 🔧 הגדרות נוספות

### Android
ערוך את `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS
ערוך את `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🎯 תכונות מיוחדות

### מערכת Streak
- מעקב אחר ימים רצופים של כניסה
- איפוס אוטומטי אם לא נכנסים יום
- תצוגה בכל מקום באפליקציה

### מערכת דרגות
- **Beginner**: 0-499 מטבעות
- **Bronze**: 500-1,999 מטבעות
- **Silver**: 2,000-4,999 מטבעות
- **Gold**: 5,000-9,999 מטבעות
- **Diamond**: 10,000+ מטבעות

### אחסון נתונים
- כל הנתונים נשמרים מקומית ב-SharedPreferences
- אין צורך בשרת או חיבור אינטרנט (מלבד פרסומות)
- שמירה אוטומטית אחרי כל פעולה

## 🐛 פתרון בעיות

### בעיות התקנה
```bash
flutter clean
flutter pub get
```

### בעיות הרצה
```bash
flutter doctor
flutter run --verbose
```

## 📝 הערות חשובות

1. **פרסומות**: יש להגדיר Google AdMob App ID בקבצי ההגדרה
2. **תמונות**: יש להוסיף תמונות לתיקיית `assets/images/`
3. **אייקונים**: האפליקציה משתמשת באימוג'ים במקום תמונות

## 🚀 בניית APK

```bash
flutter build apk --release
```

הקובץ יימצא ב:
```
build/app/outputs/flutter-apk/app-release.apk
```

## 📱 תכונות נוספות לעתיד

- [ ] אינטגרציה מלאה של Google AdMob
- [ ] מערכת Leaderboard
- [ ] משחקים נוספים
- [ ] מערכת התראות
- [ ] תמיכה בשפות נוספות

## 👨‍💻 פיתוח

האפליקציה נבנתה עם:
- Flutter 3.9.2
- Dart 3.0+
- Provider לניהול מצב
- Material Design 3

## 📄 רישיון

פרויקט זה נוצר למטרות לימוד והדגמה.

---

**נוצר עם ❤️ באמצעות Flutter**
