import 'package:equatable/equatable.dart';

/// Load state of the document types behind the "Start verification" card.
///
/// Why: the documents step looks different while the types load (start card
/// → spinner → upload form), so the state keeps this one value instead of
/// three loose fields.
class TypesLoad extends Equatable {
  const TypesLoad.idle() : isLoading = false, isLoaded = false, error = null;
  const TypesLoad.loading() : isLoading = true, isLoaded = false, error = null;
  const TypesLoad.loaded() : isLoading = false, isLoaded = true, error = null;
  const TypesLoad.failed(String this.error)
    : isLoading = false,
      isLoaded = false;

  final bool isLoading;
  final bool isLoaded;

  /// Set when the last load failed; shown on the start card.
  final String? error;

  @override
  List<Object?> get props => [isLoading, isLoaded, error];
}
