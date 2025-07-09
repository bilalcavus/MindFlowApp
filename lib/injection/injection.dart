import 'package:get_it/get_it.dart';
import 'package:mind_flow/core/helper/dio_helper.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/repositories/chat_message_repository.dart';
import 'package:mind_flow/data/repositories/dream_analysis_repository.dart';
import 'package:mind_flow/data/repositories/emotion_analysis_repository.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/data/repositories/user_preferences_repository.dart';
// DataSources


// Repositories
import 'package:mind_flow/domain/repositories/chat_bot_repository.dart';
import 'package:mind_flow/domain/repositories/dream_analysis_repository.dart';
import 'package:mind_flow/domain/repositories/journal_repository.dart';
import 'package:mind_flow/domain/repository_impl/chatbot_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/dream_analysis_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/journal_repository_impl.dart';
// Usecases
import 'package:mind_flow/domain/usecases/get_analyze_emotion.dart';
import 'package:mind_flow/domain/usecases/get_chat_response.dart';
import 'package:mind_flow/domain/usecases/get_dream_analysis.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
// ViewModels
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/language/language_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database Services
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  
  // Data Repositories
  getIt.registerLazySingleton<UserEntryRepository>(() => UserEntryRepository());
  getIt.registerLazySingleton<EmotionAnalysisRepository>(() => EmotionAnalysisRepository());
  getIt.registerLazySingleton<DreamAnalysisDataRepository>(() => DreamAnalysisDataRepository());
  getIt.registerLazySingleton<ChatMessageRepository>(() => ChatMessageRepository());
  getIt.registerLazySingleton<UserPreferencesRepository>(() => UserPreferencesRepository());
  getIt.registerLazySingleton<LanguageRepository>(() => LanguageRepository());

  // Core
  getIt.registerLazySingleton<DioHelper>(() => DioHelper());

  // DataSources
  getIt.registerLazySingleton<ApiServices>(() => ApiServices());
  

  // Repositories
  getIt.registerLazySingleton<ChatBotRepository>(() => ChatbotRepositoryImpl(getIt()));
  getIt.registerLazySingleton<JournalRepository>(() => JournalRepositoryImpl(getIt()));
  getIt.registerLazySingleton<DreamAnalysisRepository>(() => DreamAnalysisRepositoryImpl(getIt()));

  // UseCases
  getIt.registerLazySingleton<GetAnalyzeEmotion>(() => GetAnalyzeEmotion(getIt()));
  getIt.registerLazySingleton<GetChatResponse>(() => GetChatResponse(getIt()));
  getIt.registerLazySingleton<GetDreamAnalysis>(() => GetDreamAnalysis(getIt()));


  // ViewModels
  getIt.registerFactory(() => ChatBotProvider(getIt()));
  getIt.registerFactory(() => JournalViewModel(getIt()));
  getIt.registerFactory(() => DreamAnalysisProvider(getIt()));
  getIt.registerFactory(() => NavigationProvider());
  getIt.registerFactory(() => AuthenticationProvider());
  getIt.registerFactory(() => LanguageProvider(getIt()));

}
