(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/07_excercise/source")

(write-source
 (format nil "~a/01_hello_world.exs" *path*)
 `(do0
   (defmodule LiveViewTodosWeb.TodoLive
     "use LiveViewTodosWeb, :live_view"
     "alias LiveViewTodos.Todos"
     (def mount (_params _session socket)
       (tuple :ok (fetch socket)))
     (def handle_event ("add" (map (string "todo")
				   todo)
			      socket)
       (Todos.create_todo todo)
       ;; get latest todo list items to be displayed to the user
       (tuple :noreply (fetch socket)))
     
     (defp fetch (socket)
       (assign socket :todos (Todos.list_todos)))
     #+nil
     (def render (assigns)
       (string-L "Rendering LiveView")))))   





















 
