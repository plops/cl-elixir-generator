;(ql:quickload "optima")
;(ql:quickload "alexandria")
(defpackage :cl-elixir-generator
  (:use :cl
	;:optima
	:alexandria)
  (:export
   #:write-source
   ))
