import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../constants.dart';
import 'main_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                    Expanded(
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
                                  Text(
                                    '${'instructions'.tr()} ${stepIndex + 1}/${steps.length}',
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
                    Divider(color: kLightBlue,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(data.answer.developerInfo.toString(), style: kTextStyle,),
                    ),
                    Divider(color: kLightBlue,),
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
