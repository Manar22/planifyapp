import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'sign_in_page.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA13F89),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F8),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFA13F89),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 8,
          shadowColor: Color(0xFF8B3575),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shadowColor: Color(0xFF8B3575),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shadowColor: Color(0xFF8B3575),
            backgroundColor: Color(0xFFA13F89),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: AuthService.isSignedIn() ? '/planner' : '/',
      routes: {
        '/': (context) => const SignInPage(),
        '/planner': (context) => const YearPlanner(),
      },
    );
  }
}

class Task {
  String text;
  bool isCompleted;
  String category;
  Color categoryColor;
  DateTime? startTime;
  DateTime? endTime;
  int progress;
  String assignedTo;
  DateTime date;

  Task({
    required this.text,
    required this.date,
    this.isCompleted = false,
    this.category = 'Personal',
    this.categoryColor = const Color(0xFFA13F89),
    this.startTime,
    this.endTime,
    this.progress = 0,
    this.assignedTo = 'Me',
  });
}

class YearPlanner extends StatefulWidget {
  const YearPlanner({super.key});

  @override
  State<YearPlanner> createState() => _YearPlannerState();
}

class _YearPlannerState extends State<YearPlanner> {
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final Map<String, Color> categoryColors = {
    'Personal': const Color(0xFF1B5E20),
    'Work': const Color(0xFF4E342E),
    'Shopping': const Color(0xFF0D47A1),
    'Health': const Color(0xFFC2185B),
    'Other': const Color(0xFFFF6F00),
    'All Together': const Color(0xFF37474F),
  };

  final Map<String, String> monthMotivations = {
    'January': 'New Year, New Goals!',
    'February': 'Spread Love & Joy',
    'March': 'Spring into Action',
    'April': 'Embrace New Beginnings',
    'May': 'Bloom & Grow',
    'June': 'Chase Your Dreams',
    'July': 'Shine Like the Sun',
    'August': 'Make it Happen',
    'September': 'Fresh Start, Fresh Mind',
    'October': 'Fall into Success',
    'November': 'Grateful & Growing',
    'December': 'End Strong, Start Stronger',
  };

  final Map<DateTime, List<Task>> tasksByDate = {};

