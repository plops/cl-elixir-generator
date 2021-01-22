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
	       (run_ping ip))
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
     (def ping_args (ip)
       (list ,@(loop for e in `(-c 1 -w 5 -s 1)
		     collect
		     `(string ,e))
	     ip))

    
     )
   (defmodule Subnet
       (def ping (subnet)
	 (setf all (ips subnet))
	 (Enum.each all
		    (lambda (ip)
		      ;; Task.start has better logging than spawn when things go awry
		      (Task.start Ping
				  ":ping_async"
				  (list ip (self)))))
	 (wait (map)
	       (Enum.count all)))
     "@doc \"Given class-C subnet like 192.168.1.x return list of all 254 contained ips\""
     (def ips (subnet)
       (setf subnet (pipe (Regex.run "~r/^\\d+\\.\\d+\\.\\d+\\./" subnet)
			  (Enum.at 0)))
       (pipe
	(Enum.to_list "1..254")
	(Enum.map (lambda (i)
		    (string "#{subnet}#{i}")))))
     (defp wait (results 0)
       results)
     (defp wait (results remaining)
       (receive
	()
	(-> (tuple ":ok" ip pingable?)
	    (do0
	     (setf results (Map.put results ip pingable?))
	     (wait results (- remaining 1))))
	(-> (tuple ":error" ip error)
	    (do0
	     ,(lprint `((inspect error) ip))
	     (wait results (- remaining 1))))))
     )
   (case System.argv
     ((list subnet)
      (setf results (Subnet.ping subnet))
      (pipe results
	    (Enum.filter (lambda ((tuple _ip exists)
				 )
			   exists))
	    (Enum.map (lambda ((tuple ip _))
			ip))
	    Enum.sort
	    (Enum.join (string "\\n"))
	    (IO.puts)))
     (_
      "ExUnit.start"
      (defmodule SubnetTest
	"use ExUnit.Case"
	(space test (string "ips")
	       (progn
		 (setf ips (Subnet.ips (string "192.168.1.x")))
		 (assert (== (Enum.count ips)
			     254))
		 (assert (== (string "192.168.1.1")
			     (Enum.at ips 0)))
		 (assert (== (string "192.168.1.254")
			     (Enum.at ips 253))))))
      ))
   ))   




















 
