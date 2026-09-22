#!/usr/bin/env bash
# Instalador do pacote bf-jev-deep-research (macOS / Linux / Git Bash / WSL).
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.sh | bash
#
# O que este script faz, em ordem:
#   1. Clona o pacote (raso, sem histórico) para uma pasta temporária.
#   2. Copia o pacote inteiro (skill + estudo bruto) para <projeto>/bf-jev-deep-research/
#      — essa é a "biblioteca de referência" que fica navegável dentro do seu projeto.
#   3. Instala a SKILL de fato onde o agente vai encontrá-la:
#        - se <projeto>/agents/skills/ já existir, instala ali e cria um symlink
#          em <projeto>/.claude/skills/<nome> apontando para lá (evita duplicar
#          arquivos quando vários harnesses compartilham uma pasta de skills comum);
#        - senão, instala direto em <projeto>/.claude/skills/<nome>.
#   4. Reescreve os links relativos da cópia instalada da skill para apontar de
#      volta para bf-jev-deep-research/study/ na nova profundidade (ver nota abaixo).
#
# Por que reescrever links: dentro do pacote, skill/SKILL.md fica ao lado de
# study/ (mesmo nível), então usa "../study/...". Uma vez copiada para
# agents/skills/<nome>/ ou .claude/skills/<nome>/, a skill fica 3 níveis abaixo
# da raiz do projeto em vez de 1, então os links precisam de "../../../" em vez
# de "../". Sem esse ajuste, a skill instalada perde a referência para o estudo
# bruto completo.

set -euo pipefail

REPO_URL="https://github.com/BFLabsAI/bf-jev-deep-research.git"
PKG_NAME="bf-jev-deep-research"
SKILL_NAME="jev-typesafe-expert"
TARGET_DIR="${1:-$(pwd)}"

info()  { printf '\033[1;36m==>\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m!!\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m✓\033[0m %s\n' "$1"; }

if ! command -v git >/dev/null 2>&1; then
  echo "Erro: este instalador precisa do git no PATH. Instale o git e rode de novo." >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

info "Baixando ${PKG_NAME}..."
git clone --depth=1 --quiet "$REPO_URL" "$TMP_DIR"

PKG_DEST="$TARGET_DIR/$PKG_NAME"
info "Instalando a biblioteca de referência em: $PKG_DEST"
mkdir -p "$PKG_DEST"
rsync -a --delete --exclude ".git" "$TMP_DIR/" "$PKG_DEST/" 2>/dev/null || {
  rm -rf "$PKG_DEST"
  mkdir -p "$PKG_DEST"
  cp -R "$TMP_DIR/." "$PKG_DEST/"
  rm -rf "$PKG_DEST/.git"
}
ok "bf-jev-deep-research/ instalado (skill + estudo bruto navegável)."

# --- Decide onde a skill "viva" vai morar ---
AGENTS_SKILLS="$TARGET_DIR/agents/skills"
CLAUDE_SKILLS="$TARGET_DIR/.claude/skills"

if [ -d "$AGENTS_SKILLS" ]; then
  CANONICAL_DIR="$AGENTS_SKILLS/$SKILL_NAME"
  info "Pasta agents/skills detectada — instalando a skill lá e criando symlink em .claude/skills."
  DEPTH_UP="../../../"   # <projeto>/agents/skills/<nome>/  ->  <projeto>/
else
  CANONICAL_DIR="$CLAUDE_SKILLS/$SKILL_NAME"
  info "Sem agents/skills — instalando direto em .claude/skills."
  DEPTH_UP="../../../"   # <projeto>/.claude/skills/<nome>/  ->  <projeto>/
fi

rm -rf "$CANONICAL_DIR"
mkdir -p "$CANONICAL_DIR"
cp -R "$PKG_DEST/skill/." "$CANONICAL_DIR/"

# --- Reescreve os links relativos da skill instalada (ver nota no topo) ---
# SKILL.md original usa "../study/..."      (1 nível)  -> precisa de "../../../bf-jev-deep-research/study/..." (3 níveis)
# references/*.md usa   "../../study/..."   (2 níveis) -> precisa de "../../../../bf-jev-deep-research/study/..." (4 níveis)
SED_INPLACE=(-i)
if sed --version >/dev/null 2>&1; then
  : # GNU sed: -i sem argumento extra
else
  SED_INPLACE=(-i '')  # BSD/macOS sed precisa de um argumento (vazio = sem backup)
fi

sed "${SED_INPLACE[@]}" -E "s#\]\(\.\./study/#](${DEPTH_UP}${PKG_NAME}/study/#g" "$CANONICAL_DIR/SKILL.md"
if [ -d "$CANONICAL_DIR/references" ]; then
  for f in "$CANONICAL_DIR/references/"*.md; do
    sed "${SED_INPLACE[@]}" -E "s#\]\(\.\./\.\./study/#](${DEPTH_UP}../${PKG_NAME}/study/#g" "$f"
  done
fi
ok "Links da skill reescritos para apontar para ${PKG_NAME}/study/."

# --- Symlink em .claude/skills quando a instalação canônica foi em agents/skills ---
if [ -d "$AGENTS_SKILLS" ]; then
  mkdir -p "$CLAUDE_SKILLS"
  LINK_PATH="$CLAUDE_SKILLS/$SKILL_NAME"
  rm -rf "$LINK_PATH"
  ln -s "../../agents/skills/$SKILL_NAME" "$LINK_PATH"
  ok "Symlink criado: .claude/skills/$SKILL_NAME -> agents/skills/$SKILL_NAME"
fi

echo
ok "Instalação concluída."
echo "  Biblioteca completa (skill + estudo bruto): $PKG_DEST"
echo "  Skill ativa para o agente:                  $CANONICAL_DIR"
echo
echo "Para reinstalar/atualizar, rode este mesmo comando de novo."
