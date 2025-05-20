import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  int _entriesThisYear(List<Dream> dreams) {
    final now = DateTime.now();
    return dreams.where((d) => d.date.year == now.year).length;
  }

  int _totalEntries(List<Dream> dreams) => dreams.length;

  int _longestStreak(List<Dream> dreams) {
    if (dreams.isEmpty) return 0;
    final dates = dreams.map((d) => DateTime(d.date.year, d.date.month, d.date.day)).toSet().toList();
    dates.sort();
    int longest = 1, current = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontFamily: 'Montserrat')),
        backgroundColor: const Color(0xff1c2331),
      ),
      body: FutureBuilder<Box<Dream>>(
        future: Hive.isBoxOpen('dreams') ? Future.value(Hive.box<Dream>('dreams')) : Hive.openBox<Dream>('dreams'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final box = snapshot.data!;
          final dreams = box.values.toList();
          final entriesThisYear = _entriesThisYear(dreams);
          final totalEntries = _totalEntries(dreams);
          final longestStreak = _longestStreak(dreams);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Table(
                    border: null,
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          _StatCellRedesigned(
                            icon: Icons.calendar_today,
                            value: entriesThisYear.toString(),
                            description: 'entries this year',
                          ),
                          _StatCellRedesigned(
                            icon: Icons.whatshot,
                            value: longestStreak.toString(),
                            description: 'longest streak',
                          ),
                          _StatCellRedesigned(
                            icon: Icons.format_list_numbered,
                            value: totalEntries.toString(),
                            description: 'total entries',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CalendarHeatMap(dreams: dreams),
                  const SizedBox(height: 32),
                  TagTracker(dreams: dreams),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalendarHeatMap extends StatefulWidget {
  final List<Dream> dreams;
  const CalendarHeatMap({Key? key, required this.dreams}) : super(key: key);

  @override
  State<CalendarHeatMap> createState() => _CalendarHeatMapState();
}

class _CalendarHeatMapState extends State<CalendarHeatMap> {
  late final Map<DateTime, int> _entryCounts;
  late final DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _entryCounts = {};
    for (final dream in widget.dreams) {
      final date = DateTime(dream.date.year, dream.date.month, dream.date.day);
      _entryCounts[date] = (_entryCounts[date] ?? 0) + 1;
    }
  }

  Color _dotColor(int count, BuildContext context, DateTime date) {
    const Color accentColor = Color(0xff3f729b);
    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    if (isToday) return accentColor;
    const Color lightBlue = Color(0xFF90CAF9);
    if (count >= 5) return lightBlue.withOpacity(1.0);
    if (count == 4) return lightBlue.withOpacity(0.8);
    if (count == 3) return lightBlue.withOpacity(0.6);
    if (count == 2) return lightBlue.withOpacity(0.4);
    if (count == 1) return lightBlue.withOpacity(0.2);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(DateTime.now().year - 1, 1, 1),
      lastDay: DateTime(DateTime.now().year + 1, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final count = _entryCounts[DateTime(day.year, day.month, day.day)] ?? 0;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 6,
                child: count > 0
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _dotColor(count, context, day),
                          shape: BoxShape.circle,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          );
        },
      ),
      daysOfWeekVisible: true,
      availableGestures: AvailableGestures.horizontalSwipe,
      shouldFillViewport: false,
      rowHeight: 40,
    );
  }
}

class TagTracker extends StatefulWidget {
  final List<Dream> dreams;
  const TagTracker({Key? key, required this.dreams}) : super(key: key);

  @override
  State<TagTracker> createState() => _TagTrackerState();
}

enum TagTimeFilter { month, year, all }

class _TagTrackerState extends State<TagTracker> {
  TagTimeFilter _filter = TagTimeFilter.month;

  Map<String, int> _getTagCounts() {
    DateTime now = DateTime.now();
    Iterable<Dream> filtered = widget.dreams;
    if (_filter == TagTimeFilter.month) {
      filtered = filtered.where((d) => d.date.year == now.year && d.date.month == now.month);
    } else if (_filter == TagTimeFilter.year) {
      filtered = filtered.where((d) => d.date.year == now.year);
    }
    final tags = filtered.expand((d) => d.tags);
    final Map<String, int> tagCounts = {};
    for (final tag in tags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }
    return tagCounts;
  }

  @override
  Widget build(BuildContext context) {
    final tagCounts = _getTagCounts();
    final sortedTags = tagCounts.keys.toList()
      ..sort((a, b) => tagCounts[b]!.compareTo(tagCounts[a]!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CurvedFilterSelector(
            selected: _filter,
            onSelect: (f) => setState(() => _filter = f),
          ),
        ),
        const SizedBox(height: 16),
        tagCounts.isEmpty
            ? const Center(child: Text('No tags used in this period'))
            : Container(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final tag in sortedTags)
                        SizedBox(
                          height: 40,
                          child: _TagBarHorizontal(
                            tag: tag,
                            count: tagCounts[tag]!,
                            maxCount: tagCounts.values.isNotEmpty ? tagCounts.values.reduce((a, b) => a > b ? a : b) : 1,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class CurvedFilterSelector extends StatelessWidget {
  final TagTimeFilter selected;
  final ValueChanged<TagTimeFilter> onSelect;
  const CurvedFilterSelector({required this.selected, required this.onSelect, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CurvedSelectorButton(
            label: 'Month',
            selected: selected == TagTimeFilter.month,
            onTap: () => onSelect(TagTimeFilter.month),
          ),
          _CurvedSelectorButton(
            label: 'Year',
            selected: selected == TagTimeFilter.year,
            onTap: () => onSelect(TagTimeFilter.year),
          ),
          _CurvedSelectorButton(
            label: 'All Time',
            selected: selected == TagTimeFilter.all,
            onTap: () => onSelect(TagTimeFilter.all),
          ),
        ],
      ),
    );
  }
}

class _CurvedSelectorButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CurvedSelectorButton({required this.label, required this.selected, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Theme.of(context).colorScheme.secondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagBarHorizontal extends StatelessWidget {
  final String tag;
  final int count;
  final int maxCount;

  const _TagBarHorizontal({required this.tag, required this.count, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final barWidth = (count / (maxCount == 0 ? 1 : maxCount)) * 220 + 24;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              tag,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 28,
            width: barWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha:0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCellRedesigned extends StatelessWidget {
  final IconData icon;
  final String value;
  final String description;

  const _StatCellRedesigned({
    required this.icon,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 2),
        Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
