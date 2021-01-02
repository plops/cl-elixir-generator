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


(defun modify-source (fn start-pattern end-pattern)
  )

(format nil "~a/~a" *path* "./lib/hello_web/router.ex")


"#template_ROUTE_start"
"#template_ROUTE_end"
