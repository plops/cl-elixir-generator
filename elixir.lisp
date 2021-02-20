(declaim (optimize (debug 3)
		   (speed 0)
		   (safety 3)))

(in-package :cl-elixir-generator)
(setf (readtable-case *readtable*) :invert)

(defparameter *file-hashes* (make-hash-table))

(defparameter *day-names*
    '("Monday" "Tuesday" "Wednesday"
      "Thursday" "Friday" "Saturday"
      "Sunday"))

#+nil (defun modify-source (fn-part name code &key (comment-style :hash))
    (flet ((comment (str)
	     (case comment-style
	       (:hash (format nil "# ~a" str))
	       (:html (format nil "<!-- ~a -->" str)))))
     (let* (			  ;(fn-part "lib/hello_web/router.ex")
	    (fn-full (format nil "~a/~a" *path* fn-part))
					;(name "route")
	    (fn-part-name (format nil "~a ~a" fn-part name))
	    (start-comment (comment (format nil "USER CODE BEGIN ~a" fn-part-name)))
	    (end-comment (comment (format nil "USER CODE END ~a" fn-part-name)))
	    (a (with-open-file (s fn-full
				  :direction :input)
		 (let ((a (make-string (file-length s))))
		   (read-sequence a s)
		   a))))
       (let* (
	      ;; escape * characters to convert elixir comment to regex
	      (regex (format nil "~a.*~a"
			     (cl-ppcre:regex-replace-all "\\*" start-comment "\\*")
			     (cl-ppcre:regex-replace-all "\\*" end-comment "\\*")))
	      ;; now use the regex to replace the text between the comments
	      (new (cl-ppcre:regex-replace (cl-ppcre:create-scanner regex :single-line-mode t)
					   a
					   (format nil "~a~%~a~%~a" start-comment
						   (case comment-style
						     (:hash (emit-elixir :code code))
						     (:html code ;(spinneret:with-html-string code)
						      ))
						   end-comment))))
	 (with-open-file (s fn-full
			    :direction :output
			    :if-exists :supersede
			    :if-does-not-exist :create)
	   (write-sequence new s))
	 (when (eq comment-style :hash)
	  (sb-ext:run-program "/usr/bin/mix" (list "format"
						   (namestring fn-full
							       )))))))
  )

