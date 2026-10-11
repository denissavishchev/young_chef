import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:young_chef/providers/favorites_provider.dart';
import 'package:young_chef/providers/main_provider.dart';
import 'package:young_chef/providers/product_provider.dart';
import 'package:young_chef/providers/timer_provider.dart';
import 'package:alarm/alarm.dart';
import 'screens/home_shell.dart';
import 'screens/recipe_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void _openRecipeFromNotification() {
  final navigator = navigatorKey.currentState;
  final context = navigatorKey.currentContext;
  if (navigator == null || context == null || RecipeScreen.isOpen) return;
  // After a cold start the recipe is gone, so there is nothing to open.
  if (Provider.of<MainProvider>(
    context,
    listen: false,
  ).answer.recipeName.isEmpty) {
    return;
  }
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeShell()),
    (_) => false,
  );
  navigator.push(MaterialPageRoute(builder: (_) => const RecipeScreen()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: 'keys.env');
  await EasyLocalization.ensureInitialized();
  await Alarm.init();
  await Hive.initFlutter();
  await Hive.openBox(FavoritesProvider.boxName);
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pl', 'PL'),
        Locale('ru', 'RU'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<MainProvider>(create: (_) => MainProvider()),
          ChangeNotifierProvider<ProductProvider>(
            create: (_) => ProductProvider(),
          ),
          ChangeNotifierProvider<FavoritesProvider>(
            create: (_) => FavoritesProvider(),
          ),
          ChangeNotifierProvider<TimerProvider>(
            create: (_) =>
                TimerProvider(onOpenRecipe: _openRecipeFromNotification),
          ),
        ],
        builder: (context, child) {
          return ScreenUtilInit(
            designSize: const Size(360, 780),
            builder: (_, child) => MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: const HomeShell(),
            ),
          );
        },
      ),
    ),
  );
}
