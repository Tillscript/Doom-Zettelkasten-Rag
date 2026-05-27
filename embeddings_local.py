import sys
import json
import os

# Silencia logs chatos
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

try:
    from sentence_transformers import SentenceTransformer
except ImportError:
    sys.exit(1)

def main():
    input_file = sys.argv[1]
    output_file = sys.argv[2]

    with open(input_file, "r", encoding="utf-8") as f:
        raw = f.read()

    # Compatibilidade: input pode ser JSON (lista de strings = batch)
    # ou texto puro (1 chunk, modo antigo).
    try:
        texts = json.loads(raw)
        if not isinstance(texts, list):
            texts = [raw]
            batch = False
        else:
            batch = True
    except json.JSONDecodeError:
        texts = [raw]
        batch = False

    # Modelo carregado UMA vez; encode processa todos chunks de uma vez.
    model = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")
    embs = model.encode(texts)

    if batch:
        out = [e.tolist() for e in embs]
    else:
        out = embs[0].tolist()

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(out, f)

if __name__ == "__main__":
    main()
