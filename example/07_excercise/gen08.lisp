(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/08_process_ring.exs" *path*)
 `(do0
   (defmodule Pinger
       (def ping (echo limit)
	 (receive
	  ()
	  (-> (when-i (<= count limit)
		(tuple (cons next rest)
		       msg count))
	      (do0
	       ;; got message, send another to next process in ring
	       ,(lprint `((inspect msg)
			  count))
	       (":timer.sleep" 1000)
	       (send next (tuple (++ rest (list next))
				 echo
				 (+ count 1)))
	       (ping echo limit)))
	  (-> (tuple (cons next rest)
		     _
		     _)
	      ;; over our limit of messages, send ok around ring
	      (send next (tuple rest ":ok")))
	  (-> (tuple (cons next rest)
		     ":ok")
	      ;; some said stop, pass along the message
	      (send next (tuple rest ":ok")))
	  )))
   (defmodule Spawner
       (def start ()
	 (setf limit 5)
	 ,@(loop for e in `(foo bar baz)
		 collect
		 `(setf (tuple ,e ,(format nil "_~a_monitor" e))
			(spawn_monitor Pinger ":ping"
				       (list (string ,e)
					     limit))))
	 (send foo (tuple (list bar baz foo)
			  (string "start")
			  0))
	 (wait (list foo bar baz)))
     "@doc \"Waits for all processes to finish before exiting.\"  "
     (def wait (pids)
       ,(lprint `((string "wait") (inspect pids)))
       (receive ()
		(-> (tuple ":DOWN" _ _ pid _)
		    (do0
		     ,(lprint `((string "quit") (inspect pid)))
		     (setf pids (List.delete pids pid))
		     (unless (Enum.empty? pids)
		       (wait pids))))))
     )
   "Spawner.start"))   





















 
