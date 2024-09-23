import 'package:flutter/material.dart';

class MapSection extends StatelessWidget {
  final int mapSize;

  MapSection({this.mapSize = 5});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'マップ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: mapSize * mapSize,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mapSize,
            ),
            itemBuilder: (context, index) {
              return GridTile(
                child: Container(
                  margin: EdgeInsets.all(2),
                  color: Colors.green[200],
                  child: Center(
                    child: Text(''),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
