/// Hardcoded make/model catalogue for v1 (CLAUDE.md §4.5).
///
/// Common Malaysian makes with their common models, plus an "Other" free-text
/// escape hatch on both make and model. No database-backed catalogue in v1.
abstract final class CarCatalog {
  /// Sentinel for the free-text option, used on both make and model.
  static const String other = 'Other';

  static const Map<String, List<String>> _byMake = {
    'Perodua': [
      'Myvi',
      'Axia',
      'Bezza',
      'Alza',
      'Ativa',
      'Aruz',
      'Kancil',
      'Viva',
      'Kenari',
      other,
    ],
    'Proton': [
      'Saga',
      'Persona',
      'Iriz',
      'X50',
      'X70',
      'X90',
      'S70',
      'Exora',
      'Preve',
      'Wira',
      other,
    ],
    'Honda': [
      'City',
      'Civic',
      'Accord',
      'Jazz',
      'HR-V',
      'CR-V',
      'BR-V',
      'Odyssey',
      other,
    ],
    'Toyota': [
      'Vios',
      'Yaris',
      'Corolla Altis',
      'Camry',
      'Hilux',
      'Fortuner',
      'Innova',
      'Avanza',
      'Rush',
      'Alphard',
      'Vellfire',
      other,
    ],
    'Nissan': [
      'Almera',
      'Sylphy',
      'X-Trail',
      'Serena',
      'Navara',
      'Grand Livina',
      other,
    ],
    'Mazda': [
      'Mazda2',
      'Mazda3',
      'Mazda6',
      'CX-3',
      'CX-5',
      'CX-8',
      'CX-30',
      other,
    ],
    'Mitsubishi': ['Triton', 'ASX', 'Outlander', 'Xpander', other],
    'Hyundai': ['i10', 'i30', 'Elantra', 'Tucson', 'Santa Fe', 'Kona', other],
    'Kia': ['Picanto', 'Cerato', 'Sportage', 'Sorento', 'Carnival', other],
    'BMW': [
      '1 Series',
      '2 Series',
      '3 Series',
      '5 Series',
      '7 Series',
      'X1',
      'X3',
      'X5',
      other,
    ],
    'Mercedes-Benz': [
      'A-Class',
      'C-Class',
      'E-Class',
      'S-Class',
      'GLA',
      'GLC',
      'GLE',
      other,
    ],
    'Volkswagen': ['Polo', 'Golf', 'Vento', 'Passat', 'Tiguan', other],
    'Audi': ['A3', 'A4', 'A6', 'Q3', 'Q5', other],
    'Ford': ['Fiesta', 'Focus', 'Ranger', 'Everest', other],
    'Isuzu': ['D-Max', 'MU-X', other],
    'Subaru': ['Impreza', 'XV', 'Forester', 'Outback', other],
    'BYD': ['Atto 3', 'Dolphin', 'Seal', other],
    'Tesla': ['Model 3', 'Model Y', 'Model S', 'Model X', other],
    other: [other],
  };

  /// All makes, in catalogue order, with "Other" last.
  static List<String> get makes => _byMake.keys.toList();

  /// Models for [make], or just "Other" for an unknown/free-text make.
  static List<String> modelsFor(String make) => _byMake[make] ?? const [other];
}
