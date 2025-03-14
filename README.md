# AI Note

[![English](https://img.shields.io/badge/Language-English-blue)](#) [![Tiếng Việt](https://img.shields.io/badge/Language-Tiếng%20Việt-green)](README.vi.md)

A modern note-taking application with AI-powered summarization using Google Gemini.


## Features

- ✏️ Create, edit, and organize notes with Markdown support
- 🔍 Full-text search across all your notes
- 🏷️ Tag notes for better organization
- 🌓 Light and dark mode support
- 🤖 AI-powered summary generation using Google Gemini
- 🔑 Keywords extraction from note content
- 💻 Cross-platform support (Windows, Android, iOS)

## Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Google Gemini API key

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/ai-note.git
cd ai-note
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### API Key Setup

To use the AI summarization features, you need a Google Gemini API key:

1. Visit [Google AI Studio](https://ai.google.dev/)
2. Create an account if you don't have one
3. Navigate to "API keys" section
4. Create a new API key
5. Enter the key in the app's settings

## Using AI Note

### Creating Notes

- Tap the '+' button to create a new note
- Add a title and content
- Use the markdown toolbar for formatting
- Save by pressing the check icon

### Generating Summaries

- Open a note
- Tap on the magic wand icon
- The AI will generate a summary based on your note content
- View the summary in the Summary tab

### Managing Tags

- Use the 'Manage Tags' option in the note menu
- Add new tags to organize your notes
- Filter notes by tags from the home screen

## Technical Details

The application is built using the following technologies:

- **Flutter**: UI framework
- **Provider**: State management
- **SQLite**: Local database storage
- **Google Gemini API**: AI-powered text summarization
- **Flutter Markdown**: Markdown rendering

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Google Gemini for AI capabilities
- Flutter team for the amazing framework
- All contributors to open-source packages used in this project

---

*Looking for this document in another language? See [Tiếng Việt](README.vi.md)*
