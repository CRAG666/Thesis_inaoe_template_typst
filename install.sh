#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
  printf 'Uso: curl -fsSL https://raw.githubusercontent.com/CRAG666/Thesis_inaoe_template_typst/main/install.sh | bash\n' >&2
  exit 2
fi

if [[ -n ${TYPST_PACKAGE_PATH:-} ]]; then
  package_path=$TYPST_PACKAGE_PATH
elif [[ $(uname -s) == Darwin ]]; then
  package_path="$HOME/Library/Application Support/typst/packages"
else
  package_path="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages"
fi

target="$package_path/local/inaoe-tesis/0.1.0"
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT
curl -fsSL --retry 3 \
  https://github.com/CRAG666/Thesis_inaoe_template_typst/archive/refs/heads/main.tar.gz \
  -o "$temp_dir/source.tar.gz"
tar -xzf "$temp_dir/source.tar.gz" -C "$temp_dir"
source_dir=$temp_dir/Thesis_inaoe_template_typst-main

mkdir -p -- "$(dirname -- "$target")"
stage=$(mktemp -d "$(dirname -- "$target")/.inaoe-tesis-0.1.0.XXXXXX")
trap 'rm -rf -- "$temp_dir" "$stage"' EXIT
cp -R -- \
  "$source_dir/typst.toml" \
  "$source_dir/inaoe-tesis.typ" \
  "$source_dir/biblatex-cites" \
  "$source_dir/cover" \
  "$source_dir/template" \
  "$source_dir/README.md" \
  "$source_dir/README.es.md" \
  "$source_dir/LICENSE" \
  "$stage/"
rm -rf -- "$target"
mv -- "$stage" "$target"
printf 'Paquete instalado en %s\n' "$target"
printf 'Crea un proyecto con: typst init @local/inaoe-tesis:0.1.0 mi-tesis\n'
