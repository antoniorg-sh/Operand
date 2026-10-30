;;; init.el -*- lexical-binding: t; -*-

(doom! :input
       ;;bidi
       ;;chinese
       ;;japanese
       ;;layout

       :completion
       company
       ;;(corfu +orderless)
       ;;helm
       ;;ido
       ;;ivy
       vertico

       :ui
       ;;deft
       doom
       doom-dashboard
       ;;doom-quit
       ;;(emoji +unicode)
       hl-todo
       ;;indent-guides
       ;;ligatures
       ;;minimap
       modeline
       ;;nav-flash
       ;;neotree
       ophints
       (popup +defaults)
       ;;tabs
       ;;treemacs
       ;;unicode
       (vc-gutter +pretty)
       vi-tilde-fringe
       ;;window-select
       workspaces
       zen

       :editor
       (evil +everywhere)
       ;;file-templates
       ;;fold
       ;;(format +onsave)
       ;;god
       ;;lispy
       ;;multiple-cursors
       ;;objed
       ;;parinfer
       ;;rotate-text
       snippets
       word-wrap

       :emacs
       dired
       ;;electric
       ;;eww
       ;;ibuffer
       undo
       vc

       :term
       ;;eshell
       ;;shell
       ;;term
       vterm

       :checkers
       syntax
       (spell +flyspell +aspell)
       grammar

       :tools
       ;;ansible
       ;;biblio
       ;;collab
       ;;debugger
       ;;direnv
       ;;docker
       ;;editorconfig
       ;;ein
       (eval +overlay)
       (lookup +dictionary)
       (lsp +eglot) 
       ;magit
       ;;make
       ;;pass
       pdf
       ;;prodigy
       terraform
       ;;tmux
       ;;tree-sitter
       ;;upload

       :os
       (:if (featurep :system 'macos) macos)
       ;;tty

       :lang
       ;;agda
       ;;beancount
       (cc +lsp)
       ;;clojure
       ;;common-lisp
       ;;coq
       ;;crystal
       ;;csharp
       ;;data
       ;;(dart +flutter)
       ;;dhall
       ;;elixir
       ;;elm
       emacs-lisp
       ;;erlang
       ;;ess
       ;;factor
       ;;faust
       ;;fortran
       ;;fsharp
       ;;fstar
       ;;gdscript
       (go +lsp)
       ;;(graphql +lsp)
       ;;(haskell +lsp)
       ;;hy
       ;;idris
       json
       ;;(java +lsp)
       ;;(javascript +lsp)
       ;;julia
       ;;kotlin
       ;;latex
       ;;lean
       ;;ledger
       ;;lua
       markdown
       ;;nim
       ;;nix
       ;;ocaml
       (org +roam2)
       ;;php
       ;;plantuml
       ;;graphviz
       ;;purescript
       (python +lsp +pyright)
       ;;qt
       ;;racket
       ;;raku
       rest
       ;;rst
       ;;(ruby +rails)
       ;;(rust +lsp)
       ;;scala
       ;;(scheme +guile)
       sh
       ;;sml
       ;;solidity
       ;;swift
       ;;terra
       ;;(web +lsp)
       yaml
       ;;zig

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       calendar
       ;;emms
       ;;everywhere
       irc
       (rss +org)

       :config
       ;;(literate +org)
       (default +bindings +smartparens))
