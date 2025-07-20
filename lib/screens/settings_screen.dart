import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.settings_rounded), SizedBox(width: 8), Text('설정', style: TextStyle(fontWeight: FontWeight.bold))],
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // 앱 정보 섹션
          _buildSection(context, '앱 정보', [
            _buildInfoTile(context, icon: Icons.info_outline, title: '루틴트리', subtitle: '버전 1.0.0', onTap: () => _showAboutDialog(context)),
          ]),

          // 알림 섹션
          _buildSection(context, '알림', [
            _buildSwitchTile(
              context,
              icon: Icons.notifications_outlined,
              title: '푸시 알림',
              subtitle: '루틴 알림 받기',
              value: true, // TODO: SharedPreferences로 관리
              onChanged: (value) {
                // TODO: 알림 설정 변경
              },
            ),
            _buildInfoTile(
              context,
              icon: Icons.schedule,
              title: '알림 시간 설정',
              subtitle: '기본 알림 시간 변경',
              onTap: () {
                // TODO: 시간 선택 다이얼로그
              },
            ),
          ]),

          // 데이터 섹션
          _buildSection(context, '데이터', [
            _buildInfoTile(
              context,
              icon: Icons.backup_outlined,
              title: '데이터 백업',
              subtitle: '루틴 데이터 내보내기',
              onTap: () {
                // TODO: 백업 기능
              },
            ),
            _buildInfoTile(
              context,
              icon: Icons.restore_outlined,
              title: '데이터 복원',
              subtitle: '백업된 데이터 가져오기',
              onTap: () {
                // TODO: 복원 기능
              },
            ),
            _buildInfoTile(
              context,
              icon: Icons.delete_outline,
              title: '모든 데이터 삭제',
              subtitle: '앱의 모든 데이터 삭제',
              onTap: () => _showDeleteConfirmDialog(context),
              textColor: Colors.red,
            ),
          ]),

          // 기타 섹션
          _buildSection(context, '기타', [
            _buildInfoTile(
              context,
              icon: Icons.help_outline,
              title: '도움말',
              subtitle: '앱 사용법 보기',
              onTap: () {
                // TODO: 도움말 화면
              },
            ),
            _buildInfoTile(
              context,
              icon: Icons.star_outline,
              title: '앱 평가',
              subtitle: '앱스토어에서 평가하기',
              onTap: () {
                // TODO: 앱스토어 링크
              },
            ),
            _buildInfoTile(
              context,
              icon: Icons.share_outlined,
              title: '앱 공유',
              subtitle: '친구에게 루틴트리 공유하기',
              onTap: () {
                // TODO: 공유 기능
              },
            ),
          ]),

          const SizedBox(height: 100), // 하단 여백
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).colorScheme.onSurface),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '루틴트리',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('🌳', style: TextStyle(fontSize: 48)),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            '습관을 키우면서 나무를 성장시키는 앱입니다.\n'
            '매일 작은 습관들이 모여 큰 숲을 만들어가세요! 🌲',
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('⚠️ 주의'),
            content: const Text(
              '모든 데이터가 영구적으로 삭제됩니다.\n'
              '이 작업은 되돌릴 수 없습니다.\n\n'
              '정말 삭제하시겠습니까?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 데이터 삭제 구현
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 데이터가 삭제되었습니다'), backgroundColor: Colors.red));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }
}
