import '../../../../core/result/result.dart';
import '../../domain/entities/specialization.dart';
import '../../domain/repositories/specialization_repository.dart';
import '../datasources/specialization_remote_data_source.dart';

class SpecializationRepositoryImpl implements SpecializationRepository {
  final SpecializationRemoteDataSource _remote;

  const SpecializationRepositoryImpl(this._remote);

  @override
  Future<Result<List<Specialization>>> getSpecializations({
    required String categoryId,
  }) {
    return Result.guard(
      () => _remote.getSpecializations(categoryId: categoryId),
    );
  }
}
