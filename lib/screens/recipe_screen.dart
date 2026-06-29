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
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Consumer<MainProvider>(
          builder: (context, data, _){
            return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    spacing: 12,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              child: Text(data.answer,)
                          )),
                      ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) =>
                              const MainScreen())),
                          child: Text('back'.tr(), style: kTextStyle,)
                      )
                    ],
                  ),
                ),);
          },
        )
    );
  }
}