(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/06_record.exs" *path*)
 `(do0
   "ExUnit.start"
   (defmodule User
       (defstruct email "nil"
	 password "nil"))
   (defimpl String.Chars
     User
     (def to_string ((struct User
			     email email))
       email))
   (defmodule RecordTest
     "use ExUnit.Case"
     "require Record"
     )
   ))   





















 
