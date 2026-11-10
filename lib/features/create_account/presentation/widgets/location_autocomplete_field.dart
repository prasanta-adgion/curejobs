import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../domain/enums/location_type.dart';
import '../bloc/location_suggestions_bloc.dart';
import 'create_account_fields.dart';

/// Text field that shows a dropdown of location suggestions of [type] when
/// tapped and as the user types (debounced in [LocationSuggestionsBloc]).
class LocationAutocompleteField extends StatelessWidget {
  const LocationAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.type,
    required this.controller,
    this.onSelected,
    this.isOptional = false,
  });

  final String label;
  final String hint;
  final LocationType type;
  final TextEditingController controller;
  final ValueChanged<LocationSuggestion>? onSelected;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocationSuggestionsBloc>(param1: type),
      child: _LocationAutocompleteView(
        label: label,
        hint: hint,
        controller: controller,
        onSelected: onSelected,
        isOptional: isOptional,
      ),
    );
  }
}

class _LocationAutocompleteView extends StatefulWidget {
  const _LocationAutocompleteView({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onSelected,
    required this.isOptional,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<LocationSuggestion>? onSelected;
  final bool isOptional;

  @override
  State<_LocationAutocompleteView> createState() =>
      _LocationAutocompleteViewState();
}

class _LocationAutocompleteViewState extends State<_LocationAutocompleteView> {
  final _focusNode = FocusNode();
  final _overlay = OverlayPortalController();
  final _link = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  LocationSuggestionsBloc get _bloc => context.read<LocationSuggestionsBloc>();

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _overlay.show();
      _bloc.add(LocationSuggestionsRequested(widget.controller.text));
    } else {
      _overlay.hide();
      _bloc.add(const LocationSuggestionsCleared());
    }
  }

  void _select(LocationSuggestion suggestion) {
    widget.controller.value = TextEditingValue(
      text: suggestion.value,
      selection: TextSelection.collapsed(offset: suggestion.value.length),
    );
    widget.onSelected?.call(suggestion);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: widget.label, isOptional: widget.isOptional),
        LayoutBuilder(
          builder: (context, constraints) => CompositedTransformTarget(
            link: _link,
            child: OverlayPortal(
              controller: _overlay,
              overlayChildBuilder: (_) => _SuggestionsDropdown(
                link: _link,
                width: constraints.maxWidth,
                bloc: _bloc,
                onSelected: _select,
              ),
              child:
                  BlocSelector<
                    LocationSuggestionsBloc,
                    LocationSuggestionsState,
                    bool
                  >(
                    selector: (state) => state.isLoading,
                    builder: (context, isLoading) => TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (text) =>
                          _bloc.add(LocationQueryChanged(text)),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        suffixIcon: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Floating list anchored under the field.
class _SuggestionsDropdown extends StatelessWidget {
  const _SuggestionsDropdown({
    required this.link,
    required this.width,
    required this.bloc,
    required this.onSelected,
  });

  final LayerLink link;
  final double width;
  final LocationSuggestionsBloc bloc;
  final ValueChanged<LocationSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return CompositedTransformFollower(
      link: link,
      targetAnchor: Alignment.bottomLeft,
      offset: const Offset(0, 4),
      showWhenUnlinked: false,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        // Taps here count as inside the field, so it keeps focus.
        child: TextFieldTapRegion(
          child: BlocBuilder<LocationSuggestionsBloc, LocationSuggestionsState>(
            bloc: bloc,
            builder: (context, state) {
              if (!state.hasContent) return const SizedBox.shrink();

              final Widget content;
              if (state.status == LocationSuggestionsStatus.failure) {
                content = Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Couldn't load suggestions.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                );
              } else if (state.suggestions.isEmpty) {
                content = const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                );
              } else {
                content = ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: state.suggestions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final suggestion = state.suggestions[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 20),
                      title: Text(
                        suggestion.displayLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onSelected(suggestion),
                    );
                  },
                );
              }

              return Material(
                elevation: 6,
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 240, maxWidth: width),
                  child: SizedBox(width: width, child: content),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
