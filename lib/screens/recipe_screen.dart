import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/main_provider.dart';
import '../../providers/timer_provider.dart';
import '../constants.dart';

final _text = kTextStyle.copyWith(color: kLine);
final _heading = kBigTextStyle.copyWith(color: kLine, fontSize: 18);

BoxDecoration _outline({double radius = 28, Color color = kBg}) =>
    outlineDecoration(radius: radius, color: color);

enum _PhotoChoice { camera, gallery, none }

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  /// True while a [RecipeScreen] is in the tree (used by notification taps).
  static bool isOpen = false;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  void initState() {
    super.initState();
    RecipeScreen.isOpen = true;
  }

  @override
  void dispose() {
    RecipeScreen.isOpen = false;
    super.dispose();
  }

  Future<void> _toggleFavorite(BuildContext context, MainProvider data) async {
    final favorites = context.read<FavoritesProvider>();
    final id = data.favoriteId;
    if (id != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _outline(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Text(
                  'removeFavoriteTitle'.tr(),
                  textAlign: TextAlign.center,
                  style: kHeaderStyle,
                ),
                Text(
                  'removeFavoriteBody'.tr(),
                  textAlign: TextAlign.center,
                  style: _text.copyWith(color: kLine.withValues(alpha: 0.55)),
                ),
                _ActionTile(
                  icon: Icons.heart_broken_rounded,
                  label: 'remove'.tr(),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
                _ActionTile(
                  icon: Icons.close_rounded,
                  label: 'cancel'.tr(),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
              ],
            ),
          ),
        ),
      );
      if (confirmed != true) return;
      await favorites.remove(id);
      data.setFavoriteId(null);
      return;
    }
    final choice = await showModalBottomSheet<_PhotoChoice>(
      context: context,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: kLine, width: kLineWidth),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text('addPhotoTitle'.tr(), style: kHeaderStyle),
              Text(
                'addPhotoSubtitle'.tr(),
                textAlign: TextAlign.center,
                style: _text.copyWith(color: kLine.withValues(alpha: 0.55)),
              ),
              _ActionTile(
                icon: Icons.photo_camera_rounded,
                label: 'takePhoto'.tr(),
                onPressed: () => Navigator.pop(ctx, _PhotoChoice.camera),
              ),
              _ActionTile(
                icon: Icons.photo_library_rounded,
                label: 'chooseFromGallery'.tr(),
                onPressed: () => Navigator.pop(ctx, _PhotoChoice.gallery),
              ),
              _ActionTile(
                icon: Icons.favorite_border_rounded,
                label: 'saveWithoutPhoto'.tr(),
                onPressed: () => Navigator.pop(ctx, _PhotoChoice.none),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    XFile? photo;
    if (choice != _PhotoChoice.none) {
      photo = await ImagePicker().pickImage(
        source: choice == _PhotoChoice.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 80,
      );
      // Cancelling the picker cancels saving too.
      if (photo == null) return;
    }
    data.setFavoriteId(await favorites.add(data.answer, photo: photo));
  }

  Future<void> _pickDuration(BuildContext context, String name) async {
    final timer = context.read<TimerProvider>();
    final minutes = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: kLine, width: kLineWidth),
      ),
      builder: (_) => const _TimerPickerSheet(),
    );
    if (minutes != null) {
      await timer.start(Duration(minutes: minutes), name);
    }
  }

  /// Main timer action: start / pause / resume / dismiss, by current state.
  void _timerAction(TimerProvider timer, String name) {
    switch (timer.status) {
      case TimerStatus.idle:
        _pickDuration(context, name);
      case TimerStatus.running:
        timer.pause();
      case TimerStatus.paused:
        timer.resume();
      case TimerStatus.finished:
        timer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: true,
      body: Consumer2<MainProvider, TimerProvider>(
        builder: (context, data, timer, _) {
          final recipe = data.answer;
          final status = timer.status;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      const Icon(
                        shadows: kIconShadow,
                        Icons.restaurant_menu_rounded,
                        size: 28,
                        color: kLine,
                      ),
                      Expanded(
                        child: Text(
                          recipe.recipeName,
                          style: kHeaderStyle.copyWith(height: 1.15),
                        ),
                      ),
                    ],
                  ),
                  _RecipeCard(
                    title: 'ingredients'.tr(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        for (final item in recipe.ingredients)
                          Text('–  $item', style: _text.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                  _RecipeCard(
                    title: 'instructions'.tr(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        for (var i = 0; i < recipe.instructions.length; i++)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(
                                '${i + 1}.',
                                style: _heading.copyWith(fontSize: 15),
                              ),
                              Expanded(
                                child: Text(
                                  recipe.instructions[i],
                                  style: _text.copyWith(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Timer pill.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: _outline(),
                    child: Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: Text(
                            switch (status) {
                              TimerStatus.idle => 'setTimer'.tr(),
                              TimerStatus.finished => 'timerDoneTitle'.tr(),
                              _ => _formatTime(timer.remaining),
                            },
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _heading,
                          ),
                        ),
                        if (status != TimerStatus.idle &&
                            status != TimerStatus.finished)
                          GestureDetector(
                            onTap: timer.stop,
                            child: const Icon(
                              Icons.stop_rounded,
                              color: kLine,
                              size: 30,
                              shadows: kIconShadow,
                            ),
                          ),
                        _IconSquare(
                          icon: switch (status) {
                            TimerStatus.idle => Icons.hourglass_bottom_rounded,
                            TimerStatus.running => Icons.pause_rounded,
                            TimerStatus.paused => Icons.play_arrow_rounded,
                            TimerStatus.finished => Icons.stop_rounded,
                          },
                          onPressed: () =>
                              _timerAction(timer, recipe.recipeName),
                        ),
                      ],
                    ),
                  ),
                  // Macros.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: _outline(),
                    child: Row(
                      children: [
                        _Macro('calories'.tr(), recipe.calories),
                        _Macro('protein'.tr(), recipe.protein),
                        _Macro('carbohydrates'.tr(), recipe.carbohydrates),
                        _Macro('fat'.tr(), recipe.fat),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      _IconSquare(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      _IconSquare(
                        icon: data.favoriteId == null
                            ? Icons.favorite_border_rounded
                            : Icons.heart_broken_rounded,
                        onPressed: () => _toggleFavorite(context, data),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Strips "około", "ok.", "~" etc. from model output, also for saved recipes.
final _approx = RegExp(
  r'(około|ok\.|circa|approx\.?|about|~|≈|примерно|около)\s*',
  caseSensitive: false,
);

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.replaceAll(_approx, '').trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _heading.copyWith(fontSize: 15),
          ),
          Text(
            label.replaceAll(':', ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _text.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Rounded outlined square with an icon, like the date tile in the mockup.
class _IconSquare extends StatelessWidget {
  const _IconSquare({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: _outline(radius: 20),
        child: Icon(shadows: kIconShadow, icon, color: kLine, size: 28),
      ),
    );
  }
}

/// Full-width outlined button: icon + label, same look as the other buttons.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: _outline(radius: 20),
        child: Row(
          spacing: 14,
          children: [
            Icon(icon, color: kLine, size: 28, shadows: kIconShadow),
            Expanded(
              child: Text(label, style: _heading.copyWith(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _outline(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(title, style: _heading),
          child,
        ],
      ),
    );
  }
}

/// Outlined pill button; [filled] turns it solid dark.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? kBg : kLine;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: _outline(radius: 24, color: filled ? kLine : kBg),
        child: Text(label, style: _text.copyWith(color: fg)),
      ),
    );
  }
}

String _formatTime(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$sec';
}

class _TimerPickerSheet extends StatefulWidget {
  const _TimerPickerSheet();

  @override
  State<_TimerPickerSheet> createState() => _TimerPickerSheetState();
}

class _TimerPickerSheetState extends State<_TimerPickerSheet> {
  int _minutes = 5;
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: _minutes - 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text('setTimer'.tr(), style: _text),
            SizedBox(
              height: 180,
              child: CupertinoPicker(
                scrollController: _controller,
                itemExtent: 44,
                onSelectedItemChanged: (i) => _minutes = i + 1,
                children: List.generate(
                  60,
                  (i) => Center(
                    child: Text(
                      '${i + 1} ${'timerMinutesShort'.tr()}',
                      style: _text,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: _PillButton(
                label: 'startTimer'.tr(),
                filled: true,
                onPressed: () => Navigator.pop(context, _minutes),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
