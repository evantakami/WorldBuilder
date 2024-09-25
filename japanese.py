import json
import random
from typing import List, Optional
from langchain.chat_models import ChatOpenAI
from langchain import LLMChain, PromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from pydantic import BaseModel, Field
from tenacity import retry, wait_fixed, stop_after_attempt
import os
from pydantic import BaseModel, Field
from typing import Optional
import re

os.environ['OPENAI_API_KEY'] = 'sk-i1odEy2JL6rHyblZnfzg6EjMPHuVw6ZxTz4oYmrMf9T3BlbkFJ-J2_qf5anL-FyWcNmaZ8tDKtCbwP48hzIXxceSmE4A'
# ChatOpenAI LLMを初期化
llm = ChatOpenAI(temperature=1, max_tokens=1500, model_name="gpt-4o-mini")

# Pydanticデータモデルを定義
class Item(BaseModel):
    name: str = Field(description="アイテム名。創造的でシーンに関連しているべきです。")
    effect: str = Field(description="アイテムの効果や用途。プレイヤーの能力に影響を与えたり、新しいエリアを解放したり、イベントを発生させたりする可能性があります。数値を含む場合、その数値はダイスロールのシステムで表現してください。")
    description: str = Field(description="アイテムの詳細な外観説明。その独特性と魅力を強調してください。")
    rarity: str = Field(description="アイテムの希少度：普通、稀有、史詩、伝説")
    dice_value: Optional[str] = Field(description="アイテム効果数値。ダイスロールシステムで表現（例：1D6、2+1D5）。必要なければ省略可能。")
    durning: int = Field(description="スキルの持続時間。0-5の数値で、0は即時効果、1以上は持続効果。")
class Skill(BaseModel):
    skill_level: str = Field(description="スキルレベル：伝説、史詩、稀有、普通")
    name: str = Field(description="スキル名。創造的でシーンに関連しているべきです。")
    effect: str = Field(description="スキルの効果や用途。プレイヤーの能力に影響を与えたり、新しいエリアを解放したり、イベントを発生させたりする可能性があります。数値を含む場合、その数値はダイスロールのシステムで表現してください。")
    dice_value: Optional[str] = Field(description="スキル効果数値。ダイスロールシステムで表現（例：1D6、2+1D5）。必要なければ省略可能。")
    range: int = Field(description="スキルの範囲。1-5の数値で、1-2は近接スキル、5は遠距離。")
    durning: int = Field(description="スキルの持続時間。0-5の数値で、0は即時スキル、1以上は持続スキル。")
    description: str = Field(description="スキルの詳細な説明。その独特性と魅力を強調してください。")
    category: str = Field(description="スキルのカテゴリ。例：「シールド」、「攻撃」、「特殊」")
    sacrifice: str = Field(description="スキルの消費部位。手足、頭部など。")
    sacrifice_damage: Optional[str] = Field(description="スキルの消費数値。ダイスロールシステムで表現（例：1D4、2+1D3）。必要なければ省略可能。各部位の体力は10を基準に設定。")

def extract_json(response: str) -> str:
    """
    レスポンスから純粋なJSON文字列を抽出します。
    コードブロックや余分な空白を削除します。
    """
    # コードブロックマークを削除
    response = re.sub(r'```json', '', response)
    response = re.sub(r'```', '', response)
    # 前後の空白を削除
    response = response.strip()
    return response


class Tile(BaseModel):
    row: int = Field(description="行番号")
    col: int = Field(description="列番号")
    description: str = Field(description="タイルの詳細な説明。環境や感覚情報を含む")
    items: List[Item] = Field(default_factory=list, description="タイル内のアイテムリスト")
    character: Optional[str] = Field(description="キャラクターの説明。いない場合はnull")

# JsonOutputParserのインスタンスを作成
parser = JsonOutputParser()

