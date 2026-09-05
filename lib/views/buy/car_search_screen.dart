import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/widgets/common/search_scaffold.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/listing_card.dart';

class CarSearchScreen extends StatelessWidget {
  const CarSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
      hint: 'Search cars',
      idleText: 'Search by make, model or variant — e.g. “Myvi” or “Civic”.',
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
  late Future<List<Listing>> _results;

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

  void _search() => _results = searchListings(
    context.read<ListingsRepository>(),
    widget.query,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Listing>>(
      future: _results,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SearchMessage(
            icon: Icons.error_outline,
            text: 'We couldn’t search right now. Check your connection.',
            onRetry: () => setState(_search),
          );
        }
        final listings = snapshot.data;
        if (listings == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (listings.isEmpty) {
          return SearchMessage(text: 'No cars match “${widget.query}”.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: listings.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSpacing.space16),
          itemBuilder: (_, i) {
            final l = listings[i];
            return ListingCard(
              listing: l,
              cover: CoverImage(media: l.cover),
              onTap: () => context.push('/listing/${l.id}'),
            );
          },
        );
      },
    );
  }
}
