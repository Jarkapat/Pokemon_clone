import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';

/// ใช้หน้าเดียวทั้ง "สร้างทีม" และ "แก้ไขทีม"
/// - ถ้า [editTeamId] == null  => โหมดสร้างทีมใหม่
/// - ถ้า [editTeamId] != null  => โหมดแก้ไขสมาชิกทีมเดิม
class CreateTeamPage extends StatefulWidget {
  final String? editTeamId;
  const CreateTeamPage({super.key, this.editTeamId});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final c = Get.find<TeamController>();

  @override
  void initState() {
    super.initState();
    // ให้สองโหมดใช้ workflow เดียวกัน: มี draftTeam เหมือนกัน
    if (widget.editTeamId != null) {
      c.loadDraftFromTeam(widget.editTeamId!);  // เติมสมาชิกเดิมเข้ามา
    } else {
      c.resetDraft();                           // เริ่มจากว่าง
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editTeamId != null;

    return Scaffold(
      appBar: AppBar(
        // หัวข้อเดียวกันทั้งสองโหมด
        title: Obx(() => Text('เลือก 3 ตัว (${c.draftTeam.length}/3)')),
        actions: [
          // ปุ่มยืนยัน เหมือนกันทั้งสองโหมด
          Obx(() => TextButton(
                onPressed: c.draftReady
                    ? () async {
                        if (isEdit) {
                          // โหมดแก้ไข: เซฟสมาชิกใหม่ให้ทีมเดิม
                          c.updateTeamMembers(widget.editTeamId!);
                          Get.back();
                        } else {
                          // โหมดสร้าง: ขอชื่อทีม แล้วบันทึก
                          final name = await _askTeamName(context);
                          if (name != null) {
                            c.confirmCreateTeam(name);
                            Get.back();
                          }
                        }
                      }
                    : null,
                child: Text('ยืนยัน',
                    style: TextStyle(
                      color: c.draftReady
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                    )),
              )),
        ],
      ),

      body: Obx(() {
        final list = c.filtered.isEmpty ? c.pokemons : c.filtered;

        return Column(
          children: [
            // ช่องค้นหา (ใช้ query เดียวกัน)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'ค้นหาโปเกมอน',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => c.query.value = v,
              ),
            ),

            // แถวแสดงตัวที่เลือกอยู่ (ลบออกจาก draft ได้)
            SizedBox(
              height: 88,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: c.draftTeam.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final p = c.draftTeam[i];
                  return InputChip(
                    avatar: CircleAvatar(backgroundImage: NetworkImage(p.imageUrl)),
                    label: Text(p.name),
                    onDeleted: () => c.draftToggle(p),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // กริดเลือกตัวละคร (สไตล์เดียวกับการ์ดหน้า Home: ขอบเขียวเมื่อเลือก + BST)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,            // ปรับได้ตามต้องการ
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 220,          // สูงพอสำหรับ BST + รูป + ชื่อ + เส้นสถานะ
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  final selected = c.isInDraft(p);

                  // โหลดค่าสถานะแบบ on-demand เพื่อคำนวณ BST
                  c.ensureStats(p.id);
                  final s = c.stats[p.id];
                  final bst = s == null
                      ? null
                      : (s.hp + s.atk + s.def + s.spAtk + s.spDef + s.speed);

                  final borderColor = selected
                      ? Colors.green
                      : Theme.of(context).dividerColor;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => c.draftToggle(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: borderColor,
                          width: selected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        children: [
                          // แถวบน: BST อย่างเดียว (ไม่มีไอคอนบวก/ติ๊ก)
                          Row(
                            children: [
                              Text(
                                bst == null ? 'BST —' : 'BST $bst',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // รูปโปเกมอน
                          SizedBox(
                            height: 90,
                            child: Image.network(p.imageUrl, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 8),

                          // ชื่อ
                          Text(
                            p.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // เส้นแถบสั้นๆ เน้นตอนเลือก (ลบได้ถ้าไม่ต้องการ)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 3,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: selected ? Colors.green : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<String?> _askTeamName(BuildContext context) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ตั้งชื่อทีม'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'เช่น My Trio'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('ยืนยัน')),
        ],
      ),
    );
    ctrl.dispose();
    return name;
  }
}
