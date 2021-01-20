(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/04_list.exs" *path*)
 `(do0
   "ExUnit.start"
   (defmodule ListTest
     "use ExUnit.Case"
     (def sample ()
       (list ,@(loop for e in `(Tim Jen Mac Kai) collect `(string ,e))))
     (space (string "sigil")
	    (progn
	      (assert (== (sample)
			  (~w Tim Jen Mac Kai))))))
   "CowInterrogator.interrogate"
   ))   





















 
