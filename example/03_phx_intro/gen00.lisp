(declaim (optimize (debug 3)
		   (speed 0)
		   (safety 3)))

(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator")
  (ql:quickload "alexandria")
  (ql:quickload "cl-ppcre"))
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
    (with-open-file (s (format nil "~a.2" fn-full)
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
      (write-sequence new s))
    (sb-ext:run-program "/usr/bin/mix" (list "format"
					     (namestring (format nil "~a.2" fn-full)
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
   (modify-source "lib/hello_web/router.ex"
	       "route"
	       `(do0
		 (get (string "/hello")
		      HelloController
		      ":index")))
   #+nil (write-source
    (format nil "~a/source/test/kv/bucket_test.exs" *path*)
    `(do0
      (defmodule KV.BucketTest
       "use ExUnit.Case, async: true"
       (space setup
	      (progn
		(setf bucket (start_supervised! KV.Bucket))
		#+nil (setf (tuple :ok bucket)
		      (KV.Bucket.start_link (list))
		      )
		(map :bucket bucket)))
       (space test
	      (ntuple (string "stores values by key")
		      (map :bucket bucket) ;; get the setup bucket into the test context
		      )
	      (progn
	
		(assert (== nil
			    (KV.Bucket.get bucket (string "milk"))))
		(dot KV
		     Bucket
		     (put bucket (string "milk") 3))
		(assert (== 3
			    (KV.Bucket.get bucket (string "milk"))))
		(dot KV
		     Bucket
		     (delete bucket (string "milk")))
		(assert (== nil
			    (KV.Bucket.get bucket (string "milk"))))
		))
       )))
   )










