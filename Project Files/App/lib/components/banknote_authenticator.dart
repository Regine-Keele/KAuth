class BanknoteAuthenticator {
  final double ovdWeight;
  final double concealedValueWeight;

  BanknoteAuthenticator({
    this.ovdWeight = 0.4,
    this.concealedValueWeight = 0.6,
  }) : assert(
            ovdWeight + concealedValueWeight == 1.0, 'Weights must sum to 1.0');

  double combineScores(double ovdScore, double concealedValueScore) {
    return (ovdScore * ovdWeight) +
        (concealedValueScore * concealedValueWeight);
  }

  String getPrediction(double combinedScore) {
    if (combinedScore >= 0.5) {
      return 'Real';
    } else {
      return 'Fake';
    }
  }
}
