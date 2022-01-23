// To parse this JSON data, do
//
//     final thermostatModel = thermostatModelFromJson(jsonString);

import 'dart:convert';

ThermostatModel thermostatModelFromJson(String str) => ThermostatModel.fromJson(json.decode(str));

String thermostatModelToJson(ThermostatModel data) => json.encode(data.toJson());

class ThermostatModel {
  ThermostatModel({
    this.temperature,
    this.isHeating,
  });

  double? temperature;
  bool? isHeating;

  factory ThermostatModel.fromJson(Map<String, dynamic> json) => ThermostatModel(
        temperature: json["temperature"]?.toDouble(),
        isHeating: json["isHeating"],
      );

  Map<String, dynamic> toJson() => {
        "temperature": temperature,
        "isHeating": isHeating,
      };
}
