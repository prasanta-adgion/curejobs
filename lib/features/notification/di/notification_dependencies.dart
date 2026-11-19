import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/notification_remote_data_source.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/usecases/get_unread_notification_count_usecase.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/mark_notification_read_usecase.dart';
import '../presentation/bloc/notifications_bloc.dart';
import '../presentation/cubit/unread_notification_count_cubit.dart';

void registerNotificationDependencies(GetIt sl) {
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetUnreadNotificationCountUseCase>(
    () => GetUnreadNotificationCountUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<MarkNotificationReadUseCase>(
    () => MarkNotificationReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<MarkAllNotificationsReadUseCase>(
    () => MarkAllNotificationsReadUseCase(sl<NotificationRepository>()),
  );

  // New bloc per screen.
  sl.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(
      sl<GetNotificationsUseCase>(),
      sl<MarkNotificationReadUseCase>(),
      sl<MarkAllNotificationsReadUseCase>(),
    ),
  );

  // Shared so every screen sees the same badge count.
  sl.registerLazySingleton<UnreadNotificationCountCubit>(
    () => UnreadNotificationCountCubit(sl<GetUnreadNotificationCountUseCase>()),
  );
}
