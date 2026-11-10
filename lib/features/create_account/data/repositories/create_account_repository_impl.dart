import '../../../../core/result/result.dart';
import '../../domain/entities/create_account_params.dart';
import '../../domain/repositories/create_account_repository.dart';
import '../datasources/create_account_remote_data_source.dart';
import '../models/create_account_request_model.dart';

class CreateAccountRepositoryImpl implements CreateAccountRepository {
  final CreateAccountRemoteDataSource _remote;

  const CreateAccountRepositoryImpl(this._remote);

  @override
  Future<Result<void>> createAccount(CreateAccountParams params) {
    return Result.guard(
      () => _remote.createAccount(CreateAccountRequestModel(params)),
    );
  }
}
