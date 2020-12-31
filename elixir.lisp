(in-package :cl-elixir-generator)
(setf (readtable-case *readtable*) :invert)

(defparameter *file-hashes* (make-hash-table))

(defun write-source (name code &optional (dir (user-homedir-pathname))
				 ignore-hash)
  (let* ((fn (merge-pathnames (format nil "~a.exs" name)
			      dir))
	(code-str (emit-elixir
		   :clear-env t
		   :code code))
	(fn-hash (sxhash fn))
	 (code-hash (sxhash code-str)))
    (multiple-value-bind (old-code-hash exists) (gethash fn-hash *file-hashes*)
     (when (or (not exists) ignore-hash (/= code-hash old-code-hash))
       ;; store the sxhash of the c source in the hash table
       ;; *file-hashes* with the key formed by the sxhash of the full
       ;; pathname
       (setf (gethash fn-hash *file-hashes*) code-hash)
       (with-open-file (s fn
			  :direction :output
			  :if-exists :supersede
			  :if-does-not-exist :create)
	 (write-sequence code-str s))
       
       #+sbcl (sb-ext:run-program "/usr/bin/mix" (list "format"
						       (namestring fn)))))))

(defun print-sufficient-digits-f64 (f)
  "print a double floating point number as a string with a given nr. of                                                                                                                                             
  digits. parse it again and increase nr. of digits until the same bit                                                                                                                                              
  pattern."

  (let* ((a f)
         (digits 1)
         (b (- a 1)))
    (unless (= a 0)
      (loop while (< 1d-12
		     (/ (abs (- a b))
		       (abs a))
		    ) do
          (setf b (read-from-string (format nil "~,vG" digits a)))
           (incf digits)
	   ))
    (substitute #\e #\d (format nil "~,vG" digits a))))

#+nil
(print-sufficient-digits-f64 1d-12)


(defparameter *env-functions* nil)
(defparameter *env-macros* nil)



(defun emit-elixir (&key code (str nil) (clear-env nil) (level 0))
  ;(format t "emit ~a ~a~%" level code)
  (when clear-env
    (setf *env-functions* nil
	  *env-macros* nil))
  (flet ((emit (code &optional (dl 0))
	   (emit-elixir :code code :clear-env nil :level (+ dl level))))
    ;(format nil "emit-elixir ~a" level)
    (if code
	(if (listp code)
	    (case (car code)
	      (bin (let ((args (cdr code)))
		     (format nil "0b~B" (car args))))
	      (oct (let ((args (cdr code)))
		     (format nil "0o~B" (car args))))
	      (hex (let ((args (cdr code)))
		     (format nil "0x~B" (car args))))
	      #+nil (atom (let ((args (cdr code)))
			    (format nil ":~a" (emit (car args)))))
	      (tuple (let ((args (cdr code)))
		       (format nil "{~{~a,~}}" (mapcar #'emit args))))
	      (paren (let ((args (cdr code)))
		       (format nil "(~{~a~^, ~})" (mapcar #'emit args))))
	      (ntuple (let ((args (cdr code)))
			(format nil "~{~a~^, ~}" (mapcar #'emit args))))
	      (list (let ((args (cdr code)))
		      (format nil "[~{~a~^, ~}]" (mapcar #'emit args))))
	      (curly (let ((args (cdr code)))
		       (format nil "{~{~a~^, ~}}" (mapcar #'emit args))))
              (dict (let* ((args (cdr code)))
		      (let ((str (with-output-to-string (s)
				   (loop for (e f) in args
					 do
					    (format s "(~a):(~a)," (emit e) (emit f))))))
			(format nil "{~a}" ;; remove trailing comma
				(subseq str 0 (- (length str) 1))))))
	      (indent (format nil "~{~a~}~a"
			      (loop for i below level collect "    ")
			      (emit (cadr code))))
	      (do (with-output-to-string (s)
		    (format s "~{~&~a~}" (mapcar #'(lambda (x) (emit `(indent ,x) 1)) (cdr code)))))
	      (class (destructuring-bind (name parents &rest body) (cdr code)
		       (format nil "class ~a~a:~%~a"
			       name
			       (emit `(paren ,@parents))
			       (emit `(do ,@body)))))
	      (do0 (with-output-to-string (s)
		     (format s "~&~a~{~&~a~}"
			     (emit (cadr code))
			     (mapcar #'(lambda (x) (emit `(indent ,x) 0)) (cddr code)))))
	      (space (with-output-to-string (s)
		       (format s "~{~a~^ ~}"
			       (mapcar #'(lambda (x) (emit x)) (cdr code)))))
	      (lambda (destructuring-bind (lambda-list &rest body) (cdr code)
			(multiple-value-bind (req-param opt-param res-param
					      key-param other-key-p aux-param key-exist-p)
			    (parse-ordinary-lambda-list lambda-list)
			  (declare (ignorable req-param opt-param res-param
					      key-param other-key-p aux-param key-exist-p))
			  (with-output-to-string (s)
			    (format s "fn ~a -> ~a~%end"
				    (emit `(ntuple ,@(append req-param
							     (loop for e in key-param collect 
										      (destructuring-bind ((keyword-name name) init suppliedp)
											  e
											(declare (ignorable keyword-name suppliedp))
											(if init
											    `(= ,(emit name) ,init)
											    `(= ,(emit name) "None")))))))
				    (if (cdr body)
					(break "body ~a should have only one entry" body)
					(emit (car body))))))))
	      (def (destructuring-bind (name lambda-list &rest body) (cdr code)
		     (multiple-value-bind (req-param opt-param res-param
					   key-param other-key-p aux-param key-exist-p)
			 (parse-ordinary-lambda-list lambda-list)
		       (declare (ignorable req-param opt-param res-param
					   key-param other-key-p aux-param key-exist-p))
		       (with-output-to-string (s)
			 (format s "def ~a~a:~%"
				 name
				 (emit `(paren
					 ,@(append (mapcar #'emit req-param)
						   (loop for e in key-param collect 
									    (destructuring-bind ((keyword-name name) init suppliedp)
										e
									      (declare (ignorable keyword-name suppliedp))
									      (if init
										  `(= ,name ,init)
										  `(= ,name "None"))))))))
			 (format s "~a" (emit `(do ,@body)))))))
	      (= (destructuring-bind (a b) (cdr code)
		   (format nil "~a=~a" (emit a) (emit b))))
	      (in (destructuring-bind (a b) (cdr code)
		    (format nil "(~a in ~a)" (emit a) (emit b))))
	      (is (destructuring-bind (a b) (cdr code)
		    (format nil "(~a is ~a)" (emit a) (emit b))))
	      (as (destructuring-bind (a b) (cdr code)
		    (format nil "~a as ~a" (emit a) (emit b))))
	      (setf (let ((args (cdr code)))
		      (format nil "~a"
			      (emit `(do0 
				      ,@(loop for i below (length args) by 2 collect
									     (let ((a (elt args i))
										   (b (elt args (+ 1 i))))
									       `(= ,a ,b))))))))
	      (aref (destructuring-bind (name &rest indices) (cdr code)
		      (format nil "~a[~{~a~^,~}]" (emit name) (mapcar #'emit indices))))
	      #+nil (slice (let ((args (cdr code)))
			     (if (null args)
				 (format nil ":")
				 (format nil "~{~a~^:~}" (mapcar #'emit args)))))
	      (dot (let ((args (cdr code)))
		     (format nil "~{~a~^.~}" (mapcar #'emit args))))
	      (+ (let ((args (cdr code)))
		   (format nil "(~{(~a)~^+~})" (mapcar #'emit args))))
	      (- (let ((args (cdr code)))
		   (format nil "(~{(~a)~^-~})" (mapcar #'emit args))))
	      (* (let ((args (cdr code)))
		   (format nil "(~{(~a)~^*~})" (mapcar #'emit args))))
	      (== (let ((args (cdr code)))
		    (format nil "(~{(~a)~^==~})" (mapcar #'emit args))))
	      (=== (let ((args (cdr code)))
		     (format nil "(~{(~a)~^===~})" (mapcar #'emit args))))
	      (<> (let ((args (cdr code))) ;; concatenation
		    (format nil "(~{(~a)~^<>~})" (mapcar #'emit args))))
	      ;; list manipulation
	      (++ (let ((args (cdr code)))
		    (format nil "(~{(~a)~^++~})" (mapcar #'emit args))))
	      (-- (let ((args (cdr code)))
		    (format nil "(~{(~a)~^++~})" (mapcar #'emit args))))
	      (<< (let ((args (cdr code)))
		    (format nil "(~{(~a)~^<<~})" (mapcar #'emit args))))
	      (!= (let ((args (cdr code)))
		    (format nil "(~{(~a)~^!=~})" (mapcar #'emit args))))
	      (!== (let ((args (cdr code)))
		     (format nil "(~{(~a)~^!==~})" (mapcar #'emit args))))
	      (&& (let ((args (cdr code)))
		    (format nil "(~{(~a)~^&&~})" (mapcar #'emit args))))
	      (double_or (let ((args (cdr code)))
			   (format nil "(~{(~a)~^||~})" (mapcar #'emit args))))
	      (! (let ((args (cdr code)))
		   (format nil "!(~a)" (emit (car args)))))
	      (< (let ((args (cdr code)))
		   (format nil "(~{(~a)~^<~})" (mapcar #'emit args))))
	      (<= (let ((args (cdr code)))
		    (format nil "(~{(~a)~^<=~})" (mapcar #'emit args))))
	      (>> (let ((args (cdr code)))
		    (format nil "(~{(~a)~^>>~})" (mapcar #'emit args))))
	      (/ (let ((args (cdr code)))
		   (format nil "((~a)/(~a))"
			   (emit (first args))
			   (emit (second args)))))
	      (** (let ((args (cdr code)))
		    (format nil "((~a)**(~a))"
			    (emit (first args))
			    (emit (second args)))))
	      (// (let ((args (cdr code)))
		    (format nil "((~a)//(~a))"
			    (emit (first args))
			    (emit (second args)))))
	      (% (let ((args (cdr code)))
		   (format nil "((~a)%(~a))"
			   (emit (first args))
			   (emit (second args)))))
	      (and (let ((args (cdr code)))
		     (format nil "(~{(~a)~^ and ~})" (mapcar #'emit args))))
	      (& (let ((args (cdr code)))
		   (format nil "(~{(~a)~^ & ~})" (mapcar #'emit args))))
	      (logand (let ((args (cdr code)))
			(format nil "(~{(~a)~^ & ~})" (mapcar #'emit args))))
	      #+nil (logxor (let ((args (cdr code)))
			      (format nil "(~{(~a)~^ ^ ~})" (mapcar #'emit args))))
	      (|\|| (let ((args (cdr code)))
		      (format nil "(~{(~a)~^ | ~})" (mapcar #'emit args))))
	      (^ (let ((args (cdr code)))
		   (format nil "(~{(~a)~^ ^ ~})" (mapcar #'emit args))))
	      (logior (let ((args (cdr code)))
			(format nil "(~{(~a)~^ | ~})" (mapcar #'emit args))))
	      (or (let ((args (cdr code)))
		    (format nil "(~{(~a)~^ or ~})" (mapcar #'emit args))))
	      (comment (format nil "# ~a~%" (cadr code)))
	      (comments (let ((args (cdr code)))
			  (format nil "~{# ~a~%~}" args)))
	      ;; bitstring .. contiguous sequence of bits in memory
	      ;; <<42>>
	      ;; <<42::8>>
	      ;; <<42::size(8)>>
	      ;; (bitstring 1 2 3 (3 4)) => <<1::8,2::8,3::8,3:;4>>
	      (bitstring (format nil "<<~{~a~^,~}>>" (loop for e in (cdr code)
							   collect
							   (if (listp e)
							       (destructuring-bind (value bitsize) e
								 (format nil "~a::~a" value bitsize))
							       e))))
	      (string (format nil "\"~a\"" (cadr code)))
					;(string-b (format nil "b\"~a\"" (cadr code)))
	      (string3 (format nil "\"\"\"~a\"\"\"" (cadr code))) ;; string3 and heredoc are the same
	      (heredoc (format nil "\"\"\"~a\"\"\"" (cadr code)))
	      (regex (format nil "~~r/~a/" (cadr code)))
					;(rstring3 (format nil "r\"\"\"~a\"\"\"" (cadr code)))
	      (return_ (format nil "return ~a" (emit (caadr code))))
	      (return (let ((args (cdr code)))
			(format nil "~a" (emit `(return_ ,args)))))
	      (case
		  ;; case keyform {normal-clause}* [otherwise-clause]
		  ;; normal-clause::= (keys form*) 
		  ;; otherwise-clause::= (t form*)

		  ;; case <keyform> do
		  ;; key -> form
		  ;; not supported yet: key when condition -> form
		  
		  (destructuring-bind (keyform &rest clauses)
		      (cdr code)
		    (format
		     nil "case (~a) do~%~{~a~%~}~&end"
		     (emit keyform)
		     (loop for c in clauses
			   collect
			   (destructuring-bind (key &rest forms) c
			     (format nil "~&~a -> ~a"
				     (if (eq key t)
					 "_"
					 (emit key))
				     (emit
				      `(do0
					,@forms))))))))
	      (case
		  ;; case keyform {normal-clause}* [otherwise-clause]
		  ;; normal-clause::= (keys form*) 
		  ;; otherwise-clause::= (t form*)

		  ;; case <keyform> do
		  ;; key -> form
		  ;; _ -> form
		  ;; not supported yet: key when condition -> form
		  
		  (destructuring-bind (keyform &rest clauses)
		      (cdr code)
		    (format
		     nil "case (~a) do~%~{~a~%~}~&end"
		     (emit keyform)
		     (loop for c in clauses
			   collect
			   (destructuring-bind (key &rest forms) c
			     (format nil "~&~a -> ~a"
				     (if (eq key t)
					 "_"
					 (emit key))
				     (emit
				      `(do0
					,@forms))))))))
	      (cond
		;; cond {normal-condition}* [otherwise-condition]
		;; normal-condition::= (condition form*) 
		;; otherwise-condtion::= (t form*)

		;; cond do
		;; condition -> form
		;; true -> form
		  
		(destructuring-bind (keyform &rest clauses)
		    (cdr code)
		  (format
		   nil "cond do~%~{~a~%~}~&end"
		     
		   (loop for c in clauses
			 collect
			 (destructuring-bind (key &rest forms) c
			   (format nil "~&~a -> ~a"
				   (if (eq key t)
				       "true"
				       (emit key))
				   (emit
				    `(do0
				      ,@forms))))))))
	      (for (destructuring-bind ((vs ls) &rest body) (cdr code)
		     (with-output-to-string (s)
					;(format s "~a" (emit '(indent)))
		       (format s "for ~a in ~a:~%"
			       (emit vs)
			       (emit ls))
		       (format s "~a" (emit `(do ,@body))))))
	      (for-generator
	       (destructuring-bind ((vs ls) expr) (cdr code)
		 (format nil "~a for ~a in ~a"
			 (emit expr)
			 (emit vs)
			 (emit ls))))
	      (while (destructuring-bind (vs &rest body) (cdr code)
		       (with-output-to-string (s)
			 (format s "while ~a:~%"
				 (emit `(paren ,vs)))
			 (format s "~a" (emit `(do ,@body))))))

	      (if (destructuring-bind (condition true-statement &optional false-statement) (cdr code)
		    (with-output-to-string (s)
		      (format s "if ( ~a ) do~%~a"
			      (emit condition)
			      (emit `(do0 ,true-statement)))
		      (when false-statement
			(format s "~&else~%~a"
				
				(emit `(do0 ,false-statement))))
		      (format s "~&end~%"))))
	      (when (destructuring-bind (condition &rest forms) (cdr code)
                      (emit `(if ,condition
                                 (do0
                                  ,@forms)))))
              (unless (destructuring-bind (condition &rest forms) (cdr code)
                        (with-output-to-string (s)
			  (format s "unless ( ~a ) do~%~a~&end"
				  (emit condition)
				  (emit `(do0 ,@forms)))
			  )))
	      (import (destructuring-bind (args) (cdr code)
			(if (listp args)
			    (format nil "import ~a as ~a~%" (second args) (first args))
			    (format nil "import ~a~%" args))))
	      (imports (destructuring-bind (args) (cdr code)
			 (format nil "~{~a~}" (mapcar #'(lambda (x) (emit `(import ,x))) args))))
	      (with (destructuring-bind (form &rest body) (cdr code)
		      (with-output-to-string (s)
			(format s "~a~a:~%~a"
				(emit "with ")
				(emit form)
				(emit `(do ,@body))))))
	      (try (destructuring-bind (prog &rest exceptions) (cdr code)
		     (with-output-to-string (s)
		       (format s "~&~a:~%~a"
			       (emit "try")
			       (emit `(do ,prog)))
		       (loop for e in exceptions do
			 (destructuring-bind (form &rest body) e
			   (if (member form '(else finally))
			       (format s "~&~a~%"
				       (emit `(indent ,(format nil "~a:" form))))
			       (format s "~&~a~%"
				       (emit `(indent ,(format nil "except ~a:" (emit form))))))
			   (format s "~a" (emit `(do ,@body)))))))
	       
	       #+nil (let ((body (cdr code)))
		       (with-output-to-string (s)
			 (format s "~a:~%" (emit "try"))
			 (format s "~a" (emit `(do ,@body)))
			 (format s "~a~%~a"
				 (emit "except Exception as e:")
				 (emit `(do "print('Error on line {}'.format(sys.exc_info()[-1].tb_lineno), type(e).__name__, e)"))))))
	      (t (destructuring-bind (name &rest args) code
		   
		   (if (listp name)
		       ;; lambda call and similar complex constructs
		       (format nil "(~a)(~a)" (emit name) (if args
							      (emit `(paren ,@args))
							      ""))
		       #+nil(if (eq 'lambda (car name))
				(format nil "(~a)(~a)" (emit name) (emit `(paren ,@args)))
				(break "error: unknown call"))
		       ;; function call
		       (let* ((positional (loop for i below (length args) until (keywordp (elt args i)) collect
													(elt args i)))
			      (plist (subseq args (length positional)))
			      (props (loop for e in plist by #'cddr collect e)))
			 (format nil "~a~a" name
				 (emit `(paren ,@(append
						  positional
						  (loop for e in props collect
							`(= ,(format nil "~a" e) ,(getf plist e))))))))))))
	    
	    (cond
	      ((keywordp code) ;; print an atom
	       (format nil ":~a" code))
	      ((symbolp code) ;; print variable
	       (format nil "~a" code))
	      #+nil ((stringp code)
	       (substitute #\: #\- (format nil "~a" code)))
	      ((numberp code) ;; print constants
	       (cond ((integerp code) (format str "~a" code))
		     ((floatp code)
		      (format str "(~a)" (print-sufficient-digits-f64 code)))
		     ((complexp code)
		      (format str "((~a) + 1j * (~a))"
			      (print-sufficient-digits-f64 (realpart code))
			      (print-sufficient-digits-f64 (imagpart code))))))))
	"")))

