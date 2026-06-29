import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/language_widget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Consumer<MainProvider>(
          builder: (context, data, _){
            return SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          spacing: 12,
                          children: [
                            Row(
                              children: [
                                data.answer == 'Spróbuj ponownie'
                                ? Text('Spróbuj ponownie za chwilę.')
                                : SizedBox.shrink(),
                                Spacer(),
                                LanguageWidget(),
                              ],
                            ),
                            TextFormField(
                              controller: data.questionController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.multiline,
                              cursorColor: kDarkGrey,
                              decoration: textFieldDecoration.copyWith(
                                  label: Text('ingredients'.tr(),)),
                              // maxLength: 64,
                              validator: (value){
                                if(value == null || value.isEmpty) {
                                  return 'thisFieldCannotBeEmpty'.tr();
                                }
                                return null;
                              },
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'caloriesRange'.tr(args: ['${data.caloriesRange.start.round()}', '${data.caloriesRange.end.round()}']),
                                ),
                                RangeSlider(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  values: data.caloriesRange,
                                  min: 100,
                                  max: 1000,
                                  divisions: 10,
                                  labels: RangeLabels(
                                    data.caloriesRange.start.round().toString(),
                                    data.caloriesRange.end.round().toString(),
                                  ),
                                  onChanged: (RangeValues range) => data.setCaloriesRange(range),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Text('sportDiet'.tr(), style: kTextStyle,),
                                Switch(
                                  value: data.isRegularDiet,
                                  onChanged: (v) => data.setRegularOrSportDiet(v),
                                ),
                                Text('regularDiet'.tr(), style: kTextStyle,),
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
                                Text(
                                  'timeForCooking'.tr(args: ['${data.timeForCooking.toInt()}']), style: kTextStyle,
                                ),
                                Slider(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  value: data.timeForCooking,
                                  min: 10,
                                  max: 60,
                                  divisions: 5,
                                  onChanged: (v) => data.setTimeForCooking(v),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'cookingSkills'.tr(args: ['${data.cookingSkillLevel.toInt()}']), style: kTextStyle,
                                ),
                                Slider(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  value: data.cookingSkillLevel,
                                  min: 1,
                                  max: 5,
                                  divisions: 5,
                                  onChanged: (v) => data.setCookingSkillLevel(v),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Text('isVegan'.tr(), style: kTextStyle,),
                                Switch(
                                  value: data.isVegan,
                                  onChanged: (v) => data.setIsVegan(v),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: data.allergiesController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.multiline,
                              cursorColor: kDarkGrey,
                              decoration: textFieldDecoration.copyWith(
                                  label: Text('allergies'.tr(),)),
                            ),
                            TextFormField(
                              controller: data.notLikeController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.multiline,
                              cursorColor: kDarkGrey,
                              decoration: textFieldDecoration.copyWith(
                                  label: Text('notLike'.tr(),)),
                            ),
                            ElevatedButton(
                                onPressed: () => data.getRecipe(context),
                                child: Text('ask'.tr(), style: kTextStyle,)
                            )
                          ],
                        ),
                      ),
                    ),
                    data.isLoading
                        ? Container(
                      width: size.width,
                      height: size.height,
                      color: kGrey.withValues(alpha: 0.3),
                      child: const Center(child: SpinKitSpinningLines(
                        color: kBlue,
                        size: 40,
                      ),),
                    ) : const SizedBox.shrink()
                  ],
                ));
          },
        )
    );
  }
}