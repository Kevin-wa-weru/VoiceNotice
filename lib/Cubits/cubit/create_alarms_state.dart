part of 'create_alarms_cubit.dart';

@freezed
class CreateAlarmsState with _$CreateAlarmsState {
  const factory CreateAlarmsState.initial() = _Initial;
  const factory CreateAlarmsState.loading() = _Loading;
  const factory CreateAlarmsState.loaded(List allAlarms) = _Loaded;
  const factory CreateAlarmsState.error(String message) = _Error;
}
