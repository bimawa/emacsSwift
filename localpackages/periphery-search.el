;;; Periphery-search --- Search using Ag/Rg and show the result as flycheck list.  -*- lexical-binding: t; -*-

;;; Commentary: Package for showing search as result in a tabulated list

;;; Code:
(require 'periphery-helper)
(require 'periphery)
(require 'thingatpt)

(defvar current-query "")
(defvar current-title "Search")

(defun send-search-result-to-periphery (text)
  "Send result (as TEXT) to periphery."
   (periphery-parse-search-result :title current-title :text text :query current-query))

(defun setup-search-title ()
  "Default search title."
  (setq current-title "Search"))

(defun periphery--search-thing-at-point (searcher)
  "Search thing at point using (SEARCHER)."
  (if (use-region-p)
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (when (> (length text) 1)
          (periphery-run-query searcher (escape-string text))))
    (periphery-run-query searcher (thing-at-point 'symbol) "--sort path")))

(defun escape-string (text)
  "Escape string."
  (setq str (replace-regexp-in-string "\{" "\\\\{" text))
  (setq str (replace-regexp-in-string "\}" "\\\\}" str))
  (setq str (replace-regexp-in-string "\(" "\\\\(" str))
  (setq str (replace-regexp-in-string "\)" "\\\\)" str))
  str
  )

(defun periphery-run-query (searcher text &optional args)
  "Search using (SEARCHER) with (TEXT)."
  (setq current-query nil)
  (if (executable-find "rg")
      (progn
        (let ((default-directory (vc-root-dir)))
          (setq current-query (regexp-quote text))
          (message-with-color :tag "[SEARCHING]" :text (format "for %s" current-query) :attributes 'warning)
          (async-shell-command-to-string
           :process-name searcher
           :command (format "%s \"%s\" --vimgrep " searcher current-query)
           :callback #'send-search-result-to-periphery)))
    (message-with-color :tag "[FAILED]" :text (format "Install %s to use this command." searcher) :attributes 'warning)))

(defun periphery--search-for (searcher)
  "Search using (as SEARCHER)."
  (setup-search-title)
  (periphery-run-query searcher (read-string "Query: ")))

;;;###autoload
(defun periphery-search-rg ()
  "Search using RG (Ripgrep)."
  (interactive)
  (setup-search-title)
  (periphery--search-for "rg -w"))

;;;###autoload
(defun periphery-search-ag ()
  "Search using AG (The Silver Searcher)."
  (interactive)
  (setup-search-title)
  (periphery--search-for "ag"))

;;;###autoload
(defun periphery-query-todos-and-fixmes ()
  "Query todos and fixmes in the project."
  (interactive)
  (setq current-title "Fixme and todos")
  (periphery-run-query "rg -w" "(FIX|FIXME|TODO|NOTE|HACK|PERF)" "--sort path"))

;;;###autoload
(defun periphery-query-marks ()
  "Query marks in the project."
  (interactive)
  (setq current-title "Marks")
  (periphery-run-query "rg -w" "\'MARK' --sort path"))

;;;###autoload
(defun periphery-search-dwiw-ag ()
  "Search using ag (Silver searcher)."
  (interactive)
  (setup-search-title)
  (periphery--search-thing-at-point "ag"))

;;;###autoload
(defun periphery-search-dwiw-rg ()
  "Search using rg (ripgrep)."
  (interactive)
  (setup-search-title)
  (periphery--search-thing-at-point "rg -e"))

(provide 'periphery-search)
;;; periphery-search.el ends here.

