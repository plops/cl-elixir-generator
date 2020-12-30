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
	       _code_git_version
		  (string ,(let ((str (with-output-to-string (s)
					(sb-ext:run-program "/usr/bin/git" (list "rev-parse" "HEAD") :output s))))
			     (subseq str 0 (1- (length str)))))
		  _code_repository (string ,(format nil "https://github.com/plops/cl-py-generator/tree/master/example/28_dask_test/source/run_00_start.py")
					   )

		  _code_generation_time
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

	    (setf thing :world)
	    (IO.puts (string "hello #{thing} from elixir"))
	    
	    ,(lprint `((== :apple
			   :orange)))
	    (setf add (lambda (a b)
			(+ a b)))
	    ,(lprint `((add. 1 2)))
	    (setf double (lambda (a) (add. a a)))
	    ,(lprint `((double.  2)))
	    ,(lprint `((inspect (list 1 2 true 3))))
	    ,(lprint `((length (list 1 2 3)))))

	  
	   ))
    (write-source (format nil "~a/source/~a" *path* *code-file*) code)))

