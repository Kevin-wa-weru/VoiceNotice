part of 'received_message_cubit.dart';

@freezed
class ReceivedMessageState with _$ReceivedMessageState {
  const factory ReceivedMessageState.initial() = _Initial;
  const factory ReceivedMessageState.loading() = _Loading;
  const factory ReceivedMessageState.loaded(List receivedMessage) = _Loaded;
  const factory ReceivedMessageState.error(String Message) = _Error;
}
