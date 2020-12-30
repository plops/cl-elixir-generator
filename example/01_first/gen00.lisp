(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator")
  (ql:quickload "alexandria"))
(in-package :cl-elixir-generator)


(progn
  (defparameter *path* "/home/martin/stage/cl-elixir-generator/example/01_first")
  (defparameter *code-file* "run_00_start")
  (defparameter *source* (format nil "~a/source/~a" *path* *code-file*))
  (defparameter *day-names*
    '("Monday" "Tuesday" "Wednesday"
      "Thursday" "Friday" "Saturday"
      "Sunday"))
  (defun lprint (rest)
     `(IO.puts (string
                ,(format nil "#{__ENV__.file}:#{__ENV__.line} ~{~a~^ ~}"

			 (loop for e in rest
			       collect
			       (format nil "~a=#{~a}"
				       (emit-elixir :code e)
				       (emit-elixir :code e)
				       ))))))
  (let* (
	 
	 (code
	  `(do0
	    (do0 "# %% imports"
		 

		 (setf
	       code_git_version
		  (string ,(let ((str (with-output-to-string (s)
					(sb-ext:run-program "/usr/bin/git" (list "rev-parse" "HEAD") :output s))))
			     (subseq str 0 (1- (length str)))))
		  code_repository (string ,(format nil "https://github.com/plops/cl-elixir-generator/tree/master/example/01_first/source/run_00_start.py")
					   )

		  code_generation_time
		  (string ,(multiple-value-bind
				 (second minute hour date month year day-of-week dst-p tz)
			       (get-decoded-time)
			     (declare (ignorable dst-p))
		      (format nil "~2,'0d:~2,'0d:~2,'0d of ~a, ~d-~2,'0d-~2,'0d (GMT~@d)"
			      hour
			      minute
			      second
			      (nth day-of-week *day-names*)
			      year
			      month
			      date
			      (- tz)))))
		 )
	    ,(lprint `(code_git_version
		       code_repository
		       code_generation_time))
	    (setf thing :world)
	    (IO.puts (string "hello #{thing} from elixir"))
	    
	    ,(lprint `((== :apple
			   :orange)))
	    (setf add (lambda (a b)
			(+ a b)))
	    ,(lprint `((add. 1 2)))
	    (setf double (lambda (a) (add. a a)))
	    ,(lprint `((double.  2)))
	    ,(lprint `((inspect (++ (list 1 2 3) (list 1 2 true 3)))))
	    ,(lprint `((length (list 1 2 3))))
	    ,(lprint `((tuple_size (tuple :hello  1 2 3))))
	    ;,(lprint `((File.read __ENV__.file)))
	    ;; size .. constant time
	    ;; length .. linear time
	    ,(lprint `((inspect (= (tuple _a _b _c) (tuple :hello  1 2)))))
	    ,(lprint `((inspect (= (list (logior hhead htail))
				      (list 1 2 3)))
		       ))
	    ,(lprint `(hhead
		       htail))
	    (do0
	     (setf x 1)
	     ,(lprint `((inspect (= (tuple y (^ x)) (tuple 2 1)))))
	     ,(lprint `( (inspect (= (tuple y y) (tuple 1 1))))))
	    
	    (do0
	     (setf case_test
		   (case (tuple 1 2 3)
		     ((tuple 4 5 6)
		      (string "won't match"))
		     ((tuple 1 x 3)
		      (string "will match and bind x=#{x}"))
		     (t (string "match otherwise"))))
	     ,(lprint `(case_test)))

	    (do0
	     (setf cond_test
		   (cond
		     ((== (+ 2 2) 5)
		      (string "never true"))
		     ((== (* 2 2) 3)
		      (string "never true"))
		     (t (string "else"))))
	     ,(lprint `(cond_test)))


	    (do0
	     (if nil
		 (string "won't be seen")
		 (string "this will"))
	     (if true
		 (string "this works"))
	     (unless true
	       (string "never"))
	     (when true
	       (string "always")))
	    )
	  
	  
	   ))
    (write-source (format nil "~a/source/~a" *path* *code-file*) code)))

