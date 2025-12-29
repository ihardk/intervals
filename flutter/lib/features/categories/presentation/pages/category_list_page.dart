import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';
import '../bloc/categories_state.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(const LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.white));
          } else if (state is CategoriesError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppColors.error)));
          } else if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return const Center(
                  child: Text('No categories found.',
                      style: TextStyle(color: AppColors.grey4)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey1,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey2),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _parseColor(category.color),
                      radius: 12,
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      category.keywords.isEmpty
                          ? 'No keywords'
                          : category.keywords.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: AppColors.grey4, fontSize: 13),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: AppColors.grey4),
                    onTap: () {
                      context.push('/settings/categories/edit',
                          extra: category);
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        onPressed: () {
          context.push('/settings/categories/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xff')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
