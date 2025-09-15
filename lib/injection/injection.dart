import 'package:get_it/get_it.dart';
import 'package:mind_flow/core/helper/dio_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/core/services/google_play_billing_service.dart';
import 'package:mind_flow/core/utility/theme/theme_provider.dart';
import 'package:mind_flow/data/datasources/api_remote_datasource.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/repositories/chat_message_repository.dart';
import 'package:mind_flow/data/repositories/dream_analysis_repository.dart';
import 'package:mind_flow/data/repositories/emotion_analysis_repository.dart';
import 'package:mind_flow/data/repositories/habit_analysis_repository.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/data/repositories/mental_analysis_repository.dart';
import 'package:mind_flow/data/repositories/personality_analysis_repository.dart';
import 'package:mind_flow/data/repositories/stress_analysis_repository.dart';
import 'package:mind_flow/data/repositories/subscription_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/data/repositories/user_preferences_repository.dart';
import 'package:mind_flow/data/repositories/user_ticket_repository.dart';
// DataSources


// Repositories
import 'package:mind_flow/domain/repositories/chat_bot_repository.dart';
import 'package:mind_flow/domain/repositories/dream_analysis_repository.dart';
import 'package:mind_flow/domain/repositories/habit_repository.dart';
import 'package:mind_flow/domain/repositories/journal_repository.dart';
import 'package:mind_flow/domain/repositories/mental_repository.dart';
import 'package:mind_flow/domain/repositories/personality_repository.dart';
import 'package:mind_flow/domain/repositories/stress_repository.dart';
import 'package:mind_flow/domain/repository_impl/chatbot_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/dream_analysis_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/habit_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/journal_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/mental_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/personality_repository_impl.dart';
import 'package:mind_flow/domain/repository_impl/stress_analysis_impl.dart';
// Usecases
import 'package:mind_flow/domain/usecases/get_analyze_emotion.dart';
import 'package:mind_flow/domain/usecases/get_available_models.dart';
import 'package:mind_flow/domain/usecases/get_available_providers.dart';
import 'package:mind_flow/domain/usecases/get_chat_response.dart';
import 'package:mind_flow/domain/usecases/get_current_provider.dart';
import 'package:mind_flow/domain/usecases/get_dream_analysis.dart';
import 'package:mind_flow/domain/usecases/get_habit_analysis.dart';
import 'package:mind_flow/domain/usecases/get_mental_analysis.dart';
import 'package:mind_flow/domain/usecases/get_model_display_name.dart';
import 'package:mind_flow/domain/usecases/get_personality_analysis.dart';
import 'package:mind_flow/domain/usecases/get_stress_analysis.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/habit_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/mental_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/personality_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/stress_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
// ViewModels
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/language/language_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/viewmodel/support-ticket/support_ticket_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database Services
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  
  // Data Repositories
  getIt.registerLazySingleton<UserEntryRepository>(() => UserEntryRepository());
  getIt.registerLazySingleton<EmotionAnalysisRepository>(() => EmotionAnalysisRepository());
  getIt.registerLazySingleton<DreamAnalysisDataRepository>(() => DreamAnalysisDataRepository());
  getIt.registerLazySingleton<ChatMessageRepository>(() => ChatMessageRepository());
  getIt.registerLazySingleton<UserPreferencesRepository>(() => UserPreferencesRepository());
  getIt.registerLazySingleton<LanguageRepository>(() => LanguageRepository());
  getIt.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepository(getIt()));

  getIt.registerLazySingleton<HabitAnalysisRepository>(() => HabitAnalysisRepository());
  getIt.registerLazySingleton<PersonalityAnalysisRepository>(() => PersonalityAnalysisRepository());
  getIt.registerLazySingleton<MentalAnalysisRepository>(() => MentalAnalysisRepository());
  getIt.registerLazySingleton<StressAnalysisRepository>(() => StressAnalysisRepository());
  getIt.registerLazySingleton<UserTicketRepository>(() => UserTicketRepository(getIt()));

  // Core
  getIt.registerLazySingleton<DioHelper>(() => DioHelper());

  // DataSources
  getIt.registerLazySingleton<RemoteDataSource>(() => ApiRemoteDataSource());
  getIt.registerLazySingleton<ApiRemoteDataSource>(() => ApiRemoteDataSource());
  
  // Core Services
  // getIt.registerLazySingleton<SharedPrefsService>(() => SharedPrefsService());
  getIt.registerLazySingleton<BillingService>(() => BillingService(getIt()));
  

  // Repositories
  getIt.registerLazySingleton<ChatBotRepository>(() => ChatbotRepositoryImpl(getIt()));
  getIt.registerLazySingleton<JournalRepository>(() => JournalRepositoryImpl(getIt()));
  getIt.registerLazySingleton<DreamAnalysisRepository>(() => DreamAnalysisRepositoryImpl(getIt()));
  getIt.registerLazySingleton<HabitRepository>(() => HabitRepositoryImpl(getIt()));
  getIt.registerLazySingleton<PersonalityRepository>(() => PersonalityRepositoryImpl(getIt()));
  getIt.registerLazySingleton<MentalRepository>(() => MentalRepositoryImpl(getIt()));
  getIt.registerLazySingleton<StressRepository>(() => StressAnalysisImpl(getIt()));

  // UseCases
  getIt.registerLazySingleton<GetAnalyzeEmotion>(() => GetAnalyzeEmotion(getIt()));
  getIt.registerLazySingleton<GetChatResponse>(() => GetChatResponse(getIt<RemoteDataSource>()));
  getIt.registerLazySingleton<GetDreamAnalysis>(() => GetDreamAnalysis(getIt()));
  getIt.registerLazySingleton<GetAvailableModels>(() => GetAvailableModels(getIt()));
  getIt.registerLazySingleton<GetAvailableProviders>(() => GetAvailableProviders(getIt()));
  getIt.registerLazySingleton<GetCurrentProvider>(() => GetCurrentProvider(getIt()));
  getIt.registerLazySingleton<GetModelDisplayName>(() => GetModelDisplayName(getIt()));
  getIt.registerLazySingleton<GetHabitAnalysis>(() => GetHabitAnalysis(getIt()));
  getIt.registerLazySingleton<GetPersonalityAnalysis>(() => GetPersonalityAnalysis(getIt()));
  getIt.registerLazySingleton<GetStressAnalysis>(() => GetStressAnalysis(getIt()));
  getIt.registerLazySingleton<GetMentalAnalysis>(() => GetMentalAnalysis(getIt()));


  // ViewModels
  getIt.registerLazySingleton(() => ChatBotProvider(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => EmotionAnalysisProvider(getIt(), getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => DreamAnalysisProvider(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => PersonalityAnalysisProvider(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => HabitAnalysisProvider(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => StressAnalysisProvider(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => MentalAnalysisProvider(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => NavigationProvider());
  getIt.registerLazySingleton(() => AuthenticationProvider(getIt()));
  getIt.registerLazySingleton(() => LanguageProvider(getIt(), getIt()));
  getIt.registerLazySingleton(() => SubscriptionProvider(getIt<SubscriptionRepository>(), getIt<BillingService>()));
  getIt.registerLazySingleton(() => SupportTicketProvider(getIt()));
  getIt.registerLazySingleton(() => ThemeProvider());

}
