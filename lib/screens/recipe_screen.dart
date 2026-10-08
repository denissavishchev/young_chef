import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/main_provider.dart';
import '../../providers/timer_provider.dart';
import '../constants.dart';

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

  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    RecipeScreen.isOpen = false;
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(BuildContext context, MainProvider data) async {
    final favorites = context.read<FavoritesProvider>();
    final id = data.favoriteId;
    if (id != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('removeFavoriteTitle'.tr()),
          content: Text('removeFavoriteBody'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('remove'.tr(), style: const TextStyle(color: kAccent)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await favorites.remove(id);
      data.setFavoriteId(null);
      return;
    }
    final choice = await showModalBottomSheet<_PhotoChoice>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('addPhotoTitle'.tr(), style: kBigTextStyle),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'addPhotoSubtitle'.tr(),
                textAlign: TextAlign.center,
                style: kTextStyle.copyWith(color: kInk.withValues(alpha: 0.55)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: kAccent),
              title: Text('takePhoto'.tr(), style: kTextStyle),
              onTap: () => Navigator.pop(ctx, _PhotoChoice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: kAccent),
              title: Text('chooseFromGallery'.tr(), style: kTextStyle),
              onTap: () => Navigator.pop(ctx, _PhotoChoice.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border_rounded, color: kInk),
              title: Text('saveWithoutPhoto'.tr(), style: kTextStyle),
              onTap: () => Navigator.pop(ctx, _PhotoChoice.none),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Consumer<MainProvider>(
          builder: (context, data, _){
            final recipe = data.answer;
            final steps = recipe.instructions;
            final pageCount = 2 + steps.length;
            return SafeArea(
                child: Column(
                  spacing: 12,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(recipe.recipeName, style: kBigTextStyle,),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(pageCount, (i) {
                          final isActive = i <= _currentPage;
                          return Expanded(
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? kOrange
                                    : kLightBlue.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.34,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pageCount,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _RecipeCard(
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ingredients'.tr(), style: kTextStyle,),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: recipe.ingredients.length,
                                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                                      itemBuilder: (context, i) {
                                        return Text(recipe.ingredients[i], style: kTextStyle,);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (index <= steps.length) {
                            final stepIndex = index - 1;
                            return _RecipeCard(
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${'instructions'.tr()} ${stepIndex + 1}/${steps.length}',
                                    style: kTextStyle,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(steps[stepIndex], style: kTextStyle,),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return _RecipeCard(
                            child: Column(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _MacroRow(label: 'calories'.tr(), value: recipe.calories),
                                _MacroRow(label: 'protein'.tr(), value: recipe.protein),
                                _MacroRow(label: 'carbohydrates'.tr(), value: recipe.carbohydrates),
                                _MacroRow(label: 'fat'.tr(), value: recipe.fat),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    _TimerSection(recipeName: recipe.recipeName),
                    const Spacer(),
                    Divider(color: kLightBlue,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(data.answer.developerInfo.toString(), style: kTextStyle,),
                    ),
                    Divider(color: kLightBlue,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 12,
                      children: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('back'.tr(), style: kTextStyle,)
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _toggleFavorite(context, data),
                          icon: Icon(
                            data.favoriteId == null
                                ? Icons.favorite_border_rounded
                                : Icons.heart_broken_rounded,
                            color: kOrange,
                          ),
                          label: Text(
                            data.favoriteId == null
                                ? 'saveToFavorites'.tr()
                                : 'removeFromFavorites'.tr(),
                            style: kTextStyle.copyWith(color: kOrange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),);
          },
        )
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Text(label, style: kTextStyle,),
        Text(value, style: kTextStyle,),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                kLightBlue,
                kLightBlue,
                kWhite
              ],
              stops: [0.4, 0.65, 1],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kDarkBlue.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
                color: kDarkBlue.withValues(alpha: 0.4),
                blurRadius: 5,
                offset: const Offset(5, 3)
            )
          ]
      ),
      child: child,
    );
  }
}


String _formatTime(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$sec';
}

class _TimerSection extends StatelessWidget {
  const _TimerSection({required this.recipeName});

  final String recipeName;

  Future<void> _pickDuration(BuildContext context) async {
    final timer = context.read<TimerProvider>();
    final minutes = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _TimerPickerSheet(),
    );
    if (minutes != null) {
      await timer.start(Duration(minutes: minutes), recipeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        final status = timer.status;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 8,
            children: [
              if (status != TimerStatus.idle) ...[
                Text(
                  status == TimerStatus.finished
                      ? 'timerDoneTitle'.tr()
                      : _formatTime(timer.remaining),
                  style: kBigTextStyle.copyWith(
                    color: status == TimerStatus.finished ? kOrange : kDarkBlue,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: timer.progress,
                    minHeight: 6,
                    color: kOrange,
                    backgroundColor: kLightBlue.withValues(alpha: 0.45),
                  ),
                ),
              ],
              Row(
                spacing: 12,
                children: [
                  if (status == TimerStatus.idle)
                    Expanded(
                      child: _TimerButton(
                        icon: Icons.timer_outlined,
                        label: 'setTimer'.tr(),
                        onPressed: () => _pickDuration(context),
                      ),
                    ),
                  if (status == TimerStatus.running)
                    Expanded(
                      child: _TimerButton(
                        icon: Icons.pause_rounded,
                        label: 'pauseTimer'.tr(),
                        onPressed: timer.pause,
                      ),
                    ),
                  if (status == TimerStatus.paused) ...[
                    Expanded(
                      child: _TimerButton(
                        icon: Icons.stop_rounded,
                        label: 'stopTimer'.tr(),
                        filled: false,
                        onPressed: timer.stop,
                      ),
                    ),
                    Expanded(
                      child: _TimerButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'continueTimer'.tr(),
                        onPressed: timer.resume,
                      ),
                    ),
                  ],
                  if (status == TimerStatus.finished)
                    Expanded(
                      child: _TimerButton(
                        icon: Icons.stop_rounded,
                        label: 'stopTimer'.tr(),
                        onPressed: timer.stop,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: filled ? Colors.white : kOrange),
      label: Text(
        label,
        style: kTextStyle.copyWith(color: filled ? Colors.white : kOrange),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? kOrange : kWhite,
        side: const BorderSide(color: kOrange),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
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
            Text('setTimer'.tr(), style: kTextStyle),
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
                      style: kTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _minutes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'startTimer'.tr(),
                  style: kTextStyle.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
