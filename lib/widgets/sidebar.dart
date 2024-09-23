import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final _formKey = GlobalKey<FormState>();
  String scene = '';
  int mapSize = 5;
  int normalCount = 10;
  int rareCount = 5;
  int epicCount = 2;
  int legendCount = 1;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  '基本設定',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'ストーリー背景',
                  hint: '例：魔法の世界での冒険',
                  onSaved: (value) => scene = value!,
                ),
                _buildNumberField(
                  label: 'マップサイズ（3〜10の整数）',
                  hint: '例：5',
                  min: 3,
                  max: 10,
                  initialValue: mapSize.toString(),
                  onSaved: (value) => mapSize = int.parse(value!),
                ),
                _buildNumberField(
                  label: '普通のスキル・アイテム数',
                  hint: '例：10',
                  initialValue: normalCount.toString(),
                  onSaved: (value) => normalCount = int.parse(value!),
                ),
                _buildNumberField(
                  label: '稀有のスキル・アイテム数',
                  hint: '例：5',
                  initialValue: rareCount.toString(),
                  onSaved: (value) => rareCount = int.parse(value!),
                ),
                _buildNumberField(
                  label: '史詩のスキル・アイテム数',
                  hint: '例：2',
                  initialValue: epicCount.toString(),
                  onSaved: (value) => epicCount = int.parse(value!),
                ),
                _buildNumberField(
                  label: '伝説のスキル・アイテム数',
                  hint: '例：1',
                  initialValue: legendCount.toString(),
                  onSaved: (value) => legendCount = int.parse(value!),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _generate,
                  child: Text('生成'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'この項目は必須です' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required String hint,
    int? min,
    int? max,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'この項目は必須です';
          }
          int? intValue = int.tryParse(value);
          if (intValue == null) {
            return '数字を入力してください';
          }
          if (min != null && intValue < min) {
            return '$min以上の数字を入力してください';
          }
          if (max != null && intValue > max) {
            return '$max以下の数字を入力してください';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  void _generate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // ここで生成処理を実行
      Navigator.of(context).pop(); // サイドバーを閉じる
    }
  }
}
