import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../viewmodels/vm_home.dart';
import '../widgets/tng_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          TngHeader(
            title: 'scan_title'.tr(),
            subtitle: 'scan_subtitle'.tr(),
            height: 180,
            trailing: _ProfileButton(
              onTap: () => Navigator.pushNamed(context, '/wellness'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _QuickActions(
                      onScan: () => vm.foodRecognition(
                        FoodRecognitionAction.takePhoto,
                        context,
                      ),
                      onUpload: () => vm.foodRecognition(
                        FoodRecognitionAction.uploadImage,
                        context,
                      ),
                      onInsight: () => Navigator.pushNamed(context, '/insight'),
                      onHistory: () => Navigator.pushNamed(context, '/history'),
                    ),
                    const SizedBox(height: 16),

                    /// CAMERA FRAME
                    GestureDetector(
                      onTap: () {
                        vm.foodRecognition(
                          FoodRecognitionAction.takePhoto,
                          context,
                        );
                      },
                      child: Container(
                        height: 260,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cs.onPrimary.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: cs.primary.withOpacity(0.25),
                            width: 1.2,
                          ),
                        ),
                        child: vm.capturedImage == null
                            ? _buildEmptyCameraBox(context)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.file(
                                  File(vm.capturedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// ANALYZE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: vm.isAnalyzing
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () {
                                vm.foodRecognition(
                                  FoodRecognitionAction.analyze,
                                  context,
                                );
                              },
                              child: Text('analyze_button'.tr()),
                            ),
                    ),

                    const SizedBox(height: 12),

                    /// UPLOAD BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          vm.foodRecognition(
                            FoodRecognitionAction.uploadImage,
                            context,
                          );
                        },
                        icon: const Icon(Icons.folder_open),
                        label: Text('gallery_upload_button'.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          side: BorderSide(color: cs.primary.withOpacity(0.35)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CAMERA PLACEHOLDER
  Widget _buildEmptyCameraBox(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_rounded,
            size: 60, color: Theme.of(context).dividerColor),
        const SizedBox(height: 15),
        Text(
          'camera_placeholder'.tr(),
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        Text(
          'camera_tap_hint'.tr(),
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.5) ??
                  Colors.black45),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onUpload;
  final VoidCallback onInsight;
  final VoidCallback onHistory;

  const _QuickActions({
    required this.onScan,
    required this.onUpload,
    required this.onInsight,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget item({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.primary.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        item(icon: Icons.qr_code_scanner, label: 'scan_action'.tr(), onTap: onScan),
        const SizedBox(width: 10),
        item(icon: Icons.image_outlined, label: 'upload_action'.tr(), onTap: onUpload),
        const SizedBox(width: 10),
        item(icon: Icons.insights_outlined, label: 'insight_action'.tr(), onTap: onInsight),
        const SizedBox(width: 10),
        item(icon: Icons.history, label: 'history_action_label'.tr(), onTap: onHistory),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.person_outline, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
