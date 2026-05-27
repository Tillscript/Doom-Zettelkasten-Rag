;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "vampetacorneta"
      user-mail-address "your@email.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. Theme set later (gruvbox section).

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;;; =====================================================================
;;; 0. DEPENDÊNCIAS ESSENCIAIS
;;; =====================================================================
(require 'json)
(require 'seq)
(require 'subr-x) ;; Garante string-trim, string-join e string-empty-p

;;; =====================================================================
;;; 1. ORG + ORG-ROAM (Configurações e Captura)
;;; =====================================================================
(setq org-directory "~/Documents/Org")
(setq org-roam-directory (file-truename "~/Documents/Org/notas/"))

;; Agenda — inclui subpastas automaticamente (lazy: só após org carregar)
(after! org
  (setq org-agenda-files
        (append
         (directory-files-recursively "~/Documents/Org/agenda/" "\\.org$")
         (directory-files-recursively "~/Documents/Org/inbox/" "\\.org$")
         (directory-files-recursively "~/Documents/Org/notas/" "\\.org$"))))

;; Desliga warning do cache do org-element (bug conhecido, inofensivo)
(after! org
  (setq org-element-use-cache nil))

;; Org-capture templates
(after! org-capture
  (setq org-capture-templates
        '(("b" "Nota Diária Blockchain" entry
           (file (lambda ()
                   (let* ((dir (format-time-string "~/Documents/Org/agenda/Blockchains-daily-%B/"))
                          (file (format-time-string (concat dir "Blockchain-%d-%m-%y.org"))))
                     (unless (file-directory-p dir)
                       (make-directory dir t))
                     file)))
           "* %<%A, %d de %B de %Y>\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n%(with-temp-buffer\n    (insert-file-contents (expand-file-name \"~/Documents/Org/templates/daily-progressive.orgt\"))\n    (buffer-string))")
          ("i" "Inbox (Caixa de Entrada)" entry
           (file+headline "~/Documents/Org/inbox/capturas.org" "Tarefas e Ideias")
           "* TODO %?\n  %U"))))

;; Org-roam configuration
(use-package! org-roam
  :after org
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("p" "Programação" plain "* ${title}\n\n%?"
      :if-new (file+head "programacao/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("f" "Filosofia" plain "* ${title}\n\n%?"
      :if-new (file+head "filosofia/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("s" "Psicologia" plain "* ${title}\n\n%?"
      :if-new (file+head "psicologia/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("l" "Livros" plain "* ${title}\n\n%?"
      :if-new (file+head "livros/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("o" "Segurança-cibernética" plain "* ${title}\n\n%?"
      :if-new (file+head "Segurança-cibernética/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("v" "Vídeos" plain "* ${title}\n\n%?"
      :if-new (file+head "videos/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("e" "Economia" plain "* ${title}\n\n%?"
      :if-new (file+head "economia/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
 ("g" "Genkidama" plain "* ${title}\n\n%?"
      :if-new (file+head "genki/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("d" "Default" plain "* ${title}\n\n%?"
      :if-new (file+head "${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)))
  :config
  (org-roam-db-autosync-mode)
  (defun my/org-roam--set-tags-from-path ()
    "Atribui tags com base na subpasta onde a nota foi criada."
    (when-let* ((fname (buffer-file-name))
                (dir (file-name-nondirectory
                      (directory-file-name (file-name-directory fname)))))
      (if (fboundp 'org-roam-tag-add)
          (org-roam-tag-add (list dir))
        (when (fboundp 'org-roam-set-tag)
          (org-roam-set-tag (list dir))))))
  (add-hook 'org-roam-after-creation-hook #'my/org-roam--set-tags-from-path))

;; Org-roam UI
(use-package! org-roam-ui
  :after org-roam
  :hook (org-roam-mode . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

;; Org-roam Keybindings
(map! :leader
      (:prefix ("n r" . "org-roam")
       :desc "Org-roam Capture" "c" #'org-roam-capture
       :desc "Find node"        "f" #'org-roam-node-find
       :desc "Insert node"      "i" #'org-roam-node-insert
       :desc "Open graph"       "g" #'org-roam-graph))

;;; =====================================================================
;;; 2. GPTEL + RAG + INLINE EDIT (Configuração IA - BLINDADA)
;;; =====================================================================

;; --- Configuração do Backend (Groq) ---
(use-package! gptel
  :config
  (let ((key-file (expand-file-name ".groqapi" doom-user-dir)))
    (if (file-exists-p key-file)
        (setq gptel-api-key
              (string-trim (with-temp-buffer (insert-file-contents key-file) (buffer-string))))
      (message "AVISO: Arquivo .groqapi não encontrado! A IA não funcionará.")))
  
  (setq gptel-backend
        (gptel-make-openai "groq"
                           :host "api.groq.com"
                           :protocol "https"
                           :endpoint "/openai/v1/chat/completions"
                           :stream t
                           :key gptel-api-key
                           :models '(llama-3.3-70b-versatile
                                     llama-3.1-8b-instant
                                     gemma2-9b-it)))
  
  ;; Símbolo correto (sem aspas)
  (setq gptel-model 'llama-3.3-70b-versatile))

;; --- Variáveis de Embeddings ---
(defvar my/gptel-embedding-index (make-hash-table :test 'equal)
  "Índice vetorial.")

(defvar my/gptel-embedding-top-k 10
  "Quantidade de chunks.")

(defvar my/gptel-embedding-chunk-size 1500
  "Tamanho máximo dos chunks.")

(defvar my/gptel-embeddings-script
  (expand-file-name "embeddings_local.py" doom-user-dir)
  "Caminho do script Python.")

(defvar my/gptel-python-command
  (expand-file-name ".venv/bin/python" doom-user-dir)
  "Caminho do Python.")

;; --- Funções Auxiliares ---
(defun my/gptel--compute-embedding (text)
  "Gera embedding via call-process. Limpa temp files mesmo em erro."
  (let ((input-file  (make-temp-file "emb-in-"  nil ".txt" text))
        (output-file (make-temp-file "emb-out-" nil ".json")))
    (unwind-protect
        (let ((exit-code (let ((inhibit-message t))
                           (call-process my/gptel-python-command nil nil nil
                                         my/gptel-embeddings-script
                                         input-file output-file))))
          (when (and (eq exit-code 0) (file-exists-p output-file))
            (with-temp-buffer
              (insert-file-contents output-file)
              (let ((parsed (json-parse-string (buffer-string) :array-type 'list)))
                (apply 'vector (mapcar #'float parsed))))))
      (ignore-errors (delete-file input-file))
      (ignore-errors (delete-file output-file)))))

;; --- Persistência do índice ---
(defvar my/gptel-embedding-cache-file
  (expand-file-name "gptel-index.eld"
                    (or (bound-and-true-p doom-cache-dir)
                        "~/.cache/doom/"))
  "Onde persistir o índice de embeddings entre sessões.")

(defun my/gptel-save-index ()
  "Serializa my/gptel-embedding-index em disco."
  (interactive)
  (make-directory (file-name-directory my/gptel-embedding-cache-file) t)
  (with-temp-file my/gptel-embedding-cache-file
    (let ((print-length nil) (print-level nil))
      (prin1 (let (acc)
               (maphash (lambda (k v) (push (cons k v) acc))
                        my/gptel-embedding-index)
               acc)
             (current-buffer))))
  (message "💾 Índice salvo (%d arquivos)."
           (hash-table-count my/gptel-embedding-index)))

(defun my/gptel-load-index ()
  "Carrega índice serializado, se existir."
  (interactive)
  (when (file-exists-p my/gptel-embedding-cache-file)
    (with-temp-buffer
      (insert-file-contents my/gptel-embedding-cache-file)
      (goto-char (point-min))
      (let ((alist (ignore-errors (read (current-buffer)))))
        (when (listp alist)
          (clrhash my/gptel-embedding-index)
          (dolist (cell alist)
            (puthash (car cell) (cdr cell) my/gptel-embedding-index))
          (message "📂 Índice carregado (%d arquivos)."
                   (hash-table-count my/gptel-embedding-index)))))))

;; Auto-load no startup (lazy, depois de idle)
(run-with-idle-timer 2 nil #'my/gptel-load-index)

(defvar my/gptel-embedding-chunk-overlap 200
  "Caracteres de sobreposição entre chunks vizinhos.")

(defun my/gptel--chunk-text (text)
  "Quebra TEXT em parágrafos (\\n\\n), juntando até chunk-size sem cortar
frase no meio, com overlap entre chunks vizinhos."
  (let* ((paras (split-string text "\n\n+" t))
         (chunks nil)
         (cur ""))
    (dolist (p paras)
      (if (> (+ (length cur) (length p) 2) my/gptel-embedding-chunk-size)
          (progn
            (when (> (length cur) 0) (push cur chunks))
            ;; overlap: carrega o final do chunk anterior
            (let ((tail (if (> (length cur) my/gptel-embedding-chunk-overlap)
                            (substring cur (- (length cur) my/gptel-embedding-chunk-overlap))
                          cur)))
              (setq cur (concat tail "\n\n" p))))
        (setq cur (if (string-empty-p cur) p (concat cur "\n\n" p)))))
    (when (> (length cur) 0) (push cur chunks))
    (nreverse chunks)))

(defun my/gptel--cosine (v1 v2)
  (let ((dot 0.0) (n1 0.0) (n2 0.0))
    (dotimes (i (min (length v1) (length v2)))
      (setq dot (+ dot (* (aref v1 i) (aref v2 i))))
      (setq n1 (+ n1 (* (aref v1 i) (aref v1 i))))
      (setq n2 (+ n2 (* (aref v2 i) (aref v2 i)))))
    (if (or (= n1 0.0) (= n2 0.0)) 0.0 (/ dot (* (sqrt n1) (sqrt n2))))))

;; --- Embedding async (make-process + sentinel) ---
(defvar my/gptel-embedding-concurrency 4
  "Máximo de processos Python simultâneos durante indexação.")

(defun my/gptel--compute-embedding-async (text callback)
  "Computa embedding async. CALLBACK chamado com vector ou nil."
  (let* ((input-file  (make-temp-file "emb-in-"  nil ".txt" text))
         (output-file (make-temp-file "emb-out-" nil ".json"))
         (cleanup (lambda ()
                    (ignore-errors (delete-file input-file))
                    (ignore-errors (delete-file output-file)))))
    (condition-case err
        (make-process
         :name "gptel-emb"
         :noquery t
         :command (list my/gptel-python-command
                        my/gptel-embeddings-script
                        input-file output-file)
         :sentinel
         (lambda (proc _event)
           (when (memq (process-status proc) '(exit signal))
             (let ((vec (when (and (eq (process-exit-status proc) 0)
                                   (file-exists-p output-file))
                          (ignore-errors
                            (with-temp-buffer
                              (insert-file-contents output-file)
                              (let ((parsed (json-parse-string (buffer-string)
                                                               :array-type 'list)))
                                (apply 'vector (mapcar #'float parsed))))))))
               (funcall cleanup)
               (funcall callback vec)))))
      (error
       (funcall cleanup)
       (message "Erro embedding async: %s" err)
       (funcall callback nil)))))

;; --- Indexador async em lote (1 processo Python, modelo carregado 1x) ---
(defun my/gptel-index-roam-folder (dir)
  "Indexa notas async. Manda todos os chunks num único processo Python
para o modelo ser carregado apenas uma vez (em vez de 1x por chunk)."
  (interactive (list (read-directory-name "Pasta para indexar: " org-roam-directory)))
  (clrhash my/gptel-embedding-index)
  (let* ((files (directory-files-recursively dir "\\.org$"))
         (jobs '()))  ;; lista ordenada de (file . chunk)
    (dolist (f files)
      (with-temp-buffer
        (insert-file-contents f)
        (dolist (ch (my/gptel--chunk-text (buffer-string)))
          (push (cons f ch) jobs))))
    (setq jobs (nreverse jobs))
    (if (null jobs)
        (message "⚠️ Nenhum chunk para indexar em %s" dir)
      (let* ((total (length jobs))
             (input-file  (make-temp-file "emb-batch-in-"  nil ".json"
                                          (json-encode (mapcar #'cdr jobs))))
             (output-file (make-temp-file "emb-batch-out-" nil ".json"))
             (cleanup (lambda ()
                        (ignore-errors (delete-file input-file))
                        (ignore-errors (delete-file output-file)))))
        (message "🚀 Indexando %d arquivos / %d chunks (carregando modelo)..."
                 (length files) total)
        (make-process
         :name "gptel-emb-batch"
         :noquery t
         :command (list my/gptel-python-command
                        my/gptel-embeddings-script
                        input-file output-file)
         :sentinel
         (lambda (proc _event)
           (when (memq (process-status proc) '(exit signal))
             (unwind-protect
                 (if (and (eq (process-exit-status proc) 0)
                          (file-exists-p output-file))
                     (let ((vectors
                            (ignore-errors
                              (with-temp-buffer
                                (insert-file-contents output-file)
                                (json-parse-string (buffer-string)
                                                   :array-type 'list)))))
                       (if (and vectors (= (length vectors) total))
                           (progn
                             (cl-loop for job in jobs
                                      for vec in vectors
                                      do (let ((f  (car job))
                                               (ch (cdr job)))
                                           (puthash f
                                                    (cons (list :text ch
                                                                :embedding (apply 'vector (mapcar #'float vec)))
                                                          (gethash f my/gptel-embedding-index nil))
                                                    my/gptel-embedding-index)))
                             (message "✅ Indexação concluída! %d arquivos / %d chunks."
                                      (hash-table-count my/gptel-embedding-index) total)
                             (my/gptel-save-index))
                         (message "❌ Falha: resposta inválida do script de embeddings.")))
                   (message "❌ Falha na indexação (exit %d)."
                            (process-exit-status proc)))
               (funcall cleanup)))))))))

;; --- Busca Semântica ---
(defun my/gptel-semantic-search (query)
  (let* ((qvec (my/gptel--compute-embedding query))
         (results '()))
    (when qvec
      (maphash
       (lambda (file chunks)
         (dolist (item chunks)
           (let ((sim (my/gptel--cosine qvec (plist-get item :embedding))))
             (push (list :file file :text (plist-get item :text) :score sim) results))))
       my/gptel-embedding-index)
      (seq-take (sort results (lambda (a b) (> (plist-get a :score) (plist-get b :score))))
                my/gptel-embedding-top-k))))

;; --- COMANDO CORRIGIDO: RAG CHAT ---
(defun my/gptel-query-with-context (query)
  "Cria um buffer de chat, injeta o contexto e envia automaticamente."
  (interactive "sPergunta: ")
  (let* ((top (my/gptel-semantic-search query))
         (context (if (and top (listp top))
                      (string-join (mapcar (lambda (x) (format "--- [Nota: %s] ---\n%s" (file-name-nondirectory (plist-get x :file)) (plist-get x :text))) top) "\n\n")
                    "Nenhum contexto relevante encontrado."))
         (buffer-name "*GPTel RAG*"))
    
    ;; 1. Prepara o buffer de chat nativo do GPTel
    (with-current-buffer (get-buffer-create buffer-name)
      ;; CORREÇÃO CRÍTICA: Definir modo de texto ANTES do gptel-mode
      (markdown-mode)      
      (gptel-mode 1)       
      (visual-line-mode 1) 
      (erase-buffer)       
      
      ;; 2. Injeta o Prompt de Sistema + Contexto
      (insert "SYSTEM: Você é meu assistente pessoal de notas. Com base no contexto abaixo (trechos das minhas notas), responda e RESUMA o que for relevante à pergunta, citando as notas usadas. Se o contexto estiver vazio, diga que não encontrou a nota — mas se houver qualquer trecho relevante, sintetize-o, não recuse.\n\n")
      (insert "CONTEXTO ENCONTRADO:\n" context "\n\n")
      (insert "---------------------------------------------------\n")
      (insert "PERGUNTA: " query "\n\n")
      
      ;; 3. Coloca o cursor no final
      (goto-char (point-max)))
    
    ;; 4. Mostra o buffer e ENVIA
    (pop-to-buffer buffer-name)
    (message "🔍 Contexto injetado. Enviando para IA...")
    (gptel-send)))

;; --- Comando: Resumir nota inteira (todos os chunks dos arquivos relevantes) ---
(defun my/gptel-summarize-note (query)
  "Acha os arquivos mais relevantes via busca semântica e injeta TODOS os
chunks desses arquivos (não só os top-k soltos), para resumir um tópico."
  (interactive "sResumir o que escrevi sobre: ")
  (let* ((top (my/gptel-semantic-search query))
         (files (delete-dups (mapcar (lambda (x) (plist-get x :file)) top)))
         (context
          (if files
              (string-join
               (mapcar
                (lambda (f)
                  (let ((chunks (mapcar (lambda (it) (plist-get it :text))
                                        (gethash f my/gptel-embedding-index))))
                    (format "--- [Nota: %s] ---\n%s"
                            (file-name-nondirectory f)
                            (string-join (nreverse chunks) "\n\n"))))
                files)
               "\n\n")
            "Nenhuma nota relevante encontrada."))
         (buffer-name "*GPTel RAG*"))
    (with-current-buffer (get-buffer-create buffer-name)
      (markdown-mode)
      (gptel-mode 1)
      (visual-line-mode 1)
      (erase-buffer)
      (insert "SYSTEM: Você é meu assistente pessoal de notas. Resuma de forma organizada TUDO que está nas notas abaixo sobre o tema pedido, agrupando por ideia e citando as notas. Não recuse se houver conteúdo.\n\n")
      (insert "CONTEXTO (notas completas):\n" context "\n\n")
      (insert "---------------------------------------------------\n")
      (insert "TEMA: " query "\n\n")
      (goto-char (point-max)))
    (pop-to-buffer buffer-name)
    (message "🔍 Notas completas injetadas. Resumindo...")
    (gptel-send)))

;; --- Comando 2: Inline Edit Async ---
(defun my/gptel-inline-edit-async ()
  "Edição inline segura."
  (interactive)
  (let* ((orig-buf (current-buffer))
         (has-region (use-region-p))
         (start-marker (if has-region (copy-marker (region-beginning)) (point-marker)))
         (end-marker   (if has-region (copy-marker (region-end) t) (copy-marker start-marker t)))
         (selection    (when has-region (buffer-substring-no-properties start-marker end-marker)))
         (instr (read-string (if selection "Instruções: " "Gerar código: ")))
         (ctx (ignore-errors (my/gptel-semantic-search (or selection instr))))
         (context-text (if (and ctx (listp ctx))
                           (string-join (mapcar (lambda (x) (plist-get x :text)) ctx) "\n\n") ""))
         (prompt (concat (when (not (string-empty-p context-text)) (format "CONTEXT:\n%s\n\n" context-text))
                         (when selection (format "CODE:\n%s\n\n" selection))
                         (format "INSTRUCTION:\n%s" instr)))
         (system "You are an expert coder. Return ONLY raw code."))
    
    (message "🤖 Processando...")
    (gptel-request prompt :system system :callback
                   (lambda (response info)
                     (let ((resp-str (if (stringp response) response (format "%s" response))))
                       (when (buffer-live-p orig-buf)
                         (with-current-buffer orig-buf
                           (save-excursion
                             (goto-char start-marker)
                             (when has-region (delete-region start-marker end-marker))
                             (insert (string-trim resp-str))
                             (set-marker start-marker nil) (set-marker end-marker nil)
                             (message "✅ Pronto!")))))))))

;;; =====================================================================
;;; 3. KEYBINDINGS (IA MENU)
;;; =====================================================================
(map! :leader
      (:prefix ("i" . "IA / GPTel")
       :desc "Enviar prompt (GPTel)"          "l" #'gptel-send
       :desc "Indexar pasta do Org-roam"      "i" #'my/gptel-index-roam-folder
       :desc "Perguntar com contexto local"   "s" #'my/gptel-query-with-context
       :desc "Resumir nota inteira"           "r" #'my/gptel-summarize-note
       :desc "Inline edit (Cursor-style)"     "k" #'my/gptel-inline-edit-async
       
       ;; Sub-menu de Modelos
       (:prefix ("m" . "Modelos")
        :desc "Llama 3.3 70B"                  "3" (cmd! (setq gptel-model 'llama-3.3-70b-versatile) (message "Modelo: Llama 3.3 70B"))
        :desc "Llama 3.1 8B Instant"           "8" (cmd! (setq gptel-model 'llama-3.1-8b-instant) (message "Modelo: 8B Instant"))
        :desc "Gemma2 9B"                      "x" (cmd! (setq gptel-model 'gemma2-9b-it) (message "Modelo: Gemma2 9B")))))

;;; =====================================================================
;;; 4. ESTUDO: FLASHCARDS (org-fc) + POMODORO + NOTER + EPUB
;;; =====================================================================

;; --- org-fc: SRS estilo Anki dentro do org ---
(use-package! org-fc
  :after org
  :custom
  (org-fc-directories (list org-roam-directory
                            (file-truename "~/Documents/Org/flashcards/")))
  :config
  (require 'org-fc-hydra nil t)
  ;; evil shadows org-fc review keys (g/a/e/RET sao comandos evil).
  ;; Solucao: durante flip/rate/edit mode entra em emacs-state, assim
  ;; as teclas nativas do org-fc funcionam. Ao sair, volta a normal-state.
  (defun +org-fc-review-evil-state ()
    (if (or org-fc-review-flip-mode
            org-fc-review-rate-mode
            org-fc-review-edit-mode)
        (evil-emacs-state)
      (evil-normal-state)))
  (dolist (hook '(org-fc-review-flip-mode-hook
                  org-fc-review-rate-mode-hook
                  org-fc-review-edit-mode-hook))
    (add-hook hook #'+org-fc-review-evil-state))

  ;; Review por assunto especifico (tag ou pasta), nao tudo de uma vez.
  (defun +org-fc-review-tag (tag)
    "Revisa apenas cards com TAG (ex.: http, sql, calculo)."
    (interactive "sRevisar cards com a tag: ")
    (org-fc-review `(:paths all :filter (tag ,tag))))

  (defun +org-fc-review-dir (dir)
    "Revisa apenas cards dentro da pasta DIR."
    (interactive (list (read-directory-name "Revisar cards da pasta: "
                                            org-roam-directory)))
    (org-fc-review `(:paths ,(file-truename dir))))

  (defun +org-fc-review-tag-early (tag)
    "Revisa cards com TAG mesmo nao vencidos (estudo antecipado)."
    (interactive "sRevisar (antecipado) cards com a tag: ")
    (let ((org-fc-review-card-filters
           (remove #'org-fc-index-filter-due org-fc-review-card-filters)))
      (org-fc-review `(:paths all :filter (tag ,tag))))))

;; --- org-pomodoro: integra com org-clock ---
(use-package! org-pomodoro
  :after org
  :custom
  (org-pomodoro-length 25)
  (org-pomodoro-short-break-length 5)
  (org-pomodoro-long-break-length 20)
  (org-pomodoro-keep-killed-pomodoro-time t)
  (org-pomodoro-manual-break t))

;; --- spell: fixa pt_BR e nao trava se dicionario faltar ---
(after! ispell
  (setq ispell-program-name "aspell"
        ispell-dictionary "pt_BR")
  ;; aspell args: tolera unicode
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=pt_BR")))

;; se aspell ou dicionario pt_BR ausente, nao habilita flyspell
;; (evita loop "Error enabling Flyspell mode" ao abrir pomodoro/org)
(defun my/spell-available-p ()
  (and (executable-find "aspell")
       (ignore-errors
         (member "pt_BR" (split-string
                          (shell-command-to-string "aspell dump dicts"))))))

(unless (my/spell-available-p)
  (remove-hook 'org-mode-hook #'flyspell-mode)
  (remove-hook 'text-mode-hook #'flyspell-mode))

;; --- org-noter: PDF/EPUB lado a lado com notas org ---
(use-package! org-noter
  :defer t
  :custom
  (org-noter-notes-search-path (list (expand-file-name "noter/" org-directory)))
  (org-noter-always-create-frame nil)
  (org-noter-auto-save-last-location t)
  (org-noter-kill-frame-at-session-end nil))

;; --- nov.el: leitor EPUB ---
(use-package! nov
  :mode ("\\.epub\\'" . nov-mode)
  :config
  (setq nov-text-width 80))

;; --- Keybinds estudo (sem conflitar com SPC n r / SPC i) ---
;; Doom default liga SPC n F (browse-notes) e SPC n N (capture-goto) a comandos.
;; Desligar antes para poder usá-los como prefixos.
(map! :leader
      "n F" nil
      "n N" nil)

(map! :leader
      (:prefix ("n F" . "flashcards")
       :desc "Review (todos)"       "r" #'org-fc-review-all
       :desc "Review por tag"       "t" #'+org-fc-review-tag
       :desc "Review tag antecip."  "T" #'+org-fc-review-tag-early
       :desc "Review por pasta"     "p" #'+org-fc-review-dir
       :desc "Review buffer"        "b" #'org-fc-review-buffer
       :desc "Dashboard"            "d" #'org-fc-dashboard
       :desc "Card → normal"        "n" #'org-fc-type-normal-init
       :desc "Card → cloze"         "c" #'org-fc-type-cloze-init
       :desc "Card → double"        "D" #'org-fc-type-double-init
       :desc "Suspend card"         "s" #'org-fc-suspend-card
       :desc "Unsuspend card"       "u" #'org-fc-unsuspend-card)

      (:prefix ("n P" . "pomodoro")
       :desc "Start/toggle"         "p" #'org-pomodoro
       :desc "Kill pomodoro"        "k" (cmd! (org-pomodoro-kill)))

      (:prefix ("n N" . "noter")
       :desc "Start session"        "n" #'org-noter
       :desc "Insert note"          "i" #'org-noter-insert-note
       :desc "Kill session"         "k" #'org-noter-kill-session
       :desc "Sync page→note"       "s" #'org-noter-sync-current-page-or-chapter))

;; F12 global = toggle pomodoro (atalho fora do leader)
(map! "<f12>" #'org-pomodoro)

;;;=========================================================================
;;;TEMAS LEROLERO
;;;=========================================================================
(setq doom-theme 'doom-gruvbox)

;; Variante do gruvbox (muda MUITO o visual)
;; "soft"   -> mais cinza
;; "medium" -> amarelinho clássico (RECOMENDADO)
;; "hard"   -> contraste forte
(setq doom-gruvbox-dark-variant "medium")

;; Deixa comentários e modeline mais vivos
(setq doom-gruvbox-brighter-comments t
      doom-gruvbox-brighter-modeline t)

;; Garante que o tema seja aplicado corretamente
(after! doom-themes
  (load-theme 'doom-gruvbox t)

  ;; Melhor visual no Org-mode (headers, níveis, keywords)
  (doom-themes-org-config))

;;; --- FONTS -------------------------------------------------------------

;; Fonte monoespaçada (igual vibe do print)
(setq doom-font (font-spec :family "JetBrains Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "Cantarell" :size 15)
      doom-big-font (font-spec :family "JetBrains Mono" :size 18))
