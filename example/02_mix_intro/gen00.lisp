(declaim (optimize (debug 3)
		   (speed 0)
		   (safety 3)))

(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator")
  (ql:quickload "alexandria")
  (ql:quickload "cl-ppcre"))
(in-package :cl-elixir-generator)

(progn
  (defparameter *path* "/home/martin/stage/cl-elixir-generator/example/02_mix_intro")
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
   (write-source
   (format nil "~a/source/test/kv/bucket_test.exs" *path*)
   `(do0
     (defmodule KV.BucketTest
       "use ExUnit.Case, async: true"
       (space test
	      (string "stores values by key")
	      (progn
		(setf (tuple :ok bucket)
		      (KV.Bucket.start_link (list)))
		(assert (== nil
			    (KV.Bucket.get bucket (string "milk"))))
		(dot KV
		     Bucket
		     (put bucket (string "milk") 3))
		(assert (== 3
			    (KV.Bucket.get bucket (string "milk"))))
		))
       )))
   (write-source
   (format nil "~a/source/lib/kv/bucket.ex" *path*)
   `(do0
     (defmodule KV.Bucket
       "use Agent"
       (do0
	(space @doc
	       (string3 Starts a new bucket))
	(def start_link (_opts)
	  (Agent.start_link (lambda ()
			      (map)))))
       (do0
	(space @doc
	       (string3 Get value from the bucket by key))
	(def get (bucket key)
	  (Agent.get bucket (&Map.get &1 key))))
       (do0
	(space @doc
	       (string3 Put value for given key into bucket))
	(def put (bucket key value)
	  (Agent.update bucket (&Map.put &1 key value))))))))

