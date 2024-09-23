import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(BasicSettingsApp());
}

class BasicSettingsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '基本設定作成ツール',
      theme: ThemeData(
        primaryColor: Color(0xFF1e88e5), // 深蓝色按钮
        fontFamily: 'NotoSansJP',
        scaffoldBackgroundColor: Color(0xFFF5F5F5), // 背景颜色浅灰色
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1e88e5), // 按钮和其他可交互元素的颜色
          secondary: Color(0xFF4fc3f7), // 浅蓝色高亮
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// 定义稀有度对应的颜色
const Map<String, Color> rarityColors = {
  '普通': Colors.black,
  '稀有': Color(0xFF42A5F5),
  '史詩': Color(0xFF7E57C2),
  '伝説': Color(0xFFFF7043),
};

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  String scene = '';
  int mapSize = 5;
  int normalCount = 10;
  int rareCount = 5;
  int epicCount = 2;
  int legendCount = 1;

  bool isLoading = false;
  Map<String, dynamic>? gameData;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> requestData = {
        'scene': scene,
        'mapSize': mapSize,
        'normalCount': normalCount,
        'rareCount': rareCount,
        'epicCount': epicCount,
        'legendCount': legendCount,
      };

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          setState(() {
            gameData = jsonDecode(response.body);
          });
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to connect to server: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Color _getColorByRarity(String rarity) {
    return rarityColors[rarity] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('基本設定作成ツール'),
      ),
      body: Row(
        children: [
          // 左侧边栏：表单
          Container(
            width: 260,
            color: Color(0xFFE3F2FD), // 侧边栏背景颜色浅蓝色
            child: _buildForm(),
          ),
          // 主内容区域
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : gameData == null
                    ? Center(child: Text('左側のフォームのストーリー背景を詳しく書いてください！それから「生成」ボタンをクリックしてください。あなたの物語を作りましょう'))
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本情報',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 标题字体加大
            ),
            SizedBox(height: 10),
            // 调整输入框为多行输入
            TextFormField(
              decoration: InputDecoration(labelText: 'ストーリー背景'),
              maxLines: 3, // 使输入框更大
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'この項目は必須です';
                }
                return null;
              },
              onSaved: (value) => scene = value!,
            ),
            SizedBox(height: 20),
            Text(
              '設定',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'マップサイズ'),
              keyboardType: TextInputType.number,
              initialValue: mapSize.toString(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'この項目は必須です';
                }
                return null;
              },
              onSaved: (value) => mapSize = int.parse(value!),
            ),
            SizedBox(height: 20),
            Text(
              'スキル・アイテム数',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: '普通'),
              keyboardType: TextInputType.number,
              initialValue: normalCount.toString(),
              onSaved: (value) => normalCount = int.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '稀有'),
              keyboardType: TextInputType.number,
              initialValue: rareCount.toString(),
              onSaved: (value) => rareCount = int.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '史詩'),
              keyboardType: TextInputType.number,
              initialValue: epicCount.toString(),
              onSaved: (value) => epicCount = int.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '伝説'),
              keyboardType: TextInputType.number,
              initialValue: legendCount.toString(),
              onSaved: (value) => legendCount = int.parse(value!),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('生成'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // 地图区域
            Container(
              width: constraints.maxWidth * 0.5,
              padding: EdgeInsets.all(16), // 增加内边距
              child: _buildMap(),
            ),
            // 技能和道具列表
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 技能标题
                    Text(
                      'スキル',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      flex: 3, // 增加技能部分的高度比例
                      child: _buildSkills(),
                    ),
                    SizedBox(height: 20), // 技能和道具之间的间距
                    // 道具标题
                    Text(
                      'アイテム',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      flex: 2, // 保持道具部分的高度比例
                      child: _buildItems(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap() {
    if (gameData == null || !gameData!.containsKey('map')) return Container();

    final mapData = gameData!['map'];
    final gridSize = mapSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        double cellSize =
            ((constraints.maxWidth - (gridSize * 4)) / gridSize).clamp(20.0, 50.0);

        return Center(
          child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200], // 地图背景颜色
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                childAspectRatio: 1.0,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                final tile = mapData['grid'][index];
                return MouseRegion(
                  onEnter: (event) {
                    _showOverlay(context, tile, event);
                  },
                  onExit: (event) {
                    _hideOverlay();
                  },
                  child: Container(
                    margin: EdgeInsets.all(4), // 增加格子之间的间距
                    decoration: BoxDecoration(
                      color: tile['items'].length > 0 ? Colors.yellow[200] : Colors.green[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8), // 格子增加圆角
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    width: cellSize,
                    height: cellSize,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  OverlayEntry? _overlayEntry;

  void _showOverlay(
      BuildContext context, Map<String, dynamic> data, PointerEvent event) {
    final overlay = Overlay.of(context)!;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: event.position.dx + 10,
        top: event.position.dy + 10,
        child: Material(
          elevation: 4,
          child: Container(
            width: 200,
            padding: EdgeInsets.all(8),
            color: Colors.white,
            child: Text(
              _buildOverlayText(data),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  String _buildOverlayText(Map<String, dynamic> data) {
    if (data.containsKey('effect')) {
      // 技能或道具
      return '名前: ${data['name']}\n'
          '效果: ${data['effect']}\n'
          'カテゴリ: ${data['category'] ?? data['rarity']}\n'
          '情報: ${data['description']}';
    } else {
      // 地图格子
      return '座標: (${data['row']}, ${data['col']})\n'
          '情報: ${data['description']}\n'
          'アイテム: ${data['items'].length > 0 ? data['items'].map((item) => item['name']).join(', ') : '无'}';
    }
  }

  Widget _buildSkills() {
    if (gameData == null || !gameData!.containsKey('skills')) return Container();

    final skills = gameData!['skills'];

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 每行两列显示技能
        crossAxisSpacing: 16, // 列之间的间距
        mainAxisSpacing: 16, // 行之间的间距
        childAspectRatio: 2.3, // 调整每个格子的高度比例，使其约为道具容器1.3倍
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return SkillWidget(skill: skill);
      },
    );
  }

  Widget _buildItems() {
    if (gameData == null || !gameData!.containsKey('items')) return Container();

    final items = gameData!['items'];

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 每行两列显示道具
        crossAxisSpacing: 16, // 列之间的间距
        mainAxisSpacing: 16, // 行之间的间距
        childAspectRatio: 3, // 保持道具部分的高度比例不变
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemWidget(item: item);
      },
    );
  }
}

class SkillWidget extends StatelessWidget {
  final Map<String, dynamic> skill;

  SkillWidget({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 200, // 设置技能容器的最大高度
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // 增加内边距
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill['name'], // 技能名称使用特殊颜色
                style: TextStyle(
                  color: _getColorByRarity(skill['skill_level']),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text('効果: ${skill['effect']}', style: TextStyle(color: Colors.black)), // 黑色字体的效果信息
              Text('サイコロ値: ${skill['dice_value']}', style: TextStyle(color: Colors.black)),
              Text('持続時間: ${skill['durning']}ターン', style: TextStyle(color: Colors.black)),
              Text('犠牲パーツ: ${skill['sacrifice']}', style: TextStyle(color: Colors.black)),
              Text('犠牲ダメージ: ${skill['sacrifice_damage']}', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorByRarity(String skillLevel) {
    switch (skillLevel) {
      case '普通':
        return Colors.black;
      case '稀有':
        return Colors.blue;
      case '史詩':
        return Colors.purple;
      case '伝説':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class ItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  ItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 200, // 设置道具容器的最大高度
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // 增加内边距
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'], // 物品名称使用特殊颜色
                style: TextStyle(
                  color: _getColorByRarity(item['rarity']),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text('効果: ${item['effect']}', style: TextStyle(color: Colors.black)), // 黑色字体的效果信息
              Text('サイコロ値: ${item['dice_value'] ?? "なし"}', style: TextStyle(color: Colors.black)),
              Text('持続時間: ${item['durning']}ターン', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorByRarity(String rarity) {
    switch (rarity) {
      case '普通':
        return Colors.black;
      case '稀有':
        return Colors.blue;
      case '史詩':
        return Colors.purple;
      case '伝説':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

