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
       (map :foo (string "bar")
	     :baz (string "quz")))

     ,@(loop for (e f) in `((Map.get
			     (do0
			      (assert (== (Map.get (sample) ":foo")
					  (string "bar")))
			      (assert (== (Map.get (sample) ":non_existent")
					  "nil"))))
			    ("[]"
			     (do0
			      (assert (== (string "bar")
					  (aref (sample) ":foo")))
			      (assert (== "nil"
					  (aref (sample) ":non_existent")))))
			    ("."
			     (do0
			      (assert (== (string "bar")
					  (dot (sample) foo)))
			      (assert_raise KeyError (lambda ()
						       (dot (sample)
							    non_existent)))))
			    ("Map.fetch"
			     (do0
			      (setf (tuple ":ok" val)
				    (Map.fetch (sample) ":foo"))
			      (assert (== (string "bar")
					  val))
			      (setf ":error"
				    (Map.fetch (sample) ":non_existent"))))
			    ("Map.put"
			     (do0
			      (assert (== (Map.put (sample) ":foo" (string "bob"))
					  (map :foo (string "bob")
					       :baz (string "quz"))))
			      (assert (== (Map.put (sample) ":far" (string "bar"))
					  (map :foo (string "bob")
					       :baz (string "quz")
					       :far (string "bar"))))))
			    ("update map with pattern matching syntax"
			     (do0
			      (assert (== (map :foo (string "bob")
					       :baz (string "quz"))
					  "%{ sample() | foo: 'bob' }"))
			      (assert_raise KeyError (lambda () ;; new key should fail
						       "%{ sample() | far: 'bob' }"))))
			    (Map.values
			     (do0
			      (assert (== (list (string "bar")
						(string "quz"))
					  (Enum.sort (Map.values (sample))))))))
	     collect
	     `(space test (string ,e)
		     (progn
		       ,f))))))   





















 
