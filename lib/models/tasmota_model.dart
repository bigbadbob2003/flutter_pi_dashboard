// To parse this JSON data, do
//
//     final tasmotaModel = tasmotaModelFromJson(jsonString);

import 'dart:convert';

TasmotaModel tasmotaModelFromJson(String str) => TasmotaModel.fromJson(json.decode(str));

String tasmotaModelToJson(TasmotaModel data) => json.encode(data.toJson());

class TasmotaModel {
  TasmotaModel({
    this.time,
    this.am2301,
    this.tempUnit,
  });

  DateTime? time;
  Am2301? am2301;
  String? tempUnit;

  factory TasmotaModel.fromJson(Map<String, dynamic> json) => TasmotaModel(
        time: json["Time"] == null ? null : DateTime.parse(json["Time"]),
        am2301: json["AM2301"] == null ? null : Am2301.fromJson(json["AM2301"]),
        tempUnit: json["TempUnit"],
      );

  Map<String, dynamic> toJson() => {
        "Time": time?.toIso8601String(),
        "AM2301": am2301?.toJson(),
        "TempUnit": tempUnit,
      };
}

class Am2301 {
  Am2301({
    this.temperature,
    this.humidity,
    this.dewPoint,
  });

  double? temperature;
  double? humidity;
  double? dewPoint;

  factory Am2301.fromJson(Map<String, dynamic> json) => Am2301(
        temperature: json["Temperature"]?.toDouble(),
        humidity: json["Humidity"]?.toDouble(),
        dewPoint: json["DewPoint"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Temperature": temperature,
        "Humidity": humidity,
        "DewPoint": dewPoint,
      };
}
