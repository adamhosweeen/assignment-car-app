// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All users with their listing counts (admin screen). Errors for non-admin
/// callers — the server refuses the RPC.

@ProviderFor(adminUsers)
final adminUsersProvider = AdminUsersProvider._();

/// All users with their listing counts (admin screen). Errors for non-admin
/// callers — the server refuses the RPC.

final class AdminUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminUserStats>>,
          List<AdminUserStats>,
          FutureOr<List<AdminUserStats>>
        >
    with
        $FutureModifier<List<AdminUserStats>>,
        $FutureProvider<List<AdminUserStats>> {
  /// All users with their listing counts (admin screen). Errors for non-admin
  /// callers — the server refuses the RPC.
  AdminUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<AdminUserStats>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AdminUserStats>> create(Ref ref) {
    return adminUsers(ref);
  }
}

String _$adminUsersHash() => r'ee499fc6104be2d59150bb12bfefeef2398dbb59';

/// All user-filed reports, newest first (admin reports screen).

@ProviderFor(adminReports)
final adminReportsProvider = AdminReportsProvider._();

/// All user-filed reports, newest first (admin reports screen).

final class AdminReportsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminReport>>,
          List<AdminReport>,
          FutureOr<List<AdminReport>>
        >
    with
        $FutureModifier<List<AdminReport>>,
        $FutureProvider<List<AdminReport>> {
  /// All user-filed reports, newest first (admin reports screen).
  AdminReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminReportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminReportsHash();

  @$internal
  @override
  $FutureProviderElement<List<AdminReport>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AdminReport>> create(Ref ref) {
    return adminReports(ref);
  }
}

String _$adminReportsHash() => r'eee02e1309afdaf063ef11ee2868a859ac91c219';
