// Довідник типів покемонів.
enum PokemonType {
  normal,
  fire,
  water,
  electric,
  grass,
  ice,
  fighting,
  poison,
  ground,
  flying,
  psychic,
  bug,
  rock,
  ghost,
  dragon,
  dark,
  steel,
  fairy,
  other;

  // Повертає тип за назвою; невідомі назви стають other.
  static PokemonType fromName(String? name) {
    for (final type in values) {
      if (type.name == name) {
        return type;
      }
    }
    return other;
  }
}
