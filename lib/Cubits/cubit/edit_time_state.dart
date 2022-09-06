part of 'edit_time_cubit.dart';

@freezed
class EditTimeState with _$EditTimeState {
  const factory EditTimeState.initial() = _Initial;
  const factory EditTimeState.loading() = _Loading;
  const factory EditTimeState.loaded(int hour, int minute) = _Loaded;
  const factory EditTimeState.error(String message) = _Error;
}
