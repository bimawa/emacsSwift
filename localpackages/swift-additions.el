;;; swift-additions.el -*- lexical-binding: t; -*-

;;; code:

(require 'cl-lib)

(defun list-swift-publics-or-open ()
  "Open an occur buffer with file's public interface."
  (interactive)
  (let ((list-matching-lines-face nil))
    (occur "\\(public\\)\\|\\(open\\)")))

(defun list-swift-marks ()
  "Open an occur buffer with files mark."
    (interactive)
    (let ((list-matching-lines-face nil))
      (occur (regexp-quote "MARK:"))))

(defun list-swift-extensions ()
  "Open an occur buffer with all the extensions."
    (interactive)
    (let ((list-matching-lines-face nil))
      (occur "\\(extension\\)")))

(defun list-swift-lazy-variables ()
  "Open an occur buffer with swift functions."
  (interactive)
  (let ((list-matching-lines-face nil))
    (occur "\\(lazy\\)")))

(defun list-swift-functions ()
  "Open an occur buffer with swift functions."
  (interactive)
  (let ((list-matching-lines-face nil))
    (occur "\\(func\\)")))

(defvar extensions-expr (regexp-quote "(extension)"))
(defun list-swift-extensions ()
  "Open an occur buffer with files extension."
    (interactive)
    (let ((list-matching-lines-face nil))
      (occur extensions-expr)))


(defun ar/counsel-apple-search ()
  "Ivy interface for dynamically querying apple.com docs."
  (interactive)
  (require 'request)
  (require 'json)
  (require 'url-http)
  (ivy-read "apple docs: "
            (lambda (input)
              (let* ((url (url-encode-url (format "https://developer.apple.com/search/search_data.php?q=%s" input)))
                     (c1-width (round (* (- (window-width) 9) 0.3)))
                     (c2-width (round (* (- (window-width) 9) 0.5)))
                     (c3-width (- (window-width) 9 c1-width c2-width)))
                (or
                 (ivy-more-chars)
                 (let ((request-curl-options (list "-H" (string-trim (url-http-user-agent-string)))))
                   (request url
                     :type "GET"
                     :parser 'json-read
                     :success (cl-function
                               (lambda (&key data &allow-other-keys)
                                 (ivy-update-candidates
                                  (mapcar (lambda (item)
                                            (let-alist item
                                              (propertize
                                               (format "%s   %s   %s"
                                                       (truncate-string-to-width (propertize (or .title "")
                                                                                             'face '(:foreground "yellow")) c1-width nil ?\s "…")
                                                       (truncate-string-to-width (or .description "") c2-width nil ?\s "…")
                                                       (truncate-string-to-width (propertize (string-join (or .api_ref_data.languages "") "/")
                                                                                             'face '(:foreground "cyan1")) c3-width nil ?\s "…"))
                                               'url .url)))
                                          (cdr (car data)))))))
                   0))))
            :action (lambda (selection)
                      (browse-url (concat "https://developer.apple.com"
                                          (get-text-property 0 'url selection))))
            :dynamic-collection t
            :caller 'ar/counsel-apple-search))

(defun swift-print-thing-at-point ()
  "Print thing at point."
  (interactive)
  (let ((word (thing-at-point 'word)))
    (end-of-line)
    (newline-and-indent)
    (insert (format "print(\"%s:\ \\(%s\)\")" word word))))


(defun ar/counsel-hacking-with-swift-search ()
  "Ivy interface to query hackingwithswift.com."
  (interactive)
  (require 'request)
  (require 'json)
  (require 'url-http)
  (ivy-read "hacking with swift: "
            (lambda (input)
              (or
               (ivy-more-chars)
               (let ((request-curl-options (list "-H" (string-trim (url-http-user-agent-string)))))
                 (request
                   "https://www.hackingwithswift.com/example-code/search"
                   :type "GET"
                   :params (list
                            (cons "search" input))
                   :parser 'json-read
                   :success (cl-function
                             (lambda (&key data &allow-other-keys)
                               (ivy-update-candidates
                                (mapcar (lambda (item)
                                          (let-alist item
                                            (propertize .title 'url .url)))
                                        data)))))
                 0)))
            :action (lambda (selection)
                      (browse-url (concat "https://www.hackingwithswift.com"
                                          (get-text-property 0 'url selection))))
            :dynamic-collection t
            :caller 'ar/counsel-hacking-with-swift-search))

(defun mk/toggle-flycheck-errors ()
  "Function to toggle flycheck errors."
  (interactive)
  (if (get-buffer "*Flycheck errors*")
      (kill-buffer "*Flycheck errors*")
    (list-flycheck-errors)))

(provide 'swift-additions)

;;; swift-additions.el ends here


