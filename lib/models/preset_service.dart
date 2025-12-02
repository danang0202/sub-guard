class PresetService {
  final String name;
  final String? logoAssetPath;
  final String? logoUrl;
  final String colorHex;
  final String defaultCurrency;
  final double? suggestedPrice;

  const PresetService({
    required this.name,
    this.logoAssetPath,
    this.logoUrl,
    required this.colorHex,
    required this.defaultCurrency,
    this.suggestedPrice,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PresetService &&
        other.name == name &&
        other.logoAssetPath == logoAssetPath &&
        other.logoUrl == logoUrl &&
        other.colorHex == colorHex &&
        other.defaultCurrency == defaultCurrency &&
        other.suggestedPrice == suggestedPrice;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      logoAssetPath,
      logoUrl,
      colorHex,
      defaultCurrency,
      suggestedPrice,
    );
  }
}

// Popular preset services
const List<PresetService> presetServices = [
  PresetService(
    name: 'Netflix',
    logoUrl: 'https://logo.clearbit.com/netflix.com',
    colorHex: '#E50914',
    defaultCurrency: 'USD',
    suggestedPrice: 15.49,
  ),
  PresetService(
    name: 'Spotify',
    logoUrl: 'https://logo.clearbit.com/spotify.com',
    colorHex: '#1DB954',
    defaultCurrency: 'USD',
    suggestedPrice: 9.99,
  ),
  PresetService(
    name: 'GitHub',
    logoUrl: 'https://logo.clearbit.com/github.com',
    colorHex: '#181717',
    defaultCurrency: 'USD',
    suggestedPrice: 4.00,
  ),
  PresetService(
    name: 'ChatGPT',
    logoUrl: 'https://logo.clearbit.com/openai.com',
    colorHex: '#10A37F',
    defaultCurrency: 'USD',
    suggestedPrice: 20.00,
  ),
  PresetService(
    name: 'Adobe Creative Cloud',
    logoUrl: 'https://logo.clearbit.com/adobe.com',
    colorHex: '#FF0000',
    defaultCurrency: 'USD',
    suggestedPrice: 54.99,
  ),
  PresetService(
    name: 'YouTube Premium',
    logoUrl: 'https://logo.clearbit.com/youtube.com',
    colorHex: '#FF0000',
    defaultCurrency: 'USD',
    suggestedPrice: 11.99,
  ),
  PresetService(
    name: 'Disney+',
    logoUrl: 'https://logo.clearbit.com/disneyplus.com',
    colorHex: '#113CCF',
    defaultCurrency: 'USD',
    suggestedPrice: 7.99,
  ),
  PresetService(
    name: 'Amazon Prime',
    logoUrl: 'https://logo.clearbit.com/amazon.com',
    colorHex: '#FF9900',
    defaultCurrency: 'USD',
    suggestedPrice: 14.99,
  ),
  PresetService(
    name: 'Apple Music',
    logoUrl: 'https://logo.clearbit.com/apple.com',
    colorHex: '#FA243C',
    defaultCurrency: 'USD',
    suggestedPrice: 10.99,
  ),
  PresetService(
    name: 'Microsoft 365',
    logoUrl: 'https://logo.clearbit.com/microsoft.com',
    colorHex: '#0078D4',
    defaultCurrency: 'USD',
    suggestedPrice: 6.99,
  ),
  PresetService(
    name: 'Dropbox',
    logoUrl: 'https://logo.clearbit.com/dropbox.com',
    colorHex: '#0061FF',
    defaultCurrency: 'USD',
    suggestedPrice: 11.99,
  ),
  PresetService(
    name: 'Notion',
    logoUrl: 'https://logo.clearbit.com/notion.so',
    colorHex: '#000000',
    defaultCurrency: 'USD',
    suggestedPrice: 8.00,
  ),
  PresetService(
    name: 'Canva Pro',
    logoUrl: 'https://logo.clearbit.com/canva.com',
    colorHex: '#00C4CC',
    defaultCurrency: 'USD',
    suggestedPrice: 12.99,
  ),
  PresetService(
    name: 'LinkedIn Premium',
    logoUrl: 'https://logo.clearbit.com/linkedin.com',
    colorHex: '#0A66C2',
    defaultCurrency: 'USD',
    suggestedPrice: 29.99,
  ),
  PresetService(
    name: 'Zoom Pro',
    logoUrl: 'https://logo.clearbit.com/zoom.us',
    colorHex: '#2D8CFF',
    defaultCurrency: 'USD',
    suggestedPrice: 14.99,
  ),
];
