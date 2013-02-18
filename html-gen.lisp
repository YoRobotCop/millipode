(in-package :millipode)

(setf (cl-who:html-mode) :html5)

(defun generate-index-html (dir)
  (let ((file-list (ls dir)))
    (cl-who:with-html-output-to-string (*standard-output* nil :indent t :prologue t)
      (cl-who:htm
       (:html
	(:head
	(:link :href "../css/style.css" :rel "stylesheet" :type "text/css" :media "screen")
	(:link :rel "icon" :type "image/png" :href "../img/s.png")
	(:title "archive"))
       (:body
	(:div :id "container"

	      (:div :id "header"
		    (:ul (:li (:a :href "../about" "home"))))

	      (:div :id "sidebar")

	      (:div :id "content" :style "border-bottom: 0px; min-height: 500px"
		    (:h3 "archive")
		    (cl-who:htm
		     (:div :id "index_links"
			   (loop for file in file-list 
			      unless (string= (pathname-name file) "index") do
				(cl-who:htm (:p (:a :href file (cl-who:esc (pathname-name file)))))))))

	      (:div :id "filler")

	      (:div :id "footer"
		    (:div :id "empty_box")))))))))

(defun gen-blog-post-html (file)
  (let ((string-list (list-of-strings file)))
    (cl-who:with-html-output-to-string (*standard-output* nil :indent t :prologue t)
      (cl-who:htm
       (:html
	(:head
	 (:link :href "../css/style.css" :rel "stylesheet" :type "text/css" :media "screen")
	 (:link :rel "icon" :type "image/png" :href "../img/s.png")
	 (:title (cl-who:esc (pathname-name file))))
	(:body
	 (:div :id "container"
	       (:div :id "header"
		    (:ul (:li (:a :href "../about" "home"))
			 (:li (:a :href "index" "archive"))))

	      (:div :id "sidebar")

	      (:div :id "content"

		    (:h3 (cl-who:esc (first string-list)))
		    (cl-who:htm
		     (loop for string in (rest string-list) do
			  (cl-who:htm (:p (cl-who:esc string))))))

	      (:div :id "filler")

	      (:div :id "footer"))))))))
