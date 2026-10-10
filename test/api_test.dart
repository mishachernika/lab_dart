import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab_dart/lab_dart.dart';
import 'package:test/test.dart';

void main() {
  final okBody = jsonEncode({
    'id': 25,
    'name': 'pikachu',
    'height': 4,
    'weight': 60,
    'base_experience': 112,
    'types': [
      {
        'slot': 1,
        'type': {
          'name': 'electric',
          'url': 'https://pokeapi.co/api/v2/type/13/'
        },
      },
    ],
  });

  group('PokemonApi (MockClient)', () {
    test('розбирає успішну відповідь і формує правильну адресу', () async {
      final api = PokemonApi(
        client: MockClient((request) async {
          expect(request.url.host, 'pokeapi.co');
          expect(request.url.path, '/api/v2/pokemon/pikachu');
          return http.Response(okBody, 200);
        }),
      );

      final pokemon = await api.fetchPokemon('  Pikachu ');

      expect(pokemon.id, 25);
      expect(pokemon.name, 'pikachu');
      expect(pokemon.type, PokemonType.electric);
    });

    test('статус 404 перетворюється на PokemonApiException', () async {
      final api = PokemonApi(
        client: MockClient((request) async => http.Response('Not Found', 404)),
      );

      expect(
        () => api.fetchPokemon('nobody'),
        throwsA(
          isA<PokemonApiException>()
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('статус 500 перетворюється на PokemonApiException', () async {
      final api = PokemonApi(
        client: MockClient((request) async => http.Response('error', 500)),
      );

      expect(
        () => api.fetchPokemon('pikachu'),
        throwsA(
          isA<PokemonApiException>()
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('некоректний JSON дає PokemonApiException', () async {
      final api = PokemonApi(
        client: MockClient((request) async => http.Response('not json', 200)),
      );

      expect(
        () => api.fetchPokemon('pikachu'),
        throwsA(isA<PokemonApiException>()),
      );
    });

    test('відсутність інтернету дає PokemonApiException', () async {
      final api = PokemonApi(
        client: MockClient((request) async => throw const SocketException('x')),
      );

      expect(
        () => api.fetchPokemon('pikachu'),
        throwsA(isA<PokemonApiException>()),
      );
    });

    test('порожній запит не надсилається', () async {
      var called = false;
      final api = PokemonApi(
        client: MockClient((request) async {
          called = true;
          return http.Response(okBody, 200);
        }),
      );

      await expectLater(
        api.fetchPokemon('   '),
        throwsA(isA<PokemonApiException>()),
      );
      expect(called, isFalse);
    });
  });
}
