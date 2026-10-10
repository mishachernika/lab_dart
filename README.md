# lab_dart - колекція покемонів

Консольний застосунок на Dart (лабораторна робота 1-2). Зберігає колекцію
покемонів і тренерів у файлі `data.json`, отримує дані з відкритого REST API
[PokeAPI](https://pokeapi.co) (варіант 6, без авторизації).

## Запуск

```bash
dart pub get
dart run bin/main.dart
```

Меню: показати список, додати вручну, завантажити з API, видалити,
пошук за назвою, фільтр за типом, сортування, тренери, вихід.
Дані записуються в `data.json` після кожної зміни й зчитуються під час запуску.

## Використане API

- Адреса запиту: `https://pokeapi.co/api/v2/pokemon/pikachu`
  (замість `pikachu` можна вказати ID, наприклад `25`)
- З відповіді береться: `id`, `name`, `height`, `weight`, `base_experience`
  та перший елемент `types` (`types[0].type.name`).
- Скорочений приклад відповіді:

```json
{
  "id": 25,
  "name": "pikachu",
  "height": 4,
  "weight": 60,
  "base_experience": 112,
  "types": [{ "slot": 1, "type": { "name": "electric" } }]
}
```

Помилки (немає інтернету, 404, 5xx, некоректний JSON, перевищено час
очікування) обробляються: застосунок повідомляє про проблему й продовжує
працювати з локальними даними.

## Структура

```
bin/main.dart                    меню
lib/models/                      Storable, Pokemon, Trainer, PokemonType (enum), AppData
lib/services/pokemon_api.dart    запити до PokeAPI (приймає http.Client)
lib/services/pokemon_queries.dart пошук, фільтр, сортування
lib/repositories/                робота з data.json
test/                            модульні тести
```

## Тести та перевірка коду

```bash
dart test
dart format .
dart analyze
```
