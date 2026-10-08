import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    final data = Provider.of<MainProvider>(context, listen: false);
    data.getValuesFromMemory();
    data.initSpeech();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final title = kTextStyle.copyWith(color: kInk);
    final muted = kTextStyle.copyWith(
      color: kInk.withValues(alpha: 0.55),
      fontWeight: FontWeight.w600,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kScreenBg,
        resizeToAvoidBottomInset: true,
        body: Consumer<MainProvider>(
          builder: (context, data, _) {
            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
                        child: Row(
                          spacing: 10,
                          children: [
                            const Icon(
                              Icons.restaurant_rounded,
                              size: 28,
                              color: kAccent,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Young Chef',
                                    style: kBigTextStyle.copyWith(color: kInk),
                                  ),
                                  Text(
                                    'ingredients'.tr(),
                                    style: muted,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (data.answerError == 'Spróbuj ponownie')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: kAccentSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'tryAgainSoon'.tr(),
                              style: kTextStyle.copyWith(
                                color: kAccent,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Column(
                            spacing: 14,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
                                decoration: BoxDecoration(
                                  color: kCard,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    Text('ingredients'.tr(), style: title),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: data.questionController,
                                                autovalidateMode:
                                                    AutovalidateMode.onUserInteraction,
                                                keyboardType: TextInputType.multiline,
                                                cursorColor: kAccent,
                                                maxLines: null,
                                                minLines: 2,
                                                style: kTextStyle.copyWith(
                                                  color: kInk,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  hintText: 'ingredientsHint'.tr(),
                                                  hintStyle: kTextStyle.copyWith(
                                                    color: kInk.withValues(alpha: 0.35),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'thisFieldCannotBeEmpty'.tr();
                                                  }
                                                  return null;
                                                },
                                              ),
                                              if (data.isListening)
                                                Positioned.fill(
                                                  child: ColoredBox(
                                                    color: kCard.withValues(alpha: 0.8),
                                                    child: Center(
                                                      child: SpinKitWave(
                                                        color: kAccent,
                                                        size: 28,
                                                        itemCount: 7,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: data.isScanning
                                              ? null
                                              : () async {
                                                  final messenger =
                                                      ScaffoldMessenger.of(context);
                                                  final ok =
                                                      await data.scanIngredients(context);
                                                  if (!ok) {
                                                    messenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text('scanFailed'.tr()),
                                                      ),
                                                    );
                                                  }
                                                },
                                          child: Container(
                                            width: 56,
                                            height: 56,
                                            decoration: const BoxDecoration(
                                              color: kAccentSoft,
                                              shape: BoxShape.circle,
                                            ),
                                            child: data.isScanning
                                                ? const Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color: kAccent,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.photo_camera_rounded,
                                                    size: 28,
                                                    color: kAccent,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTapDown: (_) => data.startListening(context),
                                          onTapUp: (_) => data.stopListening(),
                                          onTapCancel: () => data.stopListening(),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: data.isListening
                                                  ? kAccent
                                                  : kAccentSoft,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.mic_rounded,
                                              size: 28,
                                              color: data.isListening
                                                  ? Colors.white
                                                  : kAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                                decoration: BoxDecoration(
                                  color: kCard,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 16,
                                  children: [
                                    Text('recipeOptions'.tr(), style: title),
                                    _OptionBlock(
                                      title: 'caloriesLabel'.tr(),
                                      value:
                                          '${data.caloriesRange.start.round()}–${data.caloriesRange.end.round()} ${'kcalUnit'.tr()}',
                                      titleStyle: muted,
                                      child: SliderTheme(
                                        data: _sliderTheme(),
                                        child: RangeSlider(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          values: data.caloriesRange,
                                          min: 100,
                                          max: 1000,
                                          divisions: 10,
                                          labels: RangeLabels(
                                            data.caloriesRange.start.round().toString(),
                                            data.caloriesRange.end.round().toString(),
                                          ),
                                          onChanged: (range) =>
                                              data.setCaloriesRange(range),
                                        ),
                                      ),
                                    ),
                                    _OptionBlock(
                                      title: 'timeLabel'.tr(),
                                      value:
                                          '${data.timeForCooking.toInt()} ${'minUnit'.tr()}',
                                      titleStyle: muted,
                                      child: SliderTheme(
                                        data: _sliderTheme(),
                                        child: Slider(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          value: data.timeForCooking,
                                          min: 10,
                                          max: 60,
                                          divisions: 5,
                                          onChanged: (v) => data.setTimeForCooking(v),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      spacing: 10,
                                      children: [
                                        _Chip(
                                          label: 'sportDiet'.tr(),
                                          selected: !data.isRegularDiet,
                                          onTap: () =>
                                              data.setRegularOrSportDiet(false),
                                        ),
                                        _Chip(
                                          label: 'regularDiet'.tr(),
                                          selected: data.isRegularDiet,
                                          onTap: () =>
                                              data.setRegularOrSportDiet(true),
                                        ),
                                      ],
                                    ),
                                    _Chip(
                                      label: 'isVegan'.tr(),
                                      selected: data.isVegan,
                                      onTap: () => data.setIsVegan(!data.isVegan),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: GestureDetector(
                          onTap: () => data.getRecipe(context),
                          child: Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              color: kAccent,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  'createRecipe'.tr(),
                                  style: kTextStyle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.cookie_rounded,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (data.isLoading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: kScreenBg.withValues(alpha: 0.94),
                      child: Center(
                        child: const CircularProgressIndicator(color: kAccent),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliderThemeData _sliderTheme() {
    return SliderThemeData(
      trackHeight: 8,
      thumbColor: kAccent,
      rangeThumbShape: const RoundRangeSliderThumbShape(
        enabledThumbRadius: 11,
      ),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
      activeTrackColor: kAccent,
      inactiveTrackColor: kTrackMuted,
      rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
        tickMarkRadius: 0,
      ),
      tickMarkShape: SliderTickMarkShape.noTickMark,
      activeTickMarkColor: Colors.transparent,
      inactiveTickMarkColor: Colors.transparent,
      valueIndicatorColor: kInk,
      showValueIndicator: ShowValueIndicator.onDrag,
      overlayColor: kAccent.withValues(alpha: 0.12),
    );
  }
}

class _OptionBlock extends StatelessWidget {
  const _OptionBlock({
    required this.title,
    required this.value,
    required this.titleStyle,
    required this.child,
  });

  final String title;
  final String value;
  final TextStyle titleStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: titleStyle)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: kInk,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                value,
                style: kTextStyle.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? kAccent : kInk,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
