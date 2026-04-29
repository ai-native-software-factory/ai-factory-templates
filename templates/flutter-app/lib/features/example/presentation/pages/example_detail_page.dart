import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/example_provider.dart';

/// Example detail page
class ExampleDetailPage extends ConsumerWidget {
  final String id;

  const ExampleDetailPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exampleAsync = ref.watch(exampleByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: exampleAsync.when(
        data: (example) => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        example.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 16.h),
                      const Divider(),
                      SizedBox(height: 8.h),
                      _buildInfoRow(
                        context,
                        'Created',
                        DateFormat.yMMMd().add_jm().format(example.createdAt),
                      ),
                      if (example.updatedAt != null)
                        _buildInfoRow(
                          context,
                          'Updated',
                          DateFormat.yMMMd().add_jm().format(example.updatedAt!),
                        ),
                      _buildInfoRow(
                        context,
                        'Status',
                        example.isActive ? 'Active' : 'Inactive',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.invalidate(exampleByIdProvider(id)),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Example'),
        content: const Text('Are you sure you want to delete this example?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(exampleNotifierProvider.notifier).deleteExample(id);
              Navigator.pop(context);
              // Navigate back
              ref.read(exampleNotifierProvider.notifier).refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
