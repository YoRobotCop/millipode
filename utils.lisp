(in-package :millipode)

;; TODO: figure out an elegant way of testing the existence of
;; multiple files. A with-existing macro?

;; TODO: ls could become some sort of method dispatching
;; function. Keyword args?

(defun ls (dir)
  (fad:list-directory dir))

(defun ls-ext (dir suffix)
  "Lists files with extension."
  (loop for pathname in (ls dir)
     when (string= (pathname-type pathname) suffix) collect pathname))

(defun list-modified-content (content-dir webpage-dir)
  "Lists the text files that are newer than their corresponding
generated html files."
  (assert (and (fad:directory-exists-p content-dir)
	       (fad:directory-exists-p webpage-dir)))
  (loop for file in (ls content-dir)
     when (and (generated-webpage-p webpage-dir file)
	       (content-post-newerp file webpage-dir 2))
     collect file))

(defun regular-file-exists-p (pathspec)
  (and (fad:file-exists-p pathspec)
       (not (fad:directory-pathname-p pathspec))))

(defun read-file-into-strings (pathspec separator)
  (assert (regular-file-exists-p pathspec))
  (let ((string-list (ppcre:split separator (alexandria:read-file-into-string pathspec))))
    string-list))

(defun corresponding-webpage-file (post-text-file webpage-dir)
  (assert (fad:file-exists-p post-text-file))
  (make-pathname :name (pathname-name post-text-file)
		 :type "html"
		 :defaults webpage-dir))
  
(defun corresponding-text-file (webpage-file content-dir)
  (assert (fad:file-exists-p webpage-file))
  (make-pathname :name (pathname-name webpage-file)
		 :type "txt"
		 :defaults content-dir))

(defun file-mod-time-diff (file-a file-b)
  "Returns the difference in seconds of the last-modified time."
  (assert (and (fad:file-exists-p file-a)
	       (fad:file-exists-p file-b)))
  (- (file-write-date file-a)
     (file-write-date file-b)))

(defun generated-webpage-p (webpage-dir content-file)
  "Predicate that tests whether a text-file's corresponding webpage
exists."
  (assert (and (fad:directory-exists-p webpage-dir)
	       (fad:file-exists-p content-file)))
  (fad:file-exists-p (corresponding-webpage-file content-file webpage-dir)))

(defun list-new-content (content-dir webpage-dir)
  (loop for file in (ls content-dir)
     unless (generated-webpage-p webpage-dir file)
     collect file))

(defun list-orphaned-pages (content-dir webpage-dir)
  " Lists the webpages from webpage-dir that do not have a
corresponding file in content-dir."
  (let ((webpages (ls webpage-dir)))
    (loop for webpage in webpages unless
	 (or (fad:file-exists-p (corresponding-text-file webpage content-dir))
	     (string= (pathname-name webpage) "index"))
       collect webpage)))

(defun delete-orphaned-webpages (content-dir webpage-dir)
  (mapcar #'delete-file (list-orphaned-pages content-dir webpage-dir)))

(defun content-post-newerp (post-text-file webpage-dir delay)
  (let ((generated-webpage (corresponding-webpage-file
			    post-text-file webpage-dir)))
    (assert (and (fad:file-exists-p post-text-file)
		 (fad:file-exists-p generated-webpage)))
    (> (file-mod-time-diff post-text-file generated-webpage) delay)))

(defun delete-files-in-dir (pathspec)
  "Deletes all regular files in directory."
  (assert (fad:directory-exists-p pathspec))
  (loop for file in (ls pathspec) do
       (when (not (fad:directory-pathname-p file))
	 (delete-file file))))
