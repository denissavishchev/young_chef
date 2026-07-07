import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    data.initSpeech();
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
                          spacing:8,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text('ingredients'.tr(), style: kTextStyle,),
                                Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    Container(
                                      width: size.width,
                                      constraints: BoxConstraints(
                                        minHeight: 80,
                                      ),
                                      padding: const EdgeInsets.only(left: 8, right: 44),
                                      margin: const EdgeInsets.only(right: 30),
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
                                      child: TextFormField(
                                        controller: data.questionController,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        keyboardType: TextInputType.multiline,
                                        cursorColor: kDarkBlue,
                                        maxLines: null,
                                        style: kTextStyle.copyWith(fontSize: 32.sp),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        validator: (value){
                                          if(value == null || value.isEmpty) {
                                            return 'thisFieldCannotBeEmpty'.tr();
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    data.isListening
                                      ? Container(
                                        height: 80,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                              colors: [
                                                kLightBlue.withValues(alpha: 0.7),
                                                kLightBlue.withValues(alpha: 0.7),
                                                kWhite.withValues(alpha: 0.7)
                                              ],
                                              stops: [0.4, 0.65, 1],
                                          ),
                                        ),
                                        child: Row(
                                            spacing: 1.5,
                                            children: List.generate(6, ((i){
                                              return SpinKitWave(
                                                color: kDarkBlue. withValues(alpha: 0.8),
                                                size: 40,
                                                itemCount: 10,
                                              );
                                            })),
                                          ),
                                      )
                                      : SizedBox.shrink(),
                                    GestureDetector(
                                      onTapDown: (_) => data.startListening(context),
                                      onTapUp: (_) => data.stopListening(),
                                      onTapCancel: () => data.stopListening(),
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                kLightBlue,
                                                kWhite
                                              ],
                                            stops: [0.4, 1],
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: kDarkBlue.withValues(alpha: 0.25), width: 1),
                                          boxShadow: [
                                            BoxShadow(
                                              color: kDarkBlue.withValues(alpha: 0.4),
                                              blurRadius: 5,
                                              offset: const Offset(3, 5)
                                            )
                                          ]
                                        ),
                                        child: Icon(Icons.mic, size: 48, color: kDarkBlue. withValues(alpha: 0.8),),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(color: kLightBlue,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'caloriesRange'.tr(args: [
                                    '${data.caloriesRange.start.round()}',
                                    '${data.caloriesRange.end.round()}']),
                                  style: kTextStyle,
                                ),
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 24,
                                    thumbColor: kWhite,
                                    rangeThumbShape: const RoundRangeSliderThumbShape(
                                      enabledThumbRadius: 12,
                                    ),
                                    activeTrackColor: kLightBlue,
                                    inactiveTrackColor: kLightBlue.withValues(alpha: 0.5),
                                    rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
                                      tickMarkRadius: 2,
                                    ),
                                    activeTickMarkColor: kLightBlue,
                                    inactiveTickMarkColor: kWhite,
                                    valueIndicatorColor: kLightBlue,
                                    showValueIndicator: ShowValueIndicator.onDrag,
                                  ),
                                  child: RangeSlider(
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
                                ),
                              ],
                            ),
                            Divider(color: kLightBlue,),
                            Row(
                              spacing: 8,
                              children: [
                                Text('sportDiet'.tr(), style: kTextStyle,),
                                Switch(
                                  value: data.isRegularDiet,
                                  onChanged: (v) => data.setRegularOrSportDiet(v),
                                  activeThumbColor: kWhite,
                                  activeTrackColor: kLightBlue,
                                  inactiveThumbColor: kWhite,
                                  inactiveTrackColor: kLightBlue.withValues(alpha: 0.5),
                                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                                ),
                                Text('regularDiet'.tr(), style: kTextStyle,),
                              ],
                            ),
                            Divider(color: kLightBlue,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'timeForCooking'.tr(args: ['${data.timeForCooking.toInt()}']), style: kTextStyle,
                                ),
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 24,
                                    thumbColor: kWhite,
                                    rangeThumbShape: const RoundRangeSliderThumbShape(
                                      enabledThumbRadius: 12,
                                    ),
                                    activeTrackColor: kLightBlue,
                                    inactiveTrackColor: kLightBlue.withValues(alpha: 0.5),
                                    rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
                                      tickMarkRadius: 2,
                                    ),
                                    activeTickMarkColor: kLightBlue,
                                    inactiveTickMarkColor: kWhite,
                                    valueIndicatorColor: kLightBlue,
                                    showValueIndicator: ShowValueIndicator.onDrag,
                                  ),
                                  child: Slider(
                                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                    value: data.timeForCooking,
                                    min: 10,
                                    max: 60,
                                    divisions: 5,
                                    onChanged: (v) => data.setTimeForCooking(v),
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: kLightBlue,),
                            Row(
                              spacing: 8,
                              children: [
                                Text('isVegan'.tr(), style: kTextStyle,),
                                Switch(
                                  value: data.isVegan,
                                  onChanged: (v) => data.setIsVegan(v),
                                  activeThumbColor: kWhite,
                                  activeTrackColor: kLightBlue,
                                  inactiveThumbColor: kWhite,
                                  inactiveTrackColor: kLightBlue.withValues(alpha: 0.5),
                                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                                ),
                              ],
                            ),
                            Divider(color: kLightBlue,),
                            GestureDetector(
                              onTap: () => data.getRecipe(context),
                              child: Container(
                                width: size.width * 0.6,
                                height: size.height * 0.07,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  spacing: 8,
                                  children: [
                                    const SizedBox(width: 32,),
                                    Text('createRecipe'.tr(), style: kTextStyle.copyWith(fontSize: 32.sp,)),
                                    Icon(Icons.cookie, size: 32, color: kDarkBlue.withValues(alpha: 0.8),)
                                  ],
                                ),
                              ),
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

