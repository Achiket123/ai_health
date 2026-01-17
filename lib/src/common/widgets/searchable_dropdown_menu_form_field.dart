import 'package:flutter/material.dart';







@immutable
final class SearchableDropdownMenuFormField<T> extends StatefulWidget {
  const SearchableDropdownMenuFormField({
    required this.labelText,
    required this.values,
    required this.onChanged,
    required this.displayNameBuilder,
    super.key,
    this.initialValue,
    this.validator,
    this.prefixIcon,
    this.hint,
    this.enabled = true,
  });

  
  final String labelText;

  
  final List<T> values;

  
  final T? initialValue;

  
  final ValueChanged<T?> onChanged;

  
  final String? Function(T?)? validator;

  
  
  final String Function(T) displayNameBuilder;

  
  final IconData? prefixIcon;

  
  final String? hint;

  
  final bool enabled;

  @override
  State<SearchableDropdownMenuFormField<T>> createState() =>
      _SearchableDropdownMenuFormFieldState<T>();
}

class _SearchableDropdownMenuFormFieldState<T>
    extends State<SearchableDropdownMenuFormField<T>> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormFieldState<T>> _formFieldKey =
      GlobalKey<FormFieldState<T>>();
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    final selectedValueLocal = _selectedValue;
    final initialDisplayName = selectedValueLocal != null
        ? widget.displayNameBuilder.call(selectedValueLocal)
        : '';
    _controller = TextEditingController(text: initialDisplayName);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final text = _controller.text;
      T? match;
      try {
        match = widget.values.firstWhere((e) => _getDisplayName(e) == text);
      } on StateError catch (_) {
        match = null;
      }

      if (match != null) {
        if (_selectedValue != match) {
          _updateSelection(match);
        }
      } else {
        if (widget.values.isNotEmpty) {
          final firstValue = widget.values.first;
          _updateSelection(firstValue);
          _controller.text = _getDisplayName(firstValue);
        }
      }
    }
  }

  void _updateSelection(T value) {
    setState(() {
      _selectedValue = value;
    });
    _formFieldKey.currentState?.didChange(value);
    widget.onChanged(value);
  }

  String _getDisplayName(T value) {
    return widget.displayNameBuilder.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: _formFieldKey,
      initialValue: widget.initialValue,
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(_selectedValue);
        }
        return null;
      },
      builder: (FormFieldState<T> fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownMenu<T>(
              controller: _controller,
              focusNode: _focusNode,
              initialSelection: widget.initialValue,
              enableFilter: true,
              requestFocusOnTap: true,
              enabled: widget.enabled,
              label: Text(widget.labelText),
              hintText: widget.hint,
              leadingIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon)
                  : null,
              expandedInsets: EdgeInsets.zero,
              onSelected: (T? value) {
                if (value != null) {
                  _updateSelection(value);
                }
              },
              dropdownMenuEntries: widget.values.map((enumValue) {
                final displayName = _getDisplayName(enumValue);
                return DropdownMenuEntry<T>(
                  value: enumValue,
                  label: displayName,
                );
              }).toList(),
            ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
