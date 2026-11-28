import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/package_request.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_package_requests_usecase.dart';
import '../../domain/usecases/request_package_usecase.dart';

/// Status of sending a new request.
enum PackageRequestStatus { idle, sending, success, failure }

class PackageRequestState extends Equatable {
  const PackageRequestState({
    this.status = PackageRequestStatus.idle,
    this.planName,
    this.message,
    this.requests = const [],
  });

  final PackageRequestStatus status;
  final String? planName;
  final String? message;

  /// The user's requests, newest first.
  final List<PackageRequest> requests;

  bool get isBusy => status == PackageRequestStatus.sending;

  /// The newest request for [packageId], if any.
  PackageRequest? latestFor(String packageId) =>
      requests.where((r) => r.packageId == packageId).firstOrNull;

  /// A request for [packageId] is waiting for admin.
  bool hasPendingFor(String packageId) =>
      requests.any((r) => r.packageId == packageId && r.isPending);

  PackageRequestState copyWith({
    PackageRequestStatus? status,
    String? planName,
    String? message,
    List<PackageRequest>? requests,
  }) => PackageRequestState(
    status: status ?? this.status,
    planName: planName ?? this.planName,
    message: message ?? this.message,
    requests: requests ?? this.requests,
  );

  @override
  List<Object?> get props => [status, planName, message, requests];
}

/// Loads the user's package requests and sends new ones to admin.
class PackageRequestCubit extends Cubit<PackageRequestState> {
  PackageRequestCubit(this._requestPackage, this._getRequests)
    : super(const PackageRequestState());

  final RequestPackageUseCase _requestPackage;
  final GetPackageRequestsUseCase _getRequests;

  static const maxMessageLength = 500;

  /// Loads the request list. A failure keeps the old list: the list only
  /// adds detail, the server still decides with `requestAvailable`.
  Future<void> load() async {
    final result = await _getRequests();
    if (isClosed) return;
    final requests = result.valueOrNull;
    if (requests != null) emit(state.copyWith(requests: requests));
  }

  Future<void> send(SubscriptionPackage package, {String? message}) async {
    // Drop double taps, plans closed for requests and duplicate requests.
    if (state.isBusy) return;
    if (state.hasPendingFor(package.id)) {
      _emitFailure(
        package,
        'You already have a pending request for ${package.name}.',
      );
      return;
    }
    if (!package.canRequest) {
      _emitFailure(package, "${package.name} can't be requested right now.");
      return;
    }

    var text = message?.trim() ?? '';
    if (text.length > maxMessageLength) {
      text = text.substring(0, maxMessageLength);
    }

    emit(
      PackageRequestState(
        status: PackageRequestStatus.sending,
        planName: package.name,
        requests: state.requests,
      ),
    );

    final result = await _requestPackage(
      packageId: package.id,
      message: text.isEmpty ? null : text,
    );
    if (isClosed) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      _emitFailure(package, _messageFor(failure, package.name));
      // A 409 usually means a request already exists: show it.
      if (failure is ConflictFailure) await load();
      return;
    }

    emit(
      PackageRequestState(
        status: PackageRequestStatus.success,
        planName: package.name,
        message:
            'We sent your request for ${package.name}. Our team will '
            'review it and get back to you.',
        requests: state.requests,
      ),
    );
    await load();
  }

  /// Back to idle after a result was shown; keeps the request list.
  void reset() => emit(PackageRequestState(requests: state.requests));

  void _emitFailure(SubscriptionPackage package, String message) => emit(
    PackageRequestState(
      status: PackageRequestStatus.failure,
      planName: package.name,
      message: message,
      requests: state.requests,
    ),
  );

  static String _messageFor(Failure f, String plan) {
    if (f.message.isNotEmpty) return f.message;
    if (f is ConflictFailure) {
      return 'You already have a pending request for $plan.';
    }
    if (f is NetworkFailure || f is TimeoutFailure) {
      return 'Network problem. Check your connection and try again.';
    }
    return "Couldn't send your request. Please try again.";
  }
}
