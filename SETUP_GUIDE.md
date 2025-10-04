# Kintsugi Development Environment Setup Guide
**Complete Development Environment Configuration for Samsung Washing Machine Diagnostic Assistant**

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Flutter Installation](#flutter-installation)
4. [Project Setup](#project-setup)
5. [IDE Configuration](#ide-configuration)
6. [Android Setup](#android-setup)
7. [Running the Application](#running-the-application)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Configuration](#advanced-configuration)

---

## Quick Start

**For experienced developers with existing Flutter development environments:**

```bash
# 1. Install Flutter 3.13.0 or higher
# 2. Clone the repository
git clone https://github.com/AryanSaxenaa/KintsugiNew.git
cd Kintsugi

# 3. Install project dependencies
flutter pub get

# 4. Execute the application
flutter run
```

**Demonstration Credentials:**
- Email Address: `user@demo.com`
- Password: `demo123`

---

## Prerequisites

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

## Flutter Installation

### Windows Installation

1. **Download Flutter SDK**
   - Navigate to [flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)
   - Download the latest stable Flutter SDK (version 3.13.0 or higher)
   - Extract to `C:\flutter` (avoid directory paths containing spaces)

2. **Configure Flutter PATH Environment Variable**
   ```powershell
   # Add to System Environment Variables
   # Variable Name: PATH
   # Variable Value: C:\flutter\bin
   ```

3. **Verify Installation**
   ```powershell
   flutter --version
   flutter doctor
   ```

### macOS Installation

1. **Installation using Homebrew (Recommended Method)**
   ```bash
   # Install Homebrew if not already installed
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install Flutter
   brew install --cask flutter
   ```

2. **Manual Installation Procedure**
   ```bash
   # Download and extract Flutter SDK
   cd ~/development
   unzip ~/Downloads/flutter_macos_3.13.0-stable.zip
   
   # Configure PATH in ~/.zshrc or ~/.bash_profile
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

### Linux Installation

```bash
# Download Flutter SDK
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.0-stable.tar.xz
tar xf flutter_linux_3.13.0-stable.tar.xz

# Configure PATH in ~/.bashrc
export PATH="$PATH:`pwd`/flutter/bin"

# Reload shell configuration
source ~/.bashrc
```

### Flutter Installation Verification

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

## Android Development Environment Setup

### Android Studio Installation

1. **Download Android Studio**
   - Navigate to [developer.android.com/studio](https://developer.android.com/studio)
   - Download the latest stable version
   - Install using default configuration settings

2. **Android SDK Installation**
   - Launch Android Studio
   - Navigate to **File > Settings > Appearance & Behavior > System Settings > Android SDK**
   - Install the following components:
     - **Android API 34** (latest stable version)
     - **Android API 21** (minimum required version)
     - **Android SDK Build-Tools 34.0.0**
     - **Android SDK Platform-Tools**

3. **Android Virtual Device (AVD) Configuration**
   - Open **AVD Manager** in Android Studio
   - Select **Create Virtual Device**
   - Choose **Pixel 7** or equivalent modern device profile
   - Select **API Level 34** system image
   - Configure device with **4GB RAM** and **6GB internal storage**

### Android License Acceptance

```bash
flutter doctor --android-licenses
```

Type `y` to accept all required licenses.

---

## Project Setup and Configuration

### 1. Repository Cloning

```bash
# Using HTTPS protocol
git clone https://github.com/AryanSaxenaa/KintsugiNew.git

# Using SSH protocol (if configured)
git clone git@github.com:AryanSaxenaa/KintsugiNew.git

# Navigate to project directory
cd Kintsugi
```

### 2. Dependency Installation

```bash
# Install Flutter packages
flutter pub get

# Verify dependency installation
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

## Integrated Development Environment Configuration

### Android Studio Configuration

1. **Flutter Plugin Installation**
   - Navigate to **File > Settings > Plugins**
   - Search for "Flutter" and install the plugin
   - Restart Android Studio to complete installation

2. **Project Import**
   - Select **File > Open**
   - Choose the `Kintsugi` project folder
   - Wait for project indexing to complete

3. **Flutter SDK Path Configuration**
   - Navigate to **File > Settings > Languages & Frameworks > Flutter**
   - Configure Flutter SDK path (e.g., `C:\flutter` on Windows)

### Visual Studio Code Configuration

1. **Required Extension Installation**
   ```bash
   # Install Flutter extension (includes Dart support)
   code --install-extension Dart-Code.flutter
   
   # Optional: Additional useful extensions
   code --install-extension ms-vscode.vscode-json
   code --install-extension bradlc.vscode-tailwindcss
   ```

2. **Project Opening**
   ```bash
   cd Kintsugi
   code .
   ```

3. **Workspace Settings Configuration**
   Create `.vscode/settings.json`:
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.checkForSdkUpdates": false,
     "dart.previewFlutterUiGuides": true
   }
   ```

---

## Application Execution

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

**From Command Line Interface:**
```bash
# List available emulator configurations
flutter emulators

# Launch specific emulator instance
flutter emulators --launch <emulator_id>
```

### 3. Application Execution

```bash
# Debug mode (default configuration)
flutter run

# Release mode (optimized performance)
flutter run --release

# Target specific device
flutter run -d <device_id>

# Hot reload during development
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
```

### 4. Initial Application Launch Sequence

1. **Splash Screen** - Samsung branding with loading animation
2. **Onboarding Process** - Feature introduction with washing machine imagery
3. **Authentication Screen** - Use demonstration credentials:
   - Email: `user@demo.com`
   - Password: `demo123`
4. **Chat Interface** - Primary diagnostic interaction screen

---

## Application Feature Testing

### Chat Interface Verification

1. **Text Message Functionality**
   - Input various washing machine operational issues
   - Verify chat bubble display formatting

2. **Image Attachment Capabilities**
   - Access attachment functionality
   - Select "Camera" option and capture a photograph
   - Select "Gallery" option and choose existing image
   - Verify image compression (file size should be < 2MB)

3. **Audio Recording Functionality**
   - Access attachment functionality
   - Select "Audio Recording" option
   - Record washing machine operational sounds (recommended duration: 5-30 seconds)
   - Verify WAV file creation and storage

4. **Escalation System Verification**
   - Access escalation functionality in application toolbar
   - Complete service request form with required information
   - Submit form and verify ticket generation

---

## Troubleshooting and Problem Resolution

### Common Issues and Resolution Procedures

#### 1. Flutter Doctor Configuration Issues

**Problem Description:** Red X indicators in `flutter doctor` output

**Resolution Procedures:**
```bash
# Android toolchain configuration issues
flutter doctor --android-licenses

# Web development configuration issues
flutter config --enable-web

# Missing dependency resolution
flutter clean
flutter pub get
```

#### 2. Build Process Failures

**Problem Description:** Gradle build error occurrences

**Resolution Procedures:**
```bash
# Clean and rebuild project
flutter clean
cd android
./gradlew clean
cd ..
flutter run

# Update Gradle wrapper (if necessary)
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
# Check specific dependency status
flutter pub deps --style=compact

# Upgrade package versions
flutter pub upgrade --major-versions
```

#### Performance Analysis Procedures

```bash
# Execute with performance overlay
flutter run --profile

# Analyze application size metrics
flutter build apk --analyze-size
```

---

## Advanced Configuration Options

### Custom Build Configuration

#### Debug Build with Custom Parameters

```bash
flutter run --debug --dart-define=API_BASE_URL=https://dev-api.kintsugi.com
```

#### Release Build Optimization Procedures

```bash
# Build optimized APK for specific architecture
flutter build apk --release --target-platform android-arm64

# Build App Bundle for Google Play Store distribution
flutter build appbundle --release
```

### Performance Optimization Configuration

#### Enable R8 Code Shrinking (Android Platform)

Add the following configuration to `android/app/build.gradle`:

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

## Additional Resources and Documentation

### Official Documentation Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Android Developer Guide](https://developer.android.com/guide)

### Community Resources and Support
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit - r/FlutterDev](https://www.reddit.com/r/FlutterDev/)

### Development Tools and Utilities
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Firebase Console](https://console.firebase.google.com/)

---

## Technical Support and Assistance

### Project-Specific Support Resources

1. **Review Existing Issues**: [GitHub Issues Repository](https://github.com/AryanSaxenaa/KintsugiNew/issues)
2. **Submit New Issues**: Utilize issue templates for bug reports or feature requests
3. **Direct Support Contact**: [support@kintsugi.app](mailto:support@kintsugi.app)

### Flutter Community Support Resources

1. **Flutter Discord Community**: [discord.gg/flutter](https://discord.gg/flutter)
2. **Flutter Slack Workspace**: Join the official Flutter Slack workspace
3. **Stack Overflow**: Tag questions with `flutter` and `dart` for community assistance

---

## Setup Verification Checklist

### Pre-Development Requirements

- [ ] Flutter SDK version 3.13.0 or higher installed and configured in PATH
- [ ] Android Studio installed with Flutter plugin integration
- [ ] Android SDK with API Level 21 or higher installed
- [ ] Android device or emulator configured and operational
- [ ] `flutter doctor` command returns all green checkmarks
- [ ] Project repository cloned and dependencies installed

### Initial Application Verification

- [ ] Application launches without error conditions
- [ ] Splash screen displays correctly with proper formatting
- [ ] Onboarding screens function properly
- [ ] Authentication with demonstration credentials successful
- [ ] Chat interface responds appropriately to user input
- [ ] Image attachment functionality operational (camera and gallery access)
- [ ] Audio recording functionality operates correctly
- [ ] Escalation form submission processes successfully
- [ ] Navigation between application screens operates smoothly

### Development Environment Readiness

- [ ] IDE configured with appropriate Flutter extensions
- [ ] Hot reload functionality operational
- [ ] Debugging tools accessible and functional
- [ ] Code formatting and linting enabled
- [ ] Version control (Git) configured properly
- [ ] Test environment configured and operational

---

**Congratulations!** You have successfully configured the Kintsugi development environment. The system is now ready for contribution to the Samsung washing machine diagnostic assistant project.

For any configuration issues or technical questions, please refer to the troubleshooting section above or submit an issue in the GitHub repository.

---

*Document last updated: October 2025*
