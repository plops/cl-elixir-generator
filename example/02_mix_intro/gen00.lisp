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
   
   (write-source
   (format nil "~a/source/test/kv/registry_test.exs" *path*)
   `(do0
     (defmodule KV.RegistryTest
       "use ExUnit.Case, async: true"
       (space setup
	      (progn
		(setf registry (start_supervised! KV.Registry))
		(map :registry registry)
		))
       (space test
	      (ntuple (string "spawn buckets")
		      (map :registry registry)
		      )
	      (progn
		
		(assert (== :error
			    (KV.Registry.lookup registry (string "shopping"))))
		 (KV.Registry.create registry (string "shopping"))
		 (assert (= (tuple :ok bucket)
			    (KV.Registry.lookup registry (string "shopping"))))
		 (KV.Bucket.put bucket (string "milk") 1)
		 (assert (== 1 (KV.Bucket.get bucket (string "milk"))))
		 ))
       (space test
	      (ntuple (string "remove buckets on exit")
		      (map :registry registry)
		      )
	      (progn
		
		 (KV.Registry.create registry (string "shopping"))
		 (assert (= (tuple :ok bucket)
			    (KV.Registry.lookup registry (string "shopping"))))
		 (Agent.stop bucket)
		 (assert (== :error (KV.Registry.lookup registry (string "shopping"))))
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
	  (Agent.update bucket (&Map.put &1 key value))))
       (do0
	(space @doc
	       (string3 Delete key from bucket. Returns value of key if it exists.))
	(def delete (bucket key)
	  (Agent.get_and_update bucket (&Map.pop &1 key)))))))
   
   (write-source
   (format nil "~a/source/lib/kv/registry.ex" *path*)
   `(do0
     (defmodule KV.Registry
       "use GenServer"
       (do0
	(comments "client api")
	(do0
	 (space @doc
		(string3 start registry))
	 (def start_link (opts)
	   (GenServer.start_link __MODULE__ ":ok" opts)))
	(do0
	 (space @doc
		(string3 lookup bucket pit for name stored in server))
	 (def lookup (server name)
	   (GenServer.call server (tuple :lookup name))))
	(do0
	 (space @doc
		(string3 ensure bucket exists with given name in server))
	 (def create (server name)
	   (GenServer.cast server (tuple :create name)))))
       
       
       (do0
	(comments "server callbacks")
	(space @impl true)
	(def init (:ok)
	  (setf names (map)
		refs (map))
	  (tuple :ok (tuple names refs))))
       (do0
	(space @impl true)
	(def handle_call ((tuple :lookup name) _from state)
	  (setf (tuple names _) state)
	  (tuple :reply (Map.fetch names name) state)))
       (do0
	(space @impl true)
	(def handle_cast ((tuple :create name) (tuple names refs))
	  (if (Map.has_key? names name)
	      (tuple :noreply names)
	      (do0
	       (setf (tuple :ok bucket) (KV.Bucket.start_link (list))
		     ref (Process.monitor bucket)
		     refs (Map.put refs ref name)
		     names (Map.put names name bucket))
	       
	       (tuple :noreply (tuple names refs))))))
       (do0
	(space @impl true)
	(def handle_info ((tuple :DOWN ref :process _pid _reason) (tuple names refs))
	  (setf (tuple name refs) (Map.pop refs ref)
		names (Map.delete names name))
	  (tuple :noreply (tuple names refs))))
       (do0
	(space @impl true)
	(def handle_info (_msg state)
	  (tuple :noreply state)))
      ))))

