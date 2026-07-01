import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:young_chef/screens/settings_screen.dart';
import '../../providers/main_provider.dart';
import '../constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    super.initState();
  }

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
                              spacing: 8,
                              children: [
                                data.answer == 'Spróbuj ponownie'
                                ? Text('Spróbuj ponownie za chwilę.')
                                : SizedBox.shrink(),
                                Spacer(),
                                GestureDetector(
                                    onTap: () => Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) => const SettingsScreen())),
                                    child: Icon(Icons.settings, size: 32, color: kDarkBlue,)),
                              ],
                            ),
                            TextFormField(
                              controller: data.questionController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.multiline,
                              cursorColor: kDarkBlue,
                              decoration: textFieldDecoration.copyWith(
                                  label: Text('ingredients'.tr(),)),
                              validator: (value){
                                if(value == null || value.isEmpty) {
                                  return 'thisFieldCannotBeEmpty'.tr();
                                }
                                return null;
                              },
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
                      color: kDarkBlue.withValues(alpha: 0.3),
                      child: const Center(child: SpinKitSpinningLines(
                        color: kDarkBlue,
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