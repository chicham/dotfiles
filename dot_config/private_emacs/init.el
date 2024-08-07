;; Disable the splash screen (to enable it agin, replace the t with 0)
(setq inhibit-splash-screen t)

;; Enable transient mark mode
(transient-mark-mode 1)

;;;;Org mode configuration
;; Enable Org mode
(require 'org)

(with-eval-after-load 'org
    (setq org-directory "~/.orgmode/")
    (org-indent-mode 1)
    (setq org-startup-indented t)
)

(server-start)
;; (add-to-list 'load-path "~/.config/emacs/")
(require 'org-protocol)

(setq org-capture-templates `(
  ("p" "Protocol" entry (file+headline ,(concat org-directory "inbox.org") "Web")
        "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
  ("L" "Protocol Link" entry (file+headline ,(concat org-directory "inbox.org") "Web")
   "* TODO [[%:link][%:description]]\nCaptured On: %U"
   :immediate-finish t)
))
