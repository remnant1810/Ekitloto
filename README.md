# Dream Journal

A beautiful and feature-rich Flutter application for recording and managing your dreams. This app allows you to create, edit, and organize your dream entries with ease.

## Features

- 📝 Create and manage dream entries
- 🗓️ Calendar view for tracking dreams
- 🎨 Customizable appearance with themes
- 🎙️ Record and attach audio notes to dreams
- 📊 Export dreams as PDF
- 🔍 Search and filter your dream entries
- 🔒 Local storage with Hive for data persistence

## Screenshots

*Screenshots coming soon*

## Getting Started

### Prerequisites

- Flutter SDK (>= 2.19.0)
- Dart SDK (>= 2.19.0)
- Android Studio / Xcode (for building to mobile devices)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dream_journal.git
   cd dream_journal
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate necessary files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle
```

### iOS
```bash
flutter build ios --release
```

## Dependencies

- [Hive](https://pub.dev/packages/hive) - Fast, lightweight database
- [Provider](https://pub.dev/packages/provider) - State management
- [Table Calendar](https://pub.dev/packages/table_calendar) - Calendar widget
- [PDF](https://pub.dev/packages/pdf) - PDF generation
- [Audio Players](https://pub.dev/packages/audioplayers) - Audio recording and playback
- [Record](https://pub.dev/packages/record) - Audio recording
- [Google Fonts](https://pub.dev/packages/google_fonts) - Custom fonts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with ❤️ using Flutter
- Icons by [Flutter Icons](https://pub.dev/packages/cupertino_icons)
