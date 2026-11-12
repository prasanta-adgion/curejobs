import '../../../../../../core/result/result.dart';
import '../../domain/entities/certification.dart';
import '../../domain/entities/certification_params.dart';
import '../../domain/repositories/certification_repository.dart';
import '../datasources/certification_remote_data_source.dart';

class CertificationRepositoryImpl implements CertificationRepository {
  final CertificationRemoteDataSource _remote;

  const CertificationRepositoryImpl(this._remote);

  @override
  Future<Result<List<Certification>>> getCertifications() {
    return Result.guard(_remote.getCertifications);
  }

  @override
  Future<Result<void>> addCertification(CertificationParams params) {
    return Result.guard(() => _remote.addCertification(params));
  }

  @override
  Future<Result<void>> updateCertification(
    String id,
    CertificationParams params,
  ) {
    return Result.guard(() => _remote.updateCertification(id, params));
  }

  @override
  Future<Result<void>> deleteCertification(String id) {
    return Result.guard(() => _remote.deleteCertification(id));
  }
}
