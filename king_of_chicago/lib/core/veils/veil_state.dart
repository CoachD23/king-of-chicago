import 'dart:collection';

import 'package:equatable/equatable.dart';

import 'veil_type.dart';

class VeilState extends Equatable {
  final Map<VeilType, int> _values;

  const VeilState._(this._values);

  factory VeilState.initial() {
    return VeilState._(
      Map.unmodifiable({
        for (final veil in VeilType.values) veil: 0,
      }),
    );
  }

  factory VeilState.fromMap(Map<VeilType, int> map) {
    return VeilState._(
      Map.unmodifiable({
        for (final veil in VeilType.values)
          veil: (map[veil] ?? 0).clamp(0, 100),
      }),
    );
  }

  int getValue(VeilType veil) => _values[veil] ?? 0;

  VeilState applyDeltas(Map<VeilType, int> deltas) {
    return VeilState._(
      Map.unmodifiable({
        for (final veil in VeilType.values)
          veil: (getValue(veil) + (deltas[veil] ?? 0)).clamp(0, 100),
      }),
    );
  }

  List<VeilType> getDominantVeils(int count) {
    final sorted = VeilType.values.toList()
      ..sort((a, b) => getValue(b).compareTo(getValue(a)));
    return sorted.take(count).toList();
  }

  bool meetsThreshold(VeilType veil, int threshold) {
    return getValue(veil) >= threshold;
  }

  Map<VeilType, int> toMap() {
    return UnmodifiableMapView(Map<VeilType, int>.from(_values));
  }

  @override
  List<Object?> get props => [_values];
}
