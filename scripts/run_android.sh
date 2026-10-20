#!/usr/bin/env bash
# Enciende el emulador (si no está corriendo) y ejecuta la app con FVM.
# Uso: ./scripts/run_android.sh [argumentos extra para flutter run, ej. --profile]
set -euo pipefail

AVD_NAME="${AVD_NAME:-pixel_api35}"
ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
ADB="$ANDROID_HOME/platform-tools/adb"
EMULATOR="$ANDROID_HOME/emulator/emulator"

cd "$(dirname "$0")/.."

running_emulator() {
  "$ADB" devices | awk '/^emulator-[0-9]+\tdevice$/ {print $1; exit}'
}

DEVICE_ID="$(running_emulator)"

if [[ -z "$DEVICE_ID" ]]; then
  echo "Encendiendo emulador $AVD_NAME..."
  nohup "$EMULATOR" -avd "$AVD_NAME" -gpu host >/tmp/emulator-"$AVD_NAME".log 2>&1 &

  "$ADB" wait-for-device
  until [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 2
  done
  DEVICE_ID="$(running_emulator)"
  echo "Emulador listo: $DEVICE_ID"
else
  echo "Usando emulador ya encendido: $DEVICE_ID"
fi

fvm flutter run -d "$DEVICE_ID" "$@"
