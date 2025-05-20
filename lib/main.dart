import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'screens/add_dream_screen.dart';
import 'screens/dream_detail_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/profile_screen.dart';
import 'models/audio_recording.dart';

part 'main.g.dart';

@HiveType(typeId: 0)
class Dream {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  DateTime date;
  
  @HiveField(4)
  List<String> tags;

  @HiveField(5)
  AudioRecording? audio;

  @HiveField(6)
  String? notes;

  Dream({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.tags,
    this.audio,
    this.notes,
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Hive.initFlutter(); // Web doesn't need a directory
  } else {
    final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDirectory.path);
  }
  Hive.registerAdapter(DreamAdapter());
  await Hive.openBox<Dream>('dreams');
  runApp(
    const DynamicColorApp(),
  );
}

class DynamicColorApp extends StatelessWidget {
  const DynamicColorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return DreamJournalApp(
          darkDynamic: darkDynamic,
        );
      },
    );
  }
}

class DreamJournalApp extends StatelessWidget {
  final ColorScheme? darkDynamic;
  const DreamJournalApp({Key? key, this.darkDynamic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData buildDreamTheme({
      required ColorScheme colorScheme,
      required Color scaffoldBackgroundColor,
      required Color cardColor,
      required Color appBarBackground,
      required Color? unselectedNavColor,
      Color iconColor = Colors.white,
    }) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        iconTheme: const IconThemeData(color: Colors.white),
        primaryIconTheme: const IconThemeData(color: Colors.white),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        cardColor: cardColor,
        colorScheme: colorScheme,
        textTheme: GoogleFonts.montserratTextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: appBarBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: iconColor),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            elevation: 2,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: appBarBackground,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: cardColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    const Color scaffoldBg = Color(0xff1c2331);
    const Color cardClr = Color(0x4d3f729b);
    const Color appBarBg = Color(0xff1c2331);
    final ColorScheme darkScheme = (darkDynamic ?? const ColorScheme.dark()).copyWith(
      primary: const Color(0xff3f729b),
      secondary: const Color(0xff3f729b),    
    );

    return MaterialApp(
      title: 'Dream Journal',
      darkTheme: buildDreamTheme(
        colorScheme: darkScheme,
        scaffoldBackgroundColor: scaffoldBg,
        cardColor: cardClr,
        appBarBackground: appBarBg,
        unselectedNavColor: Colors.grey[700],
      ),
      home: const MainNavScreen(),
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const DreamListScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey[400],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.insights,
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey[400],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 2
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey[400],
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class DreamListScreen extends StatefulWidget {
  const DreamListScreen({Key? key}) : super(key: key);

  @override
  _DreamListScreenState createState() => _DreamListScreenState();
}

class _DreamListScreenState extends State<DreamListScreen> {
  String _getPreviewLines(String text, int maxLines) {
    final lines = text.split(RegExp(r'\r?\n'));
    if (lines.length <= maxLines) return text;
    return '${lines.take(maxLines).join("\n")}...';
  }

  late Box<Dream> _dreamBox;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dreamBox = Hive.box<Dream>('dreams');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Dream> _filterDreams(List<Dream> dreams) {
    if (_searchQuery.isEmpty) {
      return dreams;
    }
    
    final query = _searchQuery.toLowerCase();
    return dreams.where((dream) {
      return dream.title.toLowerCase().contains(query) ||
             dream.description.toLowerCase().contains(query) ||
             dream.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Journal'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search dreams by title, content or tags',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _dreamBox.listenable(),
        builder: (context, Box<Dream> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No dreams recorded yet. Add your first dream!'),
            );
          }
          
          final allDreams = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          
          final filteredDreams = _filterDreams(allDreams);
          
          if (filteredDreams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No dreams match your search: "$_searchQuery"',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredDreams.length,
            itemBuilder: (context, index) {
              final dream = filteredDreams[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 4),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(dream.date),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  //General settings for car elements
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: ListTile(
                      title: Text(
                        dream.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            _getPreviewLines(dream.description, 5),
                            textAlign: TextAlign.justify,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.4)
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DreamDetailScreen(dream: dream),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDreamScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
