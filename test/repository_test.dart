import 'dart:io';

import 'package:lab_dart/lab_dart.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String path;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('lab_dart_test_');
    path = '${tempDir.path}${Platform.pathSeparator}data.json';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('DataRepository', () {
    test('збереження й зчитування повертають ті самі дані', () async {
      final repository = DataRepository(path);
      final data = AppData(
        pokemon: [
          const Pokemon(
            id: 25,
            name: 'pikachu',
            height: 4,
            weight: 60,
            baseExperience: 112,
            type: PokemonType.electric,
          ),
        ],
        trainers: [
          Trainer(name: 'Ash', pokemonIds: [25])
        ],
      );

      await repository.save(data);
      final restored = await repository.load();

      expect(restored.pokemon, data.pokemon);
      expect(restored.trainers.single.name, 'Ash');
    });

    test('відсутній файл дає порожні дані', () async {
      final restored = await DataRepository(path).load();
      expect(restored.pokemon, isEmpty);
      expect(restored.trainers, isEmpty);
    });

    test('пошкоджений файл дає StorageException', () async {
      File(path).writeAsStringSync('{ це не json');
      expect(
        () => DataRepository(path).load(),
        throwsA(isA<StorageException>()),
      );
    });

    test('файл з неправильною структурою дає StorageException', () async {
      File(path)
          .writeAsStringSync('{"pokemon": [{"id": "abc"}], "trainers": []}');
      expect(
        () => DataRepository(path).load(),
        throwsA(isA<StorageException>()),
      );
    });
  });
}
