from flask import Flask, render_template, request, jsonify
from flask_cors import CORS  # 导入CORS
import json
from japanese import generate_game_data

app = Flask(__name__)
CORS(app)  # 启用CORS

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/generate', methods=['POST'])
def generate():
    data = request.get_json()
    scene = data['scene']
    map_size = int(data['mapSize'])
    counts = {
        'normal': int(data['normalCount']),
        'rare': int(data['rareCount']),
        'epic': int(data['epicCount']),
        'legend': int(data['legendCount'])
    }

    try:
        game_data = generate_game_data(scene, map_size, counts)
        return jsonify(game_data)
    except Exception as e:
        print(f"Error generating game data: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
