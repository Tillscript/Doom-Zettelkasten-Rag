# doom-zettelkasten-rag

Doom Emacs personal study config, Zettelkasten notes, local RAG (chat with your notes via Groq), SRS flashcards, Pomodoro, and PDF/EPUB annotation.

- **Org-roam v2** - networked notes (Zettelkasten) with capture templates by area (programming, philosophy, economics, security...).
- **Local RAG** - semantic search and AI chat over **your own notes**, using local embeddings (Python + `sentence-transformers`) and the free **Groq** API (Llama 3.3 / Gemma2).
- **SRS flashcards** (`org-fc`, Anki-style) + **Pomodoro** + **EPUB reader** (`nov.el`) + **PDF/EPUB annotation** (`org-noter`).
- **Gruvbox** theme, **JetBrains Mono**, **evil** (Vim) keybindings.

---

## ⚡ Quick setup

```bash
# 1. Install Doom Emacs (prerequisite)
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# 2. Clone this config
git clone git@github.com:Tillscript/doom-zettelkasten-rag.git ~/.config/doom

# 3. Run the installer (creates Python venv, Org folders, runs doom sync)
bash ~/.config/doom/install.sh

# 4. Add your Groq key (free at https://console.groq.com/keys)
echo 'YOUR_GROQ_KEY' > ~/.config/doom/.groqapi

# 5. Open Emacs
emacs
```

`install.sh` is **idempotent**, safe to re-run. Checks every dependency and tells you exactly what's missing.

---

## 📋 Prerequisites

Required (`install.sh` checks and warns):

| Item | Purpose | Install (Debian/Ubuntu) |
|------|---------|------------------------|
| **Emacs ≥ 29** | base | `sudo apt install emacs` |
| **Doom Emacs** | framework | see step 1 above |
| **git** | clone/sync | `sudo apt install git` |
| **python3** | RAG embeddings | `sudo apt install python3 python3-venv` |

Optional (degrade gracefully without breaking):

| Item | Without it... | Install |
|------|--------------|---------|
| **aspell** + `pt_BR` | no spellcheck | `sudo apt install aspell aspell-pt-br` |
| **JetBrains Mono** | fallback font | `sudo apt install fonts-jetbrains-mono` |
| **Cantarell** | fallback font | `sudo apt install fonts-cantarell` |
| **cmake + gcc + make** | no `vterm`/`pdf-tools` | `sudo apt install cmake gcc make` |
| **Groq key** (`.groqapi`) | AI/RAG disabled | https://console.groq.com/keys |

> Other distros: `install.sh` detects `dnf`/`pacman`/`brew` and suggests the right command.

After installing fonts, run inside Emacs: `M-x nerd-icons-install-fonts`.

---

## 📁 File structure

```
~/.config/doom/
├── init.el              # active Doom modules
├── config.el            # main config (org-roam, gptel/RAG, flashcards, theme)
├── packages.el          # extra packages (org-roam v2, gptel, org-fc, nov...)
├── embeddings_local.py  # generates embeddings (runs in .venv)
├── requirements.txt     # Python deps
├── install.sh           # automated setup
├── templates/           # daily capture template
├── .groqapi             # your Groq key (NOT versioned, gitignored)
└── .venv/               # Python virtualenv (NOT versioned)

~/Documents/Org/         # created by install.sh
├── notas/  agenda/  inbox/  flashcards/  templates/  noter/
```

---

## 🗂️ Folder structure (Org notes)

```
~/Documents/Org/
├── agenda/         GTD, deadlines
├── inbox/          quick capture (SPC X)
├── notas/          org-roam (Zettelkasten)
│   ├── genki/      MOCs (Maps of Content)
│   ├── programacao/
│   ├── filosofia/
│   ├── livros/
│   └── ...
├── noter/          PDF annotation notes (org-noter)
└── templates/      org-capture templates
```

> Estas pastas são as que eu uso no meu setup. `install.sh` cria todas
> automaticamente, então funciona sem você mexer em nada. Se quiser nomes
> diferentes (ex: `notes/` no lugar de `notas/`, `programming/` no lugar de
> `programacao/`), edite os caminhos em `config.el` nas linhas:
>
> - `org-directory` e `org-roam-directory` (L83-84)
> - `org-agenda-files` (L88-92)
> - capture diário e inbox (L103, L108-110)
> - templates de capture org-roam (L122, L125, L131)
> - diretório de flashcards (L547)
> - `org-noter-notes-search-path` (L616)
>
> Depois ajuste `install.sh` (L108) pra criar as pastas com os novos nomes.

---

## 2. Capturing knowledge (Zettelkasten)

**Principle:** one idea = one atomic note. MOCs only aggregate via links.

