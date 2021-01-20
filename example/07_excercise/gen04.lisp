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
     (space test (string "sigil")
	    (progn
	      (assert (== (sample)
			  (~w (space Tim Jen Mac Kai))))))
     (space test (string "head")
	    (progn
	      (setf
	       "[head | _]" (sample))
	      (assert (== head (string "Tim")))))
     (space test (string "tail")
	    (progn
	      (setf
	       "[_ | tail]" (sample))
	      (assert (== tail (~w (space Jen Mac Kai))))))
     (space test (string "last item")
	    (progn
	      (assert (== (string "Kai")
			  (List.last (sample))))))
     (space test (string "delete item")
	    (progn
	      (assert (== (~w (space Tim Jen ; Mac
				     Kai))
			  
			  (List.delete (sample)
				       (string "Mac"))
			  ))
	      (assert (== (list 1 2 3)
			  (List.delete (list 1 2 2 3)
				       2)))))
     ,@(loop for (e f) in `((List.fold
			     (do0
			      (setf list (list 20 10 5 2.5)
				    sum (List.foldr list 0 (lambda (num sum) (+ num sum))))
			      (assert (== 37.5 sum))
			      ))
			    (Enum.reduce
			     
			     (do0
			      (setf list (list 20 10 5 2.5)
				    sum (Enum.reduce list 0 (lambda (num sum) (+ num sum))))
			      (assert (== 37.5 sum))
			      ))
			    (wrap
			     (do0
			      (assert (== (sample)
					  (List.wrap (sample))))
			      (assert (== (list 1)
					  (List.wrap 1)))
			      (assert (== (list)
					  (List.wrap (list))))
			      (assert (== (list)
					  (List.wrap "nil")))))
			    (list-comprehension
			     (do0
			      (setf some (for (n (sample) (< (String.first n)
							     (string "M")))
					      (<> n (string "Morgan"))))
			      (assert (== some
					  (list (string "Jen Morgan")
						(string "Kai Morgan"))))))
			    (manual-reverse-speed
			     (do0
			      (setf (tuple microsec reversed)
				    (":timer.tc"
				     (lambda ()
				       (Enum.reduce "1..1_000_000"
						    (list)
						    (lambda (i l)
						      (List.insert_at l 0 i))))
				     )
				    
				    )
			      (assert (== reversed (Enum.to_list "1_000_000..1")))
			      ,(lprint `(microsec))))
			    (Enum.reverse-speed
			     (setf (tuple microsec reversed)
				   (":timer.tc"
				    (lambda ()
				      (Enum.reverse "1..1_000_000"))))
			     (assert (== reversed (Enum.to_list "1_000_000..1")))
			     ,(lprint `(microsec))))
	     collect
	     `(space test (string ,e)
		     (progn
		       ,f))))))   





















 
