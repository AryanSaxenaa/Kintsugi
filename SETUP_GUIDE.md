# 🚀 Kintsugi Setup Guide
**Complete Development Environment Setup for Samsung Washing Machine Diagnostic Assistant**

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Flutter Installation](#flutter-installation)
4. [Project Setup](#project-setup)
5. [IDE Configuration](#ide-configuration)
6. [Android Setup](#android-setup)
7. [Running the App](#running-the-app)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Configuration](#advanced-configuration)

---

## ⚡ Quick Start

**For experienced developers:**

```bash
# 1. Install Flutter 3.13.0+
# 2. Clone repository
git clone https://github.com/AryanSaxenaa/KintsugiNew.git
cd Kintsugi

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

**Demo Credentials:**
- Email: `user@demo.com`
- Password: `demo123`

---

## 📚 Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Operating System** | Windows 10, macOS 10.14, Linux 64-bit | Windows 11, macOS 12+, Ubuntu 20.04+ |
| **RAM** | 8GB | 16GB+ |
| **Storage** | 40GB free space | 100GB+ |
| **Internet** | Required for downloads | Stable connection |

### Required Software

- **Git** - Version control system
- **Android Studio** or **VS Code** - IDE
- **Flutter SDK** - 3.13.0 or higher
- **Android SDK** - API Level 21+

---

## 🎯 Flutter Installation

### Windows Installation

1. **Download Flutter SDK**
   - Visit [flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)
   - Download the latest stable Flutter SDK (3.13.0+)
   - Extract to `C:\flutter` (avoid paths with spaces)

2. **Add Flutter to PATH**
   ```powershell
   # Add to System Environment Variables
   # Variable: PATH
   # Value: C:\flutter\bin
   ```

3. **Verify Installation**
   ```powershell
   flutter --version
   flutter doctor
   ```

### macOS Installation

1. **Install using Homebrew (Recommended)**
   ```bash
   # Install Homebrew if not already installed
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install Flutter
   brew install --cask flutter
   ```

2. **Manual Installation**
   ```bash
   # Download and extract Flutter SDK
   cd ~/development
   unzip ~/Downloads/flutter_macos_3.13.0-stable.zip
   
   # Add to PATH in ~/.zshrc or ~/.bash_profile
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

### Linux Installation

```bash
# Download Flutter SDK
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.0-stable.tar.xz
tar xf flutter_linux_3.13.0-stable.tar.xz

# Add to PATH in ~/.bashrc
export PATH="$PATH:`pwd`/flutter/bin"

# Reload shell configuration
source ~/.bashrc
```

### Verify Flutter Installation

```bash
flutter doctor -v
```

**Expected Output:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.13.0, on [OS], locale en-US)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85)
[✓] Connected device (1 available)
[✓] Network resources
```

---

## 📱 Android Setup

### Install Android Studio

1. **Download Android Studio**
   - Visit [developer.android.com/studio](https://developer.android.com/studio)
   - Download the latest version
   - Install with default settings

2. **Install Android SDK**
   - Open Android Studio
   - Go to **File > Settings > Appearance & Behavior > System Settings > Android SDK**
   - Install the following:
     - **Android API 34** (latest)
     - **Android API 21** (minimum required)
     - **Android SDK Build-Tools 34.0.0**
     - **Android SDK Platform-Tools**

3. **Create Android Virtual Device (AVD)**
   - Open **AVD Manager** in Android Studio
   - Click **Create Virtual Device**
   - Select **Pixel 7** or similar modern device
   - Choose **API Level 34** system image
   - Configure with **4GB RAM** and **6GB internal storage**

### Accept Android Licenses

```bash
flutter doctor --android-licenses
```

Type `y` to accept all licenses.

---

## 🔧 Project Setup

### 1. Clone the Repository

```bash
# Using HTTPS
git clone https://github.com/AryanSaxenaa/KintsugiNew.git

# Using SSH (if configured)
git clone git@github.com:AryanSaxenaa/KintsugiNew.git

# Navigate to project directory
cd Kintsugi
```

### 2. Install Dependencies

```bash
# Install Flutter packages
flutter pub get

# Verify dependencies
flutter pub deps
```

### 3. Project Structure Verification

Ensure your project structure matches:

```
Kintsugi/
├── android/                 # Android platform files
├── assets/                  # App assets and images
│   └── app-images/         # Washing machine images
├── lib/                    # Dart source code
│   ├── main.dart          # App entry point
│   ├── screens/           # UI screens
│   └── services/          # Business logic
├── test/                  # Test files
├── pubspec.yaml          # Project configuration
└── README.md             # Documentation
```

### 4. Asset Configuration

Verify assets are properly configured in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/app-images/
```

---

## 💻 IDE Configuration

### Android Studio Setup

1. **Install Flutter Plugin**
   - Go to **File > Settings > Plugins**
   - Search for "Flutter" and install
   - Restart Android Studio

2. **Import Project**
   - **File > Open**
   - Select the `Kintsugi` folder
   - Wait for indexing to complete

3. **Configure Flutter SDK Path**
   - **File > Settings > Languages & Frameworks > Flutter**
   - Set Flutter SDK path (e.g., `C:\flutter` on Windows)

### VS Code Setup

1. **Install Extensions**
   ```bash
   # Install Flutter extension (includes Dart)
   code --install-extension Dart-Code.flutter
   
   # Optional: Useful extensions
   code --install-extension ms-vscode.vscode-json
   code --install-extension bradlc.vscode-tailwindcss
   ```

2. **Open Project**
   ```bash
   cd Kintsugi
   code .
   ```

3. **Configure Settings**
   Create `.vscode/settings.json`:
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.checkForSdkUpdates": false,
     "dart.previewFlutterUiGuides": true
   }
   ```

---

## 🚀 Running the App

### 1. Check Connected Devices

```bash
flutter devices
```

**Expected Output:**
```
2 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 14 (API 34) (emulator)
Chrome (web)                • chrome        • web-javascript • Google Chrome 120.0.6099.129
```

### 2. Start Android Emulator

**From Android Studio:**
- Open **AVD Manager**
- Click ▶️ next to your virtual device

**From Command Line:**
```bash
# List available emulators
flutter emulators

# Start specific emulator
flutter emulators --launch <emulator_id>
```

### 3. Run the Application

```bash
# Debug mode (default)
flutter run

# Release mode (optimized performance)
flutter run --release

# Specific device
flutter run -d <device_id>

# Hot reload during development
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
```

### 4. First App Launch

1. **Splash Screen** - Samsung branding with loading animation
2. **Onboarding** - Feature introduction with washing machine images
3. **Login Screen** - Use demo credentials:
   - Email: `user@demo.com`
   - Password: `demo123`
4. **Chat Interface** - Main diagnostic screen

---

## 🔍 Testing the App Features

### Chat Interface Testing

1. **Text Messages**
   - Type various washing machine issues
   - Verify chat bubbles display correctly

2. **Image Attachments**
   - Tap attachment button (📎)
   - Select "Camera" → Take a photo
   - Select "Gallery" → Choose existing image
   - Verify image compression (should be < 2MB)

3. **Audio Recording**
   - Tap attachment button (📎)
   - Select "Audio Recording"
   - Record washing machine sounds (5-30 seconds)
   - Verify WAV file creation

4. **Escalation System**
   - Tap escalation button (⚠️) in app bar
   - Fill out service request form
   - Submit and verify ticket generation

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. Flutter Doctor Issues

**Problem:** Red X marks in `flutter doctor`

**Solutions:**
```bash
# Android toolchain issues
flutter doctor --android-licenses

# VS Code issues
flutter config --enable-web

# Missing dependencies
flutter clean
flutter pub get
```

#### 2. Build Failures

**Problem:** Gradle build errors

**Solutions:**
```bash
# Clean and rebuild
flutter clean
cd android
./gradlew clean
cd ..
flutter run

# Update Gradle wrapper (if needed)
cd android
./gradlew wrapper --gradle-version=8.0
```

#### 3. Permission Issues

**Problem:** Audio/Camera not working

**Solutions:**
- Verify permissions in `android/app/src/main/AndroidManifest.xml`
- Grant permissions manually in device settings
- Test on physical device instead of emulator

#### 4. Emulator Issues

**Problem:** Emulator won't start or is slow

**Solutions:**
```bash
# Hardware acceleration (Windows)
# Enable Hyper-V in Windows Features

# Check emulator status
flutter emulators

# Cold boot emulator
flutter emulators --launch <emulator_id> --cold-boot
```

#### 5. Hot Reload Not Working

**Solutions:**
```bash
# Stop and restart
flutter run

# Clear build cache
flutter clean
flutter run
```

### Advanced Debugging

#### Enable Verbose Logging

```bash
flutter run --verbose
```

#### Check Specific Packages

```bash
# Check specific dependency
flutter pub deps --style=compact

# Upgrade packages
flutter pub upgrade --major-versions
```

#### Performance Analysis

```bash
# Run with performance overlay
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
```

---

## ⚙️ Advanced Configuration

### Custom Build Configurations

#### Debug Build with Custom Parameters

```bash
flutter run --debug --dart-define=API_BASE_URL=https://dev-api.kintsugi.com
```

#### Release Build Optimization

```bash
# Build optimized APK
flutter build apk --release --target-platform android-arm64

# Build App Bundle for Play Store
flutter build appbundle --release
```

### Performance Optimization

#### Enable R8 Code Shrinking (Android)

Add to `android/app/build.gradle`:

```gradle
android {
    buildTypes {
        release {
            shrinkResources true
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Testing Configuration

#### Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

#### Integration Tests

```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

---

## 📚 Additional Resources

### Official Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Android Developer Guide](https://developer.android.com/guide)

### Community Resources
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit - r/FlutterDev](https://www.reddit.com/r/FlutterDev/)

### Development Tools
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Firebase Console](https://console.firebase.google.com/)

---

## 🆘 Getting Help

### Project-Specific Support

1. **Check the Issues**: [GitHub Issues](https://github.com/AryanSaxenaa/KintsugiNew/issues)
2. **Create New Issue**: Use issue templates for bug reports or feature requests
3. **Contact Support**: [support@kintsugi.app](mailto:support@kintsugi.app)

### Flutter Community Support

1. **Flutter Discord**: [discord.gg/flutter](https://discord.gg/flutter)
2. **Flutter Slack**: Join the Flutter Slack workspace
3. **Stack Overflow**: Tag questions with `flutter` and `dart`

---

## ✅ Setup Checklist

### Before Development

- [ ] Flutter SDK 3.13.0+ installed and in PATH
- [ ] Android Studio installed with Flutter plugin
- [ ] Android SDK with API Level 21+ installed
- [ ] Android device/emulator configured and running
- [ ] `flutter doctor` shows all green checkmarks
- [ ] Project cloned and dependencies installed

### First Run Verification

- [ ] App launches without errors
- [ ] Splash screen displays correctly
- [ ] Onboarding screens work properly
- [ ] Login with demo credentials successful
- [ ] Chat interface is responsive
- [ ] Image attachments work (camera and gallery)
- [ ] Audio recording functions properly
- [ ] Escalation form submits successfully
- [ ] Navigation between screens is smooth

### Development Ready

- [ ] IDE configured with Flutter extensions
- [ ] Hot reload working
- [ ] Debugging tools accessible
- [ ] Code formatting and linting enabled
- [ ] Version control (Git) set up
- [ ] Test environment configured

---

**🎉 Congratulations!** You've successfully set up the Kintsugi development environment. You're now ready to contribute to the Samsung washing machine diagnostic assistant!

For any setup issues or questions, please refer to the troubleshooting section above or create an issue in the GitHub repository.

---

*Last updated: January 2025*