| Action | Bind |
|--------|------|
| Create/open note | `SPC n r f` (`org-roam-node-find`) |
| Insert link to another note | `SPC n r i` (`org-roam-node-insert`) |
| Capture template | `SPC n r c` (choose Programming, Philosophy...) |
| Backlinks of current note | `SPC n r b` (or `M-x org-roam-buffer-toggle`) |
| Visual graph | `SPC n r g` |

**Flow:**
1. Reading book/article/lecture → insight hits → `SPC n r f` creates atomic note.
2. Link with `SPC n r i` as you write.
3. Create MOC only when you have 5+ notes on a theme. MOC = list of links, not content.
4. Hit `SPC n r b` to see what points to the note: rediscovers forgotten connections.

---

## 3. Active reading (PDF/EPUB)

| Action | Bind |
|--------|------|
| Open noter session | `SPC n N n` |
| Insert note anchored to page | `SPC n N i` |
| Sync page↔note | `SPC n N s` |
| Close session | `SPC n N k` |

**Flow:**
1. Open PDF (`SPC .` to search) or `.epub` (nov.el opens automatically).
2. `SPC n N n` → creates/reopens org notes file side by side.
3. Read. `SPC n N i` on each insight: note gets anchored to exact page.
4. Good insights → become atomic notes in org-roam (cross-linked).

---

## 4. Memorization (SRS / flashcards)

| Action | Bind |
|--------|------|
| Normal card (front/back) | `SPC n F n` on heading |
| Cloze card (fill-in-the-blank) | `SPC n F c` |
| Double card (bidirectional) | `SPC n F D` |
| Review (all due) | `SPC n F r` |
| Review by **tag** | `SPC n F t` |
| Review by tag **early** (ignore schedule) | `SPC n F T` |
| Review by **folder** | `SPC n F p` |
| Dashboard (stats) | `SPC n F d` |
| Suspend/unsuspend | `SPC n F s` / `SPC n F u` |

**Creating a card:**
1. In an org-roam note, create a heading with the question. Body = answer.
2. Cursor on heading → `SPC n F n` (becomes a card). Repeat for multiple cards in same file.
3. Cards live inside the notes themselves, no knowledge duplication.

**Review flow (keys inside review):**
1. `SPC n F r` → opens first due card (shows only the question).
2. `RET` → flips/reveals the answer.
3. Rate with:
   - `a` = again (wrong)
   - `h` = hard
   - `g` = good
   - `e` = easy
4. Next card advances automatically → repeat step 2. Ends at "Review Done".
5. During review: `q` = quit · `p` = edit card · `s` = suspend.

> Header-line shows `Flip/Rate (N) Title`: the `(N)` is cards remaining, not the type.

**Review by subject:**
- **By tag** (`SPC n F t`): tag cards with subject (e.g. `:fc:http:`, `:fc:sql:`). Then `SPC n F t` → type `http` → reviews only those.
- **By folder** (`SPC n F p`): choose folder (e.g. `~/Documents/Org/notas/programacao/`) → reviews only cards there. Good if you organize notes by theme in subfolders.

> Tag in org: at end of card heading write `:fc:subject:` (`:fc:` is required for the card; the second is your filter, **no space between them**). Or `SPC m q` (org-set-tags) to add.

**Early review** (`SPC n F T`): reviews cards of a tag **even if not due**. Good for reviewing a subject before an exam without waiting for the SRS schedule. Review data still updates normally.

**⚠️ Use `SPC n F r`, NOT `SPC n F b`.** The review-buffer (`b`) breaks with `Wrong type argument: stringp, nil` if the active buffer isn't visiting a file (dashboard/scratch/wrong window in focus).

**Cloze example:**
```org
* Concept X
{{key-concept}@1} is defined as {{definition}@2}.
```

---

## 5. Focus (Pomodoro)

| Action | Bind |
|--------|------|
| Start/toggle | `SPC n P p` or `<F12>` |
| Kill | `SPC n P k` |

**Flow:**
1. On a TODO task in `org-agenda` or heading → `SPC n P p`.
2. Auto clock-in on the task. 25min focus → 5min break.
3. 4 pomodoros → 20min long break.
4. `SPC o A` (`org-agenda`) shows total clocked time per task.

---

## 6. RAG: chat with your notes (gptel)

| Action | Bind |
|--------|------|
| Index org-roam folder | `SPC i i` (once, then incremental) |
| Ask with context | `SPC i s` |
| Inline code edit | `SPC i k` |
| Pure chat | `SPC i l` |
| Switch model | `SPC i m 3/8/x` |

