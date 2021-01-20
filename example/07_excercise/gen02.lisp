(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/02_unit_testing.exs" *path*)
 `(do0
   "ExUnit.start"
   
   (defmodule MyTest
    "use ExUnit.Case"
    (space test (string "simple test")
	   (progn
	     (assert (== (+ 1 1) 2))))
     (space test (string "refute the opposite of assert")
	   (progn
	     (refute (== (+ 1 1) 3))))
     (space test :assert_raise
	   (progn
	     (assert_raise ArithmeticError
			  (lambda () (+ 1 (string "x"))))))
     (space test (string "assert_in_delta asserts that val1 and va2 differ by less than delta.")
	    (progn
	      (assert_in_delta 1 5 6)))

    )))   





















 
