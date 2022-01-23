import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SubscriptionCallback {
  final String topic;
  final Function(String) callback;

  SubscriptionCallback({required this.topic, required this.callback});
}

class MqttService {
  static MqttServerClient? client;

  static bool connected = false;
  static List<SubscriptionCallback> _subscriptionCallbacks = [];

  static Future<bool> connect(String server, String clientName) async {
    client = MqttServerClient(server, clientName);

    client!.setProtocolV311();
    client!.keepAlivePeriod = 20;

    final connMess = MqttConnectMessage().withClientIdentifier('Mqtt_MyClientUniqueId').startClean();
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } on NoConnectionException catch (_) {
      client!.disconnect();
      return false;
    } on SocketException catch (_) {
      client!.disconnect();
      return false;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      connected = true;
    } else {
      client!.disconnect();
      return false;
    }

    client!.updates!.listen(_onClientUpdate);
    return true;
  }

  static addSubscription(String topic, Function(String) onMessage) {
    if (client == null || !connected) return;
    _subscriptionCallbacks.add(SubscriptionCallback(topic: topic, callback: onMessage));
    client!.subscribe(topic, MqttQos.atMostOnce);
  }

  static send(String topic, String payload) {
    if (client == null || !connected) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  static _onClientUpdate(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    for (var sub in _subscriptionCallbacks.where((element) => element.topic == c[0].topic)) {
      sub.callback(pt);
    }
  }
}
