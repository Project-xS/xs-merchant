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
  final switchInactiveStateBackgroundColor = Colors.blue;
  final switchActiveStateBackgroundColor = Colors.green;
  final switchDualStateBackgroundColor = Colors.red;

  final circleInactiveStateBackgroundColor = const Color(0xffFFFFFF);
  final circleActiveStateBackgroundColor = const Color(0xffFFFFFF);
  final circleDualStateBackgroundColor = const Color(0xffFFFFFF);

  AlignmentGeometry switchInitialPosition = Alignment.centerLeft;
  AlignmentGeometry switchLastKnownPosition = Alignment.centerLeft;

  late SwitchState _switchState;

  @override
  void initState() {
    super.initState();
    _switchState = widget.initialState;
    switch (_switchState) {
      case SwitchState.inactive:
        switchInitialPosition = Alignment.centerLeft;
        break;
      case SwitchState.active:
        switchInitialPosition = Alignment.centerRight;
        break;
      case SwitchState.dual:
        switchInitialPosition = Alignment.center;
        break;
    }
  }

  void toggleState() {
    setState(() {
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
      }
      widget.onChanged(_switchState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: toggleState,
        child: Container(
          width: 78,
          height: 35,
          decoration: BoxDecoration(
            color: _switchState == SwitchState.active
                ? switchActiveStateBackgroundColor
                : _switchState == SwitchState.inactive
                    ? switchInactiveStateBackgroundColor
                    : switchDualStateBackgroundColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(5.0),
          alignment: switchInitialPosition,
          child: AnimatedAlign(
            curve: Curves.easeInOutCirc,
            duration: const Duration(milliseconds: 600),
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
        ),
      ),
    );
  }
}