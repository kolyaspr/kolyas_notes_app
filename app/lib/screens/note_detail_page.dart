import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _titleController.addListener(_markChanged);
    _contentController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _titleController.removeListener(_markChanged);
    _contentController.removeListener(_markChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );
    Navigator.pop(context, {'note': updatedNote, 'action': 'update'});
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFF8888AA))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {'action': 'delete'});
            },
            child: const Text('Удалить',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _toggleDone() {
    final updatedNote = widget.note.toggleDone();
    Navigator.pop(context, {'note': updatedNote, 'action': 'update'});
  }

  Future<bool> _onWillPop() async {
    if (!_isEditing || !_hasChanges) {
      Navigator.pop(context);
      return true;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Несохранённые изменения'),
        content: const Text('Сохранить изменения перед выходом?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Не сохранять',
                style: TextStyle(color: Color(0xFF8888AA))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFF8888AA))),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result == 'save') {
      _saveChanges();
    } else if (result == 'discard') {
      Navigator.pop(context);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        await _onWillPop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Редактирование' : 'Просмотр'),
          actions: [
            // Завершить / снять завершение
            IconButton(
              icon: Icon(
                widget.note.isDone
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: widget.note.isDone ? Colors.green[400] : null,
              ),
              tooltip: widget.note.isDone
                  ? 'Отметить как незавершённое'
                  : 'Отметить как завершённое',
              onPressed: _toggleDone,
            ),
            // Редактировать / сохранить
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Редактировать',
                onPressed: () => setState(() => _isEditing = true),
              )
            else
              IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Сохранить',
                onPressed: _saveChanges,
              ),
            // Удалить
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Удалить',
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                TextField(
                  controller: _titleController,
                  readOnly: !_isEditing,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: widget.note.isDone
                        ? const Color(0xFF666680)
                        : const Color(0xFFE8E8FF),
                    decoration: widget.note.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: const Color(0xFF666680),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Название',
                    border: _isEditing
                        ? const OutlineInputBorder()
                        : InputBorder.none,
                    filled: _isEditing,
                    contentPadding: _isEditing
                        ? const EdgeInsets.all(16)
                        : EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),

                // Дата + статус
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: const Color(0xFF555580)),
                    const SizedBox(width: 6),
                    Text(
                      'Создано: ${_formatDate(widget.note.createdAt)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF555580)),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.note.isDone
                            ? Colors.green.withOpacity(0.15)
                            : colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.note.isDone
                                ? Icons.check_circle
                                : Icons.pending,
                            size: 12,
                            color: widget.note.isDone
                                ? Colors.green[400]
                                : colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.note.isDone ? 'Завершено' : 'В процессе',
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.note.isDone
                                  ? Colors.green[400]
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Текст заметки
                TextField(
                  controller: _contentController,
                  readOnly: !_isEditing,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: widget.note.isDone
                        ? const Color(0xFF555580)
                        : const Color(0xFFBBBBDD),
                    decoration: widget.note.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: const Color(0xFF555580),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Текст заметки',
                    alignLabelWithHint: true,
                    border: _isEditing
                        ? const OutlineInputBorder()
                        : InputBorder.none,
                    filled: _isEditing,
                    contentPadding: _isEditing
                        ? const EdgeInsets.all(16)
                        : EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
