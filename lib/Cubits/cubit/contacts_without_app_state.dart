part of 'contacts_without_app_cubit.dart';

@freezed
class ContactsWithoutAppState with _$ContactsWithoutAppState {
  const factory ContactsWithoutAppState.initial() = _Initial;
  const factory ContactsWithoutAppState.loading() = _Loading;
  const factory ContactsWithoutAppState.loaded(
      List<Contact> allContactsWithOutApp) = _Loaded;
  const factory ContactsWithoutAppState.error(String message) = _Error;
}
