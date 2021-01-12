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
     
    (write-source
     (format nil "~a/lib/live_view_todos_web/live/todo_live.ex" *path*)
     `(do0
       (defmodule LiveViewTodosWeb.TodoLive
	 "use LiveViewTodosWeb, :live_view"
	 "alias LiveViewTodos.Todos"
	 (def mount (_params _session socket)
	   (tuple :ok (assign socket ":todos" (Todos.list_todos)))
	   )
	 #+nil
	 (def render (assigns)
	   (string-L "Rendering LiveView")))))   
    


    (with-open-file (s (format nil "~a/lib/live_view_todos_web/live/todo_live.html.leex" *path*)
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
      (write-sequence
       (spinneret:with-html-string
	 (:div
	  (:raw "<%= for todo <- @todos do %>")
	  (:div
	   (:raw "<%= todo.title %>"))
	  (:raw "<%= end %>"))
	 #+nil
	 (:div :class "phx-hero"
	       (:h2 "hello " (:raw " <%= @messenger %>")))) s)))






   )












 
