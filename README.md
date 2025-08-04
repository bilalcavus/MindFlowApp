# 🧠 Mind Flow

[![Flutter](https://img.shields.io/badge/Flutter-3.4.3+-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-green.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Localization](https://img.shields.io/badge/Localization-11%20Languages-orange.svg)](https://github.com/your-username/mind_flow)

> **AI-powered analysis and chat application**
> Transform your thoughts into insights with advanced AI analysis across multiple models

## 🌟 Features

### 🤖 **Multi-AI Model Support**
- **GPT-4.1 Nano** - Advanced reasoning and analysis
- **Gemini 2.0 Flash** - Fast and efficient processing
- **DeepSeek v3** - Specialized in deep analysis
- **Llama 3.3** - Open-source excellence
- **Mistral Models** - Balanced performance and speed
- **Automatic Fallback** - Seamless model switching

### 📊 **6 Analysis Types**
- **🧠 Dream Analysis** - Unlock subconscious meanings
- **😊 Emotion Analysis** - Understand your feelings
- **👤 Personality Analysis** - Discover your traits
- **💪 Habit Analysis** - Optimize daily routines
- **🧘 Mental Health Analysis** - Track mental wellness
- **😰 Stress Analysis** - Manage stress levels

### 💬 **AI Chatbot**
- **Real-time Conversations** - Instant AI support
- **Multiple Chat Types** - Mental health, career, creative, technical
- **Context-Aware** - Personalized responses
- **Conversation History** - Track your journey

### 🗺️ **Visual Insights**
- **Mind Maps** - Visual thought organization
- **Progress Tracking** - Monitor your growth
- **Detailed Reports** - Comprehensive analysis results
- **Interactive Charts** - Beautiful data visualization

### 🔒 **Privacy & Security**
- **Local Storage** - SQLite database for privacy
- **Firebase Authentication** - Secure user management
- **Data Encryption** - Your data stays private
- **Offline Capability** - Work without internet

### 🌍 **Global Support**
- **11 Languages** - English, Turkish, French, German, Arabic, Japanese, Korean, Indonesian, Thai, Vietnamese, Malay
- **RTL Support** - Arabic language support
- **Cultural Adaptation** - Localized content

## 📱 Screenshots



## 🚀 Quick Start

### Prerequisites
- **Flutter SDK** 3.4.3 or higher
- **Dart SDK** 3.4.3 or higher
- **Android Studio** / **VS Code**
- **OpenRouter API Key** (free tier available)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/bilalcavus/mind_flow.git
   cd mind_flow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   # Create environment file
   cp assets/config/.env.example assets/config/.env
   
   # Edit the file and add your API keys
   nano assets/config/.env
   ```

4. **Run the application**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d chrome
   ```

## ⚙️ Configuration

### Environment Variables

Create `assets/config/.env` file:

```env
# OpenRouter API (Required)
OPENROUTER_API_KEY=your_openrouter_api_key_here

# Groq API (Optional - for additional models)
GROQ_API_KEY=your_groq_api_key_here

# Together AI API (Optional - for additional models)
TOGETHER_API_KEY=your_together_api_key_here
```

### API Setup

1. **OpenRouter** (Primary)
   - Sign up at [OpenRouter](https://openrouter.ai)
   - Get your API key from dashboard
   - Free tier: 10,000 requests/month

2. **Groq** (Optional)
   - Sign up at [Groq](https://groq.com)
   - Get your API key
   - Free tier: 100 requests/day

3. **Together AI** (Optional)
   - Sign up at [Together AI](https://together.ai)
   - Get your API key
   - Free tier: 100 requests/day

## 🏗️ Architecture

```
lib/
├── core/                 # Core functionality
│   ├── constants/       # App constants
│   ├── error/          # Error handling
│   ├── helper/         # Utility functions
│   ├── mixins/         # Shared mixins
│   ├── services/       # Core services
│   └── theme/          # App theming
├── data/               # Data layer
│   ├── datasources/    # Data sources
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
├── domain/             # Business logic
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Use cases
├── presentation/       # UI layer
│   ├── view/          # UI screens
│   ├── viewmodel/     # State management
│   └── widgets/       # Reusable widgets
└── injection/         # Dependency injection
```

## 🛠️ Development

### Project Structure

- **Clean Architecture** - Separation of concerns
- **Provider Pattern** - State management
- **Repository Pattern** - Data abstraction
- **Dependency Injection** - Loose coupling

### Key Technologies

- **Flutter** - Cross-platform framework
- **Firebase** - Backend services
- **SQLite** - Local database
- **Provider** - State management
- **Easy Localization** - Multi-language support
- **Dio** - HTTP client
- **Fl Chart** - Data visualization

### Building for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## 📊 Analytics & Monitoring

- **Firebase Analytics** - User behavior tracking
- **Crashlytics** - Crash reporting
- **Performance Monitoring** - App performance
- **Remote Config** - Dynamic configuration

## 🔧 Troubleshooting

### Common Issues

1. **API Key Issues**
   ```bash
   # Check if .env file exists
   ls assets/config/.env
   
   # Verify API key format
   cat assets/config/.env
   ```

2. **Build Issues**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Platform-Specific Issues**
   ```bash
   # Android
   cd android && ./gradlew clean
   
   # iOS
   cd ios && pod install
   ```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Add tests** (if applicable)
5. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
6. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Development Guidelines

- Follow **Flutter conventions**
- Use **meaningful commit messages**
- Add **documentation** for new features
- Write **tests** for critical functionality
- Ensure **localization** for new strings

## 🙏 Acknowledgments

- **OpenRouter** - Multi-model AI API
- **Firebase** - Backend services
- **Flutter Team** - Amazing framework
- **OpenAI** - GPT models
- **Google** - Gemini models
- **Meta** - Llama models

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## Support

- **Email**: infomindflow1@gmail.com

<div align="center">

**Made with by the Mind Flow Team**

*Your AI-powered mental wellness companion* 🧠✨

</div>
