import 'package:flutter/material.dart';
import 'task_model.dart';
import 'task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  bool _isLoading = true;

  // Tab: 0 = All, 1 = Pending, 2 = Done
  int _filterIndex = 0;

  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskService.loadTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  List<Task> get _filteredTasks {
    switch (_filterIndex) {
      case 1:
        return _tasks.where((t) => !t.isCompleted).toList();
      case 2:
        return _tasks.where((t) => t.isCompleted).toList();
      default:
        return _tasks;
    }
  }

  Future<void> _toggleTask(String id) async {
    final updated = await TaskService.toggleTask(_tasks, id);
    setState(() => _tasks = updated);
  }

  Future<void> _deleteTask(String id) async {
    final updated = await TaskService.deleteTask(_tasks, id);
    setState(() => _tasks = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xff2A2A2A),
          content: const Text(
            'Task deleted',
            style: TextStyle(color: Color(0xffFFEA00)),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xff252525),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xffFFEA00),
                  ),
                ),
                const SizedBox(height: 20),

                // Title field
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Task title *',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.task_alt, color: Color(0xffFFEA00)),
                    filled: true,
                    fillColor: const Color(0xff1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xffFFEA00), width: 1.5),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 12),

                // Description field
                TextFormField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 44),
                      child: Icon(Icons.notes, color: Color(0xffFFEA00)),
                    ),
                    filled: true,
                    fillColor: const Color(0xff1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xffFFEA00), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFEA00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final task = Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                          createdAt: DateTime.now(),
                        );
                        final updated = await TaskService.addTask(_tasks, task);
                        setState(() => _tasks = updated);
                        if (!ctx.mounted) return; Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Confirm then delete
  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Task?',
          style: TextStyle(color: Color(0xffFFEA00), fontWeight: FontWeight.bold),
        ),
        content: Text(
          '"${task.title}" will be permanently removed.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTask(task.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _tasks.where((t) => !t.isCompleted).length;
    final done = _tasks.where((t) => t.isCompleted).length;
    final filtered = _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xff1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xff1C1C1C),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('images/task_icon.png', width: 32, height: 32),
            const SizedBox(width: 10),
            const Text(
              'Task Management',
              style: TextStyle(
                color: Color(0xffFFEA00),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // Stats badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff252525),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$done/${_tasks.length} done',
                  style: const TextStyle(
                    color: Color(0xffFFEA00),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: const Color(0xffFFEA00),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xffFFEA00)))
          : Column(
              children: [
                // Summary cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      _SummaryCard(
                        label: 'Pending',
                        count: pending,
                        icon: Icons.hourglass_empty_rounded,
                        iconColor: Colors.orangeAccent,
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        label: 'Completed',
                        count: done,
                        icon: Icons.check_circle_rounded,
                        iconColor: Colors.greenAccent,
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        label: 'Total',
                        count: _tasks.length,
                        icon: Icons.list_alt_rounded,
                        iconColor: const Color(0xffFFEA00),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Filter tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff252525),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: ['All', 'Pending', 'Done'].asMap().entries.map((e) {
                        final selected = _filterIndex == e.key;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _filterIndex = e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xffFFEA00)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: selected ? Colors.black : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Task list
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(filterIndex: _filterIndex)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final task = filtered[i];
                            return _TaskCard(
                              task: task,
                              onToggle: () => _toggleTask(task.id),
                              onDelete: () => _confirmDelete(task),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ── Summary card widget ──────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xff252525),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Task card widget ─────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xff252525),
        borderRadius: BorderRadius.circular(14),
        border: task.isCompleted
            ? Border.all(color: Colors.greenAccent.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted ? Colors.greenAccent : Colors.transparent,
              border: Border.all(
                color: task.isCompleted ? Colors.greenAccent : Colors.white38,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, color: Colors.black, size: 16)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isCompleted ? Colors.white38 : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white38,
          ),
        ),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.white24 : Colors.white54,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ── Empty state widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final int filterIndex;
  const _EmptyState({required this.filterIndex});

  @override
  Widget build(BuildContext context) {
    final messages = [
      ['No tasks yet!', 'Tap + to add your first task.'],
      ['All caught up!', 'No pending tasks — nice work.'],
      ['Nothing here yet.', 'Complete a task to see it here.'],
    ];
    final msg = messages[filterIndex];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filterIndex == 2 ? Icons.check_circle_outline : Icons.inbox_outlined,
            color: const Color(0xffFFEA00).withValues(alpha: 0.3),
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            msg[0],
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            msg[1],
            style: const TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
