import 'package:lab_dart/lab_dart.dart';
import 'package:test/test.dart';

void main() {
  const pikachu = Pokemon(
    id: 25,
    name: 'pikachu',
    height: 4,
    weight: 60,
    baseExperience: 112,
    type: PokemonType.electric,
  );

  group('Pokemon', () {
    test('toJson повертає правильну мапу', () {
      expect(pikachu.toJson(), {
        'id': 25,
        'name': 'pikachu',
        'height': 4,
        'weight': 60,
        'baseExperience': 112,
        'type': 'electric',
      });
    });

    test('fromJson відновлює обʼєкт (туди й назад)', () {
      final restored = Pokemon.fromJson(pikachu.toJson());
      expect(restored, equals(pikachu));
    });

    test('fromJson кидає FormatException без обовʼязкових полів', () {
      expect(
        () => Pokemon.fromJson({'id': 1, 'name': 'x'}),
        throwsFormatException,
      );
    });

    test('fromApi розбирає відповідь PokeAPI', () {
      final pokemon = Pokemon.fromApi({
        'id': 25,
        'name': 'pikachu',
        'height': 4,
        'weight': 60,
        'base_experience': 112,
        'types': [
          {
            'slot': 1,
            'type': {'name': 'electric', 'url': 'https://pokeapi.co/api/v2/type/13/'},
          },
        ],
      });
      expect(pokemon, equals(pikachu));
    });

    test('fromApi: немає типу й досвіду - підставляє other і 0', () {
      final pokemon = Pokemon.fromApi({'id': 1, 'name': 'x'});
      expect(pokemon.type, PokemonType.other);
      expect(pokemon.baseExperience, 0);
    });

    test('fromApi кидає FormatException без id', () {
      expect(() => Pokemon.fromApi({'name': 'x'}), throwsFormatException);
    });
  });

  group('AppData', () {
    test('toJson і fromJson зберігають покемонів і тренерів', () {
      final data = AppData(
        pokemon: [pikachu],
        trainers: [Trainer(name: 'Ash', pokemonIds: [25])],
      );
      final restored = AppData.fromJson(data.toJson());
      expect(restored.pokemon, [pikachu]);
      expect(restored.trainers.single.name, 'Ash');
      expect(restored.trainers.single.pokemonIds, [25]);
    });

    test('addPokemon не додає дублікат за id', () {
      final data = AppData();
      expect(data.addPokemon(pikachu), isTrue);
      expect(data.addPokemon(pikachu), isFalse);
      expect(data.pokemon, hasLength(1));
    });

    test('removePokemon прибирає покемона й його id у тренерів', () {
      final data = AppData(
        pokemon: [pikachu],
        trainers: [Trainer(name: 'Ash', pokemonIds: [25])],
      );
      expect(data.removePokemon(25), isTrue);
      expect(data.pokemon, isEmpty);
      expect(data.trainers.single.pokemonIds, isEmpty);
      expect(data.removePokemon(25), isFalse);
    });
  });
}
