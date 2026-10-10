import 'pokemon.dart';
import 'storable.dart';
import 'trainer.dart';

// Усі дані застосунку, які зберігаються у data.json.
class AppData implements Storable {
  AppData({List<Pokemon>? pokemon, List<Trainer>? trainers})
      : pokemon = pokemon ?? <Pokemon>[],
        trainers = trainers ?? <Trainer>[];

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      pokemon: _parseList(json['pokemon'], Pokemon.fromJson, 'pokemon'),
      trainers: _parseList(json['trainers'], Trainer.fromJson, 'trainers'),
    );
  }

  final List<Pokemon> pokemon;
  final List<Trainer> trainers;

  Pokemon? findPokemon(int id) {
    for (final item in pokemon) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Trainer? findTrainer(String name) {
    final key = name.trim().toLowerCase();
    for (final trainer in trainers) {
      if (trainer.name.toLowerCase() == key) {
        return trainer;
      }
    }
    return null;
  }

  // Повертає false, якщо покемон з таким id уже є.
  bool addPokemon(Pokemon item) {
    if (findPokemon(item.id) != null) {
      return false;
    }
    pokemon.add(item);
    return true;
  }

  // Видаляє покемона й прибирає його id з усіх тренерів.
  bool removePokemon(int id) {
    final before = pokemon.length;
    pokemon.removeWhere((item) => item.id == id);
    for (final trainer in trainers) {
      trainer.pokemonIds.remove(id);
    }
    return pokemon.length != before;
  }

  @override
  Map<String, dynamic> toJson() => {
        'pokemon': pokemon.map((item) => item.toJson()).toList(),
        'trainers': trainers.map((item) => item.toJson()).toList(),
      };
}

List<T> _parseList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) parse,
  String label,
) {
  if (raw is! List) {
    throw FormatException('Поле "$label" має бути списком.');
  }
  return raw.map((element) {
    if (element is! Map<String, dynamic>) {
      throw FormatException('Елемент у "$label" має бути обʼєктом.');
    }
    return parse(element);
  }).toList();
}
