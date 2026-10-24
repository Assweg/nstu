#!/bin/bash
# =============================================================================
# Автоматический прогон ЛР4 целиком (задания 1–3 подряд).
# Для отчёта рекомендуется РУЧНОЙ режим — задания 2 и 3 по отдельности:
#   ./run_docker.sh s2-lr4-check-1
#   ./scripts/s2_lr4_task2.sh backup
#   ./scripts/s2_lr4_task2.sh before
#   # пауза 1–2 мин
#   ./scripts/s2_lr4_task2.sh disaster
#   ./scripts/s2_lr4_task3.sh all
# =============================================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Автопрогон ЛР4 (без паузы для скриншотов отчёта)."
echo "Для ручного отчёта используйте scripts/s2_lr4_task2.sh и task3.sh"
echo ""

WAIT_DISASTER="${S2_LR4_WAIT_SEC:-90}"
export S2_LR4_WAIT_SEC="$WAIT_DISASTER"

bash ./scripts/s2_lr4_task2.sh backup
bash ./scripts/s2_lr4_task2.sh before
echo "Пауза ${WAIT_DISASTER} с..."
sleep "$WAIT_DISASTER"
bash ./scripts/s2_lr4_task2.sh disaster
bash ./scripts/s2_lr4_task3.sh all

echo "Готово."
