(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/09_ping.exs" *path*)
 `(do0
   (defmodule Ping
       (def ping_async (ip parent)
	 (send parent
	       (ring_ping ip))
	 )
     (def run_ping (ip)
       (try
	(do0
	 (setf (tuple cmd_output _)
	       (System.cmd (string "ping")
			   (ping_args ip)))
	 (setf alive? (not (Regex.match?
			    "~r/100(\\.0)?% packet loss/" cmd_output)))
	 (tuple ":ok"
		ip alive?))
	:rescue
	(-> e (tuple ":error"
		     ip
		     e))))
     )))   





















 
