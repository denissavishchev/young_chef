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
                      padding: EdgeInsets.all(12),
                      child: Column(
                        spacing: 12,
                        children: [
                          Row(
                            children: [
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
                          SizedBox(
                              height: size.height * 0.5,
                              child: SingleChildScrollView(
                                  child: Text(data.answer,)
                              )),
                          ElevatedButton(
                              onPressed: () => data.getRecipe(context),
                              child: Text('ask'.tr(), style: kTextStyle,)
                          )
                        ],
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