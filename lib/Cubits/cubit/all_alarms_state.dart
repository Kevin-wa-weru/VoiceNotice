part of 'all_alarms_cubit.dart';

@freezed
class AllAlarmsState with _$AllAlarmsState {
  const factory AllAlarmsState.initial() = _Initial;
  const factory AllAlarmsState.loading() = _Loading;
  const factory AllAlarmsState.loaded(List allAlarms, List userNames) = _Loaded;
  // ignore: non_constant_identifier_names
  const factory AllAlarmsState.error(String Message) = _Error;
}
