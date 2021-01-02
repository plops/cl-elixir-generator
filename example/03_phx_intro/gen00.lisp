(declaim (optimize (debug 3)
		   (speed 0)
		   (safety 3)))

(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator")
  (ql:quickload "alexandria")
  (ql:quickload "cl-ppcre")
  (ql:quickload "spinneret"))

(in-package :cl-elixir-generator)

(progn
  (defparameter *path* "/home/martin/stage/cl-elixir-generator/example/03_phx_intro/hello/")
  (defparameter *code-file* "run_00_start")
  (defparameter *source* (format nil "~a/source/~a" *path* *code-file*))
  (defparameter *day-names*
    '("Monday" "Tuesday" "Wednesday"
      "Thursday" "Friday" "Saturday"
      "Sunday"))
  (defun modify-source (fn-part name code)
  (let* (;(fn-part "lib/hello_web/router.ex")
       (fn-full (format nil "~a/~a" *path* fn-part))
       ;(name "route")
       (fn-part-name (format nil "~a ~a" fn-part name))
       (start-comment (format nil "# USER CODE BEGIN ~a" fn-part-name))
       (end-comment (format nil "# USER CODE END ~a" fn-part-name))
       (a (with-open-file (s fn-full
			     :direction :input)
	    (let ((a (make-string (file-length s))))
	      (read-sequence a s)
	      a))))
  (let* (
	 ;; escape * characters to convert elixir comment to regex
	 (regex (format nil "~a.*~a"
			(cl-ppcre:regex-replace-all "\\*" start-comment "\\*")
			(cl-ppcre:regex-replace-all "\\*" end-comment "\\*")))
	 ;; now use the regex to replace the text between the comments
	 (new (cl-ppcre:regex-replace (cl-ppcre:create-scanner regex :single-line-mode t)
				      a
				      (format nil "~a~%~a~%~a" start-comment
					      (emit-elixir :code code)
					      end-comment))))
    (with-open-file (s fn-full
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
      (write-sequence new s))
    (sb-ext:run-program "/usr/bin/mix" (list "format"
					     (namestring fn-full
							 )))))
  )
   (defun lprint (rest)
     `(IO.puts (string
                ,(format nil "#{__ENV__.file}:#{__ENV__.line} ~{~a~^ ~}"

			 (loop for e in rest
			       collect
			       (format nil "~a=#{~a}"
				       ;(substitute  #\' #\" (emit-elixir :code e))
				       (cl-ppcre:regex-replace-all "\"" (emit-elixir :code e) "\\\"")
				       (emit-elixir :code e)
				       ))))))

   (progn
    (modify-source "lib/hello_web/router.ex"
		   "route"
		   `(do0
		     (get (string "/hello")
			  HelloController
			  ":index")))
    (write-source
     (format nil "~a/lib/hello_web/controllers/hello_controller.ex" *path*)
     `(do0
       (defmodule HelloWeb.HelloController 
	 "use HelloWeb, :controller"
	 ;; tell the view to render index.html
	 (def index (conn _params)
	   (render conn (string "index.html"))))))
    (write-source
     (format nil "~a/lib/hello_web/views/hello_view.ex" *path*)
     `(do0
       (defmodule HelloWeb.HelloView
	 "use HelloWeb, :view")))
   
    

    (progn
      ;; create template
      ;; this will be injected into lib/hello_web/templates/layout/app.html.eex at @inner_content
      
      ;; article about spinneret, with a few examples
      ;; https://40ants.com/lisp-project-of-the-day/2020/09/0189-spinneret.html
      
      (with-open-file (s (format nil "~a/lib/hello_web/templates/hello/index.html.eex" *path*)
			 :direction :output
			 :if-exists :supersede
			 :if-does-not-exist :create)
	(write-sequence
	 (spinneret:with-html-string
	   (:div :class "phx-hero"
		 (:h2 "hello world from phoenix"))) s))))
   

   )












 
