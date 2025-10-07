import 'package:flutter/material.dart';
import '../models/service_item.dart';
import '../l10n/app_localizations.dart';

class ServiceItemAutocomplete extends StatefulWidget {
  final List<ServiceItem> allItems;
  final String languageCode;
  final Function(ServiceItem) onItemSelected;
  final Function(String) onCustomItemCreate;

  const ServiceItemAutocomplete({
    super.key,
    required this.allItems,
    required this.languageCode,
    required this.onItemSelected,
    required this.onCustomItemCreate,
  });

  @override
  State<ServiceItemAutocomplete> createState() =>
      _ServiceItemAutocompleteState();
}

class _ServiceItemAutocompleteState extends State<ServiceItemAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  List<ServiceItem> _filteredItems = [];
  bool _showDropdown = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.allItems;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showDropdown = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.allItems;
        _showDropdown = true;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredItems = widget.allItems.where((item) {
        final name = item.getName(widget.languageCode).toLowerCase();
        final nameEn = item.nameEn.toLowerCase();
        final nameHu = item.nameHu.toLowerCase();
        return name.contains(lowerQuery) ||
            nameEn.contains(lowerQuery) ||
            nameHu.contains(lowerQuery);
      }).toList();
      _showDropdown = true;
    });
  }

  void _selectItem(ServiceItem item) {
    setState(() {
      _controller.clear();
      _showDropdown = false;
    });
    widget.onItemSelected(item);
    _focusNode.unfocus();
  }

  void _createCustomItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _controller.clear();
      _showDropdown = false;
    });
    widget.onCustomItemCreate(text);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasExactMatch = _filteredItems.any(
      (item) =>
          item.getName(widget.languageCode).toLowerCase() ==
          _controller.text.trim().toLowerCase(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: l10n.searchOrAddItem,
            hintText: l10n.startTyping,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _filterItems('');
                    },
                  )
                : null,
          ),
          onChanged: _filterItems,
          onTap: () {
            setState(() => _showDropdown = true);
            _filterItems(_controller.text);
          },
        ),
        if (_showDropdown && (_filteredItems.isNotEmpty || _controller.text.trim().isNotEmpty))
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: theme.cardColor,
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                // Existing items
                ..._filteredItems.map((item) {
                  final isCustom = item.isCustom;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isCustom ? Icons.label : Icons.build,
                      size: 20,
                      color: isCustom ? Colors.blue : Colors.grey,
                    ),
                    title: Text(item.getName(widget.languageCode)),
                    subtitle: isCustom ? Text(l10n.custom) : null,
                    onTap: () => _selectItem(item),
                  );
                }),
                // Add custom item option
                if (_controller.text.trim().isNotEmpty && !hasExactMatch) ...[
                  const Divider(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.add_circle_outline, color: Colors.green),
                    title: Text(
                      l10n.addAsCustomItem(_controller.text.trim()),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: _createCustomItem,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

