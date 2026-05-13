#!/usr/bin/env bash
# Ejecuta los integration tests de la app con retry policy.
#
# Por qué este script externo:
#   reactivecircus/android-emulator-runner@v2 ejecuta el `script:` línea por
#   línea como `/usr/bin/sh -c <line>`, lo cual rompe cualquier construcción
#   multi-línea (until/while/for/if con múltiples líneas, heredocs, etc.).
#   La práctica recomendada es invocar un script bash externo desde el
#   `script:` del action, donde sí se interpreta como un programa completo.
#
# Uso en CI:
#   - name: Run integration tests with retry
#     uses: reactivecircus/android-emulator-runner@v2
#     with:
#       script: bash scripts/run_integration_tests.sh
#
# Variables:
#   MAX_ATTEMPTS  número de intentos (default 3). Mitiga flakiness intrínseca
#                 del emulator Android en CI.
#   RETRY_SLEEP   segundos entre intentos fallidos (default 10).

set -uo pipefail

MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
RETRY_SLEEP="${RETRY_SLEEP:-10}"

attempt=1
while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
  echo "=== Intento $attempt de $MAX_ATTEMPTS ==="
  if flutter test --coverage integration_test/ --flavor dev; then
    echo "=== Integration tests PASSED (intento $attempt) ==="
    exit 0
  fi

  if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
    echo "Intento $attempt falló. Esperando ${RETRY_SLEEP}s antes de retry..."
    sleep "$RETRY_SLEEP"
  fi
  attempt=$((attempt + 1))
done

echo "=== Todos los $MAX_ATTEMPTS intentos fallaron ==="
exit 1
