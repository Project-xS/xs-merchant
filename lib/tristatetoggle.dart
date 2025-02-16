import 'package:flutter/material.dart';
enum SwitchState { active, inactive, dual }

class TriStateToggleSwitch extends StatefulWidget {
  const TriStateToggleSwitch({
    super.key,
    required this.onChanged,
    required this.initialState,
  });

  final ValueChanged<SwitchState> onChanged;
  final SwitchState initialState;

  @override
  State<TriStateToggleSwitch> createState() => _TriStateToggleSwitchState();
}

class _TriStateToggleSwitchState extends State<TriStateToggleSwitch> {
  final switchInactiveStateBackgroundColor = const Color(0xffE9E9EA);
  final switchActiveStateBackgroundColor = const Color(0xff34C759);
  final switchDualStateBackgroundColor = const Color(0xfff1f1f1);

  final circleInactiveStateBackgroundColor = const Color(0xffFFFFFF);
  final circleActiveStateBackgroundColor = const Color(0xffFFFFFF);
  final circleDualStateBackgroundColor = const Color(0xffFFFFFF);

  AlignmentGeometry switchInitialPosition = Alignment.centerLeft;
  AlignmentGeometry switchLastKnownPosition = Alignment.centerLeft;

  SwitchState _switchState = SwitchState.inactive;

  void toggleState() {
    switch (switchInitialPosition) {
      case Alignment.centerLeft:
        switchInitialPosition = Alignment.center;
        switchLastKnownPosition = Alignment.centerLeft;
        _switchState = SwitchState.dual;
        break;
      case Alignment.center:
        if (switchLastKnownPosition == Alignment.centerLeft) {
          switchInitialPosition = Alignment.centerRight;
          _switchState = SwitchState.active;
        } else {
          switchInitialPosition = Alignment.centerLeft;
          _switchState = SwitchState.inactive;
        }
        break;
      case Alignment.centerRight:
        switchInitialPosition = Alignment.center;
        switchLastKnownPosition = Alignment.centerRight;
        _switchState = SwitchState.dual;
        break;
      default:
        switchInitialPosition = Alignment.center;
        switchInitialPosition = Alignment.centerLeft;
        _switchState = SwitchState.dual;
        break;
    }
    widget.onChanged(_switchState);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleState,
      child: Container(
        width: 76.5,
        height: 31,
        decoration: BoxDecoration(
          color: _switchState == SwitchState.active
              ? switchActiveStateBackgroundColor
              : _switchState == SwitchState.inactive
                  ? switchInactiveStateBackgroundColor
                  : switchDualStateBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.all(2.0),
        alignment: switchInitialPosition,
        child: Container(
          height: 27.0,
          width: 27.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _switchState == SwitchState.active
                ? circleActiveStateBackgroundColor
                : _switchState == SwitchState.inactive
                    ? circleInactiveStateBackgroundColor
                    : circleDualStateBackgroundColor,
          ),
        ),
      ),
    );
  }
}