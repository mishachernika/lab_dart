import 'pokemon_type.dart';
import 'storable.dart';

class Pokemon implements Storable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.type,
  });

  // Відновлення з нашого файлу data.json.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final height = json['height'];
    final weight = json['weight'];
    final baseExperience = json['baseExperience'];
    final type = json['type'];
    if (id is! int ||
        name is! String ||
        height is! int ||
        weight is! int ||
        baseExperience is! int ||
        type is! String) {
      throw FormatException('Некоректні дані покемона: $json');
    }
    return Pokemon(
      id: id,
      name: name,
      height: height,
      weight: weight,
      baseExperience: baseExperience,
      type: PokemonType.fromName(type),
    );
  }

  // Розбір відповіді PokeAPI (https://pokeapi.co/api/v2/pokemon/pikachu).
  factory Pokemon.fromApi(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! int || name is! String) {
      throw const FormatException('Відповідь API не містить id або name.');
    }
    final height = json['height'];
    final weight = json['weight'];
    final baseExperience = json['base_experience'];

    var type = PokemonType.other;
    final types = json['types'];
    if (types is List && types.isNotEmpty) {
      final first = types.first;
      if (first is Map<String, dynamic>) {
        final typeInfo = first['type'];
        if (typeInfo is Map<String, dynamic>) {
          final typeName = typeInfo['name'];
          if (typeName is String) {
            type = PokemonType.fromName(typeName);
          }
        }
      }
    }

    return Pokemon(
      id: id,
      name: name,
      height: height is int ? height : 0,
      weight: weight is int ? weight : 0,
      baseExperience: baseExperience is int ? baseExperience : 0,
      type: type,
    );
  }

  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final PokemonType type;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'height': height,
        'weight': weight,
        'baseExperience': baseExperience,
        'type': type.name,
      };

  @override
  bool operator ==(Object other) =>
      other is Pokemon &&
      other.id == id &&
      other.name == name &&
      other.height == height &&
      other.weight == weight &&
      other.baseExperience == baseExperience &&
      other.type == type;

  @override
  int get hashCode =>
      Object.hash(id, name, height, weight, baseExperience, type);

  @override
  String toString() =>
      '#$id $name [${type.name}] зріст: $height, вага: $weight, досвід: $baseExperience';
}
