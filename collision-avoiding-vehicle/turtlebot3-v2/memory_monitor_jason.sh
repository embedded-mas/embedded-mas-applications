#!/bin/bash

# launch the application and produce a log with memory and cpu usage data

TARGET="./gradlew run"
LOG="rosnode_memlog_jason.csv"
INTERVAL=0.1

# Alinha o cabeçalho com o do Script 1
echo "timestamp,pid,cpu_percent,rss_kb,vsz_kb,cmdline" > "$LOG"

# Inicia monitoramento em background
(
    JVM_PID=""
    while true; do
        if [[ -z "$JVM_PID" ]]; then
            JVM_PID=$(pgrep -P $$ -f 'java.*')
        fi

        TIMESTAMP=$(date +%s.%N)
        if [[ -n "$JVM_PID" && -e /proc/$JVM_PID ]]; then
            STATS=$(ps -o %cpu=,rss=,vsz=,cmd= -p "$JVM_PID" --no-headers)
            echo "$TIMESTAMP,$JVM_PID,$STATS" >> "$LOG"
        else
            echo "$TIMESTAMP,0,0,0,0,processo_finalizado" >> "$LOG"
        fi

        sleep $INTERVAL

        if [[ -n "$JVM_PID" && ! -e /proc/$JVM_PID ]]; then
            break
        fi
    done
) &
MON_PID=$!

# Lança a aplicação via Gradle
$TARGET

# Espera monitoramento encerrar
wait $MON_PID

