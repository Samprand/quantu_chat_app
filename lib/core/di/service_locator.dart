import 'package:get_it/get_it.dart';

import '../../data/datasources/chat_local_datasource.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/websocket_chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/websocket_chat_repository.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../presentation/bloc/chat_bloc.dart';
import '../services/websocket_client.dart';
import '../controllers/ai_chat_controller.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => ChatBloc(
    getMessages: sl(),
    sendMessage: sl(),
  ));

  // AI Chat Controller (requires userId - to be passed when creating)
  sl.registerFactoryParam<AIChatController, String, void>((userId, _) => 
    AIChatController(
      repository: sl(),
      userId: userId,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  sl.registerLazySingleton<WebSocketChatRepository>(
    () => WebSocketChatRepositoryImpl(
      webSocketClient: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton<WebSocketClient>(() => WebSocketClient());

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(),
  );
} 