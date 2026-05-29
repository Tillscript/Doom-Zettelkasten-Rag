#!/usr/bin/env bash
# =============================================================================
# test-install-clean.sh — Valida install.sh num container Ubuntu limpo.
#
# Roda fora do container. Sobe ubuntu:24.04, clona o repo (só arquivos
# commitados — sem .venv/.groqapi) e exercita install.sh em 2 estágios:
#
#   Stage A (regressão): SEM python3-venv. Confirma que o check novo detecta
#                        e PARA, em vez de quebrar em "ensurepip not available".
#   Stage B:             COM python3-venv. Confirma que a venv builda.
#                        Torch (~2 GB) só com TEST_FULL=1.
#
# Uso:   bash test-install-clean.sh           # rápido (A + B sem torch)
#        TEST_FULL=1 bash test-install-clean.sh  # + pip install real (lento)
# =============================================================================
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMG="ubuntu:24.04"
FULL="${TEST_FULL:-0}"

pass() { printf "\033[32m✔ PASS\033[0m %s\n" "$1"; }
fail() { printf "\033[31m✘ FAIL\033[0m %s\n" "$1"; FAILED=1; }
FAILED=0

# Script que roda DENTRO do container. $1 = TEST_FULL.
read -r -d '' INNER <<'EOS'
set -u
FULL="$1"
export DEBIAN_FRONTEND=noninteractive

echo "### preparando container (python3 SEM venv) ###"
# python3 sozinho NÃO traz o módulo venv/ensurepip no Ubuntu — é exatamente
# o estado que reproduz o bug. NÃO instalar python3-venv aqui.
apt-get update -qq && apt-get install -y -qq python3 >/dev/null 2>&1

# Copia a ÁRVORE DE TRABALHO atual (testa edits ainda não commitados),
# excluindo .git, venv e segredos — simula um clone limpo do repo.
mkdir -p /root/.config/doom
tar -C /src --exclude=.git --exclude=.venv --exclude=.groqapi \
    --exclude=__pycache__ --exclude='*.pyc' --exclude=.cache \
    -cf - . | tar -C /root/.config/doom -xf - || { echo "COPY_FAIL"; exit 91; }
cd /root/.config/doom

echo ""
echo "================ STAGE A: SEM python3-venv ================"
python3 --version || { echo "python3 ausente na base?!"; exit 90; }
# Roda install.sh; ele tenta tudo, mas só nos importa o check venv.
OUT_A="$(bash install.sh 2>&1)"
echo "$OUT_A" | grep -E "venv|ensurepip" || true
echo "----------------------------------------------------------"
# Esperado: detecta módulo venv ausente. NÃO deve aparecer crash do python.
if echo "$OUT_A" | grep -q "módulo venv ausente"; then
  echo "RESULT_A=detected"
else
  echo "RESULT_A=missing_check"
fi
# Marcadores robustos do crash (a msg do ensurepip quebra em várias linhas):
# "ensurepip", "Failing command", "No such file or directory", "Traceback".
if echo "$OUT_A" | grep -qiE "ensurepip|Failing command|No such file or directory|Traceback"; then
  echo "RESULT_A_CRASH=yes"
else
  echo "RESULT_A_CRASH=no"
fi

echo ""
echo "================ STAGE B: COM python3-venv ================"
apt-get install -y -qq python3-venv >/dev/null 2>&1
# Testa só a criação da venv (parte que quebrava), não o install.sh inteiro.
if python3 -m venv /tmp/testvenv >/dev/null 2>&1 && [ -x /tmp/testvenv/bin/python ]; then
  echo "RESULT_B=venv_ok"
else
  echo "RESULT_B=venv_fail"
fi

if [ "$FULL" = "1" ]; then
  echo "### TEST_FULL=1: pip install -r requirements.txt (puxa torch, lento) ###"
  /tmp/testvenv/bin/pip install --quiet --upgrade pip >/dev/null 2>&1
  if /tmp/testvenv/bin/pip install --quiet -r requirements.txt; then
    echo "RESULT_FULL=deps_ok"
    # smoke test: importa e roda o script de embeddings num texto.
    echo '["hello world","org-roam nota teste"]' > /tmp/in.json
    if /tmp/testvenv/bin/python embeddings_local.py /tmp/in.json /tmp/out.json \
       && python3 -c "import json,sys; d=json.load(open('/tmp/out.json')); sys.exit(0 if len(d)==2 and len(d[0])>0 else 1)"; then
      echo "RESULT_FULL_SMOKE=embeddings_ok"
    else
      echo "RESULT_FULL_SMOKE=embeddings_fail"
    fi
  else
    echo "RESULT_FULL=deps_fail"
  fi
fi
echo "### inner done ###"
EOS

echo "Imagem: $IMG  |  TEST_FULL=$FULL  |  repo: $REPO"
echo "Subindo container..."
RAW="$(docker run --rm -v "$REPO":/src:ro "$IMG" bash -c "$INNER" bash "$FULL" 2>&1)"
echo "$RAW"
echo ""
echo "==================== VEREDITO ===================="

grep -q "RESULT_A=detected"   <<<"$RAW" && pass "Stage A: check venv dispara em sistema sem python3-venv" \
                                        || fail "Stage A: check NÃO disparou"
grep -q "RESULT_A_CRASH=no"   <<<"$RAW" && pass "Stage A: sem crash ensurepip/traceback (fix funciona)" \
                                        || fail "Stage A: ainda crasha com ensurepip"
grep -q "RESULT_B=venv_ok"    <<<"$RAW" && pass "Stage B: venv builda com python3-venv instalado" \
                                        || fail "Stage B: venv falhou"
if [ "$FULL" = "1" ]; then
  grep -q "RESULT_FULL=deps_ok"          <<<"$RAW" && pass "Full: requirements.txt instala (torch+sentence-transformers)" \
                                                    || fail "Full: install de deps falhou"
  grep -q "RESULT_FULL_SMOKE=embeddings_ok" <<<"$RAW" && pass "Full: embeddings_local.py gera vetores" \
                                                       || fail "Full: smoke test embeddings falhou"
fi

echo "=================================================="
[ "$FAILED" = 0 ] && { echo "TUDO PASSOU"; exit 0; } || { echo "FALHAS ACIMA"; exit 1; }
