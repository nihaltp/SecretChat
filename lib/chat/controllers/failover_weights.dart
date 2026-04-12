// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Secret Chat Contributors

/// Weight configuration for post-failover host optimization.
class FailoverWeights {
  static const double latencyWeight = 0.6;
  static const double batteryWeight = 0.4;
}

/// Computes a host score where higher is better.
///
/// - Lower latency increases score.
/// - Higher battery increases score.
/// - If latency is unknown, only battery contributes.
double computeFailoverHostScore({
  required int? averageRttMs,
  required int batteryLevel,
}) {
  final int normalizedBattery = batteryLevel.clamp(0, 100);
  final double batteryScore = normalizedBattery / 100.0;

  final double latencyScore;
  if (averageRttMs == null || averageRttMs <= 0) {
    latencyScore = 0.0;
  } else {
    latencyScore = 1.0 / (averageRttMs + 1.0);
  }

  return (FailoverWeights.latencyWeight * latencyScore) +
      (FailoverWeights.batteryWeight * batteryScore);
}