**How it works:**
1. You write notes in `~/Documents/Org/notas/` (org-roam).
2. `SPC i i` indexes the folder: `embeddings_local.py` generates embeddings for each chunk and saves the index to `~/.cache/doom/gptel-index.eld`.
3. `SPC i s` asks a question: finds most relevant chunks (cosine similarity) and sends to Groq to answer **citing your notes**.

The `paraphrase-multilingual-MiniLM-L12-v2` model (~120 MB) downloads on first use.

**Flow:**
1. After writing many notes: `SPC i i` reindexes (async, non-blocking).
2. `SPC i s` → ask something like "what do I have on queue theory?". AI answers citing your notes.
3. Coding: select code → `SPC i k` → instruction → AI rewrites in place with context from your notes.

---

## 7. Programming

| Action | Bind |
|--------|------|
| Find file in project | `SPC SPC` |
| Grep project | `SPC s p` |
| Switch project (Projectile) | `SPC p p` |
| Add project to Projectile | `SPC p a` or `M-x projectile-add-known-project` |
| LSP rename | `SPC c r` |
| LSP go to definition | `g d` |
| LSP references | `g r` |
| Magit | `SPC g g` |
| Terminal popup | `SPC o t` (vterm) |
| Inline AI edit | `SPC i k` |

**TDD/study flow:**
1. org-roam note of the concept (e.g. "haskell-monads").
2. Executable code block inside: `C-c C-c` runs it (org-babel).
3. Pomodoro `<F12>` → 25min hack.
4. Insight → becomes SRS card in same file.
5. Magit commit (`SPC g g`).

### JS/TS + Fastify (LSP)

Module `(javascript +lsp)` in `init.el` → typescript-mode/tsx, js2-mode, autocomplete via corfu, hover/peek (lsp-ui), nav (`gd`/`gr`), rename (`SPC c r`), format on-save (prettier).

**External tooling (npm global):**
```bash
npm install -g typescript typescript-language-server prettier
```

**Per Fastify project:**
```bash
npm init -y && npm i fastify && npm i -D typescript && npx tsc --init
```

**Verify:** open `.ts` → modeline shows `LSP[ts-ls]`. Type `fastify(` → autocomplete popup. `gd` jumps to types. Save → prettier reformats. Type error → inline underline.

---

## 8. Suggested daily routine

| Time | Action | Bind |
|------|--------|------|
| Morning | SRS review | `SPC n F r` |
| Morning | Day agenda | `SPC o A` |
| Study block | Pomodoro + noter | `<F12>` + `SPC n N n` |
| Post-reading | Atomic notes | `SPC n r f` |
| Post-reading | Create cards | `SPC n F n` |
| End of day | Reindex RAG | `SPC i i` |
| Reflection | Graph + backlinks | `SPC n r g` / `b` |

---

## ⌨️ Cheat sheet

```
ZETTEL    SPC n r f/i/c/b/g
NOTER     SPC n N n/i/s/k
SRS       SPC n F r/d/n/c/D/s/u
POMO      SPC n P p/k     <F12>
RAG/AI    SPC i l/i/s/k/m
AGENDA    SPC o A
MAGIT     SPC g g
```

---

## 🐞 Troubleshooting

**"WARNING: .groqapi file not found!"**
Create the file: `echo 'YOUR_KEY' > ~/.config/doom/.groqapi`. AI won't work without it; rest of config works normally.

**RAG finds nothing / `SPC i s` returns empty**
Index first with `SPC i i`. Confirm venv exists: `ls ~/.config/doom/.venv/bin/python`. If not, run `bash install.sh` again.

**Embeddings / Python error**
Test the script manually:
```bash
echo "test" > /tmp/in.txt
~/.config/doom/.venv/bin/python ~/.config/doom/embeddings_local.py /tmp/in.txt /tmp/out.txt && cat /tmp/out.txt
```
If it fails with `ImportError`, reinstall: `~/.config/doom/.venv/bin/pip install -r ~/.config/doom/requirements.txt`.

**`vterm`/`pdf-tools` won't compile**
Missing `cmake`/`gcc`/`make`/`libtool`. Install them and run `doom sync`.

**Flyspell errors on org open**
Missing pt_BR dictionary. Install `aspell-pt-br` or ignore: config auto-disables flyspell if dictionary is absent.

**Changed `init.el` or `packages.el`**
Always run `~/.config/emacs/bin/doom sync` and restart Emacs.

**General diagnostics**
`~/.config/emacs/bin/doom doctor`

---

## Aliases (add to `~/.zshrc`)

```bash
alias ds='~/.config/emacs/bin/doom sync && echo "doom sync done"'
alias dsu='~/.config/emacs/bin/doom sync -u && echo "doom sync + upgrade done"'
alias dd='~/.config/emacs/bin/doom doctor'
```
