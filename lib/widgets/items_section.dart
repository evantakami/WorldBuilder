import 'package:flutter/material.dart';

class ItemsSection extends StatelessWidget {
  final List<Map<String, String>> items = [
    {'name': 'ヒーリングポーション', 'description': 'HPを回復する薬', 'rarity': 'normal'},
    // 他のアイテムを追加
  ];

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: '生成されたアイテム',
      items: items,
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
