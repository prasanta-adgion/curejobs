part of 'organization_details_cubit.dart';

enum OrganizationStatus { initial, loading, success, failure }

class OrganizationDetailsState extends Equatable {
  final OrganizationStatus status;

  /// Kept during a reload so the page doesn't blank out.
  final OrganizationDetails? organization;

  /// Signed logo URL, once resolved.
  final String? logoUrl;

  /// Set when [status] is failure.
  final Failure? failure;

  const OrganizationDetailsState({
    this.status = OrganizationStatus.initial,
    this.organization,
    this.logoUrl,
    this.failure,
  });

  @override
  List<Object?> get props => [status, organization, logoUrl, failure];
}
