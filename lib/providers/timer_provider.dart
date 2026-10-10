import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

enum TimerStatus { idle, running, paused, finished }

/// Cooking timer based on an absolute end time, so it stays correct while the
/// app is in the background. The end is signalled by a real alarm (own audio
/// stream and foreground service), which rings even in silent mode and with
/// the app minimized.
class TimerProvider extends ChangeNotifier with WidgetsBindingObserver {
  TimerProvider({required this.onOpenRecipe}) {
    WidgetsBinding.instance.addObserver(this);
    _ringSub = Alarm.ringing.listen(_onRinging);
  }

  static const int _alarmId = 1;

  /// Called when the user comes back to the app after the alarm rang in the
  /// background (e.g. by tapping its notification).
  final VoidCallback onOpenRecipe;

  late final StreamSubscription<AlarmSet> _ringSub;

  TimerStatus status = TimerStatus.idle;
  Duration total = Duration.zero;
  DateTime? _endTime;
  Duration _pausedRemaining = Duration.zero;
  String _recipeName = '';
  Timer? _ticker;
  bool _inForeground = true;
  bool _rangInBackground = false;
  int _lastShownSeconds = -1;

  Duration get remaining {
    switch (status) {
      case TimerStatus.running:
        final left = _endTime!.difference(DateTime.now());
        return left.isNegative ? Duration.zero : left;
      case TimerStatus.paused:
        return _pausedRemaining;
      case TimerStatus.finished:
      case TimerStatus.idle:
        return Duration.zero;
    }
  }

  double get progress => total.inMilliseconds == 0
      ? 0
      : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

  Future<void> start(Duration duration, String recipeName) async {
    await Alarm.stop(_alarmId);
    _recipeName = recipeName;
    total = duration;
    _endTime = DateTime.now().add(duration);
    status = TimerStatus.running;
    _startTicker();
    notifyListeners();
    await _scheduleAlarm();
  }

  Future<void> pause() async {
    if (status != TimerStatus.running) return;
    _pausedRemaining = remaining;
    _ticker?.cancel();
    status = TimerStatus.paused;
    notifyListeners();
    await Alarm.stop(_alarmId);
  }

  Future<void> resume() async {
    if (status != TimerStatus.paused) return;
    _endTime = DateTime.now().add(_pausedRemaining);
    status = TimerStatus.running;
    _startTicker();
    notifyListeners();
    await _scheduleAlarm();
  }

  Future<void> stop() async {
    _ticker?.cancel();
    status = TimerStatus.idle;
    total = Duration.zero;
    _endTime = null;
    _rangInBackground = false;
    notifyListeners();
    await Alarm.stop(_alarmId);
  }

  Future<void> _scheduleAlarm() async {
    try {
      if (Platform.isAndroid) {
        await Permission.notification.request();
        if (await Permission.scheduleExactAlarm.isDenied) {
          await Permission.scheduleExactAlarm.request();
        }
      }
      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: _alarmId,
          dateTime: _endTime!,
          assetAudioPath: 'assets/sounds/alarm.wav',
          loopAudio: true,
          vibrate: true,
          warningNotificationOnKill: Platform.isIOS,
          androidFullScreenIntent: true,
          volumeSettings: const VolumeSettings.fixed(volumeEnforced: true),
          notificationSettings: NotificationSettings(
            title: 'timerDoneTitle'.tr(),
            body: 'timerDoneBody'.tr(args: [_recipeName]),
            stopButton: 'stopTimer'.tr(),
          ),
        ),
      );
    } catch (e) {
      log('Scheduling alarm failed: $e');
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _lastShownSeconds = -1;
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  void _tick() {
    if (status != TimerStatus.running) return;
    if (remaining == Duration.zero) {
      _ticker?.cancel();
      status = TimerStatus.finished;
      notifyListeners();
      return;
    }
    final seconds = remaining.inSeconds;
    if (seconds != _lastShownSeconds) {
      _lastShownSeconds = seconds;
      notifyListeners();
    }
  }

  void _onRinging(AlarmSet ringing) {
    if (!ringing.alarms.any((a) => a.id == _alarmId)) return;
    _ticker?.cancel();
    status = TimerStatus.finished;
    if (!_inForeground) _rangInBackground = true;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _inForeground = false;
      case AppLifecycleState.resumed:
        _inForeground = true;
        final endedInBackground =
            _rangInBackground ||
            (status == TimerStatus.running && remaining == Duration.zero);
        if (endedInBackground) {
          // The user came back (e.g. tapped the notification): silence the
          // alarm and show the recipe with the finished timer.
          _rangInBackground = false;
          _ticker?.cancel();
          status = TimerStatus.finished;
          notifyListeners();
          Alarm.stop(_alarmId);
          onOpenRecipe();
        } else if (status == TimerStatus.running) {
          _tick();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ringSub.cancel();
    _ticker?.cancel();
    super.dispose();
  }
}
