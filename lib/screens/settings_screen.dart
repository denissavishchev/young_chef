import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../constants.dart';
import '../widgets/language_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Consumer<MainProvider>(
          builder: (context, data, _){
            return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LanguageWidget(),
                          ],
                        ),
                        Row(
                          children: [
                            Text('useOnlyMyIngredients'.tr(), style: kTextStyle,),
                            Checkbox(
                              value: data.onlyUserIngredients,
                              onChanged: (v) => data.setOnlyUserIngredients(v),
                            )
                          ],
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            Text('girl'.tr(), style: kTextStyle,),
                            Switch(
                              value: data.isBoy,
                              onChanged: (v) => data.setBoyOrGirl(v),
                            ),
                            Text('boy'.tr(), style: kTextStyle,),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                Text('cookingSkills'.tr(args: ['${data.cookingSkillLevel.toInt()}']), style: kTextStyle,),
                                Text('${data.cookingSkillLevel.toInt()}', style: kTextStyle,),
                              ],
                            ),
                            Slider(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              value: data.cookingSkillLevel,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              onChanged: (v) => data.setCookingSkillLevel(v),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: data.allergiesController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.multiline,
                          cursorColor: kDarkBlue,
                          decoration: textFieldDecoration.copyWith(
                              label: Text('allergies'.tr(),)),
                          onChanged: (v) => data.setAllergies(v),
                        ),
                        TextFormField(
                          controller: data.notLikeController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.multiline,
                          cursorColor: kDarkBlue,
                          decoration: textFieldDecoration.copyWith(
                              label: Text('notLike'.tr(),)),
                          onChanged: (v) => data.setNotLikes(v),
                        ),
                      ],
                    ),
                  ),
                ),);
          },
        )
    );
  }
}