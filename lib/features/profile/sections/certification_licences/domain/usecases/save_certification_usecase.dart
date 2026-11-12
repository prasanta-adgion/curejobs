import '../../../../../../core/result/result.dart';
import '../entities/certification_params.dart';
import '../repositories/certification_repository.dart';

/// Adds a new certificate, or updates one when [id] is given.
class SaveCertificationUseCase {
  final CertificationRepository _repository;

  const SaveCertificationUseCase(this._repository);

  Future<Result<void>> call(CertificationParams params, {String? id}) {
    return id == null
        ? _repository.addCertification(params)
        : _repository.updateCertification(id, params);
  }
}
