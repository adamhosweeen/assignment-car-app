/// Spacing scale, screen padding, corner radii, and hairline thickness for the
/// iOS-minimalist design system.
///
/// This is the ONLY place spacing and radius values are defined (CLAUDE.md §5).
/// Widgets must pull from here — no raw spacing, radius, or size literals in any
/// widget file.
abstract final class AppSpacing {
  // ── Spacing scale: 4, 8, 12, 16, 20, 24, 32 ──────────────────────────────
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  /// Standard screen horizontal padding.
  static const double screenPadding = space16;

  // ── Corner radii ─────────────────────────────────────────────────────────
  /// Text fields (per §5 token table).
  static const double radiusInput = 10;

  /// Buttons (per §5 token table: "10 (buttons, inputs)").
  static const double radiusButton = 10;

  /// Cards and grouped sections.
  static const double radiusCard = 12;

  /// Sheets and modals.
  static const double radiusSheet = 14;

  /// Hairline divider / border thickness.
  static const double hairline = 0.5;

  // ── Ordered lists (used by the design demo) ──────────────────────────────
  /// The spacing scale in order, for visualisation.
  static const List<double> scale = [
    space4,
    space8,
    space12,
    space16,
    space20,
    space24,
    space32,
  ];

  /// The three distinct corner radii, smallest to largest.
  static const List<double> radii = [radiusInput, radiusCard, radiusSheet];

  // ── Component dimensions ─────────────────────────────────────────────────
  /// Primary button height (§5).
  static const double controlHeight = 50;

  /// Bottom navigation bar height (§5).
  static const double navBarHeight = 50;

  /// Minimum iOS touch target.
  static const double minTouchTarget = 44;

  // ── Icon sizes ───────────────────────────────────────────────────────────
  /// Bottom-nav icons (§5).
  static const double iconNav = 24;
  static const double iconMd = 24;
  static const double iconLg = 40;

  /// Splash logo / large empty-state glyphs.
  static const double iconXl = 64;

  /// Profile screen avatar diameter.
  static const double avatarLg = 96;

  /// Small avatar in list rows (seller search results, seller row).
  static const double avatarSm = 44;

  /// Avatar ring stroke width.
  static const double avatarRingWidth = 2;

  /// Diameter of the small "change photo" badge on an editable avatar.
  static const double avatarBadge = 28;

  /// Small icon (inside badges).
  static const double iconSm = 16;

  // ── Media sizes ──────────────────────────────────────────────────────────
  /// Photo thumbnail (sell photo grid, review strip).
  static const double thumbMd = 96;

  /// Listing card cover height.
  static const double coverHeight = 200;

  /// Listing detail gallery height.
  static const double galleryHeight = 300;

  // ── Recommended row (Buy feed) ───────────────────────────────────────────
  /// Compact recommendation card width (~2.3 cards visible on a 390pt
  /// screen, so the row visibly continues off the right edge).
  static const double recommendCardWidth = 168;

  /// Compact recommendation card cover height.
  static const double recommendCoverHeight = 112;

  /// Height of the horizontal recommendation list: cover + text block with a
  /// little slack (the card itself is content-sized and top-aligned).
  static const double recommendRowHeight = 184;

  // ── Market insights (ranked bars, monthly chart) ─────────────────────────
  /// Width reserved for the rank number in a ranked row.
  static const double rankWidth = 28;

  /// Thickness of a horizontal proportion bar.
  static const double rankBarHeight = 6;

  /// Corner radius of proportion bars (half of [rankBarHeight]).
  static const double radiusBar = 3;

  /// Height of the bars area in the monthly registrations chart.
  static const double monthlyChartHeight = 120;

  /// Minimum visible height of a non-zero monthly bar.
  static const double monthlyBarMinHeight = 2;

  // ── Search ───────────────────────────────────────────────────────────────
  /// Height reserved under the Buy app bar for the search bar (field + gap).
  static const double searchBarHeight = 56;

  // ── Segmented control ────────────────────────────────────────────────────
  /// Total height of the control.
  static const double segmentHeight = 32;

  /// Corner radius of the track.
  static const double radiusSegment = 8;

  /// Gap between the track edge and the selected pill.
  static const double segmentInset = 2;
}
