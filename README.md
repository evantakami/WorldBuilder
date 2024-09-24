# WorldcBuilder 🎮
![alt text](images/webui_flutter.png)
## In the future
- **Add NPC generation**:Every NPC will have a Agent powered by LLM  
- **Add quest generation**:A quest line will be generater by LLM for every NPC every NPC will follow their purpose.  
- **Add map control**: Beable to control the tile type such as sturucture,special tile...  
- **Add png**:The app will be able to choose the png of the tile/item/skill by the tag created by LLM.  
flowchart TD
    A[Start] --> B[User Input]
    B --> C[Send Request to Backend]
    C --> D[Generate Game Data]
    D --> E[Generate Items Agent]
    D --> F[Generate Skills Agent]
    D --> G[Generate Map]
    G --> H[Create Tile Agent]
    H --> I[Extract JSON]
    E --> I
    F --> I
    I --> J[Return Data]
    J --> K[Display Data]
    K --> L[End]
## Description
WorldcBuilder is a Flutter-based application designed to help users create their own role-playing games (RPGs). This project serves as a starting point for developing a fully functional RPG creator, providing essential features and a user-friendly interface. The application leverages AI to generate game elements dynamically, enhancing creativity and gameplay experience. Get ready to unleash your imagination! ✨

## Features
- **Dynamic Map Generation**: Create immersive game maps with unique tiles and descriptions. 🗺️
- **Item and Skill Creation**: Generate items and skills with specific effects, rarity levels, and descriptions. ⚔️
- **AI Integration**: Utilizes AI models to assist in generating creative content for the game. 🤖

## Getting Started

### Prerequisites
- Flutter SDK installed on your machine.
- An IDE such as Android Studio, Visual Studio Code, or IntelliJ IDEA.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Evantakami/WorldBuilder.git
   cd WorldBuilder
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Usage
Once the application is running, you can start creating your RPG by following the on-screen instructions. Explore various features to customize your game, including skill/item creation, map building, Let your adventure begin! 🌟

## Resources
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

## Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
