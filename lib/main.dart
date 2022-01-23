import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:homeautomation_dashboard/config.dart';
import 'package:homeautomation_dashboard/controls/temperature_display/temperature_display.dart';
import 'package:homeautomation_dashboard/controls/thermostat_dial/thermostat_dial.dart';
import 'package:homeautomation_dashboard/controls/thermostat_panel.dart';
import 'package:homeautomation_dashboard/models/tasmota_model.dart';
import 'package:homeautomation_dashboard/models/thermostat_model.dart';
import 'package:homeautomation_dashboard/services/mqtt_service.dart';
import 'package:homeautomation_dashboard/utils/dpi_adjuster.dart';
import 'package:process_run/shell.dart';

void main() {
  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        canvasColor: Colors.blueGrey[800],
        cardTheme: const CardTheme(
          margin: EdgeInsets.all(5),
          elevation: 7,
        ),
      ),
      home: const DpiAdjuster(newDevicePixelRatio: 1.0, child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TasmotaModel? tempSensor1;
  TasmotaModel? tempSensor2;
  TasmotaModel? tempSensor3;

  ThermostatModel thermostatModel = ThermostatModel(temperature: 20.0, isHeating: false);

  GlobalKey<TemperatureControlState> tempControlKey = GlobalKey<TemperatureControlState>();

  bool hasRecievedSetTemperature = false;

  @override
  void initState() {
    setupMqtt();
    super.initState();
  }

  setupMqtt() async {
    if (await MqttService.connect(kMqttServer, kMqttClientName)) {
      MqttService.addSubscription(kTempSensor1Subject, (p0) {
        setState(() {
          tempSensor1 = tasmotaModelFromJson(p0);
        });
      });

      MqttService.addSubscription(kTempSensor2Subject, (p0) {
        setState(() {
          tempSensor2 = tasmotaModelFromJson(p0);
        });
      });

      MqttService.addSubscription(kTempSensor3Subject, (p0) {
        setState(() {
          tempSensor3 = tasmotaModelFromJson(p0);
        });
      });

      MqttService.addSubscription(kThermostatCurrentTargetSubject, (p0) {
        setState(() {
          thermostatModel = thermostatModelFromJson(p0);
          tempControlKey.currentState!.updateVal(thermostatModel.temperature!);
          hasRecievedSetTemperature = true;
        });
      });

      MqttService.addSubscription(kPiDisplayBacklightControlSubject, (p0) {
        try {
          if (p0 == "on") {
            var shell = Shell();
            shell.run("vcgencmd display_power 1");
          }
          if (p0 == "off") {
            var shell = Shell();
            shell.run("vcgencmd display_power 0");
          }
        } catch (_) {}
      });
    } else {
      print("Mqtt did not connect, retrying...");
      Future.delayed(const Duration(seconds: 30)).then((value) => setupMqtt());
    }
  }

  Timer? publishWhenChangeStopTimer;

  onChange(double val) {
    const duration = Duration(milliseconds: 300);
    if (publishWhenChangeStopTimer != null) {
      setState(() => publishWhenChangeStopTimer!.cancel()); // clear timer
    }
    setState(() => publishWhenChangeStopTimer = Timer(duration, () => publishChange()));

    setState(() {
      double newVal = double.parse(val.toStringAsPrecision(3));
      if (thermostatModel.temperature != newVal) {
        thermostatModel.temperature = newVal;
      }
    });
  }

  publishChange() {
    if (hasRecievedSetTemperature) {
      MqttService.send(kThermostatSetTargetSubject, thermostatModelToJson(thermostatModel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ThermostatPanel(
                tempControlKey: tempControlKey,
                onValueChanged: onChange,
                setTemperature: thermostatModel.temperature ?? 20,
                atTemperature: !(thermostatModel.isHeating ?? false),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TemperatureDisplay(
                    title: kTempSensor1Name,
                    temp: "${tempSensor1?.am2301?.temperature ?? ""}°C",
                    humidity: "${tempSensor1?.am2301?.humidity ?? ""}%",
                  ),
                  TemperatureDisplay(
                    title: kTempSensor2Name,
                    temp: "${tempSensor2?.am2301?.temperature ?? ""}°C",
                    humidity: "${tempSensor2?.am2301?.humidity ?? ""}%",
                  ),
                  TemperatureDisplay(
                    title: kTempSensor3Name,
                    temp: "${tempSensor3?.am2301?.temperature ?? ""}°C",
                    humidity: "${tempSensor3?.am2301?.humidity ?? ""}%",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
