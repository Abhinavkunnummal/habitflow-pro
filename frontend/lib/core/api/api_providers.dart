import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/session_storage.dart';
import 'api_client.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw UnimplementedError('sessionStorageProvider must be initialized in main()');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final sessionStorage = ref.watch(sessionStorageProvider);
  return ApiClient(
    sessionStorage: sessionStorage,
  );
});
