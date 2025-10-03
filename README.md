# Kintsugi - Washing Machine Diagnostic App

<div align="center">
  <img src="assets/app-images/washing-machine.png" alt="Kintsugi Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com/)
</div>

## 📱 About

**Kintsugi** is an intelligent washing machine diagnostic application built with Flutter that helps users troubleshoot Samsung washing machine issues through an interactive chat interface. The name "Kintsugi" comes from the Japanese art of repairing broken pottery with gold, symbolizing how we help fix and improve washing machine problems.

### 🌟 Key Features

- **🤖 AI-Powered Chat Interface**: Interactive diagnostic conversations with intelligent responses
- **🎙️ Audio Recording**: Record washing machine sounds for audio-based diagnostics (WAV format)
- **📷 Image Attachments**: Capture and attach photos of washing machine issues with automatic compression
- **🚨 Escalation System**: Submit service requests with static ticket generation
- **🎨 Samsung Theme**: Beautiful Samsung blue (#1428A0) color scheme throughout the app
- **📱 Mobile-First Design**: Optimized for Android devices with responsive UI
- **🔊 Multimedia Support**: Handle images (PNG/JPG), audio (WAV), and text inputs

## 🏗️ Architecture

### Frontend (Flutter/Dart)
- **Framework**: Flutter 3.13.0+
- **Language**: Dart
- **UI Components**: Material Design with custom Samsung theming
- **State Management**: StatefulWidget with local state management
- **Navigation**: Flutter's built-in navigation system

### Core Screens
- `splash_screen.dart` - App startup and branding
- `onboarding_screen.dart` - User introduction and setup
- `login_screen.dart` - User authentication interface
- `chat_screen.dart` - Main diagnostic chat interface
- `escalation_screen.dart` - Service request submission

### Services
- `kintsugi_api_service.dart` - API communication service
- `escalation_service.dart` - Static escalation ticket management
- `audio_recorder_service.dart` - Audio recording functionality

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.6
  animated_splash_screen: ^1.3.0
  flutter_svg: ^2.0.7
  google_fonts: ^6.1.0
  provider: ^6.0.5
  http: ^1.1.0
  image_picker: ^1.0.4
  image: ^4.0.17
  flutter_sound: ^9.2.13
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
```

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.13.0 or higher)
- **Dart SDK** (3.1.0 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (API level 21 or higher)
- **Git** for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AryanSaxenaa/KintsugiNew.git
   cd Kintsugi
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup**
   ```bash
   flutter doctor
   ```

4. **Connect your Android device or start an emulator**

5. **Run the application**
   ```bash
   flutter run
   ```

### Demo Credentials
- **Email**: user@demo.com
- **Password**: demo123

### Android Permissions

The app requires the following permissions (automatically handled):
- `INTERNET` - For API communication
- `RECORD_AUDIO` - For audio recording functionality
- `CAMERA` - For taking photos
- `READ_EXTERNAL_STORAGE` - For accessing gallery images
- `WRITE_EXTERNAL_STORAGE` - For saving recorded audio files

## 🎯 Usage Guide

### 1. **Starting the App**
- Launch the app and go through the onboarding process
- Complete the login process with demo credentials
- You'll be taken to the main chat interface

### 2. **Chat Interface**
- Type messages to describe washing machine issues
- Use the attachment button (📎) to access multimedia options:
  - **Camera**: Take photos of the washing machine
  - **Gallery**: Select existing images
  - **Audio Recording**: Record machine sounds for diagnosis

### 3. **Audio Recording**
- Tap the recording option in the attachment menu
- Record washing machine sounds (optimal: 5-30 seconds)
- Stop recording when done - files are saved in WAV format

### 4. **Image Attachments**
- Images are automatically compressed to under 2MB
- Supports PNG and JPG formats
- Perfect for showing error codes, machine conditions, or problem areas

### 5. **Escalation System**
- Tap the escalation button (⚠️) in the app bar
- Fill out the service request form:
  - Issue description
  - Customer information
  - Model number
  - Priority level (Critical, High, Medium, Low)
  - Service center selection
  - Additional requirements
- Submit to generate a static ticket ID

## 🔧 Technical Details

### Image Processing
- **Compression**: Automatic compression to ensure files stay under 2MB
- **Format Conversion**: All images converted to PNG for API compatibility
- **Quality Optimization**: Maintains visual quality while reducing file size

### Audio Recording
- **Format**: WAV (16kHz, mono, PCM16)
- **Duration**: Configurable recording length
- **Storage**: Temporary files with automatic cleanup
- **Permissions**: Runtime microphone permission handling

### API Integration
- **HTTP Client**: Custom service for API communication
- **Timeout Handling**: 5-minute timeout for all requests
- **Error Management**: Comprehensive error handling and user feedback
- **Response Parsing**: JSON response processing with fallback handling

### Static Escalation System
- **Ticket Generation**: Local ticket ID generation with timestamp
- **Form Validation**: Comprehensive input validation
- **Priority Levels**: Critical, High, Medium, Low
- **No Database**: Self-contained system without external database dependencies

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── chat_screen.dart
│   └── escalation_screen.dart
├── services/                 # Business logic services
│   ├── kintsugi_api_service.dart
│   ├── escalation_service.dart
│   └── audio_recorder_service.dart
└── assets/
    └── app-images/           # App assets and images
        ├── washing-machine.png
        ├── washing-machine.gif
        └── [other assets]
```

## 🎨 Design System

### Color Scheme
- **Primary**: Samsung Blue (#1428A0)
- **Background**: White (#FFFFFF)
- **Text**: Dark Gray (#333333)
- **Accent**: Light Blue variations

### Typography
- **Font Family**: Google Fonts integration
- **Headings**: Bold, Sans-serif
- **Body Text**: Regular, readable font sizes
- **UI Elements**: Consistent sizing and spacing

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Manual Testing Checklist
- [ ] App launches successfully
- [ ] Chat interface responds correctly
- [ ] Image attachment and compression works
- [ ] Audio recording functions properly
- [ ] Escalation form submission works
- [ ] Navigation between screens is smooth
- [ ] Permissions are requested appropriately

## 📦 Build and Deployment

### Development Build
```bash
flutter run --debug
```

### Release Build
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### Build Outputs
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## 🐛 Troubleshooting

### Common Issues

**1. Flutter Doctor Issues**
```bash
flutter doctor
# Follow the recommendations to fix any issues
```

**2. Dependency Conflicts**
```bash
flutter clean
flutter pub get
```

**3. Android Build Errors**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**4. Audio Recording Permission Issues**
- Ensure microphone permissions are granted
- Check device audio recording capabilities
- Verify audio file paths and storage permissions

**5. Image Compression Issues**
- Verify image file formats (PNG/JPG supported)
- Check available storage space
- Ensure proper image picker permissions

## 🔬 Integrated AI Backends

Kintsugi integrates four AI services to power advanced diagnostics:  
- **RAG Samsung Manual Chatbot** (document QA)  
- **Multi-Modal Orchestrator** (text/image/audio handling)  
- **Image Color Classifier** (visual rust/zinc detection)  
- **Hierarchical Audio Classifier** (washing machine sound anomaly detection)

---


### 📊 Architecture at a Glance

<table>
  <tr>
    <td align="center" width="50%">
      <img src="assets/app-images/connections.jpg" alt="Kintsugi App Architecture" width="100%"><br/>
      <sub><b>Kintsugi App Architecture</b><br/>Flutter Frontend + AI Service Integration</sub>
    </td>
    <td align="center" width="50%">
      <img src="assets/app-images/screenshot.jpg" alt="Multi-Modal Orchestrator" width="100%"><br/>
      <sub><b>Multi-Modal Orchestrator</b><br/>Text / Image / Audio Routing + Groq Summaries</sub>
    </td>
  </tr>
</table>


---

### 1. RAG Samsung Manual Chatbot

<p align="center">
  <img src="assets/app-images/rag_manual.png" alt="RAG Samsung Manual Chatbot architecture" width="800">
</p>

- **Input:** User query (text)  
- **Retriever:** ChromaDB (k=2 chunks per query)  
- **Embeddings:** `all-MiniLM-L6-v2` (Sentence Transformers)  
- **LLM Generator:** `flan-t5-base` (Hugging Face pipeline)  
- **Memory:** Conversational buffer for multi-turn Q&A  
- **Use case:** Ask questions like *“How do I reset my Samsung washing machine?”* and get grounded answers directly from the manual.


[Check out the model](https://huggingface.co/spaces/Anvit25/LLM_chatbot2)

---

### 2. Multi-Modal Orchestrator

<p align="center">
  <img src="assets/app-images/multimodal_orchestrator.png" alt="Multi-Modal Orchestrator flow" width="800">
</p>

- **Intent Classification:** Rule-based (`intents.json`)  
  - `"chat"` → Send to chatbot client  
  - `"search_local_image"` → Run semantic image search  
  - `"request_image_analysis"` → Vision client + Groq summary  
  - `"request_audio_analysis"` → Audio client + Groq summary  
- **Semantic Image Search:** Embeddings + cosine similarity (threshold 0.4)  
- **Image/Audio Analysis:** AI models → JSON → Summarized by Groq (Llama-3.3-70B)  
- **Conversation Management:** Maintains chat history across text, image, audio

[Check out the model](https://huggingface.co/spaces/Anvit25/Orchestrator_final)


---

### 3. Image Color Classifier

<p align="center">
  <img src="assets/app-images/image_color_classifier.png" alt="Image Color Classifier pipeline" width="800">
</p>

- **Pipeline:**  
  1. Input image → convert to Lab color space  
  2. Compute medians (a*, b*) → thresholds with Δ=6.0  
  3. Ratios:  
     - `rustish_ratio = mean(a* > a_thr)`  
     - `zincish_ratio = mean(b* > b_thr)`  
  4. Rule-based classification:  
     - zinc > threshold → **Zinc**  
     - rust > threshold → **Rust**  
     - else → **Normal**  
- **Extras:** K-Means palette (k=3) for dominant colors  
- **Output:** JSON with class label, ratios, and palette


[Check out the model](https://huggingface.co/spaces/Anvit25/vision-classifier)

---

### 4. Hierarchical Audio Classifier

<p align="center">
  <img src="assets/app-images/audio_classifier.png" alt="Hierarchical Audio Classifier stages" width="800">
</p>

- **Stage 1 (Coarse):** Normal vs Abnormal detection (CNN on spectrograms)  
- **Stage 2 (Fine):**  
  - If Normal → classify mode (Wash, Spin, etc.)  
  - If Abnormal → classify anomaly (e.g., Bearing noise, Dehydration noise)  
- **Preprocessing:**  
  - .wav audio → log-Mel spectrogram (224×224)  
  - Params: sr=22050, n_fft=2048, hop=512, n_mels=128  
- **Architecture:**  
  - CNN backbone (Conv2D + ReLU + MaxPooling ×3 → Dense → Dropout → Softmax)  
- **Artifacts:**  
  - `stage1_model.h5`  
  - `normal_model.h5`  
  - `abnormal_model.h5`  
  - `label_meta.json` (class mapping)

[Check out the model](https://huggingface.co/spaces/Anvit25/new_audio)

---




## 🔄 Version History

### v1.0.0 (Current)
- ✅ Initial release with full chat functionality
- ✅ Audio recording with WAV format support
- ✅ Image attachments with automatic compression
- ✅ Static escalation system
- ✅ Samsung-themed UI design
- ✅ Android platform support

### Planned Features
- 🔮 Speech-to-text integration
- 🔮 Enhanced AI diagnostic capabilities
- 🔮 Real-time database integration
- 🔮 Push notifications for service updates
- 🔮 Multi-language support
- 🔮 iOS platform support

## 🤝 Contributing

We welcome contributions to improve Kintsugi! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Dart/Flutter coding standards
- Add tests for new features
- Update documentation as needed
- Ensure responsive design principles
- Maintain consistent UI/UX patterns

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, please contact:
- **Email**: [support@kintsugi.app](mailto:support@kintsugi.app)
- **GitHub Issues**: [Create an issue](https://github.com/AryanSaxenaa/KintsugiNew/issues)
- **Documentation**: [Wiki](https://github.com/AryanSaxenaa/KintsugiNew/wiki)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Samsung for design inspiration
- Open source community for valuable packages
- Contributors and testers

---

## 📋 Submissions

### 📹 Video Demonstrations

- **App Demo Video**: [Add URL here]
- **Feature Walkthrough**: [Add URL here]
- **Technical Overview**: [Add URL here]

### 📚 Additional Resources

- **Live Demo**: [Add URL here]
- **Presentation Slides**: [Add URL here]

### 🔗 Repository Links
- **Main Repository**: [https://github.com/AryanSaxenaa/KintsugiNew](https://github.com/AryanSaxenaa/KintsugiNew)
- **Release Page**: [Add URL here]
- **Issues & Bug Reports**: [https://github.com/AryanSaxenaa/KintsugiNew/issues](https://github.com/AryanSaxenaa/KintsugiNew/issues)

---

<div align="center">
  <p>Made with ❤️ for Samsung washing machine users worldwide</p>
  <p><strong>Kintsugi - Fixing what's broken, making it beautiful</strong></p>
</div>

## Note
This is a frontend-only implementation. No backend or actual AI integration is included yet. The escalation system generates demo ticket IDs and simulates service center communication.
