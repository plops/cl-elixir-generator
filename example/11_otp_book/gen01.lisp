(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)


(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/11_otp_book/01_mix_new_chucky")

;; generate the following files
;; mix.exs
;; lib/chucky.ex
;; test/chucky_test.exs
;; test/test_helper.exs

(let*
    ((project 'Chucky)
     
     (l
       `((lib/server.ex
	  (defmodule Chucky.Server
	    "use GenServer"
	    (def start_link ()
	      ;; globally register genserver in the cluster
	      (GenServer.start_link
	       __MODULE__
	       (list)
	       (list :name
		     (tuple @global
			    __MODULE__))))
	    ;; calls and casts to a globally registered genserver have
	    ;; an extra :global
	    (def fact ()
	      (GenServer.call (tuple @global __MODULE__)
			      @fact))
	    (def init ((list))
	      (@random.seed (@os.timestamp))
	      (setf facts (pipe (string "facts.txt")
				File.read!
				(String.split (string "\\n"))))
	      (tuple @ok facts))
	    (def handle_call (@fact _from facts)
	      (setf random_fact (pipe facts
				      Enum.shuffle
				      List.first))
	      (tuple @reply
		     random_fact
		     facts)))
	  )
	 (test/test_helper.exs
	     (do0
	      (ExUnit.start)))
	 (test/cucky_test.exs
	  (defmodule ,(format nil "~aTest" project)
	    "use ExUnit.Case"
	    (space doctest ,project)
	    (space test (string "greets the world")
		   (progn
		     (assert (== (dot ,project
				      (hello))
				 @world))))))
	 (lib/chucky.ex
	  (defmodule ,project
	      (space "@moduledoc"
		     (string3 "Documentation for `Chucky`."))
	    (def hello ()
	      @world)))
	 (mix.exs
	  (do0
	   (defmodule (dot ,project MixProject)
	      (use Mix.Project)
	    (def project ()
	      (list
	       :app ,(string-downcase (format nil ":~a" project))
	       :version (string "0.1.0")
	       :elixir (string "~> 1.11")
	       ;:elixirc_paths (elixirc_paths (Mix.env))
	       
	       :start_permanent (== (Mix.env)
				    @prod)
	       ;:aliases (aliases)
	       :deps (deps)))
	    (def application ()
	      (list ;:mod (tuple (dot ,project Application) (list))
		    :extra_applications (list @logger
					      )))
	     (defp deps ()
	      (list
	       ,@(loop for e in
		       `(
			 
			 ;(postgrex 0.0.0 :op >=)
			 )
		       collect
		       (destructuring-bind (name version &key (op '~>) only) e
			 (if only
			     `(tuple ,(format nil ":~a" name)
				 (string ,(format nil "~a ~a" op version))
				 :only ,only)
			    `(tuple ,(format nil ":~a" name)
				 (string ,(format nil "~a ~a" op version))
				 ))))))
	   ))
	 ))
       ))
  (loop for (fn code) in l
	do
	   (let ((dir (directory-namestring (format nil "~a/~a" *path* fn))))
	     ;(format t "create dir ~a~%" dir)
	    (ensure-directories-exist dir)
	    (write-source
	     (format nil "~a/~a" *path* fn)
	     code)))
  )
