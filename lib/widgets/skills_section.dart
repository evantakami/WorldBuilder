import 'package:flutter/material.dart';

class SkillsSection extends StatelessWidget {
  final List<Map<String, String>> skills = [
    {'name': 'ファイアボール', 'description': '火の玉を放つ魔法', 'rarity': 'normal'},
    // 他のスキルを追加
  ];

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: '生成されたスキル',
      items: skills,
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Column(
            children: items.map((item) {
              return ListTile(
                title: Text(
                  item['name']!,
                  style: TextStyle(
                    color: _getRarityColor(item['rarity']!),
                  ),
                ),
                subtitle: Text(item['description']!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'normal':
        return Colors.black;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legend':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
