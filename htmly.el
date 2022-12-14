(defun htmly-special-slurp ()
  (interactive)
  (cond ((and (region-active-p) (eq (char-before) ?>))
         (sgml-skip-tag-forward 1))
        ((and (region-active-p) (eq (char-after) ?<))
         (sgml-skip-tag-backward 1))
        (t
         (call-interactively #'self-insert-command))))

(defun htmly-special-barf ()
  (interactive)
  (cond ((and (region-active-p) (eq (char-before) ?>))
         (sgml-skip-tag-backward 1)
         (backward-char 1))
        ((and (region-active-p) (eq (char-after) ?<))
         (sgml-skip-tag-forward 1)
         (forward-char 1))
        (t
         (call-interactively #'self-insert-command))))

(defun htmly-special-mark-tag ()
  (interactive)
  (cond ((eq (char-before) ?>)
         (set-mark (point))
         (sgml-skip-tag-backward 1))
        ((eq (char-after) ?<)
         (set-mark (point))
         (sgml-skip-tag-forward 1))
        (t
         (call-interactively #'self-insert-command))))

(defun htmly-special-render ()
  (interactive)
  (cond
   ((region-active-p)
    (let ((region (buffer-substring (region-beginning)
                                    (region-end))))
      (with-current-buffer (get-buffer-create "*htmly*")
        (erase-buffer)
        (insert region)
        (shr-render-region (point-min)
                           (point-max)
                           "*htmly*"))
      (display-buffer "*htmly*")))
   ((eq (char-before) ?>)
    (let ((region (buffer-substring (save-excursion
                                      (sgml-skip-tag-backward 1)
                                      (point))
                                    (point))))
      (with-current-buffer (get-buffer-create "*htmly*")
        (erase-buffer)
        (insert region)
        (shr-render-region (point-min)
                           (point-max)
                           "*htmly*"))
      (display-buffer "*htmly*")))
   ((eq (char-after) ?<)
    (save-excursion
      (sgml-skip-tag-forward 1)
      (htmly-special-render)))
   (t
    (call-interactively #'self-insert-command))))


(defun htmly-delete-backward-char ()
  (interactive)
  (if (eq (char-before) ?>)
      (delete-region (point)
                     (save-excursion
                       (sgml-skip-tag-backward 1)
                       (point)))
    (delete-backward-char 1)))

(defun htmly-delete-forward-char ()
  (interactive)
  (if (eq (char-after) ?<)
      (delete-region (point)
                     (save-excursion
                       (sgml-skip-tag-forward 1)
                       (point)))
    (delete-forward-char 1)))

(defun htmly-special-new-copy ()
  (interactive)
  (cond
   ((eq (char-after) ?<)
    (sgml-skip-tag-forward 1)
    (htmly-special-new-copy)
    (sgml-skip-tag-backward 1))
   ((eq (char-before) ?>)
    (kill-ring-save (point)
                    (save-excursion
                      (sgml-skip-tag-backward 1)
                      (point))))
   (t
    (call-interactively #'self-insert-command))))

(defun htmly-special-clone ()
  (interactive)
  (cond ((eq (char-before) ?>)
         (htmly-special-new-copy)
         (newline)
         (yank))
        ((eq (char-after) ?<)
         (htmly-special-new-copy)
         (sgml-skip-tag-forward 1)
         (newline)
         (yank)
         (sgml-skip-tag-backward 1))
        (t
         (call-interactively #'self-insert-command))))

(defun htmly-special-up ()
  (interactive)
  (cond
   ((eq (char-after) ?<)
    (sgml-skip-tag-forward 1)
    (htmly-special-up)
    (sgml-skip-tag-backward 1))
   ((eq (char-before) ?>)
    (kill-region (point)
                 (save-excursion
                   (sgml-skip-tag-backward 1)
                   (point)))
    (delete-backward-char 1)
    (sgml-skip-tag-backward 1)
    (yank 1)
    (newline)
    (backward-char 1))
   (t
    (call-interactively #'self-insert-command))))

(defun htmly-special-down ()
  (interactive)
  (cond
   ((eq (char-after) ?<)
    (sgml-skip-tag-forward 1)
    (htmly-special-down)
    (sgml-skip-tag-backward 1))
   ((eq (char-before) ?>)
    (kill-region (point)
                 (save-excursion
                   (sgml-skip-tag-backward 1)
                   (point)))
    (delete-backward-char 1)
    (sgml-skip-tag-forward 1)
    (forward-char 1)
    (yank 1)
    (newline)
    (backward-char 1)
    )
   (t
    (call-interactively #'self-insert-command))))

(defun htmly-special-next ()
  (interactive)
  (cond
   ((eq (char-after) ?<)
    (sgml-skip-tag-forward 1)
    (htmly-special-next)
    (sgml-skip-tag-backward 1))
   ((eq (char-before) ?>)
    (sgml-skip-tag-forward 1))
   (t
    (call-interactively #'self-insert-command))))

(defun htmly-special-previous ()
  (interactive)
  (cond
   ((eq (char-after) ?<)
    (sgml-skip-tag-forward 1)
    (htmly-special-previous)
    (sgml-skip-tag-backward 1))
   ((eq (char-before) ?>)
    (sgml-skip-tag-backward 1)
    (backward-char 1))
   (t
    (call-interactively #'self-insert-command))))

(defun htmly-special-other ()
  (interactive)
  (cond
   ((region-active-p)
    (let ((saved (point)))
      (goto-char (mark))
      (set-mark saved)))
   ((eq (char-after) ?<)
    (sgml-skip-tag-forward 1))
   ((eq (char-before) ?>)
    (sgml-skip-tag-backward 1))
   (t
    (call-interactively #'self-insert-command))))

(define-key svelte-mode-map (kbd "DEL")
            #'htmly-delete-backward-char)
(define-key svelte-mode-map (kbd "C-d")
            #'htmly-delete-forward-char)
(define-key svelte-mode-map (kbd "n")
            #'htmly-special-new-copy)
(define-key svelte-mode-map (kbd "w")
            #'htmly-special-up)
(define-key svelte-mode-map (kbd "s")
            #'htmly-special-down)
(define-key svelte-mode-map (kbd "j")
            #'htmly-special-next)
(define-key svelte-mode-map (kbd "k")
            #'htmly-special-previous)
(define-key svelte-mode-map (kbd "d")
            #'htmly-special-other)
(define-key svelte-mode-map (kbd "e")
            #'htmly-special-render)
(define-key svelte-mode-map (kbd "m")
            #'htmly-special-mark-tag)
(define-key svelte-mode-map (kbd ">")
            #'htmly-special-slurp)
(define-key svelte-mode-map (kbd "<")
            #'htmly-special-barf)
(define-key svelte-mode-map (kbd "c")
            #'htmly-special-clone)
