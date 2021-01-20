(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/03_input_output.exs" *path*)
 `(do0   
   (defmodule CowInterrogator
     (space @doc (string3 "Gets name from standard IO"))
     (def get_name ()
       (pipe (IO.gets (string "what is your name? "))
	     String.trim))
     (def get_cow_lover ()
       (IO.getn (string "do you like cows? [y|n]") 1))
     (def interrogate ()
       (setf name (get_name)
	     )
       (case (String.downcase (get_cow_lover))
	 ((string "y")
	  (IO.puts (string "great! here is a cow for you #{name}:"))
	  (IO.puts (cow_art)))
	 ((string "n")
	  (IO.puts (string "that is a shame, #{name}.")))
	 (t (IO.puts (string "you should have entered 'y' or 'n'.")))))
     (def cow_art ()
       (setf path (Path.expand (string "support/cow.txt") __DIR__))
       (case (File.read path)
	 ((tuple :ok art)
	  art)
	 ((tuple :error _)
	  (IO.puts (string "error: cow.txt file not found"))
	  (System.halt 1))))

     )

   "ExUnit.start"
   (defmodule InputOutputTest
     "use ExUnit.Case"
     "import String"
     (space test (string "checks if cow_art returns string from support/cow.txt")
	    (progn
	      (setf art (CowInterrogator.cow_art))
	      (assert (== (pipe (trim art)
			     first
			     )
			  (string "("))))))
   "CowInterrogator.interrogate"
   ))   





















 
