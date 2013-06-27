(in-package :millipode)

(defclass pode ()
  ((content-dir  :accessor content-dir  :initarg :content-dir)
   (webpage-dir  :accessor webpage-dir  :initarg :webpage-dir)
   (template-dir :accessor template-dir :initarg :template-dir)
   (post-template-file :accessor post-template-file :initarg :post-template-file)
   (index-template-file :accessor index-template-file :initarg :index-template-file))
  (:documentation
   "A pode is a simple compound type consisting of two pathspecs
content-dir, webpage-dir and template-dir.

content-dir is the directory containing text files, webpage-dir is
where the the html files should be generated and template-dir is where
the html templates are."))

(defmacro with-existing-pode-slots (pode &body body)
  `(with-accessors ((content-dir content-dir)
                    (webpage-dir webpage-dir)
                    (template-dir template-dir)
                    (post-template-file post-template-file)
                    (index-template-file index-template-file)) ,pode
     (check-type ,pode pode)
     (assert (and (directory-exists-p content-dir)
                  (directory-exists-p webpage-dir)
                  (directory-exists-p template-dir))
             (content-dir webpage-dir))
     ,@body))

(defmethod print-object ((pode pode) stream)
  (print-unreadable-object (pode stream :type t :identity t)
    (with-existing-pode-slots pode
      (format stream "content: ~a~%webpages: ~a~%templates: ~a~%"
              content-dir webpage-dir template-dir))))

(defmethod make-load-form ((pode pode) &optional env)
  (declare (ignore env))
  (make-load-form-saving-slots pode))
