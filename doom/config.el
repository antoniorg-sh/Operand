(setq
 doom-font (font-spec :family "MonoLisa Nerd Font" :size 19 :weight 'semibold)
 doom-variable-pitch-font (font-spec :family "MonoLisa Nerd Font" :size 19 :weight 'bold))

(setq doom-theme 'doom-dark+)

(setq display-line-numbers-type t)

(setq org-directory "~/brain/")


(remove-hook 'dired-mode-hook #'dired-omit-mode)
(set-face-attribute 'default nil :background "#000000")
(set-frame-parameter nil 'alpha-background 80)
(add-to-list 'default-frame-alist '(alpha-background . 80))

(defun +doom-dashboard-ascii-banner-fn ()
  (let ((banner
                                '("                _____                      _            _     "
                                  "               /  ___|                    | |          | |    "
                                  "               \\ `--.  ___   ___ _ __ __ _| |_ ___  ___| |__  "
                                  "                `--. \\/ _ \\ / __| '__/ _` | __/ _ \\/ __| '_ \\ "
                                  "               /\\__/ / (_) | (__| | | (_| | ||  __/ (__| | | |"
                                  "               \\____/ \\___/ \\___|_|  \\__,_|\\__\\___|\\___|_| |_|"
                                  "\n"
                                  "                                  socratech.sh                  "
                                  "\n")))
    (dolist (line banner)
      (insert line "\n"))))

(setq +doom-dashboard-ascii-banner-fn #'+doom-dashboard-ascii-banner-fn)

;; Agenda scans DIRECTORIES NON-RECURSIVELY — a bare "~/brain/" only picked up
;; TODOS.org and INDEX.org, so any task written in plans/, ventures/, journal/
;; or tracking/ was silently invisible. Each folder must be listed explicitly.
(after! org
  (setq org-agenda-files '("~/brain/"
                           "~/brain/plans/"
                           "~/brain/ventures/"
                           "~/brain/journal/"
                           "~/brain/tracking/"))
  ;; Streak graph for habits (the daily-practice TODO uses :STYLE: habit).
  (add-to-list 'org-modules 'org-habit))

;; SPC X t used to capture into ~/brain/todo.org — a second, competing task
;; file. Point it at the real one.
(setq +org-capture-todo-file "TODOS.org")

(after! org
  ;; Without org-log-done you know a task is DONE but not WHEN — which is
  ;; exactly what habit streaks and any "did I actually practice daily?"
  ;; question need to read.
  (setq org-log-done 'time
        org-log-into-drawer t          ; keep the log noise folded away
        org-habit-graph-column 60      ; where the streak graph starts
        org-agenda-start-on-weekday 1  ; weeks begin Monday
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t))

;; Spelling: aspell with both dictionaries. F12 swaps language mid-buffer for
;; the Spanish writing (language/palabras_para_la_abuela.org and journal).
(after! ispell
  (setq ispell-program-name "aspell"
        ispell-dictionary "en_US"
        ispell-personal-dictionary (expand-file-name "~/.aspell.en.pws")))

(defun +my/toggle-dictionary ()
  "Switch between English and Spanish spell checking."
  (interactive)
  (require 'ispell)
  (let ((next (if (string= (or ispell-local-dictionary ispell-dictionary) "en_US")
                  "es" "en_US")))
    (ispell-change-dictionary next)
    (when (bound-and-true-p flyspell-mode) (flyspell-buffer))
    (message "Dictionary: %s" next)))

(map! :leader :desc "Toggle spell dictionary" "t d" #'+my/toggle-dictionary)

;; Grammar: LanguageTool runs fully offline from the local Arch package
;; (/usr/bin/languagetool). Nothing is uploaded.
(after! langtool
  (setq langtool-default-language "en-US"))


(after! org-roam
  (setq org-roam-directory "~/brain")
        (setq org-roam-capture-templates
                '(("d" "default" plain
                "
* %<%d-%m-%Y> Protocol
        :PROPERTIES:
        :ID:             %(org-id-new)
        :SLEEP_HOURS:    %^{Sleep Hours}
        :SLEEP_QUAL:     %^{Sleep Quality (1-10)}
        :MOOD:           %^{Mood (1-10)}
        :ENERGY:         %^{Energy (1-10)}
        :WEIGHT:         %^{Weight (kg)|0}
        :WAIST SIZE:     %^{Waist size (cm)|0}
        :FAT:            %^{Fat (g)|0}
        :PROTEIN:        %^{Protein (g)|0}
        :CARBS:          %^{Carbohydrates (g)|0}
        :STEPS:          %^{Steps |0}
        :CARDIO_MINS:    %^{Cardio Mins|0}
        :STRENGTH_MINS:  %^{Strength Mins|0}
        :EXPENSE_TOTAL:  %^{Total Expenses ($)|0}
        :END:

** Sleep Analysis
/Dreams, wake up time, grogginess./
- %?

** Training Log
/Specific lifts, zones, or perceived exertion./
-

** The Lexicon (New Vocabulary)
:PROPERTIES:
:CATEGORY: Learning
:END:
-

** Engineering & Work Tasks
:PROPERTIES:
:CATEGORY: Work
:END:
*** Priorities (The 'Must Dos')
- [ ]

** Things I want to learn (Log)
/What do I want to research?/
-

** Financial Ledger
/Update the :EXPENSE_TOTAL: property after filling this./
| Item Description | Category | Cost ($) |
|------------------+----------+----------|
|                  |          |          |
|------------------+----------+----------|
| *Total* |           |      |
#+TBLFM: @>$3=vsum(@2$3..@-1$3)


** Things I want to remember 
:PROPERTIES:
:CATEGORY: Memories
:END:
-

** Closing Reflection
/Synthesis of the day./"
                :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n#+filetags: :protocol:\n")
                :unnarrowed t))))

(after! org-capture
  (set-popup-rule! "^CAPTURE" :actions '(display-buffer-same-window) :select t :quit nil))


(after! elfeed-org
  (setq rmh-elfeed-org-files '("~/brain/reference/rss.org"))
  (elfeed-org))

(after! elfeed
  (setq elfeed-search-filter "@2-weeks-ago +unread"
        elfeed-search-title-max-width 100
        elfeed-search-title-min-width 30))

(after! org
  (add-to-list 'org-capture-templates
               '("r" "Capture from elfeed" entry
                 (file+headline "~/brain/reference/reading-inbox.org" "Inbox")
                 "* TODO Read: %:elfeed-entry-title\n  Source: %:elfeed-entry-link\n  Tags: %:elfeed-entry-tags\n  Captured: %U\n"
                 :empty-lines 1)))


