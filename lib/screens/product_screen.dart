import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

/// Type, say or photograph a product and get its story, pros and cons and
/// nutrition per 100 g.
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    final muted = kTextStyle.copyWith(
      color: kLine.withValues(alpha: 0.55),
      fontWeight: FontWeight.w600,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        resizeToAvoidBottomInset: true,
        body: Consumer<ProductProvider>(
          builder: (context, data, _) {
            final info = data.info;
            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
                    child: Row(
                      spacing: 10,
                      children: [
                        const Icon(
                          shadows: kIconShadow,
                          Icons.eco_rounded,
                          size: 28,
                          color: kLine,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'productTitle'.tr(),
                                style: kBigTextStyle.copyWith(color: kLine),
                              ),
                              Text('productSubtitle'.tr(), style: muted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        12 + 64 + 12 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        spacing: 14,
                        children: [
                          _InputCard(data: data),
                          _AnalyzeButton(data: data),
                          if (data.hasError)
                            _Tile(
                              icon: Icons.error_outline_rounded,
                              title: 'tryAgainSoon'.tr(),
                              child: const SizedBox.shrink(),
                            ),
                          if (info != null && !data.isLoading) ..._tiles(info),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _tiles(ProductInfo info) {
    final body = kTextStyle.copyWith(color: kLine, fontWeight: FontWeight.w600);
    return [
      _Tile(
        icon: Icons.menu_book_rounded,
        title: info.name.isEmpty ? 'productAbout'.tr() : info.name,
        subtitle: 'productAbout'.tr(),
        child: Text(info.about, style: body),
      ),
      _Tile(
        icon: Icons.balance_rounded,
        title: 'productProsCons'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _Bullets(
              label: 'productPros'.tr(),
              icon: Icons.add_circle_outline_rounded,
              items: info.pros,
            ),
            _Bullets(
              label: 'productCons'.tr(),
              icon: Icons.remove_circle_outline_rounded,
              items: info.cons,
            ),
            if (info.usefulFor.isNotEmpty) ...[
              Text(
                'productUseful'.tr(),
                style: kTextStyle.copyWith(
                  color: kLine.withValues(alpha: 0.55),
                ),
              ),
              Text(info.usefulFor, style: body),
            ],
          ],
        ),
      ),
      _Tile(
        icon: Icons.local_fire_department_rounded,
        title: 'productNutrition'.tr(),
        child: Column(
          spacing: 8,
          children: [
            _NutrientRow('calories'.tr(), info.calories),
            _NutrientRow('protein'.tr(), info.protein),
            _NutrientRow('carbohydrates'.tr(), info.carbohydrates),
            _NutrientRow('fat'.tr(), info.fat),
            _NutrientRow('fiber'.tr(), info.fiber),
          ],
        ),
      ),
    ];
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.data});

  final ProductProvider data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      decoration: outlineDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text('productLabel'.tr(), style: kTextStyle),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    TextFormField(
                      controller: data.controller,
                      keyboardType: TextInputType.multiline,
                      cursorColor: kLine,
                      maxLines: null,
                      minLines: 2,
                      style: kTextStyle,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'productHint'.tr(),
                        hintStyle: kTextStyle.copyWith(
                          color: kLine.withValues(alpha: 0.35),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (data.isListening)
                      Positioned.fill(
                        child: ColoredBox(
                          color: kBg.withValues(alpha: 0.8),
                          child: Center(
                            child: SpinKitWave(
                              color: kLine,
                              size: 28,
                              itemCount: 7,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: data.isScanning
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await data.scan(context);
                        if (!ok) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('scanFailed'.tr())),
                          );
                        }
                      },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: outlineDecoration(circle: true),
                  child: data.isScanning
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: kLine,
                          ),
                        )
                      : const Icon(
                          shadows: kIconShadow,
                          Icons.photo_camera_rounded,
                          size: 28,
                          color: kLine,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTapDown: (_) => data.startListening(context),
                onTapUp: (_) => data.stopListening(),
                onTapCancel: () => data.stopListening(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  height: 56,
                  decoration: outlineDecoration(
                    circle: true,
                    color: data.isListening ? kLine : kBg,
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    shadows: data.isListening ? null : kIconShadow,
                    size: 28,
                    color: data.isListening ? kBg : kLine,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyzeButton extends StatelessWidget {
  const _AnalyzeButton({required this.data});

  final ProductProvider data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        data.analyze(context);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: outlineDecoration(radius: 28, color: kLine),
        child: data.isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: kBg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'productAnalyze'.tr(),
                    style: kTextStyle.copyWith(color: kBg),
                  ),
                  const Icon(Icons.search_rounded, size: 24, color: kBg),
                ],
              ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: outlineDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(icon, size: 24, color: kLine, shadows: kIconShadow),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: kBigTextStyle),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: kTextStyle.copyWith(
                          color: kLine.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.label, required this.icon, required this.items});

  final String label;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(label, style: kTextStyle),
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Icon(icon, size: 18, color: kLine),
              Expanded(
                child: Text(
                  item,
                  style: kTextStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: kTextStyle.copyWith(color: kLine.withValues(alpha: 0.55)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: kLine,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(value, style: kTextStyle.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
