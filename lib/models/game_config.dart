class GameConfig {
  final String id;
  final String name;
  final String gameType;
  final Map<String, dynamic> design;
  final List<GameLevel> levels;
  final Map<String, dynamic> sounds;
  final Map<String, dynamic> icon;
  final Map<String, dynamic> settings;
  final List<CoinPackConfig> coinPacks;

  GameConfig({
    required this.id,
    required this.name,
    required this.gameType,
    required this.design,
    required this.levels,
    required this.sounds,
    required this.icon,
    required this.settings,
    required this.coinPacks,
  });

  factory GameConfig.fromMap(Map<String, dynamic> m) {
    return GameConfig(
      id: m['id'] ?? '',
      name: m['name'] ?? '',
      gameType: m['gameType'] ?? 'guess_picture',
      design: Map<String, dynamic>.from(m['design'] ?? {}),
      levels: (m['levels'] as List?)?.map((l) => GameLevel.fromMap(l)).toList() ?? [],
      sounds: Map<String, dynamic>.from(m['sounds'] ?? {}),
      icon: Map<String, dynamic>.from(m['icon'] ?? {}),
      settings: Map<String, dynamic>.from(m['settings'] ?? {}),
      coinPacks: (m['coinPacks'] as List?)?.map((p) => CoinPackConfig.fromMap(p)).toList() ?? [],
    );
  }
}

class GameLevel {
  final String id;
  final int order;
  final String imageUrl;
  final String question;
  final String answer;
  final List<String> options;
  final int coinsReward;
  final String hint;

  GameLevel({
    required this.id, required this.order, this.imageUrl = '',
    this.question = '', required this.answer, this.options = const [],
    this.coinsReward = 10, this.hint = '',
  });

  factory GameLevel.fromMap(Map<String, dynamic> m) => GameLevel(
    id: m['id'] ?? '', order: m['order'] ?? 0, imageUrl: m['imageUrl'] ?? '',
    question: m['question'] ?? '', answer: m['answer'] ?? '',
    options: List<String>.from(m['options'] ?? []),
    coinsReward: m['coinsReward'] ?? 10, hint: m['hint'] ?? '',
  );
}

class CoinPackConfig {
  final String id;
  final String name;
  final int coins;
  final double price;

  CoinPackConfig({required this.id, required this.name, required this.coins, required this.price});

  factory CoinPackConfig.fromMap(Map<String, dynamic> m) => CoinPackConfig(
    id: m['id'] ?? '', name: m['name'] ?? '',
    coins: m['coins'] ?? 0, price: (m['price'] ?? 0).toDouble(),
  );
}