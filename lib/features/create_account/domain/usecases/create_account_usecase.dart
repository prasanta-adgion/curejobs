import '../../../../core/result/result.dart';
import '../entities/create_account_params.dart';
import '../repositories/create_account_repository.dart';

/// Saves the candidate profile filled in during account creation.
class CreateAccountUseCase {
  final CreateAccountRepository _repository;

  const CreateAccountUseCase(this._repository);

  Future<Result<void>> call(CreateAccountParams params) =>
      _repository.createAccount(params);
}
