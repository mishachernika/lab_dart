import 'dart:io';

import 'package:lab_dart/lab_dart.dart';

const String _menu = '''
===== Колекція покемонів =====
1. Показати список
2. Додати покемона вручну
3. Завантажити покемона з API
4. Видалити покемона
5. Пошук за назвою
6. Фільтр за типом
7. Сортування
8. Тренери
0. Вихід''';

Future<void> main() async {
  final repository = DataRepository();
  final api = PokemonApi();
  final data = await _loadData(repository);

  var running = true;
  while (running) {
    _out();
    _out(_menu);
    final choice = _ask('Оберіть пункт: ');
    switch (choice) {
      case '1':
        _showList(data.pokemon, 'Усі покемони');
      case '2':
        await _addManually(data, repository);
      case '3':
        await _fetchFromApi(data, repository, api);
      case '4':
        await _remove(data, repository);
      case '5':
        _search(data);
      case '6':
        _filter(data);
      case '7':
        _sort(data);
      case '8':
        await _trainersMenu(data, repository);
      case '0' || null:
        running = false;
      default:
        _out('Невідомий пункт меню. Введіть число від 0 до 8.');
    }
  }

  api.close();
  _out('До побачення!');
}

// ---------- допоміжні функції введення/виведення ----------

void _out([String text = '']) => stdout.writeln(text);

String? _ask(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync()?.trim();
}

// Повертає null, якщо введення некоректне (і повідомляє про це).
int? _askInt(String prompt, {int? min, int? max}) {
  final text = _ask(prompt);
  if (text == null) {
    return null;
  }
  final value = int.tryParse(text);
  if (value == null) {
    _out('Потрібно ввести ціле число.');
    return null;
  }
  if (min != null && value < min) {
    _out('Число має бути не менше $min.');
    return null;
  }
  if (max != null && value > max) {
    _out('Число має бути не більше $max.');
    return null;
  }
  return value;
}

Future<AppData> _loadData(DataRepository repository) async {
  try {
    final data = await repository.load();
    _out(
      'Дані зчитано з ${repository.path}: покемонів — ${data.pokemon.length}, '
      'тренерів — ${data.trainers.length}.',
    );
    return data;
  } on StorageException catch (e) {
    _out(e.message);
    _out('Починаємо з порожнього списку.');
    return AppData();
  }
}

Future<void> _save(DataRepository repository, AppData data) async {
  try {
    await repository.save(data);
  } on StorageException catch (e) {
    _out('Не вдалося зберегти дані: ${e.message}');
  }
}

void _showList(List<Pokemon> list, String title) {
  _out();
  _out('$title (${list.length}):');
  if (list.isEmpty) {
    _out('  Список порожній.');
    return;
  }
  for (final item in list) {
    _out('  $item');
  }
}

PokemonType? _chooseType() {
  final types = PokemonType.values;
  for (var i = 0; i < types.length; i++) {
    _out('  ${i + 1}. ${types[i].name}');
  }
  final number = _askInt('Тип (номер): ', min: 1, max: types.length);
  return number == null ? null : types[number - 1];
}

// ---------- пункти меню ----------

Future<void> _addManually(AppData data, DataRepository repository) async {
  final id = _askInt('ID (додатне число): ', min: 1);
  if (id == null) {
    return;
  }
  final name = _ask('Імʼя: ');
  if (name == null || name.isEmpty) {
    _out('Імʼя не може бути порожнім.');
    return;
  }
  final height = _askInt('Зріст: ', min: 0);
  if (height == null) {
    return;
  }
  final weight = _askInt('Вага: ', min: 0);
  if (weight == null) {
    return;
  }
  final experience = _askInt('Базовий досвід: ', min: 0);
  if (experience == null) {
    return;
  }
  final type = _chooseType();
  if (type == null) {
    return;
  }

  final pokemon = Pokemon(
    id: id,
    name: name,
    height: height,
    weight: weight,
    baseExperience: experience,
    type: type,
  );
  if (data.addPokemon(pokemon)) {
    _out('Додано: $pokemon');
    await _save(repository, data);
  } else {
    _out('Покемон з ID $id уже є в списку.');
  }
}

