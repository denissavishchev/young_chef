import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../constants.dart';
import 'main_screen.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Consumer<MainProvider>(
          builder: (context, data, _){
            return SafeArea(
                child: Column(
                  spacing: 12,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                              spacing: 12,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(data.answer.recipeName, style: kBigTextStyle,),
                                ),
                                Divider(color: kOrange, height: 0,),
                                Container(
                                  width: size.width,
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
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
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ingredients'.tr(), style: kTextStyle,),
                                      Column(
                                        spacing: 4,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(data.answer.ingredients.length, (i) {
                                          return Text(data.answer.ingredients[i], style: kTextStyle,);
                                        }),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: size.width,
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
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
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('instructions'.tr(), style: kTextStyle,),
                                      Text(data.answer.instructions, style: kTextStyle,),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: size.width,
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
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
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        spacing: 4,
                                        children: [
                                          Text('calories'.tr(), style: kTextStyle,),
                                          Text(data.answer.calories, style: kTextStyle,),
                                        ],
                                      ),
                                      Row(
                                        spacing: 4,
                                        children: [
                                          Text('protein'.tr(), style: kTextStyle,),
                                          Text(data.answer.protein, style: kTextStyle,),
                                        ],
                                      ),
                                      Row(
                                        spacing: 4,
                                        children: [
                                          Text('carbohydrates'.tr(), style: kTextStyle,),
                                          Text(data.answer.carbohydrates, style: kTextStyle,),
                                        ],
                                      ),
                                      Row(
                                        spacing: 4,
                                        children: [
                                          Text('fat'.tr(), style: kTextStyle,),
                                          Text(data.answer.fat, style: kTextStyle,),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: kLightBlue,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(data.answer.developerInfo.toString(), style: kTextStyle,),
                                ),
                                Divider(color: kLightBlue,),
                              ],
                            ),)
                        ),
                    ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) =>
                            const MainScreen())),
                        child: Text('back'.tr(), style: kTextStyle,)
                    )
                  ],
                ),);
          },
        )
    );
  }
}