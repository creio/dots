#!/usr/bin/env bash

# pactl set-source-port 0 analog-input-rear-mic
# pactl set-source-port 0 analog-input-front-mic

## --- Переменные ---
# micro="alsa_input.pci-0000_00_1b.0.analog-stereo"
# micro=$(pactl get-default-source | sed 's/\.[^\.]*$//')

SINK_NAME="mic_denoised_out"
FILTER_NAME="mic_filter_sink"
# Определяем физический микрофон, игнорируя наш собственный виртуальный монитор
PHYS_MIC=$(pactl get-default-source | grep -v "$SINK_NAME")
PHYS_SINK="$(pactl get-default-sink)"
PLUGIN="/usr/lib/ladspa/librnnoise_ladspa.so"

# Если вдруг дефолтным был наш шумодав, берем первый попавшийся железный источник
if [ -z "$PHYS_MIC" ]; then
    PHYS_MIC=$(pactl list sources short | grep "alsa_input" | head -n1 | awk '{print $2}')
fi

# --- Проверки перед стартом ---
# 1. Проверяем наличие плагина физически на диске
if [[ ! -f "$PLUGIN" ]]; then
    echo "Ошибка: Плагин шумоподавления не найден по пути $PLUGIN"
    echo "Установи пакет: noise-suppression-for-voice"
    exit 1
fi

# 2. Проверяем, запущен ли звуковой сервер (pactl должен отвечать)
if ! pactl info &>/dev/null; then
    echo "Ошибка: Звуковой сервер (PipeWire/PulseAudio) не запущен."
    exit 1
fi

# Очистка старых модулей перед запуском
cleanup() {
    pactl list modules short | grep -E "$SINK_NAME|$FILTER_NAME|module-loopback" \
    | awk '{print $1}' | xargs -r -L1 pactl unload-module 2>/dev/null
}

## Режим выключения
if [[ $1 == "-u" ]]; then
    cleanup
    pactl set-default-source "$PHYS_MIC"
    echo "Шумоподавление отключено."
    exit 0
fi

cleanup

sleep 0.5

# --- Основная логика ---
# Используем переменную $SINK_NAME везде далее
pactl load-module module-null-sink \
    sink_name="$SINK_NAME" \
    sink_properties=device.description="Denoised_Microphone" \
    rate=48000 > /dev/null

pactl load-module module-ladspa-sink \
    sink_name="$FILTER_NAME" \
    sink_master="$SINK_NAME" \
    label=noise_suppressor_mono \
    plugin="$PLUGIN" > /dev/null

sleep 0.5

# Загружаем петлю и НЕ мьютим её
pactl load-module module-loopback \
    source="$PHYS_MIC" \
    sink="$FILTER_NAME" \
    channels=1 \
    source_dont_move=true \
    sink_dont_move=true > /dev/null

# Настройка уровней
pactl set-sink-mute "$SINK_NAME" 0
pactl set-sink-volume "$SINK_NAME" 100%
pactl set-default-source "${SINK_NAME}.monitor"

echo "-------------------------------------------------------"
echo "Шумодав [$SINK_NAME] запущен."
echo "Микрофон в приложениях: Monitor of Denoised_Microphone"
echo "Физический вход: $PHYS_MIC"
echo "-------------------------------------------------------"