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
  MergeField(id: 'client_name', label: 'Client Name'),
  MergeField(id: 'client_passport_num', label: 'Passport #'),
  MergeField(id: 'contract_date', label: 'Contract Date'),
  MergeField(id: 'contract_num', label: 'Contract #'),
  MergeField(id: 'date', label: 'Date'),
  MergeField(id: 'unit_number', label: 'Unit Number'),
  MergeField(id: 'project_name', label: 'Project Name'),
  MergeField(id: 'building_name', label: 'Building Name'),
  MergeField(id: 'floor', label: 'Floor'),
  MergeField(id: 'area_sqm', label: 'Area (sqm)'),
  MergeField(id: 'total_price', label: 'Total Price'),
  MergeField(id: 'currency', label: 'Currency'),
  MergeField(id: 'initial_payment', label: 'Initial Payment'),
  MergeField(id: 'installment_months', label: 'Installment Months'),
  MergeField(id: 'seller_name', label: 'Seller Name'),
];
