import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:homeautomation_dashboard/controls/thermostat_dial/thermostat_dial.dart';

class ThermostatPanel extends StatelessWidget {
  const ThermostatPanel({
    Key? key,
    required this.onValueChanged,
    required this.setTemperature,
    required this.atTemperature,
    required this.tempControlKey,
  }) : super(key: key);

  final Function(double) onValueChanged;
  final double setTemperature;
  final bool atTemperature;
  final GlobalKey<TemperatureControlState> tempControlKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Card(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TemperatureControl(
                key: tempControlKey,
                min: 10,
                max: 30,
                onChange: onValueChanged,
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: atTemperature
                      ? const Icon(
                          TablerIcons.flame,
                          color: Colors.grey,
                          size: 150,
                        )
                      : const Icon(
                          TablerIcons.flame,
                          color: Colors.red,
                          size: 150,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    atTemperature ? "Heating Off" : "Heating On",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  "Target: ${setTemperature.toStringAsPrecision(3)}°C",
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
