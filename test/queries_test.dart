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
  const charmander = Pokemon(
    id: 4,
    name: 'charmander',
    height: 6,
    weight: 85,
    baseExperience: 62,
    type: PokemonType.fire,
  );
  const bulbasaur = Pokemon(
    id: 1,
    name: 'bulbasaur',
    height: 7,
    weight: 69,
    baseExperience: 64,
    type: PokemonType.grass,
  );
  final all = [pikachu, charmander, bulbasaur];

  group('пошук і фільтрація', () {
    test('searchByName шукає за частиною імені без урахування регістру', () {
      expect(searchByName(all, 'CHAR'), [charmander]);
    });

    test('searchByName повертає порожній список, якщо нічого не знайдено', () {
      expect(searchByName(all, 'zzz'), isEmpty);
    });

    test('filterByType залишає лише потрібний тип', () {
      expect(filterByType(all, PokemonType.fire), [charmander]);
      expect(filterByType(all, PokemonType.water), isEmpty);
    });
  });

  group('сортування', () {
    test('за id за зростанням', () {
      final sorted = sortPokemon(all, SortField.id);
      expect(sorted.map((p) => p.id), [1, 4, 25]);
    });

    test('за базовим досвідом за спаданням', () {
      final sorted =
          sortPokemon(all, SortField.baseExperience, ascending: false);
      expect(sorted.map((p) => p.name), ['pikachu', 'bulbasaur', 'charmander']);
    });

    test('не змінює початковий список', () {
      sortPokemon(all, SortField.name);
      expect(all.first, pikachu);
    });
  });
}
