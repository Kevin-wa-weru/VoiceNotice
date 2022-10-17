part of 'contacts_with_app_cubit.dart';

@freezed
class ContactsWithAppState with _$ContactsWithAppState {
  const factory ContactsWithAppState.initial() = _Initial;
  const factory ContactsWithAppState.loading() = _Loading;
  const factory ContactsWithAppState.loaded(List<Contact> allContactsWithApp) =
      _Loaded;
  const factory ContactsWithAppState.error(String message) = _Error;
}
