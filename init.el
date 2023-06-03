(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq-default straight-use-package-by-default t
              package-enable-at-startup nil)

(setq dired-use-ls-dired nil)

(setq backup-directory-alist '(("." . "~/.emacs.d/backup")))

(setq-default inhibit-startup-screen t
              tab-width 4
              line-spacing 0.1
              display-line-numbers-width 5
              require-final-newline 'visit-save)

(column-number-mode 1)

(display-time-mode 1)
(setq display-time-24hr-format 1)
(setq display-time-day-and-date 1)

(fset 'yes-or-no-p 'y-or-n-p)
(global-hl-line-mode 1)
(show-paren-mode 1)

(menu-bar-mode t)
(scroll-bar-mode -1)
(tool-bar-mode -1)

(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

(setq mac-command-modifier 'control)

(when (>= emacs-major-version 29)
  (pixel-scroll-precision-mode))

(use-package exec-path-from-shell
  :straight (:host github :repo "purcell/exec-path-from-shell")
  :config
  (exec-path-from-shell-initialize))

(use-package move-lines
  :straight (:host github :repo "targzeta/move-lines")
  :config
  (move-lines-binding))

;; Themes

;; Font and ligatures

(set-face-attribute 'default nil
                    :family "JetBrains Mono" :height 125 :weight 'normal)

(use-package ligature
  :config
  (ligature-set-ligatures 'prog-mode '("==" "===" "!=" "->" "-->" "++" "***" "||" ">=" "<=" "!==" "//" "/*" "*/" ";;"
                                       ">>" "<<" ">>>" "<<<" "=>" "==>" "#:" "#!" "#=" "[|" "|]" "{|" "|}" "..." ".."
                                       "::" ":::" ":=" "///" "/=" "/==" "//=" "??" "???" "!!" "!!!" "&&" "&&&" "&="
                                       "<$" ">:" "<=>" ";;;" ";;;;" "__" "___" "<-"))
  (global-ligature-mode 't))

(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italics t)
  :config
  (load-theme 'doom-monokai-ristretto t))

(use-package nyan-mode)


(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-auto-odd-face-perc 100)
  (highlight-indent-guides-auto-even-face-perc 100)
  (highlight-indent-guides-auto-character-face-perc 100)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-method 'character))

(use-package xterm-color
  :config
  (setq comint-output-filter-functions
        (remove 'ansi-color-process-output comint-output-filter-functions))
  (add-hook 'shell-mode-hook (lambda ()
                               (font-lock-mode -1)
                               (setq-local font-lock-function (lambda (_) nil))
                               (add-hook 'comint-preoutput-filter-functions 'xterm-color-filter nil t)))
  (setq compilation-environment '("TERM=xterm-256color"))
  (advice-add 'compilation-filter :around (lambda (f proc string)
                                            (funcall f proc (xterm-color-filter string)))))

(global-unset-key (kbd "<C-mouse-4>"))
(global-unset-key (kbd "<C-mouse-5>"))

;; Project setup

(use-package which-key
  :config
  (which-key-setup-side-window-bottom)
  (which-key-mode))

(use-package swiper
  :bind (("C-s" . swiper-isearch)))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file))
  :config
  (counsel-mode))

(use-package ivy
  :defer 0
  :diminish
  :after (counsel swiper)
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "(%d/%d)")
  :bind (("C-x b" . ivy-switch-buffer)
         ("C-c v" . ivy-push-view)
         ("C-c V" . ivy-pop-view))
  :config
  (ivy-mode))

(use-package projectile
  :defer 0
  :after ivy
  :custom
  (projectile-complete-system 'ivy)
  (projectile-indexing-method 'hybrid)
  :config
  (projectile-mode +1)
  :bind-keymap ("C-c p" . projectile-command-map))

(use-package magit)

(use-package elcord)

(use-package auth-source
  :custom
  (auth-sources '((:source "~/.authinfo")))
  :config
  (auth-source-pass-enable))

;; Language servers

(use-package yasnippet-snippets)
(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))

(use-package company
  :hook ((prog-mode text-mode) . company-mode)
  :bind (:map company-active-map
              ("<return>" . nil)
              ("RET" . nil)
              ("M-n" . company-select-next)
              ("M-p" . company-select-previous)
              ("C-n" . nil)
              ("C-p" . nil))
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 1)
  (company-dabbrev-downcase 0)
  (company-selection-wrap-around t)
  ;; (company-backends '((company-capf :with company-yasnippet)))
  :config
  (company-tng-configure-default))

(use-package company-box
  :hook (company-mode . company-box-mode))

(setq gc-cons-threshold 1600000)
(setq read-process-output-max (* 1024 1024))
(use-package eglot
  :ensure t
  :commands eglot eglot-mode eglot-ensure
  :hook ((c-mode c++-mode cmake-mode tuareg-mode haskell-mode vhdl-mode) eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-workspace-configuration
   '((haskell (plugin (stan (globalOn . :json-false))))))
  :config

  (add-to-list 'eglot-server-programs
               '(vhdl-mode . ("ghdl-ls")))
  (add-to-list 'eglot-server-programs
               '(tuareg-mode . ("ocamllsp" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(python-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((c++-mode c-mode) . ("/usr/local/opt/llvm@16/bin/clangd"
                                      "--clang-tidy"
                                      "-j=4"
                                      "--header-insertion=never"
                                      "--query-driver=/Users/aleksandrpokatilov/.espressif/**/xtensa-esp32-elf-*" "--query-driver=/usr/local/bin/avr-gcc")))
  (add-to-list 'eglot-server-programs
             '(haskell-mode . ("haskell-language-server-wrapper" "lsp")))
  (add-to-list 'eglot-server-programs
               '(cmake-mode . ("cmake-language-server")))
  (add-to-list 'eglot-server-programs
               '(rust-mode . ("rust-analyzer" "--parallel"))))

(use-package flymake
  :config
  (define-key flymake-mode-map (kbd "C-c d n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-c d p") 'flymake-goto-prev-error)
  (define-key flymake-mode-map (kbd "C-c d s") 'flymake-show-project-diagnostics))

;; C/C++

(setq-default
 c-default-style "k&r"
 c-basic-offset 4
 indent-tabs-mode nil)

(setq-default
 c++-default-style "k&r"
 c++-basic-offset 4
 indent-tabs-mode nil)

;; Cmake

(use-package cmake-mode
  :after eglot
  :hook (cmake-mode . eglot-ensure)
  :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))

;; Python

(use-package pyvenv)

(use-package auto-virtualenv
  :hook (python-mode . auto-virtualenv-set-virtualenv))
  

;; (use-package python)

;; OCaml

(use-package tuareg
  :hook ((tuareg-mode tuareg-interactive-mode) . eglot-ensure)
  :custom
  (tuareg-match-patterns-aligned t))

;; Haskell

(use-package haskell-mode
  :after eglot
  :hook (haskell-mode . eglot-ensure))

;; Markdown

(use-package markdown-mode
  :custom
  (markdown-command '("pandoc" "--from=markdown" "--to=pdf" "--standalone"))
  (markdown-command-needs-filename t))

;; YAML

(use-package yaml-mode)

;; Device tree

(use-package dts-mode)

;; AI-tools

(use-package gptel)

(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :bind (:map copilot-mode-map
              ("C-c C-g" . copilot-accept-completion)))

;; Custom

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(connection-local-criteria-alist
   '(((:application tramp :machine "MacBook1.local")
      tramp-connection-local-darwin-ps-profile)
     ((:application tramp :machine "localhost")
      tramp-connection-local-darwin-ps-profile)
     ((:application tramp :machine "145-76-251-51.wifi.saxion.nl")
      tramp-connection-local-darwin-ps-profile)
     ((:application tramp)
      tramp-connection-local-default-system-profile tramp-connection-local-default-shell-profile)
     ((:application eshell)
      eshell-connection-default-profile)))
 '(connection-local-profile-alist
   '((tramp-connection-local-darwin-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o" "pid,uid,user,gid,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "state=abcde" "-o" "ppid,pgid,sess,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etime,pcpu,pmem,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (euid . number)
       (user . string)
       (egid . number)
       (comm . 52)
       (state . 5)
       (ppid . number)
       (pgrp . number)
       (sess . number)
       (ttname . string)
       (tpgid . number)
       (minflt . number)
       (majflt . number)
       (time . tramp-ps-time)
       (pri . number)
       (nice . number)
       (vsize . number)
       (rss . number)
       (etime . tramp-ps-time)
       (pcpu . number)
       (pmem . number)
       (args)))
     (tramp-connection-local-busybox-ps-profile
      (tramp-process-attributes-ps-args "-o" "pid,user,group,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "stat=abcde" "-o" "ppid,pgid,tty,time,nice,etime,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (user . string)
       (group . string)
       (comm . 52)
       (state . 5)
       (ppid . number)
       (pgrp . number)
       (ttname . string)
       (time . tramp-ps-time)
       (nice . number)
       (etime . tramp-ps-time)
       (args)))
     (tramp-connection-local-bsd-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o" "pid,euid,user,egid,egroup,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "state,ppid,pgid,sid,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etimes,pcpu,pmem,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (euid . number)
       (user . string)
       (egid . number)
       (group . string)
       (comm . 52)
       (state . string)
       (ppid . number)
       (pgrp . number)
       (sess . number)
       (ttname . string)
       (tpgid . number)
       (minflt . number)
       (majflt . number)
       (time . tramp-ps-time)
       (pri . number)
       (nice . number)
       (vsize . number)
       (rss . number)
       (etime . number)
       (pcpu . number)
       (pmem . number)
       (args)))
     (tramp-connection-local-default-shell-profile
      (shell-file-name . "/bin/sh")
      (shell-command-switch . "-c"))
     (tramp-connection-local-default-system-profile
      (path-separator . ":")
      (null-device . "/dev/null"))
     (eshell-connection-default-profile
      (eshell-path-env-list))))
 '(custom-safe-themes
   '("eca44f32ae038d7a50ce9c00693b8986f4ab625d5f2b4485e20f22c47f2634ae" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "c4cecd97a6b30d129971302fd8298c2ff56189db0a94570e7238bc95f9389cfb" default))
 '(package-selected-packages
   '(company-box gptel auto-virtualenv pyvenv yaml-mode markdown-mode exec-path-from-shell haskell-mode tuareg yasnippet-snippets nyan-mode which-key elcord projectile treemacs yasnippet plantuml-mode cmake-mode python-mode magit use-package doom-themes rust-mode multiple-cursors move-text))
 '(safe-local-variable-values
   '((eval eshell-command ". /Users/aleksandrpokatilov/.esp/esp-idf/export.sh")))
 '(warning-suppress-types '((use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(put 'narrow-to-region 'disabled nil)
