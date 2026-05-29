#!/usr/bin/env bash
# =============================================================================
# install.sh — Setup plug-and-play desta config Doom Emacs.
#
# Faz, de forma idempotente (pode rodar várias vezes):
#   1. Checa pré-requisitos de sistema (emacs, doom, git, aspell, fontes...).
#   2. Cria a venv Python e instala as dependências do RAG (.venv/).
#   3. Cria a estrutura de pastas ~/Documents/Org/ usada pela config.
#   4. Configura o arquivo de chave .groqapi.
#   5. Roda `doom sync`.
#
# Uso:  bash install.sh
# =============================================================================
set -uo pipefail

DOOMDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG="$HOME/Documents/Org"
OK="\033[32m✔\033[0m"; WARN="\033[33m⚠\033[0m"; ERR="\033[31m✘\033[0m"
MISSING_SYS=0

say()  { printf "\n\033[1m== %s ==\033[0m\n" "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Sugere comando de instalação conforme o gerenciador de pacotes detectado.
pkg_hint() {
  if   have apt;    then echo "sudo apt install $1";
  elif have dnf;    then echo "sudo dnf install $1";
  elif have pacman; then echo "sudo pacman -S $1";
  elif have brew;   then echo "brew install $1";
  else echo "instale: $1"; fi
}

# -----------------------------------------------------------------------------
say "1/5  Pré-requisitos de sistema"

check_bin() { # nome_bin  pacote_sugerido  obrigatorio(1/0)
  if have "$1"; then
    printf "  $OK %s\n" "$1"
  elif [ "$3" = 1 ]; then
    printf "  $ERR %s ausente — %s\n" "$1" "$(pkg_hint "$2")"; MISSING_SYS=1
  else
    printf "  $WARN %s ausente (opcional) — %s\n" "$1" "$(pkg_hint "$2")"
  fi
}

check_bin emacs  emacs               1
check_bin git    git                 1
check_bin python3 python3            1

# python3 existe mas o módulo venv pode faltar (Debian/Ubuntu separam em
# python3-venv). Sem ele, `python3 -m venv` falha com "ensurepip is not
# available" e a instalação do RAG quebra no passo 2.
if have python3; then
  if python3 -c "import venv, ensurepip" >/dev/null 2>&1; then
    printf "  $OK python3-venv\n"
  else
    printf "  $ERR módulo venv ausente — %s\n" "$(pkg_hint python3-venv)"; MISSING_SYS=1
  fi
fi
check_bin aspell aspell              0   # corretor ortográfico (flyspell)
check_bin cmake  cmake               0   # build do vterm
check_bin gcc    gcc                 0   # build do vterm/pdf-tools
check_bin make   make                0

# Emacs >= 29 recomendado
if have emacs; then
  EV=$(emacs --version | head -1 | grep -oE '[0-9]+' | head -1)
  [ "${EV:-0}" -ge 29 ] && printf "  $OK emacs %s\n" "$EV" \
                        || printf "  $WARN emacs %s — recomendado >= 29\n" "$EV"
fi

# Doom instalado?
if [ -x "$HOME/.config/emacs/bin/doom" ]; then
  DOOM="$HOME/.config/emacs/bin/doom"; printf "  $OK doom encontrado\n"
elif [ -x "$HOME/.emacs.d/bin/doom" ]; then
  DOOM="$HOME/.emacs.d/bin/doom"; printf "  $OK doom encontrado\n"
else
  DOOM=""; MISSING_SYS=1
  printf "  $ERR Doom não instalado. Instale com:\n"
  printf "      git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs\n"
fi

# Dicionário pt_BR do aspell (a config usa ispell-dictionary \"pt_BR\")
if have aspell; then
  aspell dump dicts 2>/dev/null | grep -qx pt_BR \
    && printf "  $OK dicionário aspell pt_BR\n" \
    || printf "  $WARN dicionário pt_BR ausente — %s\n" "$(pkg_hint 'aspell-pt-br')"
fi

# Fontes JetBrains Mono + Cantarell (config.el)
if have fc-list; then
  fc-list | grep -qi "JetBrains Mono" \
    && printf "  $OK fonte JetBrains Mono\n" \
    || printf "  $WARN fonte 'JetBrains Mono' ausente — %s\n" "$(pkg_hint 'fonts-jetbrains-mono')"
  fc-list | grep -qi "Cantarell" \
    && printf "  $OK fonte Cantarell\n" \
    || printf "  $WARN fonte 'Cantarell' ausente — %s\n" "$(pkg_hint 'fonts-cantarell')"
fi

# -----------------------------------------------------------------------------
say "2/5  Ambiente Python (RAG / busca semântica)"
if have python3; then
  if [ ! -x "$DOOMDIR/.venv/bin/python" ]; then
    echo "  criando venv em .venv/ ..."
    python3 -m venv "$DOOMDIR/.venv"
  fi
  echo "  instalando dependências do RAG..."
  echo "  NOTA: sentence-transformers puxa PyTorch (~1-2 GB de download +"
  echo "        ~3 GB em disco). Pode demorar vários minutos na 1ª vez."
  "$DOOMDIR/.venv/bin/pip" install --quiet --upgrade pip
  if "$DOOMDIR/.venv/bin/pip" install --quiet -r "$DOOMDIR/requirements.txt"; then
    printf "  $OK venv pronta\n"
  else
    printf "  $ERR falha ao instalar dependências Python\n"; MISSING_SYS=1
  fi
else
  printf "  $ERR python3 ausente — pulei a venv\n"
fi

# -----------------------------------------------------------------------------
say "3/5  Estrutura de pastas ~/Documents/Org"
for d in notas agenda inbox flashcards templates noter; do
  mkdir -p "$ORG/$d" && printf "  $OK %s\n" "$ORG/$d"
done
# inbox capture target precisa do arquivo + headline
[ -f "$ORG/inbox/capturas.org" ] || printf "* Tarefas e Ideias\n" > "$ORG/inbox/capturas.org"
# template do capture diário (não sobrescreve se já existir)
[ -f "$ORG/templates/daily-progressive.orgt" ] || \
  cp "$DOOMDIR/templates/daily-progressive.orgt" "$ORG/templates/daily-progressive.orgt"
printf "  $OK capturas.org + template\n"

# -----------------------------------------------------------------------------
say "4/5  Chave da API Groq (.groqapi)"
if [ -f "$DOOMDIR/.groqapi" ]; then
  printf "  $OK .groqapi já existe\n"
else
  printf "  $WARN .groqapi ausente. Pegue uma chave free em https://console.groq.com/keys\n"
  printf "        depois rode:  echo 'SUA_CHAVE' > %s/.groqapi\n" "$DOOMDIR"
  printf "        (a IA/RAG não funciona sem ela; o resto da config funciona normal.)\n"
fi

# -----------------------------------------------------------------------------
say "5/5  doom sync"
if [ -n "$DOOM" ]; then
  "$DOOM" sync && printf "  $OK doom sync concluído\n" \
                || printf "  $ERR doom sync falhou — veja o erro acima\n"
else
  printf "  $WARN doom não encontrado — rode 'doom sync' depois de instalar o Doom\n"
fi

# -----------------------------------------------------------------------------
say "Resumo"
if [ "$MISSING_SYS" = 0 ]; then
  printf "$OK Tudo pronto. Abra o Emacs.\n"
else
  printf "$WARN Faltam itens obrigatórios acima. Resolva-os e rode 'bash install.sh' de novo.\n"
fi
