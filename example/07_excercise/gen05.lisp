(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/05_map.exs" *path*)
 `(do0
   "ExUnit.start"
   (defmodule MapTest
     "use ExUnit.Case"
     (def sample ()
       (dict :foo (string "bar")
	     :baz (string "quz")))

     ,@(loop for (e f) in `((Map.get
			     (do0
			      (assert (== (Map.get (sample) ":foo")
					  (string "bar"))))))
	     collect
	     `(space test (string ,e)
		     (progn
		       ,f))))))   





















 
