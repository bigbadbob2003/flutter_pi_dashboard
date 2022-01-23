#!/bin/bash

#Flutter SDK path
FLUTTER_PATH=

#gen_snapshot_linux_x64_release path
FLUTTERPI_PATH=

PACKAGE_NAME=homeautomation_dashboard

##ssh Path of pi
PI=pi@xxx.xxx.xxx.xxx
PI_FOLDER=/home/pi/


flutter build bundle

if [ $# -eq 0 ]
then
    rsync -a --info=progress2 ./build/flutter_assets/ $PI:${PI_FOLDER}${PACKAGE_NAME}

    ssh $PI killall flutter-pi

    ssh $PI flutter-pi ${PI_FOLDER}${PACKAGE_NAME}
fi

if [ $1 == "--release" ]
then
    dart \
  $FLUTTER_PATH/bin/cache/dart-sdk/bin/snapshots/frontend_server.dart.snapshot \
  --sdk-root $FLUTTER_PATH/bin/cache/artifacts/engine/common/flutter_patched_sdk_product \
  --target=flutter \
  --aot \
  --tfa \
  -Ddart.vm.product=true \
  --packages .packages \
  --output-dill build/kernel_snapshot.dill \
  --verbose \
  --depfile build/kernel_snapshot.d \
  package:$PACKAGE_NAME/main.dart
  
  $FLUTTERPI_PATH/gen_snapshot_linux_x64_release \
  --deterministic \
  --snapshot_kind=app-aot-elf \
  --elf=build/flutter_assets/app.so \
  --strip \
  --sim-use-hardfp \
  build/kernel_snapshot.dill

  rsync -a --info=progress2 ./build/flutter_assets/ $PI:${PI_FOLDER}${PACKAGE_NAME}
  
  ssh $PI killall flutter-pi

  ssh $PI flutter-pi --release ${PI_FOLDER}${PACKAGE_NAME}
fi

  
if [ $1 == "-k" ]
then
  ssh $PI killall flutter-pi
fi