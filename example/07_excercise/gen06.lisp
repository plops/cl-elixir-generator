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
     (defmodule ScopeTest
       "use ExUnit.Case"
       "require Record"
       (Record.defrecord ":person"
			 :first_name "nil"
			 :last_name "nil"
			 :age "nil")
       (space test (string "defrecordp")
	      (progn
		(setf p (person :first_name (string "Kai")
				:last_name (string "Morgan")
				:age 5))
		(assert (== p (tuple :person (string "Kai") (string "Morgan") 5))))))
     ;; (CompileError) source/06_record.exs:28: undefined function person/0
     #+nil
     (space test (string "defrecordp out of scope")
	  (progn (person)))

     (def sample ()
       (struct User email (string "kay@example.com")
		    password (string "trains")))
     
     ,@(loop for (e f) in
	     `(#+nil (defstruct
		   (do0
		    (assert (== (sample)
				(map __struct__ User
				     email (string "kai@example.com")
				     password (string "trains"))))))
	       (property
		   (do0
		    (assert (== (dot (sample)
				     email)
				(string "kai@example.com")))))
	       (update
		(do0
		 (setf u (sample)
		       u2 (space %User (curly  "u | email: \"tim@example.com\"")))
		 (assert (== u2
			     (struct User email (string "tim@example.com")
				     password (string "trains"))))))
	       (protocol
		(do0
		 (assert (== (to_string (sample)
					)
			     (string "kai@example.com"))))))
	     collect
	     `(space test (string ,e)
		     (progn
		       ,f)))
     
     )   

   
   ))   





















 
