(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)


(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/11_otp_book/01_mix_new_chucky")

;; code from chapter 9 of little elixir otp guidebook



(let*
    ((project 'Chucky)
     
     (l
       `((lib/server.ex
	  (defmodule Chucky.Server
	    "use GenServer"
	    (def start_link ()
	      ;; globally register genserver in the cluster in the
	      ;; global_name_server process, each node will have a
	      ;; replica of the name tables
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
	      ;; https://github.com/benjamintanweihao/the-little-elixir-otp-guidebook-code/blob/master/chapter_9/chucky/facts.txt
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
		     facts))))
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
	  (defmodule Chucky
	    "use Application"
	    "require Logger"
	    (def start (type _args)
	      "import Supervision.Spec"
	      (setf children (list (worker Chucky.Server)
				   (list)))
	      (case type
		(@normal (Logger.info (string "Application is started on #{node}.")))
		((tuple @takeover
			old_node)
		 (Logger.info (string "#{node} is taking over #{old_node}.")))
		((tuple @failover
			old_node)
		 (Logger.info (string "#{old_node} is failing over to #{node}."))))
	      (setf opts (keyword-list strategy
				       @one_for_one
				       name (tuple @global Chucky.Supervisor)))
	      (Supervisor.start_link children opts))
	    (def fact ()
	      Chucky.Server.fact)))
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