# 単一のタイルを生成する関数を定義
@retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
def create_tile(scene, x, y, adjacent_descriptions=None, global_conditions=None):
    # 隣接タイルの説明とグローバル条件のテキストブロックを構築
    adjacent_descriptions_block = ""
    if adjacent_descriptions:
        adjacent_descriptions_block = "**隣接タイルの説明**：\n" + "\n".join(
            [f"- **{direction}**：{desc}" for direction, desc in adjacent_descriptions.items()]
        ) + "\n現在のタイルの説明が隣接タイルと調和し、シーンの連続性を高めるようにしてください。"

    global_conditions_block = ""
    if global_conditions:
        global_conditions_block = "**グローバル条件**：\n" + "\n".join(
            [f"- **{key}**：{value}" for key, value in global_conditions.items()]
        ) + "\nタイルの説明がグローバル条件に適合するようにしてください。"

    # プロンプトテンプレートを定義（jinja2構文を使用し、{{ }}を正しく処理）
    prompt_template = """
あなたは創造性と想像力に富んだマップ生成AIであり、没入型アドベンチャーゲームのためのマップをデザインしています。
プレイヤーはシーン：「{{ scene }}」を提供しました。
今、あなたは座標 ({{ x }}, {{ y }}) に位置する、面積2×2平方メートルのタイルを生成する必要があります。
あなたの目標は、ゲームをより面白く、挑戦的にし、プレイヤーの探索とインタラクションを引きつけることです。

{{ adjacent_descriptions_block }}
{{ global_conditions_block }}

このタイルに対して以下の内容を生成し、隣接タイルの環境と一致させ、シーンの連続性を高めてください：

- **row**：整数、行番号。
- **col**：整数、列番号。
- **description**：文字列。タイルの詳細な説明。環境や感覚情報を含む。シーンの詳細（音、匂い、光と影など）を強調し、主観的な評価は避けてください。
- **character**：デフォルトはnull,
- **furniture**：説明に基づいて生成された、シーンと密接に関連する固定オブジェクト。アイテムがシーンの説明と一致することを確認してください。

結果はJSON形式のみで出力し、追加のテキストや説明は一切含めないでください。出力は有効なJSONである必要があります。

注意：
- 出力のJSON形式が正しく、解析可能であることを確認してください。
- 内容と無関係なテキストは含めないでください。
"""

    # PromptTemplateを作成（jinja2テンプレートを使用）
    tile_prompt_template = PromptTemplate(
        input_variables=[
            "scene",
            "x",
            "y",
            "adjacent_descriptions_block",
            "global_conditions_block",
        ],
        template=prompt_template,
        template_format='jinja2',
    )

    # 最終的なプロンプトをレンダリング
    rendered_prompt = tile_prompt_template.format(
        scene=scene,
        x=x,
        y=y,
        adjacent_descriptions_block=adjacent_descriptions_block,
        global_conditions_block=global_conditions_block,
    )

    # LLMChainを作成
    tile_chain = LLMChain(llm=llm, prompt=PromptTemplate(template=rendered_prompt, input_variables=[]))

    # タイルの内容を生成
    try:
        response = tile_chain.run({})
    except Exception as e:
        print(f"LLMChainの呼び出しに失敗しました：{e}")
        raise e

    # 出力を解析
    try:
        tile_dict = parser.parse(response)
        # 解析された辞書をPydanticオブジェクトに変換し、データ検証を行う
        tile_data = Tile(**tile_dict)
    except Exception as e:
        print(f"解析エラー：{e}")
        print("モデルが返した内容：", response)
        raise e

    return tile_data

# 隣接タイルの説明を取得する関数を定義
def get_adjacent_descriptions(map_grid, x, y):
    directions = {
        "上": (x - 1, y),
        "下": (x + 1, y),
        "左": (x, y - 1),
        "右": (x, y + 1)
    }
    adjacent = {}
    for direction, (adj_x, adj_y) in directions.items():
        if 0 <= adj_x < len(map_grid) and 0 <= adj_y < len(map_grid[0]):
            adjacent_tile = map_grid[adj_x][adj_y]
            if adjacent_tile:
                adjacent[direction] = adjacent_tile.description
    return adjacent if adjacent else None

# 完全なマップを生成する関数を定義
@retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
def generate_full_map(scene, map_size=3, global_conditions=None):
    map_grid = [[None for _ in range(map_size)] for _ in range(map_size)]

    for x in range(map_size):
        for y in range(map_size):
            adjacent_descriptions = get_adjacent_descriptions(map_grid, x, y)
            tile = create_tile(scene, x, y, adjacent_descriptions, global_conditions)
            map_grid[x][y] = tile

    # マップをJSONに保存
    game_map = {'grid': [tile.dict() for row in map_grid for tile in row if tile]}
    with open('generated_map.json', 'w', encoding='utf-8') as f:
        json.dump(game_map, f, ensure_ascii=False, indent=2)

    return map_grid



@retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
def generate_items(scene: str, counts: dict) -> List[Item]:
    items = []
    rarity_levels = [
        ('伝説', counts['legend']),
        ('史詩', counts['epic']),
        ('稀有', counts['rare']),
        ('普通', counts['normal']),
    ]

    for rarity, max_count in rarity_levels:
        prompt = f"""
あなたは創造性に富んだゲームデザイナーであり、「{scene}」をテーマとしたアドベンチャーゲームのアイテムをデザインしています。
武器、防具、薬品、魔法道具など、プレイヤーに役立つアイテムをデザインする必要があります。これらのアイテムは、プレイヤーの戦闘力を増加させたり、生存能力を高めたり、探索能力を向上させたりします。
全体の設定は暗く、スキルを発動するには身体の部位を消耗する必要があります。薬品を設計する際にも、副作用や身体の部位の修復を考慮してください。
このシーンのために{max_count}個の{rarity}アイテムをデザインしてください。

各アイテムには以下の情報が必要です：
- **rarity**："{rarity}"。
- **name**：アイテム名。創造的でシーンに関連しているべきです。アイテムの希少度と一致させてください。普通のアイテム名は一般的で、稀有はやや良く、史詩はさらに良く、伝説のアイテム名は最も独特です。
- **category**：アイテムの分類。武器、防具、薬品、魔法道具
- **effect**：アイテムの効果や用途。プレイヤーの能力に影響を与えたり、装備の特殊効果、または重要なアイテム。アイテムの希少度と一致させてください。普通の効果は弱く、伝説の効果は強力です。
- **dice_value**：スキルの効果数値。**ダイスロールシステムのみを使用して表現してください**（例：1D6、2+1D5）。必要なければ省略可能。普通の効果は弱く、伝説の効果は強力です。
- **range**：スキルの範囲。1-5の数値で、スキルの説明に基づいて設計してください。1-2は近接スキル、5は遠距離。
- **description**：アイテムの詳細な外観説明。その独特性と魅力を強調してください。普通の効果は弱く、伝説の効果は強力です。
- **durning**：スキルの持続時間。0-5の数値で、0は即時スキル、1以上は持続スキル。

結果はJSON形式のみで出力し、アイテムのリストとします。

注意：
- 出力のJSON形式が正しく、解析可能であることを確認してください。
- 内容と無関係なテキストは含めないでください。
"""

        # LLMChainを作成
        item_chain = LLMChain(llm=llm, prompt=PromptTemplate(template=prompt, input_variables=[]))

        # アイテムリストを生成
        try:
            response = item_chain.run({})
        except Exception as e:
            print(f"LLMChainの呼び出しに失敗しました：{e}")
            raise e

        # 出力を解析
        try:
            items_list = parser.parse(response)
            # 解析されたアイテムをアイテムリストに追加
            for item_dict in items_list:
                item_data = Item(**item_dict)
                items.append(item_data)
        except Exception as e:
            print(f"解析エラー：{e}")
            print("モデルが返した内容：", response)
            raise e

    # 生成されたアイテムをJSONファイルに保存
    items_json = json.dumps([item.dict() for item in items], ensure_ascii=False, indent=4)
    with open('items.json', 'w', encoding='utf-8') as f:
        f.write(items_json)
    print("アイテムは'items.json'ファイルに保存されました。")

    return items




@retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
def generate_skills(scene: str, counts: dict) -> List[Skill]:
    skills: List[Skill] = []
    rarity_levels_skill = [
        ('伝説', counts['legend']),
        ('史詩', counts['epic']),
        ('稀有', counts['rare']),
        ('普通', counts['normal']),
    ]


    for level, max_count in rarity_levels_skill:
        prompt = f"""
あなたは創造性に富んだゲームデザイナーであり、「{scene}」をテーマとしたアドベンチャーゲームのスキルをデザインしています。
シールド、攻撃、特殊などのタイプのスキルをデザインする必要があります。これらのスキルは、プレイヤーのゲーム体験を向上させ、戦闘力を増加させたり、生存能力を高めたり、探索能力を向上させたりします。
これらのスキルはすべて、一部の肉体を犠牲にすることで得られます。効果と犠牲にする部位をできるだけ一致させてください。

このシーンのために{max_count}個の{level}スキルをデザインしてください。

各スキルには以下の情報が必要です：
- **skill_level**："{level}"。
- **name**：スキル名。創造的でシーンに関連しているべきです。あまり直球でなく、詩のように、同時に犠牲にする部位と関連性を持たせてください。古代の日本語を使用しても構いません，直接に部分の名前を使わないでください。何々"の"のような命名しないでください。
- **sacrifice**：使用できる重要な部位は："脳","心臓","肺","脊髄","目","耳","肝臓","腎臓","膵臓","脾臓","甲状腺"、二次的な部位は："胃部","左腕","右腕","左脚","右脚","左手","右手","左足","右足","皮膚","腸道"。これら以外の部位は使用しないでください。
- **sacrifice_damage**：スキルの消費数値。**ダイスロールシステムのみを使用して表現してください**（例：1D4、2+1D3）。必要なければ省略可能。重要な部位の最大体力は5、二次的な部位の最大体力は20です。これを基準にスキルの消費数値を設定してください。
- **effect**：スキルの効果や用途。プレイヤーの能力に影響を与えたり、新しいエリアを解放したり、イベントを発生させたりする可能性があります。数値を含む場合、その数値はダイスロールのシステムで表現してください。効果と犠牲にする部位を一致させてください。普通のスキル効果は一般的、稀有のスキルはやや強力、史詩、伝説のスキル効果は非常に強力にできます。
- **category**：スキルのカテゴリ。例：「シールド」、「攻撃」、「特殊」。
- **dice_value**：スキルの効果数値。**ダイスロールシステムのみを使用して表現してください**（例：1D6、2+1D5）。必要なければ省略可能。
- **range**：スキルの範囲。1-5の数値で、スキルの説明に基づいて設計してください。1-2は近接スキル、5は遠距離。
- **description**：スキルの詳細な説明。その独特性と魅力を強調してください。
- **durning**：スキルの持続時間。0-5の数値で、0は即時スキル、1以上は持続スキル。

結果は純粋なJSON形式で出力し、スキルのリストとします。**追加の文章、注釈、コードブロックマークは含めないでください。**

注意：
- 出力のJSON形式が正しく、解析可能であることを確認してください。
- 内容と無関係なテキストは含めないでください。
"""

        # LLMChainを作成
        skill_chain = LLMChain(llm=llm, prompt=PromptTemplate(template=prompt, input_variables=[]))

        # スキルリストを生成
        try:
            response = skill_chain.run({})
            print("LLMが返した原始的な内容：", response)  # デバッグ出力
        except Exception as e:
            print(f"LLMChainの呼び出しに失敗しました：{e}")
            raise e

        # 出力を解析
        try:
            # JSONを抽出
            json_str = extract_json(response)
            print("抽出後のJSON文字列：", json_str)  # デバッグ出力

            skill_list = json.loads(json_str)
            
            # リストであることを確認
            if not isinstance(skill_list, list):
                raise ValueError("生成されたJSONがリストではありません。")

            # 解析されたスキルをスキルリストに追加
            for skill_dict in skill_list:
                skill_data = Skill(**skill_dict)
                skills.append(skill_data)
        except json.JSONDecodeError as e:
            print(f"JSONの解析に失敗しました：{e}")
            print("モデルが返した内容：", response)
            raise e
        except Exception as e:
            print(f"解析エラー：{e}")
            print("モデルが返した内容：", response)
            raise e

    # 生成されたスキルをJSONファイルに保存
    skills_json = json.dumps([skill.dict() for skill in skills], ensure_ascii=False, indent=4)
    with open('skills.json', 'w', encoding='utf-8') as f:
        f.write(skills_json)
    print("スキルは'skills.json'ファイルに保存されました。")


    return skills


# アイテムをタイルに割り当てる関数を定義
def assign_items_to_tiles(items, map_grid):
    # 2次元マップを1次元リストに変換
    tiles = [tile for row in map_grid for tile in row if tile]

    # アイテムの希少度でソートし、希少なアイテムが適切なタイルに優先的に割り当てられるようにする
    items_sorted = sorted(items, key=lambda x: ['普通', '稀有', '史詩', '伝説'].index(x.rarity))

    for item in items_sorted:
        # アイテムの説明に一致するタイルを見つけようとする
        suitable_tiles = []
        for tile in tiles:
            if not tile.items:
                # キーワードマッチング（必要に応じて改良可能）
                if any(keyword in tile.description for keyword in item.description.split()):
                    suitable_tiles.append(tile)

        if suitable_tiles:
            selected_tile = random.choice(suitable_tiles)
        else:
            # 適切なタイルが見つからない場合、アイテムのないタイルをランダムに選択
            available_tiles = [tile for tile in tiles if not tile.items]
            if available_tiles:
                selected_tile = random.choice(available_tiles)
            else:
                print(f"アイテムを配置するための利用可能なタイルがありません：{item.name}")
                continue

        selected_tile.items.append(item)
        print(f"アイテム '{item.name}' がタイル ({selected_tile.row}, {selected_tile.col}) に配置されました")
def generate_game_data(scene_description, map_size, counts):
    items = generate_items(scene_description, counts)
    skills = generate_skills(scene_description, counts)
    map_grid = generate_full_map(scene_description, map_size)
    

    assign_items_to_tiles(items, map_grid)
    

    game_data = {
        'items': [item.dict() for item in items],
        'skills': [skill.dict() for skill in skills],
        'map': {'grid': [tile.dict() for row in map_grid for tile in row if tile]}
    }
    
    return game_data
