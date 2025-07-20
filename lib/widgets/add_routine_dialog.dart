import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/routine_provider.dart';
import '../models/routine.dart';

class AddRoutineDialog extends ConsumerStatefulWidget {
  const AddRoutineDialog({super.key});

  @override
  ConsumerState<AddRoutineDialog> createState() => _AddRoutineDialogState();
}

class _AddRoutineDialogState extends ConsumerState<AddRoutineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedEmoji = '🌱';
  RoutineType _selectedType = RoutineType.daily;

  final List<String> _emojiOptions = ['🌱', '💪', '📚', '🏃', '💧', '🧘', '🎯', '✍️', '🎵', '🎨'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 루틴 만들기'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이모지 선택
              Text('이모지 선택', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    _emojiOptions.map((emoji) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = emoji),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedEmoji == emoji ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedEmoji == emoji ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),

              // 제목 입력
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '루틴 이름', hintText: '예: 물 한 잔 마시기', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '루틴 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 설명 입력
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '설명 (선택사항)', hintText: '간단한 설명을 입력하세요', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // 타입 선택
              DropdownButtonFormField<RoutineType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: '루틴 타입', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: RoutineType.daily, child: Text('매일')),
                  DropdownMenuItem(value: RoutineType.weekly, child: Text('주간')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
        ElevatedButton(onPressed: _saveRoutine, child: const Text('만들기')),
      ],
    );
  }

  void _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(routinesProvider.notifier)
          .addRoutine(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            emoji: _selectedEmoji,
            type: _selectedType,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('새 루틴이 등록되었습니다! 🎉'), backgroundColor: Colors.green));
      }
    }
  }
}
