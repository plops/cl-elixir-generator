(declaim (optimize (debug 3)
		   (speed 0)
		   (safety 3)))

(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator")
  (ql:quickload "alexandria")
  (ql:quickload "cl-ppcre"))
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
				       ;(substitute  #\' #\" (emit-elixir :code e))
				       (cl-ppcre:regex-replace-all "\"" (emit-elixir :code e) "\\\"")
				       (emit-elixir :code e)
				       ))))))
  (let* (
	 
	 (code
	  `(do0
	    (do0 (comments " comment")
		 

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
		     ((tuple 1  x 3)
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
	       (string "always"))
	     ("if" false (keyword-list do :this
				     else :that)))


	    (do0
	     (comments "bitstring")
	     ,(lprint `((=== (bitstring 42)
			     (bitstring (42 8)))))
	     ,(lprint `((== (bitstring (0 1)
				       (0 1)
				       (1 1)
				       (1 1))
			    (bitstring 3 4))))
	     ,(lprint `((=== (bitstring 1)
			     (bitstring 257))))
	     (do0 ,(lprint `((= (bitstring 0 1 x)
			    (bitstring 0 1 2))
			     ))
		  ,(lprint `(x))))
	    (do0 ,(lprint `((= (bitstring (head (binary-size 2))
					  (rest binary))
			       (bitstring 0 1 2 3))))
		 ,(lprint `(head rest)))
	    (do0 ,(lprint `((= (bitstring head
					  (rest binary))
			       (string "banana"))))
		 ,(lprint `(head rest)))
	    
	    (do0
	   (comments "charlist")
	   (setf q (charlist "hello"))
	   ,(lprint `(q)))
	    
	    (do0
	     (comments "keyword lists")
	     ,(lprint `((== (list (tuple :a 1)
				  (tuple :b 2))
			    (keyword-list a 1
					  b 2)))))
	    (do0
	     (comments "map")
	     (setf map (map :a 1
			    2 :b)))


	    (do0
	     (comments "module")
	     (defmodule Math
		 (def sum (a b)
		   (+ a b))
	       (defp do_sum (a b)
		 (+ a b)
		 )
	       (def zero? (0)
		 true)
	       (def zero? (x)
		 (declare (when (is_integer x)))
		 false)
	       )
	     ,(lprint `((Math.sum 1 2)))
	     ,(lprint `((Math.zero? 0)
			(Math.zero? 1)))
	     ;,(lprint `((Math.do_sum 1 2)))
	     )

	     (do0
	     (comments "named function with default argument")
	     (defmodule Concat
		 
		 (def join (a &optional (b "nil") (sep (string " ")))
		  )
	       (def join (a b _sep)
		 (declare (when (is_nil b)))
		 a)
	       (def join (a b sep)
		   (<> a sep b)))
	     ,(lprint `((Concat.join (string "hello")
				     (string "world"))))
	     ,(lprint `((Concat.join (string "hello")
				     (string "world")
				     (string "_"))))
	     ,(lprint `((Concat.join (string "hello")
				     ))))

	    (do0
	     (defmodule MathRec
		 (def sum_list ((list (logior head tail))
				accumulator)
		   (sum_list tail (+ head accumulator)))
	       (def sum_list ("[]" accumulator)
		 accumulator))
	     ,(lprint `((MathRec.sum_list (list 1 2 3)
					  0)))
	     )

	    (do0
	     (comment "pipe operator")
	     (setf odd? (lambda (x)
			  (!= 0 (rem x 2))))
	     ,(lprint `(
			(pipe "1..100_000"
			      (Enum.map (lambda (x) (* x 3))
					)
			      (Enum.filter odd?)
			      Enum.sum)))
	     ,(lprint `(
			(pipe "1..100_000"
			      (Stream.map (lambda (x) (* x 3))
					)
			      (Stream.filter odd?)
			      Enum.sum))))
	    

	    (do0
	     (comments "spawn")
	     (setf pid
		   (spawn (lambda () (+ 1 2))))
	     ,(lprint `((inspect pid) (Process.alive? pid)
				      ))
	     ,(lprint `((inspect (self))
			(Process.alive? (self)))))


	    (do0
	     (comments "messages")
	     (setf parent (self))
	     (spawn (lambda ()
		      (send parent (tuple :hello (self)))))
	     (receive ()
		      (-> (tuple :hello pid)
			  ,(lprint `((string "got hello from #{inspect pid}"))))
		      ))

	    (do0
	     (comments "state")
	     (defmodule KV
		 (space @moduledoc (string3 "module example for state"))
		 (def start_link ()
		   (Task.start_link (lambda ()
				      (loop (map))))
		   )
	       (defp loop (map)
		 (receive ()
		  (-> (tuple :get key caller)
		      (do0 (send caller (Map.get map key))
			   (loop map)))
		  (-> (tuple :put key value)
		      (loop (Map.put map key value))))))
	     ,(lprint `((inspect (setf (tuple :ok pid)
			       (KV.start_link)))))
	     ,(lprint `((inspect (send pid (tuple :get :hello (self))))))

	     (do0
	      (comments "struct")
	      (defmodule User
		  (defstruct name (string "John")
		    age 27))
	      ;; needs compilation before use
	      #+nil ,(lprint `((struct User
				name (string "Jane")))))
	     (do0
	      (comments "protocol")
	      (defprotocol Utility
		  (space @spec (type "t") "::" (String.t))
		(def type (value)))
	      ,@(loop for e ; (e f)
			in `(;(BitString string)
				     ;(Integer integer)
				     Atom BitString Float Function Integer List Map PID Port Reference Tuple)
		      collect
		      `(defimpl Utility ,e
			 (def type (_value)
			   (string ,e))))
	      ,(lprint `((inspect (Utility.type (string "foo")))))
	      ,(lprint `((inspect (Utility.type 123))))

	       
	      )

	     (do0
	      (comments "comprehension")
	      (for (n (list 1 2 3 4))
		   (* n n))
	      (setf multiple_of_3? (lambda (n) (== (rem n 3) 0)))
	      (for (n (list 1 2 3 4) (multiple_of_3?. n))
		   (* n n))

	      (do0
	       (setf dirs (list (string "/home")
				(string "/tmp")))
	       (for (dir dirs
			 (<- file (File.ls! dir))
			 (= path (Path.join dir file))
			 (File.regular? path))
		    (dot (File.stat! path)
			 size))))

	     (do0
	      (comments "bitstring generator")
	      (setf pixels (bitstring 213 45 132 64 32 12 45 31 9 0 0 231))
	      (for-bitstring ((ntuple "r::8" "g::8" "b::8")
			      pixels)
			     (tuple r g b)))

	     (do0
	      (comments "into .. remove whitespace")
	      (for-bitstring (c (string "hello world ")
				(!= c "?\\s")
				(space "into:" (string "")))
			     (bitstring c)))

	     (do0
	      (comments "into .. transform map")
	      (for ((tuple key val)
		    (map (string "a") 1
			 (string "b") 2)
		    (space "into:" (map)))
		   (tuple key (* val val))))


	     (do0 (comments "sigils")

		  ;; ~r"foo"i is equivalent to sigil_r(<<"foo">>,'i')
		  ;; get documentation with h sigil_r
		  ;; regex ~r/hello/
		  ;; allowed characters / | " ' ( [ { <
		  ;; string ~s/this is a string/
		  ;; char-list ~c/this is a char list/
		  ;; word-list ~w/this is a word list/ => ["this", "is" ...]
		  ;; word list as atoms ~w/foo bar bat/a
		  ;;   allowed modifiers: c (char-list) s (string) a (atoms)

		  ;; upper case sigil variants don't allow escape codes and interpolation
		  ;; ~s/string with interpolation #{bla}/
		  ;; escape codes: \ a b d e f n r s t v 0 xDD uDDDD "

		  ;; ~S"""avoid double-escape with uppercase heredoc sigil"""

		  ;; %Date{} ~D[2019-10-31]
		  ;; %Time{} ~T[23:00:07.0]
		  ;; %NativeDateTime{} ~N[2019-10-31 23:00:07]
		  ;; %DateTime{} ~U[2019-10-31 23:00:07Z] has field for timezone
 		  )

	     (do0 (comments "errors")
		  (defmodule MyError
		      (defexception default message))
					;(raise MyError)

		  (try
		   (raise (string "oops"))
		   :rescue
		   
		   (-> (in e RuntimeError)
			     e))
		  )
	     )

	    
	    
	    )
	  

	  
	  

	  
	  
	   ))
    (write-source (format nil "~a/source/~a" *path* *code-file*) code)))

