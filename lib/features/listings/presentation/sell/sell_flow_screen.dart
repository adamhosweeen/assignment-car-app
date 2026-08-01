import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../shared/widgets/button_spinner.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/listing_draft.dart';
import 'sell_controller.dart';
import 'steps/step_condition.dart';
import 'steps/step_identity.dart';
import 'steps/step_location.dart';
import 'steps/step_photos.dart';
import 'steps/step_price.dart';
import 'steps/step_review.dart';
import 'steps/step_specs.dart';

const int _lastStep = 6;

/// The 7-step create-listing flow. One step per screen, a thin progress bar,
/// back preserves data, and the draft is written to Hive after every step.
class SellFlowScreen extends ConsumerStatefulWidget {
  const SellFlowScreen({super.key});

  @override
  ConsumerState<SellFlowScreen> createState() => _SellFlowScreenState();
}

class _SellFlowScreenState extends ConsumerState<SellFlowScreen> {
  int _step = 0;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _step = ref.read(sellControllerProvider).currentStep.clamp(0, _lastStep);
  }

  void _goTo(int step) {
    final target = step.clamp(0, _lastStep);
    setState(() => _step = target);
    ref.read(sellControllerProvider.notifier).setStep(target);
  }

  void _back() {
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
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    setState(() => _publishing = true);
    final draft = ref.read(sellControllerProvider);
    final res = await ref
        .read(listingsRepositoryProvider)
        .publish(draft, user.id);
    if (!mounted) return;
    switch (res) {
      case Ok():
        await ref.read(sellControllerProvider.notifier).discard();
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
    final draft = ref.watch(sellControllerProvider);
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
      canPop: _step == 0,
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
