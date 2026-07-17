import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/note_card.dart';
import 'note_detail_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await StorageService.loadNotes();
    if (mounted) {
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotes() async {
    await StorageService.saveNotes(_notes);
  }

  void _addNote(String title, String content) {
    final newNote = Note.create(title: title, content: content);
    setState(() => _notes.insert(0, newNote));
    _saveNotes();
  }

  void _updateNote(Note updatedNote) {
    setState(() {
      final index = _notes.indexWhere((n) => n.id == updatedNote.id);
      if (index != -1) _notes[index] = updatedNote;
    });
    _saveNotes();
  }

  void _deleteNote(String noteId) {
    setState(() => _notes.removeWhere((n) => n.id == noteId));
    _saveNotes();
  }

  void _toggleDone(Note note) {
    setState(() {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) _notes[index] = note.toggleDone();
    });
    _saveNotes();
  }

  int _calculateColumns(double width) {
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 5;
  }

  void _showAddNoteDialog() {
    showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddNoteDialog(),
    ).then((result) {
      if (result != null && mounted) {
        _addNote(result['title']!, result['content']!);
      }
    });
  }

  void _openNoteDetail(Note note) {
    Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
    ).then((result) {
      if (!mounted || result == null) return;
      if (result['action'] == 'delete') {
        _deleteNote(note.id);
      } else if (result['action'] == 'update') {
        _updateNote(result['note'] as Note);
      }
    });
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить заметку?'),
            content: const Text('Это действие нельзя отменить.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена',
                    style: TextStyle(color: Color(0xFF8888AA))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Удалить',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить все заметки?'),
        content: Text(
            'Вы уверены? Будет удалено: ${_notes.length} заметок.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFF8888AA))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _notes.clear());
              _saveNotes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Все заметки удалены')),
              );
            },
            child: const Text('Удалить',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completedCount = _notes.where((n) => n.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        actions: [
          if (_notes.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                ' $completedCount/${_notes.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              tooltip: 'Удалить все',
              onPressed: _confirmClearAll,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddNoteDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final total = _notes.length;
    final today = _notes.where((n) {
      final now = DateTime.now();
      return n.createdAt.year == now.year &&
          n.createdAt.month == now.month &&
          n.createdAt.day == now.day;
    }).length;
    final completed = _notes.where((n) => n.isDone).length;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A45), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              icon: Icons.note_alt_outlined,
              label: 'Всего',
              value: total.toString(),
              color: colorScheme.primary,
            ),
            Container(
                height: 32, width: 1, color: const Color(0xFF2A2A45)),
            _statItem(
              icon: Icons.today_outlined,
              label: 'Сегодня',
              value: today.toString(),
              color: const Color(0xFF64B5F6),
            ),
            Container(
                height: 32, width: 1, color: const Color(0xFF2A2A45)),
            _statItem(
              icon: Icons.check_circle_outline,
              label: 'Готово',
              value: completed.toString(),
              color: Colors.green[400]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8888AA)),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
          strokeWidth: 2,
        ),
      );
    }
    if (_notes.isEmpty) return _buildEmptyState();
    return _buildNotesGrid();
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.note_add_outlined,
                size: 56, color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'Пока нет заметок',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE8E8FF),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNotesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _calculateColumns(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return Dismissible(
              key: Key(note.id),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.4)),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 28),
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 28),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  _toggleDone(note);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          note.isDone
                              ? 'Отмечено как незавершённое'
                              : 'Отмечено как завершённое',
                        ),
                        backgroundColor: Colors.green[800],
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'Отмена',
                          textColor: Colors.white,
                          onPressed: () => _toggleDone(note),
                        ),
                      ),
                    );
                  }
                  return false;
                } else {
                  return await _showDeleteConfirmation();
                }
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  _deleteNote(note.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Заметка удалена'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: NoteCard(
                key: ValueKey(note.id),
                note: note,
                onTap: () => _openNoteDetail(note),
              ),
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────
// Диалог добавления заметки
// ──────────────────────────────────────────
class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isNotEmpty) {
      Navigator.of(context).pop({'title': title, 'content': content});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название заметки')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit_note, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Новая заметка',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8E8FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Color(0xFFE8E8FF)),
              decoration: const InputDecoration(
                labelText: 'Название',
                prefixIcon: Icon(Icons.title, size: 20),
                hintText: 'Введите заголовок...',
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Color(0xFFE8E8FF)),
              decoration: const InputDecoration(
                labelText: 'Текст заметки',
                prefixIcon: Icon(Icons.note, size: 20),
                hintText: 'Напишите что-нибудь...',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена',
                      style: TextStyle(color: Color(0xFF8888AA))),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _handleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
