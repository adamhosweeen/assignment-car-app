import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/views/sell/steps/step_condition.dart';
import 'package:assignment/views/sell/steps/step_identity.dart';
import 'package:assignment/views/sell/steps/step_location.dart';
import 'package:assignment/views/sell/steps/step_photos.dart';
import 'package:assignment/views/sell/steps/step_price.dart';
import 'package:assignment/views/sell/steps/step_review.dart';
import 'package:assignment/views/sell/steps/step_specs.dart';

const int _lastStep = 6;

/// The 7-step create-listing flow. One step per screen, a thin progress bar,
/// back preserves data, and the draft is written to sqflite after every step.
class SellFlowScreen extends StatefulWidget {
  const SellFlowScreen({super.key, this.editing = false});

  /// True when the flow was opened to edit an existing listing (it starts on
  /// the review step). Changes how Back behaves: instead of walking the whole
  /// wizard backwards, Back returns to review, and Back from review leaves the
  /// flow entirely — so editing then hitting Back lands on the listing again.
  final bool editing;

  @override
  State<SellFlowScreen> createState() => _SellFlowScreenState();
}

class _SellFlowScreenState extends State<SellFlowScreen> {
  int _step = 0;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _step = context.read<SellController>().draft.currentStep.clamp(0, _lastStep);
  }

  void _goTo(int step) {
    final target = step.clamp(0, _lastStep);
    setState(() => _step = target);
    context.read<SellController>().setStep(target);
  }

  void _back() {
    if (widget.editing) {
      // Edit mode enters on review; the only route to an earlier step is the
      // review screen's per-section jump, so Back returns there — and Back
      // from review leaves the flow (back to the listing).
      if (_step == _lastStep) {
        context.pop();
      } else {
        _goTo(_lastStep);
      }
      return;
    }
    if (_step == 0) {
      context.pop();
    } else {
      _goTo(_step - 1);
    }
  }

  Future<void> _next() async {
    if (_step < _lastStep) {
      _goTo(_step + 1);
    } else {
      await _publish();
    }
  }

  Future<void> _publish() async {
    final user = context.read<AuthRepository>().currentUser;
    if (user == null) return;
    setState(() => _publishing = true);
    final draft = context.read<SellController>().draft;
    final res = await context.read<ListingsRepository>().publish(
      draft,
      user.id,
    );
    if (!mounted) return;
    switch (res) {
      case Ok():
        await context.read<SellController>().discard();
        if (!mounted) return;
        context.go('/home/sell');
      case Err(:final message):
        setState(() => _publishing = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool _canAdvance(ListingDraft d) => switch (_step) {
    0 => d.photoPaths.length >= 3,
    1 => d.make != null && d.model != null && d.year != null,
    2 =>
      d.mileageKm != null &&
          d.transmission != null &&
          d.fuelType != null &&
          d.bodyType != null &&
          (d.colour?.isNotEmpty ?? false),
    3 => d.ownersCount != null,
    4 =>
      d.registrationRegion != null &&
          d.state != null &&
          (d.city?.isNotEmpty ?? false),
    5 => d.priceMyr != null && d.priceMyr! > 0 && d.priceMyr! <= kMaxPriceMyr,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<SellController>().draft;
    final isReview = _step == _lastStep;
    final content = switch (_step) {
      0 => const StepPhotos(),
      1 => const StepIdentity(),
      2 => const StepSpecs(),
      3 => const StepCondition(),
      4 => const StepLocation(),
      5 => const StepPrice(),
      _ => StepReview(onEditStep: _goTo),
    };

    return PopScope(
      canPop: widget.editing ? _step == _lastStep : _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(_step == 0 ? Icons.close : Icons.arrow_back_ios_new),
            onPressed: _back,
          ),
          title: const Text('Sell your car'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(AppSpacing.space4),
            child: LinearProgressIndicator(
              value: (_step + 1) / (_lastStep + 1),
              minHeight: AppSpacing.space4,
              backgroundColor: AppColors.separator,
              color: AppColors.primary,
            ),
          ),
        ),
        body: SafeArea(child: content),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: FilledButton(
              onPressed: (!_publishing && _canAdvance(draft)) ? _next : null,
              child: _publishing
                  ? const ButtonSpinner()
                  : Text(isReview ? 'Publish' : 'Next'),
            ),
          ),
        ),
      ),
    );
  }
}
