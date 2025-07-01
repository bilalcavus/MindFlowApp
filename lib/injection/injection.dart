import 'package:get_it/get_it.dart';
import 'package:mind_flow/core/helper/dio_helper.dart';
import 'package:mind_flow/core/services/api_services.dart';
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
// ViewModels
import 'package:mind_flow/presentation/viewmodel/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<DioHelper>(() => DioHelper());

  // DataSources
  getIt.registerLazySingleton<ApiServices>(() => ApiServices());
  // getIt.registerLazySingleton<GenreRemoteDataSource>(() => GenreRemoteDataSourceImpl(getIt()));
  // getIt.registerLazySingleton<PlaylistRemoteDataSource>(() => PlaylistRemoteDataSourceImpl(getIt()));

  // Repositories
  getIt.registerLazySingleton<ChatBotRepository>(() => ChatbotRepositoryImpl(getIt()));
  getIt.registerLazySingleton<JournalRepository>(() => JournalRepositoryImpl(getIt()));
  getIt.registerLazySingleton<DreamAnalysisRepository>(() => DreamAnalysisRepositoryImpl(getIt()));
  // PlaylistRepository de gerekiyorsa ekle

  // UseCases
  getIt.registerLazySingleton<GetAnalyzeEmotion>(() => GetAnalyzeEmotion(getIt()));
  getIt.registerLazySingleton<GetChatResponse>(() => GetChatResponse(getIt()));
  getIt.registerLazySingleton<GetDreamAnalysis>(() => GetDreamAnalysis(getIt()));


  // getIt.registerLazySingleton<GetGenres>(() => GetGenres(getIt()));
  // getIt.registerLazySingleton<GetPopularPlaylists>(() => GetPopularPlaylists(getIt()));

  // ViewModels
  getIt.registerFactory(() => ChatBotProvider(getIt()));
  getIt.registerFactory(() => JournalViewModel(getIt()));
  getIt.registerFactory(() => DreamAnalysisProvider(getIt()));
  getIt.registerFactory(() => NavigationProvider());

}