(defun lprint (rest)
     `(|IO.puts| (string
                ,(format nil "#{__ENV__.file}:#{__ENV__.line} ~{~a~^ ~}"

			 (loop for e in rest
			       collect
			       (format nil "~a=#{~a}"
				       ;(substitute  #\' #\" (emit-elixir :code e))
				       (cl-ppcre:regex-replace-all "\"" (emit-elixir :code e) "\\\"")
				       (emit-elixir :code e)
				       ))))))

(defun write-source (name code &optional (dir (user-homedir-pathname))
				 ignore-hash)
  (let* ((fn (merge-pathnames (format nil "~a" name)
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

(defun consume-declare (body)
  "take a list of instructions from body, parse type declarations,
return the body without them and a hash table with an environment"
  (let ((env (make-hash-table))
	(when-conditions nil)
	(looking-p t) 
	(new-body nil))
    (loop for e in body do
	 (if looking-p
	     (if (listp e)
		 (if (eq (car e) 'declare)
		     (loop for declaration in (cdr e) do
			  (when (eq (first declaration) 'when)
			    (destructuring-bind (instr &rest conditions) declaration
			      (setf when-conditions conditions)))
			  )
		     (progn
		       (push e new-body)
		       (setf looking-p nil)))
		 (progn
		   (setf looking-p nil)
		   (push e new-body)))
	     (push e new-body)))
    (values (reverse new-body) env when-conditions)))

(defun parse-def (code &key (private nil))
  (flet ((emit (code &optional (dl 0))
	   (emit-elixir :code code :clear-env nil :level (+ dl 0))))
   (destructuring-bind (name lambda-list &rest body) (cdr code)
     ;; def <name> ( a, b ) do ..
     ;; def <name> ( [head|tail], accumulator ) do ..
     ;;    (def name ((list (logior head tail)) accumulator) ...
     ;; def <name> ( var \\ default ) do ..
     ;;    (def name (&optional (var default)) ...
     (multiple-value-bind (body env conditions) (consume-declare body) 
       (let* ((pos-opt (position '&optional lambda-list))
			      
	      (req-param (if pos-opt
			     (subseq lambda-list 0 pos-opt)
			     lambda-list))
	      (opt-param (when pos-opt
			   (subseq lambda-list (+ 1 pos-opt))))
	      )
	 ;(format t "pos-opt: ~a req-param: ~a opt-param: ~a ~%" pos-opt req-param opt-param)
	 #+nil(multiple-value-bind
		    (req-param opt-param res-param
		     key-param other-key-p aux-param key-exist-p)
		  (parse-ordinary-lambda-list lambda-list)
		(declare (ignorable req-param opt-param res-param
				    key-param other-key-p aux-param key-exist-p)))
	 (with-output-to-string (s)
			   
	   (format s "~a ~a~a~@[ when ~a~]"
		   (if private
		       "defp"
		       "def")
		   name
		   (emit `(paren
			   ,@req-param
			   ,@(loop for e in opt-param
				   collect
				   (destructuring-bind (var &optional default) e
								   
				     (format nil "~a \\\\ ~a"
					     (emit var)
					     (emit default))))))
		   (when conditions (emit `(and ,@conditions))))
	   (when body
	     (format s " do~%~a" (emit `(do ,@body)))
	     (format s "~&end"))))))))

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
		       (format nil "{~{~a~^,~}}"
					;(mapcar #'emit args)
			       (let ((res ()))
				 (loop for i below (length args) do
				   (let ((arg (elt args i)))
				     (if (keywordp arg)
					 (progn
					   (push (format nil "~a: ~a"
							 (if (find #\. (format nil "~a" arg))
							     (format nil "\"~a\"" arg)
							     arg)
							(emit (elt args (+ 1 i))))
						res
						)
					  (incf i))
					 (push (emit arg) res)))
				       )
				 (reverse res))
			       )))
	      (paren (let ((args (cdr code)))
		       (format nil "(~{~a~^, ~})" (mapcar #'emit args))))
	      (space
		   ;; space {args}*
		   (let ((args (cdr code)))
		     (format nil "~{~a~^ ~}" (mapcar #'emit args))))
	      (ntuple (let ((args (cdr code)))
			(format nil "~{~a~^, ~}" (mapcar #'emit args))))
	      (list (let ((args (cdr code)))
		      (format nil "[~{~a~^, ~}]" #+nil (mapcar #'emit args)
						 (let ((res ()))
				 (loop for i below (length args) do
				   (let ((arg (elt args i)))
				     (if (keywordp arg)
					 (progn
					   (push (format nil "~a: ~a"
							 (if (find #\. (format nil "~a" arg)) ;; quote dot
							     (format nil "\"~a\"" arg)
							     arg)
							(emit (elt args (+ 1 i))))
						res
						)
					  (incf i))
					 (push (emit arg) res)))
				       )
				 (reverse res)))))
	      (cons (let ((args (cdr code)))
		      (format nil "[~a | ~a]"
			      (emit (first args))
			      (emit (second args)))))
	      (keyword-list (let ((args (cdr code)))
			      (format nil "[~{~a~^, ~}]"
				      (loop for (e f) on args by #'cddr
					    collect
					    (format nil "~a: ~a" (emit e) (emit f))))))
	      (plist (emit `(keyword-list ,@(cdr code))))
	      (defstruct (let ((args (cdr code)))
			   ;; defstruct <name> <value> <name2> <value2>
			   ;; <value> can be "nil"
			   (emit `("defstruct" (keyword-list ,@(mapcar #'emit args))
					        ))))
	      
	      (curly (let ((args (cdr code)))
		       (format nil "{~{~a~^, ~}}" (mapcar #'emit args))))
              #+nil (dict (let* ((args (cdr code)))
		      (let ((str (with-output-to-string (s)
				   (loop for (e f) in args
					 do
					    (format s "(~a):(~a)," (emit e) (emit f))))))
			(format nil "{~a}" ;; remove trailing comma
				(subseq str 0 (- (length str) 1))))))
	      (map (let* ((args (cdr code)))
		     (format nil "%{~{~a~^,~}}"
			     (loop for (e f) on args by #'cddr
				   collect
				   (format nil "~a => ~a"
					   (emit e)
					   (emit f))))))
	      (struct (let* ((args (cdr code)))
			;; struct <name> <name1> <value1> <name2> <value2> ...
			(destructuring-bind (name &rest rest) args
			  (format nil "%~a{~{~a~^,~}}"
				  name
				 (loop for (e f) on rest by #'cddr
				       collect
				       (format nil "~a: ~a"
					       (emit e)
					       (emit f)))))))
	      
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
	      (progn (let ((args (cdr code)))
		       (format nil "do~%~{~a~%~}end~%"
			       (mapcar #'emit args))))
	      (lambda (destructuring-bind (lambda-list &rest body) (cdr code)
			(handler-case
			 (multiple-value-bind (req-param opt-param res-param
					       key-param other-key-p aux-param key-exist-p)
			     (parse-ordinary-lambda-list lambda-list)
			   (declare (ignorable req-param opt-param res-param
					       key-param other-key-p aux-param key-exist-p))
			   (with-output-to-string (s)
			     (format s "fn ~a -> ~a~%end"
				     (emit `(paren ,@(append req-param
							     (loop for e in key-param collect 
										      (destructuring-bind ((keyword-name name) init suppliedp)
											  e
											(declare (ignorable keyword-name suppliedp))
											(if init
											    `(= ,(emit name) ,init)
											    `(= ,(emit name) "None")))))))
				     (if (cdr body)
					 (emit `(do0 ,@body)) ; (break "body ~a should have only one entry" body)
					 (emit (car body))))))
			  (simple-program-error ()
			    ;; handle complex types in parameter list
			    (format nil "fn ~{~a~^,~} -> ~a~%end"
				    (mapcar #'emit lambda-list)
				    (if (cdr body)
					 (emit `(do0 ,@body))
					 (emit (car body))))))))
	      (defmodule (let* ((args (cdr code)))
			   (with-output-to-string (s)
			     (format s "defmodule ~a do~%" (car args))
			     (format s "~a" (emit `(do0 ,@(cdr args))))
			     (format s "~&end"))))
	      (defprotocol (let* ((args (cdr code)))
			   (with-output-to-string (s)
			     (format s "defprotocol ~a do~%" (car args))
			     (format s "~a" (emit `(do0 ,@(cdr args))))
			     (format s "~&end"))))
	      (defimpl (let* ((args (cdr code)))
			 ;; defimpl <name> <for> {body*}
			 (destructuring-bind (name for-expr &rest body) args
			      (with-output-to-string (s)
				(format s "defimpl ~a, for: ~a do~%"
					name
					(emit for-expr)
					)
				(format s "~a" (emit `(do0 ,@body)))
				(format s "~&end")))))
	      (defexception (let* ((args (cdr code)))
			      (format nil "defexception message: \"~{~a~^ ~}\""
				      args)))
	      (def (parse-def code :private nil)
	       
	       )
	      (defp (parse-def code :private t))
	      (= (destructuring-bind (a b) (cdr code)
		   (format nil "~a = ~a" (emit a) (emit b))))
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
		     (format nil "~{~a^.~}" (mapcar #'emit args))))
	      (+ (let ((args (cdr code)))
		   (format nil "(~{(~a)~^+~})" (mapcar #'emit args))))
	      (- (let ((args (cdr code)))
		   (format nil "(~{(~a)~^-~})" (mapcar #'emit args))))
	      (* (let ((args (cdr code)))
		   (format nil "(~{(~a)~^*~})" (mapcar #'emit args))))
	      (== (let ((args (cdr code)))
		    (format nil "(~{(~a)~^==~})" (mapcar #'emit args))))
	      (=~ (let ((args (cdr code)))
		    (format nil "(~{(~a)~^=~~~})" (mapcar #'emit args))))
	      
	      (=== (let ((args (cdr code)))
		     (format nil "(~{(~a)~^===~})" (mapcar #'emit args))))
	      (<> (let ((args (cdr code))) ;; concatenation
		    (format nil "(~{(~a)~^<>~})" (mapcar #'emit args))))
	      (\|> (let ((args (cdr code))) ;; pipe
		     (format nil "(~{(~a)~^|>~})" (mapcar #'emit args))))
	      (pipe (let ((args (cdr code))) ;; pipe
		    (format nil "(~{(~a)~^|>~})" (mapcar #'emit args))))
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
	      (& (let ((args (cdr code))) ;; capture operator
		   (format nil "&(~a)" (emit (car args)))))
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
	      #+nil (& (let ((args (cdr code)))
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
	      (charlist (format nil "'~a'" (cadr code)))
	      ;; bitstring .. contiguous sequence of bits in memory
	      ;; <<42>>
	      ;; <<42::8>>
	      ;; <<42::size(8)>>
	      ;; (bitstring 1 2 3 (3 4)) => <<1::8,2::8,3::8,3:;4>>
	      (bitstring (format nil "<<~{~a~^,~}>>" (loop for e in (cdr code)
							   collect
							   (if (listp e)
							       (destructuring-bind (value bitsize) e
								 (format nil "~a::~a" value (emit bitsize)))
							       e))))
	      (string (format nil "\"~a\"" (cadr code)))
	      (string-L (format nil "~~L\"~a\"" (cadr code)))
					;(string-b (format nil "b\"~a\"" (cadr code)))
	      (string3 (format nil "\"\"\"~&~{~a~^ ~}~%\"\"\"" (cdr code))) ;; string3 and heredoc are the same
	      ;(heredoc (format nil "\"\"\"~a\"\"\"" (cadr code)))
	      (regex (format nil "~~r/~a/" (cadr code)))
					;(rstring3 (format nil "r\"\"\"~a\"\"\"" (cadr code)))
	      (return_ (format nil "return ~a" (emit (caadr code))))
	      (return (let ((args (cdr code)))
			(format nil "~a" (emit `(return_ ,args)))))
	      (-> (let ((args (cdr code)))
		    ;; s-expression: (-> a b)
		    ;; elixir: a -> b
		    ;; s-expression: (-> a b c d)
		    ;; elixir: a -> b
		    ;;         c -> d
		    (format t "~&-> ~a~%" args)
		    (with-output-to-string (s)
		      (loop for (e f) on args by #'cddr
			    collect
			    (format s   "~&~a -> ~a~%" (emit e) (emit f)))
		      )))
	      (<- (let ((args (cdr code)))
		 
		    (with-output-to-string (s)
		      (loop for (e f) on args by #'cddr
			    collect
			    (format s   "~a <- ~a" (emit e) (emit f)))
		    )))
	      (receive_old (let ((args (cdr code)))
			 ;; receive do
			 ;;   {:bla, foo} -> foo
			 ;; after
			 ;;   1_000 -> "nothing"
			 ;; end

			 ;; receive <after_body> <body>
			 ;; (receive (1_000 "nothing") (-> (tuple :bla foo) foo))
			 (destructuring-bind ((&rest after-body)
					      &rest body) args
			   (with-output-to-string (s)
			     (format s "receive do~%")
			     (format s "~a" (emit `(do ,@body)))
			     (when after-body
			       (format s "~&after~%")
			       (format s "~a" (emit `(do ,@after-body))))
			     (format s "~&end~%")))
			 ))
	      (receive (let ((args (cdr code)))
			 ;; receive do
			 ;;   {:bla, foo} -> foo
			 ;; after
			 ;;   1_000 -> "nothing"
			 ;; end

			 ;; receive (<clause0> <forms0>) (<clause1> <forms1>) ... [:after <after-code>]
			
			 ;; (receive ((tuple :bla foo) foo) :after (1_000 (setf q (+ 1 2)) (string "nothing"))
			 (destructuring-bind (&rest clause-forms) args
			   (with-output-to-string (s)
			     (format s "receive do~%")
			     (let ((count 0))
			       ;; process clause forms until atom :after is detected
			       (loop for clause-form in clause-forms
				     and i from 0
				     while (listp clause-form)
				     do
				     (destructuring-bind (clause &rest forms) clause-form
				       (setf count i)
				       (format s "~a~%"
					       (emit `(-> ,clause
							  (do0
							   ,@forms))))))
			       (when (< (+ count 1) (length clause-forms))
				(unless (eq (elt clause-forms (+ 1 count))
					    :after)
				  (break "atom :after expected"))
				(format s "~&after~%")
				(destructuring-bind (time &rest cmds) (car (subseq clause-forms
										   (+ 2 count)))
				  (format s "~a~%"
					  (emit `(-> ,time (do0
							    ,@cmds))))))
			         (format s "~&end~%"))))))
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
	      (for (destructuring-bind ((vs ls &rest filters) &rest body) (cdr code)
		     ;; for n <- [1,2,3,4], odd?(n) do
		     ;;   n*n
		     ;; end
		     ;; for (<var> <values> <filter0>) <body>
		     (with-output-to-string (s)
					;(format s "~a" (emit '(indent)))
		       (format s "for ~a <- ~a do~%"
			       (emit vs)
			       (emit `(ntuple ,ls ,@filters)))
		       (format s "~a~%end~%" (emit `(do ,@body))))))
	      (for-bitstring (destructuring-bind ((vs ls &rest filters) &rest body) (cdr code)
		     ;; for <<n <- <<1,2,3,4>>>>, odd?(n) do
		     ;;   n*n
		     ;; end
		     ;; for (<var> <values> <filter0>) <body>
		     (with-output-to-string (s)
					
		       (format s "for <<~a>>~@[~{,~a~}~] do~%"
			       (emit `(<- ,vs
					  ,ls)
				     )
			       (mapcar #'emit filters))
		       (format s "~a~%end~%" (emit `(do ,@body))))))
	      
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
	      (when-i (destructuring-bind (condition form) (cdr code)
			;; inlined when
			;;    when-i <condition> <form>
			;; => <form> when-i <condition>
			(format nil "~a when ~a"
				(emit form)
				(emit condition))))
              (unless (destructuring-bind (condition &rest forms) (cdr code)
                        (with-output-to-string (s)
			  (format s "unless ( ~a ) do~%~a~&end"
				  (emit condition)
				  (emit `(do0 ,@forms)))
			  )))

	      (use (destructuring-bind (&rest args) (cdr code)
		     (format nil "~{use ~a~%~}" (mapcar #'emit args))))
	      (import (destructuring-bind (&rest args) (cdr code)
			 (format nil "~{import ~a~%~}" (mapcar #'emit args))))
	      (with (destructuring-bind (form &rest body) (cdr code)
		      (with-output-to-string (s)
			(format s "~a~a:~%~a"
				(emit "with ")
				(emit form)
				(emit `(do ,@body))))))
	      (try (let ((args (cdr code)))
		     ;; try {expr-block} &key rescue catch after else
		     (format t "~&try: ~a~%" args)
		     (destructuring-bind (prog &key rescue catch after else) args
		       ;(format t "~&try2: prog=~a r=~a c=~a a=~a e=~a~%" (emit prog) (emit rescue) catch after else)
		       
			     (with-output-to-string (s)
			       (format s "try do~%~a"
				       (emit prog))
			       (when rescue
				 (format s "~&rescue~%~a~%"
					 (emit rescue)))
			       (when catch
				 (format s "~&catch~%~a~%"
					 (emit catch)))
			       (when after
				 (format s "~&after~%~a~%"
					 (emit after)))
			       (when else
				 (format s "~&after~%~a~%"
					 (emit else)))
			       (format s "~&end~%"))
			     ))
	       
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
							(format nil "~a: ~a" e (emit (getf plist e))) ))))))))))
	    
	    (cond
	      ((keywordp code) ;; print an atom
	       (format nil ":~a" code)
	       #+nil
	       (if (find #\. (format nil "~a" code))
		   (format nil ":\"~a\"" code) ;; surround with " if contains dot character
		   (format nil ":~a" code))
	       )
	      ((symbolp code) ;; print variable
	       (let ((str (format nil "~a" code)))
		 (if (eq #\@ (aref str 0)) ;; symbols starting with @ are converted to elixir keywords
		     (format nil ":~a" (subseq str 1))
		     (format nil "~a" code))))
	      ((stringp code)
	       code
	       #+nil (substitute #\: #\- (format nil "~a" code)))
	      ((numberp code) ;; print constants
	       (cond ((integerp code) (format str "~a" code))
		     ((floatp code)
		      (format str "(~a)" (print-sufficient-digits-f64 code)))
		     ((complexp code)
		      (format str "((~a) + 1j * (~a))"
			      (print-sufficient-digits-f64 (realpart code))
			      (print-sufficient-digits-f64 (imagpart code))))))))
	"")))


