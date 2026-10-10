import 'storable.dart';

// Тренер зберігає id покемонів, яких упіймав (звʼязок з моделлю Pokemon).
class Trainer implements Storable {
  Trainer({required this.name, List<int>? pokemonIds})
      : pokemonIds = pokemonIds ?? <int>[];

  factory Trainer.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final ids = json['pokemonIds'];
    if (name is! String || ids is! List || ids.any((e) => e is! int)) {
      throw FormatException('Некоректні дані тренера: $json');
    }
    return Trainer(name: name, pokemonIds: ids.cast<int>().toList());
  }

  final String name;
  final List<int> pokemonIds;

  // Повертає false, якщо покемон уже є в тренера.
  bool catchPokemon(int id) {
    if (pokemonIds.contains(id)) {
      return false;
    }
    pokemonIds.add(id);
    return true;
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'pokemonIds': List<int>.of(pokemonIds),
      };

  @override
  String toString() => '$name (покемонів: ${pokemonIds.length})';
}
