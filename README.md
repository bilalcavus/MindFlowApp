# Mind Flow

AI-powered personal analysis and chat application using multiple AI models through OpenRouter API.

## Features

- **Multi-AI Support**: GPT-4.1 Nano, Gemini 2.0 Flash, DeepSeek v3, Llama 4, Mistral models
- **6 Analysis Types**: Emotion, Mental Health, Dream, Personality, Habit, Stress analysis
- **AI Chatbot**: Real-time supportive conversations
- **Mind Maps**: Visual thought organization
- **Local Storage**: SQLite database for privacy
- **Cross-Platform**: Android, iOS, Web, Windows, macOS, Linux


## Setup

### Requirements
- Flutter SDK 3.4.3+
- OpenRouter API key

### Installation

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd mind_flow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Create environment file**
   ```bash
   # Create assets/config/.env
   echo "OPENROUTER_API_KEY=your_api_key_here" > assets/config/.env
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## API Configuration

1. Sign up at [OpenRouter](https://openrouter.ai)
2. Get your API key
3. Add to `assets/config/.env`:
   ```env
   OPENROUTER_API_KEY=your_openrouter_api_key_here
   ```
## Contributing

1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

MIT License

---

**Mind Flow** - Your AI-powered mental wellness companion 🧠✨
