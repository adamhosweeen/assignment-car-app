import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';

/// Build an editable [ListingDraft] from an existing [Listing], for the Edit
/// action. Starts at the review step so the seller can tweak and re-publish.
ListingDraft draftFromListing(Listing l) {
  final videos = l.media.where((m) => m.mediaType == MediaType.video).toList();
  return ListingDraft(
    id: l.id,
    photoPaths: l.media
        .where((m) => m.mediaType == MediaType.photo)
        .map((m) => m.storagePath)
        .toList(),
    videoPath: videos.isEmpty ? null : videos.first.storagePath,
    make: l.make,
    model: l.model,
    variant: l.variant,
    year: l.year,
    mileageKm: l.mileageKm,
    transmission: l.transmission,
    fuelType: l.fuelType,
    bodyType: l.bodyType,
    colour: l.colour,
    ownersCount: l.ownersCount,
    accidentFree: l.accidentFree,
    roadTaxExpiry: l.roadTaxExpiry,
    registrationRegion: l.registrationRegion,
    state: l.state,
    city: l.city,
    priceMyr: l.priceMyr,
    negotiable: l.negotiable,
    description: l.description,
    currentStep: 6,
    updatedAt: DateTime.now().toUtc(),
  );
}
