import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/services/save_service.dart';

/// Player profile (collection + records), loaded once and saved on change.
class ProfileController extends Notifier<Profile> {
  @override
  Profile build() => ref.read(saveServiceProvider).loadProfile();

  void _commit() {
    ref.read(saveServiceProvider).saveProfile(state);
    ref.notifyListeners();
  }

  /// Records Kuts/bosses/records revealed by [run].
  void observe(RunState run) {
    if (state.observe(run)) _commit();
  }

  void runStarted() {
    state.runsStarted++;
    _commit();
  }

  void runWon() {
    state.runsWon++;
    _commit();
  }
}

final profileProvider = NotifierProvider<ProfileController, Profile>(
  ProfileController.new,
);
