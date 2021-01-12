(declaim (optimize (debug 3)
		   (speed 0)
		   (safety 3)))

(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator")
  (ql:quickload "alexandria")
  (ql:quickload "cl-ppcre")
  (ql:quickload "spinneret")
  (ql:quickload "inferior-shell"))
(in-package :cl-elixir-generator)



(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/05_todo/live_view_todos/")

(inferior-shell:run/ss
 (format nil
	 "sed -i s/PageLive/TodoLive/ ~a"
	 (first (directory (format nil "~a/lib/*/router.ex" *path*)))))


(progn
  
  
  (defparameter *day-names*
    '("Monday" "Tuesday" "Wednesday"
      "Thursday" "Friday" "Saturday"
      "Sunday"))

  (defun modify-source (fn-part name code &key (comment-style :hash))
    (flet ((comment (str)
	     (case comment-style
	       (:hash (format nil "# ~a" str))
	       (:html (format nil "<!-- ~a -->" str)))))
     (let* (			  ;(fn-part "lib/hello_web/router.ex")
	    (fn-full (format nil "~a/~a" *path* fn-part))
					;(name "route")
	    (fn-part-name (format nil "~a ~a" fn-part name))
	    (start-comment (comment (format nil "USER CODE BEGIN ~a" fn-part-name)))
	    (end-comment (comment (format nil "USER CODE END ~a" fn-part-name)))
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
						   (case comment-style
						     (:hash (emit-elixir :code code))
						     (:html code ;(spinneret:with-html-string code)
						      ))
						   end-comment))))
	 (with-open-file (s fn-full
			    :direction :output
			    :if-exists :supersede
			    :if-does-not-exist :create)
	   (write-sequence new s))
	 (when (eq comment-style :hash)
	  (sb-ext:run-program "/usr/bin/mix" (list "format"
						   (namestring fn-full
							       )))))))
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
			  ":index")
		     (get (string "/hello/:messenger")
			  HelloController
			  ":show")))
    (write-source
     (format nil "~a/lib/hello_web/controllers/hello_controller.ex" *path*)
     `(do0
       (defmodule HelloWeb.HelloController 
	 "use HelloWeb, :controller"
	 ;; tell the view to render index.html
	 (def index (conn _params)
	   (render conn (string "index.html")))
	 (def show (conn (map (string messenger) messenger))
	   (render conn (string "show.html")
		   :messenger messenger)))))
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
		 (:h2 "hello world from phoenix"))) s)))

    (with-open-file (s (format nil "~a/lib/hello_web/templates/hello/show.html.eex" *path*)
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
      (write-sequence
       (spinneret:with-html-string
	 (:div :class "phx-hero"
	       (:h2 "hello " (:raw " <%= @messenger %>")))) s)))


   (progn
     ;; add a inspection plug

     (modify-source "lib/hello_web/endpoint.ex"
		   "endpoint-end-definition"
		   `(do0
		     (plug ":introspect")))
     (modify-source "lib/hello_web/endpoint.ex"
		   "plug-before-helloweb.router"
		   `(do0
		     (def introspect (conn _opts)
		       ,(lprint `((inspect conn.method)
				  (inspect conn.host)
				  (inspect conn.req_headers)))
		       conn)))

     
     )


   (progn
     ;; add a module plug
     ;; localhost:4000/?locale=fr
     (write-source
     (format nil "~a/lib/hello_web/plugs/locale.ex" *path*)
     `(do0
       (defmodule HelloWeb.Plugs.Locale
	 "import Plug.Conn"
	 (space @locales (list (string "en")
			       (string "fr")
			       (string "de")))
	 (def init (default)
	   default)
	 (def call ((= (struct Plug.Conn
			       params (map (string "locale") loc))
		       conn)
		    _default)
	   (declare (when (in loc @locales)))
	   (assign conn ":locale" loc)
	   ) 
	 (def call (conn default)
	   (assign conn ":locale" default)))))
     (modify-source "lib/hello_web/router.ex"
		   "browser-pipeline-end"
		   `(do0
		     (plug HelloWeb.Plugs.Locale (string "en"))))
     (modify-source "lib/hello_web/templates/layout/app.html.eex"
		   "main-top"
		   (spinneret:with-html-string
		     (:p
			"Locale:"
			(:raw "<%= @locale %>")))
		   :comment-style :html)
     
     )

   )












 
