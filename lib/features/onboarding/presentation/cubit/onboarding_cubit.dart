import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/local/local_storage_service.dart';

class OnboardingCubit extends Cubit<bool> {
  final LocalStorageService _storageService;

  OnboardingCubit({required LocalStorageService storageService})
      : _storageService = storageService,
        super(false);

  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingComplete(true);
    emit(true);
  }
}
