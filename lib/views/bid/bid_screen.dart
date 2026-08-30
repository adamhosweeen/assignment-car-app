import 'package:flutter/material.dart';

import 'package:assignment/widgets/common/coming_soon.dart';

/// Bid is not built in v1 — a placeholder holds the middle tab
/// (V1_SPEC §4.3). Skeletons for it live under `model/bid/` and
/// `control/bid/`; there is no database schema for bids yet.
class BidScreen extends StatelessWidget {
  const BidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Bid',
      icon: Icons.gavel_outlined,
      message: 'Place bids on cars and let buyers compete for yours.',
    );
  }
}
