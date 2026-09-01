import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/search_scaffold.dart';
import 'package:assignment/widgets/profile/seller_row.dart';

/// Profile → Find Sellers: look up other users by name and open their public
/// seller page (V1_SPEC §4.10).
class SellerSearchScreen extends StatelessWidget {
  const SellerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
      hint: 'Search sellers',
      idleText: 'Search sellers by name to see the cars they’re selling.',
      resultsBuilder: (context, query) => _Results(query: query),
    );
  }
}

class _Results extends StatefulWidget {
  const _Results({required this.query});

  final String query;

  @override
  State<_Results> createState() => _ResultsState();
}

class _ResultsState extends State<_Results> {
  /// Held so a rebuild doesn't re-issue the request; the search field is
  /// already debounced, and a new query replaces this outright.
  late Future<List<PublicProfile>> _results;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void didUpdateWidget(_Results old) {
    super.didUpdateWidget(old);
    if (widget.query != old.query) _search();
  }

  void _search() =>
      _results = searchSellers(context.read<ProfilesRepository>(), widget.query);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PublicProfile>>(
      future: _results,
      builder: (context, snapshot) {
        final error = snapshot.error;
        if (error != null) {
          return SearchMessage(
            icon: Icons.error_outline,
            text: error is ProfilesException
                ? error.message
                : 'We couldn’t search right now. Check your connection.',
            onRetry: () => setState(_search),
          );
        }
        final profiles = snapshot.data;
        if (profiles == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (profiles.isEmpty) {
          return SearchMessage(
            icon: Icons.person_search_outlined,
            text: 'No sellers match “${widget.query}”.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            GroupedSection(
              children: [
                for (final p in profiles)
                  SellerRow(
                    profile: p,
                    onTap: () => context.push('/seller/${p.id}'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
