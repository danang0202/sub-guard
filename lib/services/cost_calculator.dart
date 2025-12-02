import '../models/subscription.dart';

/// Service for calculating subscription costs and currency conversions
class CostCalculator {
  // Exchange rates map (currency code -> rate relative to USD)
  // For MVP, we use 1:1 conversion, but this can be extended with real rates
  final Map<String, double> _exchangeRates;

  CostCalculator({Map<String, double>? exchangeRates})
    : _exchangeRates = exchangeRates ?? _defaultExchangeRates;

  static final Map<String, double> _defaultExchangeRates = {
    'USD': 1.0,
    'EUR': 1.0,
    'GBP': 1.0,
    'IDR': 1.0,
    'JPY': 1.0,
    'AUD': 1.0,
    'CAD': 1.0,
    'SGD': 1.0,
    'MYR': 1.0,
  };

  /// Calculate total monthly cost across all subscriptions
  /// Normalizes yearly subscriptions and converts to base currency
  double calculateMonthlyTotal(
    List<Subscription> subscriptions,
    String baseCurrency,
  ) {
    try {
      double total = 0.0;

      for (final subscription in subscriptions) {
        // Only include active subscriptions
        if (!subscription.isActive) {
          continue;
        }

        // Normalize to monthly cost
        final monthlyCost = normalizeToMonthly(
          subscription.cost,
          subscription.billingCycle,
        );

        // Convert to base currency
        final convertedCost = convertCurrency(
          monthlyCost,
          subscription.currency,
          baseCurrency,
        );

        total += convertedCost;
      }

      return total;
    } catch (e) {
      throw CostCalculatorException('Failed to calculate monthly total: $e');
    }
  }

  /// Normalize subscription cost to monthly equivalent
  /// Yearly subscriptions are divided by 12
  double normalizeToMonthly(double amount, BillingCycle cycle) {
    try {
      switch (cycle) {
        case BillingCycle.monthly:
          return amount;
        case BillingCycle.yearly:
          return amount / 12.0;
      }
    } catch (e) {
      throw CostCalculatorException('Failed to normalize to monthly: $e');
    }
  }

  /// Convert amount from one currency to another
  /// For MVP, uses 1:1 conversion if rates not available
  double convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    try {
      // If same currency, no conversion needed
      if (fromCurrency == toCurrency) {
        return amount;
      }

      // Get exchange rates
      final fromRate = _exchangeRates[fromCurrency] ?? 1.0;
      final toRate = _exchangeRates[toCurrency] ?? 1.0;

      // Convert to USD first, then to target currency
      final amountInUSD = amount / fromRate;
      final convertedAmount = amountInUSD * toRate;

      return convertedAmount;
    } catch (e) {
      throw CostCalculatorException('Failed to convert currency: $e');
    }
  }

  /// Update exchange rates
  /// Allows updating rates from external API in the future
  void updateExchangeRates(Map<String, double> newRates) {
    _exchangeRates.addAll(newRates);
  }

  /// Get current exchange rate for a currency
  double? getExchangeRate(String currency) {
    return _exchangeRates[currency];
  }

  /// Check if a currency is supported
  bool isCurrencySupported(String currency) {
    return _exchangeRates.containsKey(currency);
  }
}

/// Custom exception for cost calculator operations
class CostCalculatorException implements Exception {
  final String message;

  CostCalculatorException(this.message);

  @override
  String toString() => 'CostCalculatorException: $message';
}
