(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/17_dining_philosophers.exs" *path*)
 `(do0
   (defmodule Philosopher
       (defstruct
	   name "nil"
	 ate 0
	 thought 0))
   (def simulate ()
     (setf forks (list ,@(loop for i below 5 collect
					     (format nil ":fork~a" i))))
     (setf table (spawn_link Table
			     ":manage_resource"
			     (list forks)))
     ,@(loop for e in `(Aris
			Kant
			Spin
			Marx
			Russ)
	     collect
	     `(spawn Dine ":dine"
		     (list (struct Philosopher
				   name (string ,e))
			   table)))
     (receive
     
      (_ ":ok")))
   (def manage_resources (forks &optional (waiting (list)))
     (when (< 0 (length waiting))
       (setf names (for ((tuple _ phil)
			 waiting)
			phil.name))
       
       ,(lprint `((length waiting)
		  names))
       (when (<= 2 (length forks))
	 (setf (cons (tuple pid _)
		     waiting)
	       waiting
	       (cons "fork1, fork2"
		     forks)
	       forks)
	 (send pid (tuple :eat (list fork1 fork2))))
       (receive
	
	( (tuple :sit_down pid phil)
	    (manage_resources forks (cons (tuple pid phil)
					  waiting)))
	( (tuple :give_up_seat
		   free_forks _)
	    (setf forks (++ free_forks forks))
	  ,(lprint `((length forks)))
	  (manage_resources forks waiting)))))
   (defmodule Dine
       (def dine (phil table)
	 (send table (tuple :sit_down self phil))
	 (receive
	  
	  ((tuple :eat forks )
	   (setf phil (eat phil forks table)
		 phil (think phil table))))))
   ))




















 
