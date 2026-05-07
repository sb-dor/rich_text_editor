import 'package:flutter/foundation.dart';

/// A template placeholder that can be inserted into a document and later
/// replaced by a server / template engine with concrete data.
///
/// The placeholder uses Mustache-style `{{id}}` syntax so it survives any
/// HTML / Word / plain-text round-trip without colliding with HTML tags.
@immutable
class MergeField {
  const MergeField({required this.id, required this.label});

  /// Stable machine identifier — the value the server keys off.
  final String id;

  /// Human-readable label shown on the toolbar button.
  final String label;

  /// The literal text inserted into the document.
  String get placeholder => '{{$id}}';
}

/// Built-in merge fields. Add new entries here.
const List<MergeField> kAvailableMergeFields = <MergeField>[
  MergeField(id: 'customer_name', label: 'Customer Name'),
  MergeField(id: 'customer_passport_num', label: 'Passport #'),
  MergeField(id: 'contract_date', label: 'Contract Date'),
  MergeField(id: 'contract_num', label: 'Contract #'),
];
