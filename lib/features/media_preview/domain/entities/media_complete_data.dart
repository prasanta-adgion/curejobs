import 'package:equatable/equatable.dart';

class MediaCompleteData extends Equatable {
  final String fileId;
  final String status;
  final DateTime finalizedAt;

  const MediaCompleteData({
    required this.fileId,
    required this.status,
    required this.finalizedAt,
  });

  bool get isFinalized => status == 'FINALIZED';

  @override
  List<Object?> get props => [fileId, status, finalizedAt];
}
