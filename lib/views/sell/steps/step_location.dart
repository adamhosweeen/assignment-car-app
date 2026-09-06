import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/services/location_service.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/malaysian_states.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

class StepLocation extends StatefulWidget {
  const StepLocation({super.key});

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  late final TextEditingController _city;

  // Transient UI state for the "Use my location" row — not part of the draft.
  bool _detecting = false;
  bool _locationFailed = false;

  @override
  void initState() {
    super.initState();
    _city = TextEditingController(
      text: context.read<SellController>().draft.city ?? '',
    );
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  SellController get _notifier => context.read<SellController>();

  Future<void> _detectLocation() async {
    if (_detecting) return;
    setState(() {
      _detecting = true;
      _locationFailed = false;
    });
    final detected = await detectStateName();
    if (!mounted) return;
    if (detected != null) _notifier.setDetectedState(detected);
    setState(() {
      _detecting = false;
      _locationFailed = detected == null;
    });
  }

  Future<void> _pickRegion() async {
    final picked = await showSelectSheet<RegistrationRegion>(
      context: context,
      title: 'Region',
      options: RegistrationRegion.values,
      labelOf: (r) => r.label,
      selected: context.read<SellController>().draft.registrationRegion,
    );
    if (picked != null) _notifier.setRegion(picked);
  }

  Future<void> _pickState() async {
    final region = context.read<SellController>().draft.registrationRegion;
    if (region == null) return;
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'State',
      options: MalaysianStates.inRegion(region),
      labelOf: (s) => s,
      selected: context.read<SellController>().draft.state,
    );
    if (picked != null) _notifier.setStateName(picked);
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<SellController>().draft;
    const placeholder = AppColors.tertiaryLabel;
    return SellStepScaffold(
      title: 'Registration & location',
      subtitle: 'Use your location, or pick the region — the state list '
          'follows from it.',
      children: [
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Use my location',
              labelColor: AppColors.primary,
              value: '',
              trailing: _detecting
                  ? const SizedBox(
                      width: AppSpacing.iconMd,
                      height: AppSpacing.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSpacing.avatarRingWidth,
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      size: AppSpacing.iconMd,
                      color: AppColors.primary,
                    ),
              onTap: _detecting ? null : _detectLocation,
            ),
            GroupedRow(
              label: 'Region',
              value: draft.registrationRegion?.label ?? 'Select',
              valueColor: draft.registrationRegion == null ? placeholder : null,
              showChevron: true,
              onTap: _pickRegion,
            ),
            GroupedRow(
              label: 'State',
              value: draft.state ?? 'Select',
              valueColor: draft.state == null ? placeholder : null,
              showChevron: true,
              onTap: draft.registrationRegion == null ? null : _pickState,
            ),
          ],
        ),
        if (_locationFailed) ...[
          const SizedBox(height: AppSpacing.space12),
          const InlineNotice(
            kind: NoticeKind.error,
            text: 'We couldn’t detect your location — pick the region and '
                'state manually.',
          ),
        ] else if (draft.state != null) ...[
          const SizedBox(height: AppSpacing.space12),
          InlineNotice(
            kind: NoticeKind.success,
            text: 'Set to ${draft.state}, ${draft.registrationRegion?.label}.',
          ),
        ],
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('City'),
        TextField(
          controller: _city,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Petaling Jaya'),
          onChanged: (v) =>
              _notifier.setCity(v.trim().isEmpty ? null : v.trim()),
        ),
      ],
    );
  }
}
