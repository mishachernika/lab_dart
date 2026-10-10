import '../models/pokemon.dart';
import '../models/pokemon_type.dart';

enum SortField { id, name, height, weight, baseExperience }

// Пошук за частиною імені (без урахування регістру).
List<Pokemon> searchByName(List<Pokemon> list, String query) {
  final key = query.trim().toLowerCase();
  return list.where((item) => item.name.toLowerCase().contains(key)).toList();
}

List<Pokemon> filterByType(List<Pokemon> list, PokemonType type) {
  return list.where((item) => item.type == type).toList();
}

// Повертає новий відсортований список, початковий не змінюється.
List<Pokemon> sortPokemon(
  List<Pokemon> list,
  SortField field, {
  bool ascending = true,
}) {
  final copy = List<Pokemon>.of(list);
  copy.sort((a, b) {
    final result = switch (field) {
      SortField.id => a.id.compareTo(b.id),
      SortField.name => a.name.compareTo(b.name),
      SortField.height => a.height.compareTo(b.height),
      SortField.weight => a.weight.compareTo(b.weight),
      SortField.baseExperience => a.baseExperience.compareTo(b.baseExperience),
    };
    return ascending ? result : -result;
  });
  return copy;
}
