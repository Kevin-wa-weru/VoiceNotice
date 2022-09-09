part of 'sent_voices_cubit.dart';

@freezed
class SentVoicesState with _$SentVoicesState {
  const factory SentVoicesState.initial() = _Initial;
  const factory SentVoicesState.loading() = _Loading;
  const factory SentVoicesState.loaded(List sentAlarms) = _Loaded;
  const factory SentVoicesState.error(String Message) = _Error;
}
