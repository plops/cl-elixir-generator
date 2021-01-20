(asdf:defsystem cl-elixir-generator
    :version "0"
    :description "Emit Elixir code"
    :maintainer " <kielhorn.martin@gmail.com>"
    :author " <kielhorn.martin@gmail.com>"
    :licence "GPL"
    :depends-on ("alexandria" "cl-ppcre")
    :serial t
    :components ((:file "package")
		 (:file "elixir")) )
