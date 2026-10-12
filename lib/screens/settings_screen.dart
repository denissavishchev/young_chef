import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../constants.dart';
import '../widgets/language_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = kTextStyle.copyWith(color: kLine, fontSize: 14);
    final title = kBigTextStyle.copyWith(
      color: kLine,
      fontSize: 14,
      letterSpacing: 3,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        resizeToAvoidBottomInset: true,
        body: Consumer<MainProvider>(
          builder: (context, data, _) {
            return SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        const Icon(
                          shadows: kIconShadow,
                          Icons.settings_rounded,
                          size: 28,
                          color: kLine,
                        ),
                        Expanded(
                          child: Text('navSettings'.tr(), style: kHeaderStyle),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: outlineDecoration(radius: 20),
                          child: const LanguageWidget(),
                        ),
                      ],
                    ),
                    _Tile(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'useOnlyMyIngredients'.tr(),
                              style: text,
                            ),
                          ),
                          _Toggle(
                            value: data.onlyUserIngredients,
                            onChanged: data.setOnlyUserIngredients,
                          ),
                        ],
                      ),
                    ),
                    _Tile(
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: _Segment(
                              label: 'girl'.tr(),
                              selected: !data.isBoy,
                              onTap: () => data.setBoyOrGirl(false),
                            ),
                          ),
                          Expanded(
                            child: _Segment(
                              label: 'boy'.tr(),
                              selected: data.isBoy,
                              onTap: () => data.setBoyOrGirl(true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Tile(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'cookingSkills'.tr(
                                    args: ['${data.cookingSkillLevel.toInt()}'],
                                  ),
                                  style: text,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: kLine,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  '${data.cookingSkillLevel.toInt()}',
                                  style: text.copyWith(color: kBg),
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: outlineSliderTheme(),
                            child: Slider(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              value: data.cookingSkillLevel,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              onChanged: data.setCookingSkillLevel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('allergies'.tr().toUpperCase(), style: title),
                    _Tile(
                      child: _Field(
                        controller: data.allergiesController,
                        onChanged: data.setAllergies,
                      ),
                    ),
                    Text('notLike'.tr().toUpperCase(), style: title),
                    _Tile(
                      child: _Field(
                        controller: data.notLikeController,
                        onChanged: data.setNotLikes,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: outlineDecoration(),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 4,
      cursorColor: kLine,
      style: kTextStyle.copyWith(color: kLine, fontSize: 14),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
      ),
      onChanged: onChanged,
    );
  }
}

/// Outlined on/off switch with a dark knob.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 60,
        height: 34,
        padding: const EdgeInsets.all(4),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: outlineDecoration(radius: 20),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? kLine : Colors.transparent,
            border: Border.all(color: kLine, width: kLineWidth),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: outlineDecoration(
          radius: 20,
          color: selected ? kLine : kBg,
        ),
        child: Text(
          label,
          style: kTextStyle.copyWith(
            color: selected ? kBg : kLine,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