Future<void> _fetchFromApi(
  AppData data,
  DataRepository repository,
  PokemonApi api,
) async {
  final query = _ask('Імʼя або ID покемона (наприклад, pikachu або 25): ');
  if (query == null || query.isEmpty) {
    _out('Порожній запит.');
    return;
  }
  try {
    final pokemon = await api.fetchPokemon(query);
    if (data.addPokemon(pokemon)) {
      _out('Отримано з API й додано: $pokemon');
      await _save(repository, data);
    } else {
      _out('Покемон ${pokemon.name} (ID ${pokemon.id}) уже є в списку.');
    }
  } on PokemonApiException catch (e) {
    _out('Не вдалося отримати дані: ${e.message}');
    _out('Можна продовжити роботу з локальними даними.');
  }
}

Future<void> _remove(AppData data, DataRepository repository) async {
  _showList(data.pokemon, 'Усі покемони');
  if (data.pokemon.isEmpty) {
    return;
  }
  final id = _askInt('ID для видалення: ');
  if (id == null) {
    return;
  }
  if (data.removePokemon(id)) {
    _out('Покемона з ID $id видалено.');
    await _save(repository, data);
  } else {
    _out('Покемона з ID $id не знайдено.');
  }
}

void _search(AppData data) {
  final query = _ask('Частина імені: ');
  if (query == null || query.isEmpty) {
    _out('Порожній запит.');
    return;
  }
  _showList(searchByName(data.pokemon, query), 'Результати пошуку');
}

void _filter(AppData data) {
  final type = _chooseType();
  if (type == null) {
    return;
  }
  _showList(filterByType(data.pokemon, type), 'Покемони типу ${type.name}');
}

void _sort(AppData data) {
  final fields = SortField.values;
  for (var i = 0; i < fields.length; i++) {
    _out('  ${i + 1}. ${fields[i].name}');
  }
  final number = _askInt('Поле (номер): ', min: 1, max: fields.length);
  if (number == null) {
    return;
  }
  final order = _askInt(
    'Порядок: 1 - за зростанням, 2 - за спаданням: ',
    min: 1,
    max: 2,
  );
  if (order == null) {
    return;
  }
  final sorted = sortPokemon(
    data.pokemon,
    fields[number - 1],
    ascending: order == 1,
  );
  _showList(sorted, 'Сортування за ${fields[number - 1].name}');
}

Future<void> _trainersMenu(AppData data, DataRepository repository) async {
  var back = false;
  while (!back) {
    _out();
    _out('--- Тренери ---');
    _out('1. Показати тренерів');
    _out('2. Додати тренера');
    _out('3. Додати покемона тренеру');
    _out('0. Назад');
    final choice = _ask('Оберіть пункт: ');
    switch (choice) {
      case '1':
        _showTrainers(data);
      case '2':
        await _addTrainer(data, repository);
      case '3':
        await _assignPokemon(data, repository);
      case '0' || null:
        back = true;
      default:
        _out('Невідомий пункт меню.');
    }
  }
}

void _showTrainers(AppData data) {
  _out();
  if (data.trainers.isEmpty) {
    _out('Тренерів ще немає.');
    return;
  }
  for (final trainer in data.trainers) {
    _out(trainer.toString());
    for (final id in trainer.pokemonIds) {
      final pokemon = data.findPokemon(id);
      _out('    ${pokemon == null ? 'невідомий покемон #$id' : pokemon.name}');
    }
  }
}

Future<void> _addTrainer(AppData data, DataRepository repository) async {
  final name = _ask('Імʼя тренера: ');
  if (name == null || name.isEmpty) {
    _out('Імʼя не може бути порожнім.');
    return;
  }
  if (data.findTrainer(name) != null) {
    _out('Тренер з таким імʼям уже є.');
    return;
  }
  data.trainers.add(Trainer(name: name));
  _out('Тренера "$name" додано.');
  await _save(repository, data);
}

Future<void> _assignPokemon(AppData data, DataRepository repository) async {
  final name = _ask('Імʼя тренера: ');
  if (name == null) {
    return;
  }
  final trainer = data.findTrainer(name);
  if (trainer == null) {
    _out('Тренера "$name" не знайдено.');
    return;
  }
  _showList(data.pokemon, 'Доступні покемони');
  final id = _askInt('ID покемона: ');
  if (id == null) {
    return;
  }
  if (data.findPokemon(id) == null) {
    _out('Покемона з ID $id немає в колекції.');
    return;
  }
  if (trainer.catchPokemon(id)) {
    _out('Покемона додано тренеру ${trainer.name}.');
    await _save(repository, data);
  } else {
    _out('У тренера ${trainer.name} уже є цей покемон.');
  }
}
