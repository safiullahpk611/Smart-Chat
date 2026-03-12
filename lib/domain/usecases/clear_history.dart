import '../repositories/chat_repository.dart';


class ClearHistory {
  final ChatRepository _repo;

  ClearHistory(this._repo);

  Future<void> call() => _repo.clearHistory();
}
