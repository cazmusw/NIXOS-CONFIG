#!/usr/bin/env bash
# Install this directory as /etc/nixos; build first, activate last.
set -Eeuo pipefail

ETC_DIR=/etc
LOCK_FILE=/run/nixos-config-install.lock
SOURCE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
mode=install
case "${1:-}" in
  '') ;;
  --check) mode=check ;;
  -h|--help)
    printf '%s\n' 'Использование: sudo bash install.sh [--check]' \
      'Без аргументов: сборка, резервная копия /etc/nixos, установка и переключение.' \
      '--check: только сборка, без изменения /etc/nixos; sudo не обязателен.'
    exit 0 ;;
  *) printf 'Неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
esac
if (( $# > 1 )); then printf 'Слишком много аргументов.\n' >&2; exit 2; fi

for tool in nix cp mktemp rm mv; do
  command -v "$tool" >/dev/null || { printf 'Не найдена команда: %s\n' "$tool" >&2; exit 1; }
done
for file in flake.nix flake.lock; do
  [[ -f "$SOURCE_DIR/$file" ]] || { printf 'Нет файла: %s/%s\n' "$SOURCE_DIR" "$file" >&2; exit 1; }
done

if [[ "$mode" == install ]]; then
  if [[ $(id -u) != 0 ]]; then
    printf 'Запусти установку с правами администратора:\n  sudo bash %q\n' "$SOURCE_DIR/install.sh" >&2
    exit 1
  fi
  command -v nixos-rebuild >/dev/null || { printf 'Нужна установленная NixOS.\n' >&2; exit 1; }
  command -v flock >/dev/null || { printf 'Не найдена команда flock.\n' >&2; exit 1; }
  exec 9>"$LOCK_FILE"
  flock -n 9 || { printf 'Другой установщик уже работает.\n' >&2; exit 1; }
  if [[ -L "$ETC_DIR/nixos" || ( -e "$ETC_DIR/nixos" && ! -d "$ETC_DIR/nixos" ) ]]; then
    printf '%s/nixos должен быть обычной папкой, а не ссылкой или файлом.\n' "$ETC_DIR" >&2
    exit 1
  fi
fi

work_dir=''
stage_dir=''
backup_dir=''
old_moved=0
new_installed=0
success=0
cleanup() {
  local status=$?
  trap - EXIT INT TERM HUP
  # Restore config files if publishing or activation failed. A failed switch can
  # have changed services/profile already; report the separate system rollback.
  if [[ "$mode" == install && "$success" == 0 && "$new_installed" == 1 ]]; then
    local failed_dir
    failed_dir=$(mktemp -d "$ETC_DIR/nixos.failed.XXXXXXXX")
    if mv -T -- "$ETC_DIR/nixos" "$failed_dir/config"; then
      printf 'Новый конфиг сохранён для диагностики: %s/config\n' "$failed_dir" >&2
    else
      printf 'Не удалось переместить новый конфиг. Резервная копия: %s\n' "$backup_dir" >&2
    fi
    printf 'Если переключение частично применилось, выполни: sudo nixos-rebuild switch --rollback\n' >&2
  fi
  if [[ "$success" == 0 && "$old_moved" == 1 ]]; then
    if [[ ! -e "$ETC_DIR/nixos" && ! -L "$ETC_DIR/nixos" ]] && mv -T -- "$backup_dir" "$ETC_DIR/nixos"; then
      printf 'Исходный /etc/nixos восстановлен.\n' >&2
    else
      printf 'Восстанови конфиг вручную из: %s\n' "$backup_dir" >&2
    fi
  fi
  [[ -z "$stage_dir" ]] || rm -rf -- "$stage_dir"
  [[ -z "$work_dir" ]] || rm -rf -- "$work_dir"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP

# Freeze the input before building. This also supports running from /etc/nixos.
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/nixos-install.XXXXXXXX")
mkdir -- "$work_dir/config"
cp -a -- "$SOURCE_DIR/." "$work_dir/config/"
flake="path:$work_dir/config#nixosConfigurations.nixos.config.system.build.toplevel"
printf 'Сборка конфигурации nixos…\n'
nix --extra-experimental-features 'nix-command flakes' build \
  "$flake" --no-link --no-update-lock-file --print-build-logs

if [[ "$mode" == check ]]; then
  printf 'Сборка успешна. /etc/nixos не изменён, система не переключалась.\n'
  success=1
  exit 0
fi

# Stage on the same filesystem as /etc/nixos so publishing uses rename.
stage_dir=$(mktemp -d "$ETC_DIR/.nixos-install.XXXXXXXX")
cp -a -- "$work_dir/config/." "$stage_dir/"
chown -R root:root -- "$stage_dir"
chmod -R go-w -- "$stage_dir"
chmod 755 -- "$stage_dir"
if [[ -d "$ETC_DIR/nixos" ]]; then
  backup_dir=$(mktemp -d "$ETC_DIR/nixos.backup.$(date +%Y%m%d-%H%M%S).XXXXXXXX")
  rmdir -- "$backup_dir"
  mv -T -- "$ETC_DIR/nixos" "$backup_dir"
  old_moved=1
  printf 'Резервная копия: %s\n' "$backup_dir"
fi
mv -T -- "$stage_dir" "$ETC_DIR/nixos"
stage_dir=''
new_installed=1
printf 'Применение конфигурации…\n'
nixos-rebuild switch --flake "path:$ETC_DIR/nixos#nixos" --no-update-lock-file
success=1
printf 'Настройки установлены в %s/nixos и применены.\n' "$ETC_DIR"
[[ -z "$backup_dir" ]] || printf 'Предыдущие файлы: %s\n' "$backup_dir"
