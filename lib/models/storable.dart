// Базовий клас для всіх моделей, які можна зберегти у JSON.
abstract class Storable {
  Map<String, dynamic> toJson();
}
