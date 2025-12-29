import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/category.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';

class CategoryEditPage extends StatefulWidget {
  final Category? category;

  const CategoryEditPage({super.key, this.category});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _keywordController;
  late List<String> _keywords;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _keywordController = TextEditingController();
    _keywords = List.from(widget.category?.keywords ?? []);
    _selectedColor = _parseColor(widget.category?.color);
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xff')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _addKeyword() {
    final keyword = _keywordController.text.trim();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      setState(() {
        _keywords.add(keyword);
        _keywordController.clear();
      });
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CategoriesBloc>();
    final name = _nameController.text.trim();
    final colorHex = _colorToHex(_selectedColor);

    if (widget.category == null) {
      // Add new
      bloc.add(AddCategory(
        name: name,
        color: colorHex,
        keywords: _keywords,
      ));
    } else {
      // Edit existing
      final updatedCategory = widget.category!.copyWith(
        name: name,
        color: colorHex,
        keywords: _keywords,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      bloc.add(EditCategory(updatedCategory));
    }

    context.pop();
  }

  void _deleteCategory() {
    if (widget.category == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content:
            Text('Are you sure you want to delete "${widget.category!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<CategoriesBloc>()
                  .add(RemoveCategory(widget.category!.id));
              Navigator.pop(ctx); // Close dialog
              context.pop(); // Close page
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Category' : 'New Category',
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCategory,
              color: AppColors.error,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Input
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: AppColors.grey4),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.grey2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.white),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Color Picker
              Row(
                children: [
                  const Text('Color',
                      style: TextStyle(fontSize: 16, color: AppColors.white)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.grey1,
                          title: const Text('Pick a color',
                              style: TextStyle(color: AppColors.white)),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: _selectedColor,
                              onColorChanged: (color) {
                                setState(() => _selectedColor = color);
                                Navigator.pop(ctx);
                              },
                              availableColors: const [
                                AppColors.categoryWork,
                                AppColors.categoryBreak,
                                AppColors.categoryLearning,
                                AppColors.categorySocial,
                                AppColors.categoryDistraction,
                                Colors.red,
                                Colors.pink,
                                Colors.purple,
                                Colors.deepPurple,
                                Colors.indigo,
                                Colors.blue,
                                Colors.lightBlue,
                                Colors.cyan,
                                Colors.teal,
                                Colors.green,
                                Colors.lightGreen,
                                Colors.lime,
                                Colors.yellow,
                                Colors.amber,
                                Colors.orange,
                                Colors.deepOrange,
                                Colors.brown,
                                Colors.grey,
                                Colors.blueGrey,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: _selectedColor,
                        radius: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Keywords Section
              const Text(
                'Keywords (Auto-categorization)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Logs containing these words will be automatically assigned to this category.',
                style: TextStyle(fontSize: 13, color: AppColors.grey4),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add keyword (e.g. "meeting")',
                        hintStyle: TextStyle(color: AppColors.grey4),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.white),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _addKeyword(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _addKeyword,
                    icon: const Icon(Icons.add_circle, size: 40),
                    color: AppColors.white,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_keywords.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No keywords added yet.',
                      style: TextStyle(
                          color: AppColors.grey4, fontStyle: FontStyle.italic)),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _keywords.map((keyword) {
                    return Chip(
                      label: Text(keyword,
                          style: const TextStyle(color: AppColors.black)),
                      backgroundColor: AppColors.white,
                      deleteIcon: const Icon(Icons.close,
                          size: 18, color: AppColors.black),
                      onDeleted: () => _removeKeyword(keyword),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 48),

              // Save Button
              AppButton(
                label: 'Save Category',
                onPress: _saveCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
