import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import 'create_team_page.dart';

class TeamListPage extends StatelessWidget {
  const TeamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    return Scaffold(
      appBar: AppBar(title: const Text('รายชื่อทีม')),
      body: Obx(() {
        if (c.savedTeams.isEmpty) return const Center(child: Text('ยังไม่มีทีมที่บันทึก'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: c.savedTeams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final t = c.savedTeams[i];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(t.name),
                subtitle: Row(
                  children: t.members.take(3).map((m) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(backgroundImage: NetworkImage(m.imageUrl)),
                  )).toList(),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'rename') {
                      final newName = await _askRename(context, t.name);
                      if (newName != null) c.renameTeam(t.id, newName);
                    } else if (v == 'edit') {
                      Get.to(() => CreateTeamPage(editTeamId: t.id));
                    } else if (v == 'delete') {
                      final ok = await _confirmDelete(context);
                      if (ok == true) c.deleteTeam(t.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('เปลี่ยนชื่อทีม')),
                    PopupMenuItem(value: 'edit', child: Text('แก้สมาชิกทีม')),
                    PopupMenuItem(value: 'delete', child: Text('ลบทีม')),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<String?> _askRename(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เปลี่ยนชื่อทีม'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('บันทึก')),
        ],
      ),
    );
    ctrl.dispose();
    return name;
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบทีม'),
        content: const Text('ต้องการลบทีมนี้หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
        ],
      ),
    );
  }
}
