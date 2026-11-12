import '../../../../../../core/result/result.dart';
import '../entities/certification.dart';
import '../entities/certification_params.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class CertificationRepository {
  Future<Result<List<Certification>>> getCertifications();

  Future<Result<void>> addCertification(CertificationParams params);

  Future<Result<void>> updateCertification(
    String id,
    CertificationParams params,
  );

  Future<Result<void>> deleteCertification(String id);
}
