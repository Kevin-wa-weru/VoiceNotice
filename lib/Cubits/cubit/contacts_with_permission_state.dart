part of 'contacts_with_permission_cubit.dart';

@freezed
class ContactsWithPermissionState with _$ContactsWithPermissionState {
  const factory ContactsWithPermissionState.initial() = _Initial;
  const factory ContactsWithPermissionState.loading() = _Loading;
  const factory ContactsWithPermissionState.loaded(
      List allContactsWithPermissions) = _Loaded;
  const factory ContactsWithPermissionState.error(String message) = _Error;
}
