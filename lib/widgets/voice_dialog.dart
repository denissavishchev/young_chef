import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants.dart';

/// Pop-up shown while dictating. The recognized words land in the screen's text
/// field; [text] returns only this session's words, shown here read-only. The pop-up closes
/// with the bottom button, which also calls [onStop].
Future<void> showVoiceDialog(
  BuildContext context, {
  required String Function() text,
  required Listenable listening,
  required bool Function() isListening,
  required VoidCallback onStart,
  required VoidCallback onStop,
}) async {
  onStart();
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: outlineDecoration(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              ListenableBuilder(
                listenable: listening,
                builder: (_, _) => Row(
                  spacing: 10,
                  children: [
                    const Icon(
                      Icons.mic_rounded,
                      shadows: kIconShadow,
                      size: 28,
                      color: kLine,
                    ),
                    Expanded(
                      child: Text('voiceRecording'.tr(), style: kHeaderStyle),
                    ),
                    if (isListening())
                      SpinKitWave(color: kLine, size: 24, itemCount: 5),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 120,
                  maxHeight: 280,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: ListenableBuilder(
                    listenable: listening,
                    builder: (_, _) => Text(
                      text().isEmpty ? 'voiceSpeakNow'.tr() : text(),
                      style: kTextStyle.copyWith(
                        color: text().isEmpty
                            ? kLine.withValues(alpha: 0.35)
                            : kLine,
                      ),
                    ),
                  ),
                ),
              ),
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    onStop();
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: outlineDecoration(radius: 28, color: kLine),
                    child: Text(
                      'voiceStop'.tr(),
                      style: kTextStyle.copyWith(color: kBg),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
