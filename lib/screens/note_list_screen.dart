import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/travel_note.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<TravelNote> notes = [];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _expenseController = TextEditingController();
  String? _selectedCategory;
  String? _selectedWeather;
  int _rating = 0;

  final List<String> _categories = [
    'Ẩm thực',
    'Khách sạn',
    'Di chuyển',
    'Tham quan',
    'Mua sắm',
    'Khác'
  ];

  final List<String> _weatherOptions = [
    'Nắng',
    'Mưa',
    'Mây',
    'Nắng nhẹ',
    'Mưa nhỏ',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = notesJson.map((json) => TravelNote.fromMap(jsonDecode(json))).toList();
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => jsonEncode(note.toMap())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  void _addNote() {
    _titleController.clear();
    _contentController.clear();
    _locationController.clear();
    _expenseController.clear();
    _selectedCategory = null;
    _selectedWeather = null;
    _rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm Ghi Chú Mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    hintText: 'Nhập tiêu đề ghi chú',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    hintText: 'Nhập nội dung ghi chú',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Địa điểm',
                    hintText: 'Nhập địa điểm',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _expenseController,
                  decoration: const InputDecoration(
                    labelText: 'Chi phí',
                    hintText: 'Nhập chi phí',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Loại ghi chú',
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedWeather,
                  decoration: const InputDecoration(
                    labelText: 'Thời tiết',
                  ),
                  items: _weatherOptions.map((weather) {
                    return DropdownMenuItem(
                      value: weather,
                      child: Text(weather),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedWeather = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đánh giá:'),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _contentController.text.isNotEmpty) {
                  final newNote = TravelNote(
                    id: const Uuid().v4(),
                    title: _titleController.text,
                    content: _contentController.text,
                    createdAt: DateTime.now(),
                    location: _locationController.text.isNotEmpty
                        ? _locationController.text
                        : null,
                    expense: _expenseController.text.isNotEmpty
                        ? double.tryParse(_expenseController.text)
                        : null,
                    category: _selectedCategory,
                    weather: _selectedWeather,
                    rating: _rating > 0 ? _rating : null,
                  );
                  setState(() {
                    notes.add(newNote);
                  });
                  _saveNotes();
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _editNote(TravelNote note) {
    _titleController.text = note.title;
    _contentController.text = note.content;
    _locationController.text = note.location ?? '';
    _expenseController.text = note.expense?.toString() ?? '';
    _selectedCategory = note.category;
    _selectedWeather = note.weather;
    _rating = note.rating ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa Ghi Chú'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'Nhập tiêu đề ghi chú',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  hintText: 'Nhập nội dung ghi chú',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa điểm',
                  hintText: 'Nhập địa điểm',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _expenseController,
                decoration: const InputDecoration(
                  labelText: 'Chi phí',
                  hintText: 'Nhập chi phí',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Loại ghi chú',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedWeather,
                decoration: const InputDecoration(
                  labelText: 'Thời tiết',
                ),
                items: _weatherOptions.map((weather) {
                  return DropdownMenuItem(
                    value: weather,
                    child: Text(weather),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWeather = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Đánh giá:'),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                final updatedNote = TravelNote(
                  id: note.id,
                  title: _titleController.text,
                  content: _contentController.text,
                  createdAt: note.createdAt,
                  updatedAt: DateTime.now(),
                  location: _locationController.text.isNotEmpty
                      ? _locationController.text
                      : null,
                  expense: _expenseController.text.isNotEmpty
                      ? double.tryParse(_expenseController.text)
                      : null,
                  category: _selectedCategory,
                  weather: _selectedWeather,
                  rating: _rating > 0 ? _rating : null,
                );
                setState(() {
                  final index = notes.indexWhere((n) => n.id == note.id);
                  if (index != -1) {
                    notes[index] = updatedNote;
                  }
                });
                _saveNotes();
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(BuildContext context, TravelNote note) async {
    if (!mounted) return;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        setState(() {
          notes.removeWhere((n) => n.id == note.id);
        });
        await _saveNotes();
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi xóa ghi chú'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ẩm thực':
        return Colors.red;
      case 'Khách sạn':
        return Colors.blue;
      case 'Di chuyển':
        return Colors.green;
      case 'Tham quan':
        return Colors.purple;
      case 'Mua sắm':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getWeatherEmoji(String weather) {
    switch (weather) {
      case 'Nắng':
        return '☀️';
      case 'Mưa':
        return '🌧️';
      case 'Mây':
        return '☁️';
      case 'Nắng nhẹ':
        return '🌤️';
      case 'Mưa nhỏ':
        return '🌦️';
      default:
        return '🌈';
    }
  }

  void _viewNote(TravelNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (note.rating != null)
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < note.rating! ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (note.location != null) ...[
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.teal),
                  title: Text(note.location!),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (note.category != null) ...[
                ListTile(
                  leading: Icon(Icons.category,
                      color: _getCategoryColor(note.category!)),
                  title: Text(note.category!),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (note.weather != null) ...[
                ListTile(
                  leading: Text(
                    _getWeatherEmoji(note.weather!),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(note.weather!),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (note.expense != null) ...[
                ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: Text('${note.expense!.toStringAsFixed(0)} VNĐ'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.grey),
                title: Text(
                  'Ngày tạo: ${note.createdAt.toString().split('.')[0]}',
                  style: const TextStyle(fontSize: 12),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              if (note.updatedAt != null)
                ListTile(
                  leading: const Icon(Icons.update, color: Colors.grey),
                  title: Text(
                    'Cập nhật: ${note.updatedAt.toString().split('.')[0]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sổ Tay Du Lịch'),
          centerTitle: true,
        ),
        body: notes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_add,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có ghi chú nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy thêm ghi chú mới!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (note.rating != null)
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < note.rating!
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (note.location != null)
                                Chip(
                                  avatar: const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    note.location!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.teal,
                                ),
                              if (note.category != null)
                                Chip(
                                  label: Text(
                                    note.category!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: _getCategoryColor(note.category!),
                                ),
                              if (note.weather != null)
                                Chip(
                                  avatar: Text(
                                    _getWeatherEmoji(note.weather!),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  label: Text(
                                    note.weather!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  backgroundColor: Colors.grey[200],
                                ),
                              if (note.expense != null)
                                Chip(
                                  avatar: const Icon(
                                    Icons.attach_money,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    '${note.expense!.toStringAsFixed(0)} VNĐ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Sửa'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _editNote(note);
                            },
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteNote(context, note);
                            },
                          ),
                        ],
                      ),
                      onTap: () => _viewNote(note),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNote,
          label: const Text('Thêm ghi chú'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
} 