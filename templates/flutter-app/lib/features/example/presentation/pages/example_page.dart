import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../providers/example_provider.dart';
import '../widgets/example_card.dart';

/// Example list page
class ExamplePage extends ConsumerWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examplesAsync = ref.watch(exampleNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.exampleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(exampleNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: examplesAsync.when(
        data: (examples) {
          if (examples.isEmpty) {
            return const Center(
              child: Text(AppStrings.emptyNoData),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(exampleNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: examples.length,
              itemBuilder: (context, index) {
                final example = examples[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ExampleCard(
                    example: example,
                    onTap: () => context.goToExampleDetail(example.id),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.read(exampleNotifierProvider.notifier).refresh(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Example'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(exampleNotifierProvider.notifier).createExample(
                    title: titleController.text,
                    description: descController.text,
                  );
              Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