  String _selectedCategory = 'Personal';
  String? _filterCategory;
  bool _showAllTogether = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    for (int month = 1; month <= 12; month++) {
      for (int day = 1; day <= DateTime(now.year, month + 1, 0).day; day++) {
        tasksByDate[DateTime(now.year, month, day)] = [];
      }
    }
  }

  String _getCurrentDate(String month) {
    final now = DateTime.now();
    final monthIndex = months.indexOf(month);
    return '${now.year}';
  }

  List<Task> _getTasksForDate(DateTime date) {
    return tasksByDate[date] ?? [];
  }

  List<Task> _getFilteredTasksForDate(DateTime date) {
    final dateTasks = _getTasksForDate(date);
    if (_filterCategory == null) {
      return dateTasks;
    } else if (_filterCategory == 'All Together') {
      return dateTasks;
    } else {
      return dateTasks
          .where((task) => task.category == _filterCategory)
          .toList();
    }
  }

  Future<DateTime?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
    }
    return null;
  }

  void _addTask(DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        String newTask = '';
        DateTime? startTime;
        DateTime? endTime;
        int progress = 0;
        String assignedTo = 'Me';
        return AlertDialog(
          title: Text('Add Task for ${date.day}/${date.month}/${date.year}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => newTask = value,
                  decoration: const InputDecoration(
                    hintText: 'Enter your task',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => assignedTo = value,
                  decoration: const InputDecoration(
                    hintText: 'Assigned to',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: categoryColors.keys.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: categoryColors[category],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Start Time'),
                        subtitle: Text(
                          startTime != null
                              ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await _selectTime(context);
                          if (time != null) {
                            setState(() {
                              startTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('End Time'),
                        subtitle: Text(
                          endTime != null
                              ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await _selectTime(context);
                          if (time != null) {
                            setState(() {
                              endTime = time;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Progress: '),
                    Expanded(
                      child: Slider(
                        value: progress.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: '$progress%',
                        onChanged: (value) {
                          setState(() {
                            progress = value.round();
                          });
                        },
                      ),
                    ),
                    Text('$progress%'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  setState(() {
                    final task = Task(
                      text: newTask,
                      date: date,
                      category: _selectedCategory,
                      categoryColor: categoryColors[_selectedCategory]!,
                      startTime: startTime,
                      endTime: endTime,
                      progress: progress,
                      assignedTo: assignedTo,
                    );
                    tasksByDate[date]!.add(task);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editTask(DateTime date, int taskIndex) {
    final task = _getTasksForDate(date)[taskIndex];
    showDialog(
      context: context,
      builder: (context) {
        String editedTask = task.text;
        String selectedCategory = task.category;
        DateTime? startTime = task.startTime;
        DateTime? endTime = task.endTime;
        int progress = task.progress;
        String assignedTo = task.assignedTo;
        return AlertDialog(
          title: Text('Edit Task for ${date.day}/${date.month}/${date.year}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => editedTask = value,
                  controller: TextEditingController(text: task.text),
                  decoration: const InputDecoration(
                    hintText: 'Edit your task',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => assignedTo = value,
                  controller: TextEditingController(text: task.assignedTo),
                  decoration: const InputDecoration(
                    hintText: 'Assigned to',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: categoryColors.keys.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: categoryColors[category],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedCategory = newValue;
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Start Time'),
                        subtitle: Text(
                          startTime != null
                              ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await _selectTime(context);
                          if (time != null) {
                            setState(() {
                              startTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('End Time'),
                        subtitle: Text(
                          endTime != null
                              ? '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await _selectTime(context);
                          if (time != null) {
                            setState(() {
                              endTime = time;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Progress: '),
                    Expanded(
                      child: Slider(
                        value: progress.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: '$progress%',
                        onChanged: (value) {
                          setState(() {
                            progress = value.round();
                          });
                        },
                      ),
                    ),
                    Text('$progress%'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editedTask.isNotEmpty) {
                  setState(() {
                    final updatedTask = Task(
                      text: editedTask,
                      date: date,
                      isCompleted: task.isCompleted,
                      category: selectedCategory,
                      categoryColor: categoryColors[selectedCategory]!,
                      startTime: startTime,
                      endTime: endTime,
                      progress: progress,
                      assignedTo: assignedTo,
                    );
                    tasksByDate[date]![taskIndex] = updatedTask;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateProgress(DateTime date, int taskIndex, int newProgress) {
    final tasks = _getTasksForDate(date);
    if (tasks.isNotEmpty && taskIndex < tasks.length) {
      setState(() {
        tasks[taskIndex].progress = newProgress;
      });
    }
  }

  void _showProgressDialog(DateTime date, int taskIndex) {
    final task = _getTasksForDate(date)[taskIndex];
    int currentProgress = task.progress;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update Progress'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (var progress in [0, 25, 50, 75, 100])
                            SizedBox(
                              width: 64,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  setDialogState(() {
                                    currentProgress = progress;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentProgress == progress
                                      ? task.categoryColor
                                      : Colors.grey[200],
                                  foregroundColor: currentProgress == progress
                                      ? Colors.white
                                      : Colors.black87,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text('$progress%'),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Custom: '),
                          Expanded(
                            child: Slider(
                              value: currentProgress.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              label: '$currentProgress%',
                              onChanged: (value) {
                                setDialogState(() {
                                  currentProgress = value.round();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              '$currentProgress%',
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
    setState(() {
                      task.progress = currentProgress;
                      if (currentProgress == 100) {
                        task.isCompleted = true;
                      } else if (currentProgress == 0) {
                        task.isCompleted = false;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: Scaffold(
        body: Column(
          children: [
            AppBar(
              title: Text(
                'Planify',
                style: GoogleFonts.dancingScript(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (String category) {
                    setState(() {
                      _filterCategory = category == 'All' ? null : category;
                      _showAllTogether = category == 'All Together';
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'All',
                        child: Text('All'),
                      ),
                      ...categoryColors.keys.map((String category) {
                        return PopupMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ];
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    AuthService.signOut();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 600
                      ? 1
                      : constraints.maxWidth < 900
                          ? 2
                          : 3;
                  return SingleChildScrollView(
                    padding:
                        EdgeInsets.all(constraints.maxWidth < 600 ? 8 : 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio:
                            constraints.maxWidth < 600 ? 0.85 : 1.0,
                        crossAxisSpacing: constraints.maxWidth < 600 ? 8 : 12,
                        mainAxisSpacing: constraints.maxWidth < 600 ? 8 : 12,
                      ),
                      itemCount: months.length,
                      itemBuilder: (context, index) =>
                          _buildMonthCard(months[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(String month) {
    final now = DateTime.now();
    final monthIndex = months.indexOf(month);
    final firstDay = DateTime(now.year, monthIndex + 1, 1);
    final lastDay = DateTime(now.year, monthIndex + 2, 0);
    List<Task> monthTasks = [];
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(now.year, monthIndex + 1, day);
      monthTasks.addAll(_getFilteredTasksForDate(date));
    }

    return Card(
      elevation: 4,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'images/pattern.jpg',
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 300;
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFA13F89),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              month,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: isSmallScreen ? 18 : 24,
                              ),
                              onPressed: () => _addTask(
                                  DateTime(now.year, monthIndex + 1, 1)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          monthMotivations[month]!,
                          style: GoogleFonts.dancingScript(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: monthTasks.isEmpty ? 1 : 2,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
                              child: _buildCalendar(month, isSmallScreen),
                            ),
                          ),
                        ),
                        if (monthTasks.isNotEmpty)
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(12)),
                                border: Border(
                                  top: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: monthTasks.length,
                                itemBuilder: (context, index) {
                                  final task = monthTasks[index];
                                  return InkWell(
                                    onTap: () {
                                      final taskDate = task.date;
                                      final taskIndex =
                                          tasksByDate[taskDate]!.indexOf(task);
                                      _showProgressDialog(taskDate, taskIndex);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 4 : 8,
                                        vertical: isSmallScreen ? 2 : 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: isSmallScreen ? 20 : 24,
                                            height: isSmallScreen ? 20 : 24,
                                            child: Transform.scale(
                                              scale: isSmallScreen ? 0.7 : 0.8,
                                              child: Checkbox(
                                                value: task.isCompleted,
                                                activeColor: task.categoryColor,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    task.isCompleted =
                                                        value ?? false;
                                                    task.progress =
                                                        value ?? false
                                                            ? 100
                                                            : 0;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: isSmallScreen ? 2 : 4),
                                          Expanded(
                                            child: Text(
                                              task.text,
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 10 : 11,
                                                decoration: task.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: task.isCompleted
                                                    ? Colors.grey
                                                    : null,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                              width: isSmallScreen ? 2 : 4),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isSmallScreen ? 2 : 4,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: task.categoryColor
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: task.categoryColor
                                                    .withOpacity(0.4),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '${task.progress}%',
                                              style: TextStyle(
                                                fontSize: isSmallScreen ? 8 : 9,
                                                color: task.categoryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Transform.scale(
                                            scale: isSmallScreen ? 0.7 : 0.8,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                size: isSmallScreen ? 14 : 16,
                                                color: Colors.grey[600],
                                              ),
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: EdgeInsets.all(
                                                  isSmallScreen ? 2 : 4),
                                              onPressed: () {
                                                final taskDate = task.date;
                                                final taskIndex =
                                                    tasksByDate[taskDate]!
                                                        .indexOf(task);
                                                _editTask(taskDate, taskIndex);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(String month, bool isMobile) {
    final now = DateTime.now();
    final monthIndex = months.indexOf(month);
    final firstDay = DateTime(now.year, monthIndex + 1, 1);
    final lastDay = DateTime(now.year, monthIndex + 2, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;
    final currentDate = DateTime.now();
    final isCurrentMonth = currentDate.month == monthIndex + 1;

    final numberOfRows = ((daysInMonth + firstWeekday) / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: isMobile ? 0.9 : 1.0,
        crossAxisSpacing: isMobile ? 1 : 2,
        mainAxisSpacing: isMobile ? 1 : 2,
      ),
      itemCount: numberOfRows * 7,
      itemBuilder: (context, index) {
        final day = index - firstWeekday + 1;
        if (day < 1 || day > daysInMonth) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }

        final date = DateTime(now.year, monthIndex + 1, day);
        final tasks = _getFilteredTasksForDate(date);
        final hasTasks = tasks.isNotEmpty;
        final isToday = isCurrentMonth && currentDate.day == day;

        return GestureDetector(
          onTap: () => _addTask(date),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isToday ? const Color(0xFFA13F89) : Colors.grey[300]!,
                width: isToday ? 2 : 1,
              ),
              color: hasTasks ? tasks[0].categoryColor.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                if (isToday)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA13F89),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(2),
                          bottomLeft: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 2,
                  left: 2,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: hasTasks || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isToday
                          ? const Color(0xFFA13F89)
                          : (hasTasks ? Colors.black87 : null),
                    ),
                  ),
                ),
                if (hasTasks)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        color: tasks[0].categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: tasks[0].categoryColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${tasks[0].progress}%',
                            style: TextStyle(
                              fontSize: 8,
                              color: tasks[0].categoryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (tasks.length > 1)
                            Container(
                              margin: const EdgeInsets.only(left: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 1),
                              decoration: BoxDecoration(
                                color: tasks[0].categoryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '+${tasks.length - 1}',
                                style: TextStyle(
                                  fontSize: 7,
                                  color: tasks[0].categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
