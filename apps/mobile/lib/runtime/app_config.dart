class AppConfig {
  const AppConfig._();

  static const String openAiApiKey =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String openAiBaseUrl =
      String.fromEnvironment('OPENAI_BASE_URL', defaultValue: 'https://api.openai.com');
  static const String openAiModel =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');

  static bool get hasOpenAiKey => openAiApiKey.trim().isNotEmpty;
}
