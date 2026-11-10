import '../../../../core/result/result.dart';
import '../entities/create_account_params.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class CreateAccountRepository {
  Future<Result<void>> createAccount(CreateAccountParams params);
}
