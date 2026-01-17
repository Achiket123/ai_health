import 'package:ai_health/utils/constants/app_texts.dart';
import 'package:flutter/material.dart';













abstract class BasePickerField<T> extends StatefulWidget {
  const BasePickerField({
    required this.label,
    required this.onChanged,
    required this.icon,
    super.key,
    this.initialValue,
    this.validator,
    this.onTap,
  });

  
  final String label;

  
  final T? initialValue;

  
  final ValueChanged<T> onChanged;

  
  final String? Function(T?)? validator;

  
  
  final VoidCallback? onTap;

  
  final IconData icon;

  
  
  
  String formatValue(T? value);

  
  
  
  Future<T?> showPicker(BuildContext context, T? currentValue);
}




abstract class BasePickerFieldState<T, W extends BasePickerField<T>>
    extends State<W> {
  late final TextEditingController _controller;
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = TextEditingController(
      text: widget.formatValue(_selectedValue),
    );
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedValue = widget.initialValue;
      _controller.text = widget.formatValue(_selectedValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectValue(BuildContext context) async {
    widget.onTap?.call();
    final picked = await widget.showPicker(context, _selectedValue);
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedValue = picked;
      _controller.text = widget.formatValue(picked);
    });

    widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: Icon(widget.icon),
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () => _selectValue(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${AppTexts.pleaseSelect} ${widget.label}';
        }
        return widget.validator?.call(_selectedValue);
      },
    );
  }
}
