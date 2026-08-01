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

  // ── Media sizes ──────────────────────────────────────────────────────────
  /// Photo thumbnail (sell photo grid, review strip).
  static const double thumbMd = 96;

  /// Listing card cover height.
  static const double coverHeight = 200;

  /// Listing detail gallery height.
  static const double galleryHeight = 300;
}
