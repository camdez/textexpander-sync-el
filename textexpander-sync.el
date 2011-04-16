;;; textexpander-sync.el --- A utility to import textexpander entries into abbrev-mode

;; Copyright (C) 2009  Ted Roden <tedroden@gmail.com>

;; Author: Ted Roden <tedroden@gmail.com>
;; Author: Cameron Desautels <camdez@gmail.com>

;; This file is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation; either version 2, or (at your option) any
;; later version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.

;;; Instructions:

;; 1) Assuming that you have TextExpander set up
;; 2) put this file and osx-plist.el in your lisp dir
;; 3) add to .emacs:
;;   (require 'textexpander-sync)
;; 4) sync (and resync) via: M-x textexpander-sync
;; 5) In TextExpander settings set "Expand In" to
;;    "all applications except" Emacs
;;
;; This code requires a modified version of osx-plist which is available here:
;;   https://github.com/camdez/textexpander-sync-el/blob/master/osx-plist.el
;;


;;; Code:

(require 'osx-plist)

(defvar textexpander-sync-file "~/Library/Application Support/TextExpander/Settings.textexpander"
  "Path to your TextExpander settings file.")

(defconst textexpander-snippet-type-plaintext   0)
(defconst textexpander-snippet-type-richtext    1)
(defconst textexpander-snippet-type-applescript 2)
(defconst textexpander-snippet-type-shellscript 3)

(defun textexpander-sync ()
  "Import TextExpander snippets."
  (interactive)
  (mapc (lambda (snippet)
          (let ((abbrev (gethash "abbreviation" snippet))
                (expansion (gethash "plainText" snippet))
                (type (gethash "snippetType" snippet)))
            (cond ((= type textexpander-snippet-type-plaintext)
                   (define-abbrev global-abbrev-table abbrev expansion))
                  ((= type textexpander-snippet-type-applescript)
                   (define-abbrev global-abbrev-table abbrev t
                     `(lambda ()
                        (backward-delete-char ,(length abbrev))
                        (insert (do-applescript ,expansion)))))
                  ((= type textexpander-snippet-type-shellscript)
                   (define-abbrev global-abbrev-table abbrev t
                     `(lambda ()
                        (backward-delete-char ,(length abbrev))
                        (insert (shell-command-to-string ,expansion))))))))
        (gethash "snippetsTE2" (osx-plist-parse-file textexpander-sync-file))))

(provide 'textexpander-sync)
