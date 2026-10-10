import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonApiException implements Exception {
  PokemonApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'PokemonApiException: $message';
}

// Клієнт PokeAPI. http.Client передається через конструктор,
// щоб у тестах його можна було замінити на MockClient.
class PokemonApi {
  PokemonApi({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _client = client ?? http.Client();

  static const String _host = 'pokeapi.co';

  final http.Client _client;
  final Duration timeout;

  Future<Pokemon> fetchPokemon(String nameOrId) async {
    final query = nameOrId.trim().toLowerCase();
    if (query.isEmpty) {
      throw PokemonApiException('Порожній запит: введіть імʼя або ID.');
    }
    final uri = Uri(
      scheme: 'https',
      host: _host,
      pathSegments: ['api', 'v2', 'pokemon', query],
    );

    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 404) {
        throw PokemonApiException(
          'Покемона "$query" не знайдено.',
          statusCode: 404,
        );
      }
      if (response.statusCode != 200) {
        throw PokemonApiException(
          'Сервер відповів статусом ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Очікувався JSON-обʼєкт.');
      }
      return Pokemon.fromApi(decoded);
    } on PokemonApiException {
      rethrow;
    } on SocketException {
      throw PokemonApiException('Немає звʼязку з сервером (перевірте інтернет).');
    } on http.ClientException catch (e) {
      throw PokemonApiException('Помилка зʼєднання: ${e.message}');
    } on TimeoutException {
      throw PokemonApiException(
        'Перевищено час очікування (${timeout.inSeconds} с).',
      );
    } on FormatException catch (e) {
      throw PokemonApiException('Некоректна відповідь сервера: ${e.message}');
    }
  }

  void close() => _client.close();
}
