(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/08_minimal_live/source")

(let
    ((l
       `((config/config.exs
	  (do0
	   (use Mix.Config)
	   (config @q
		   :ecto_repos (list Q.Repo))
	   (config @q
		   QWeb.Endpoint
		   :url (plist host (string "localhost"))
		   :secret_key_base (string "Wy+j/oXYSmC2gLpNSuAz8XCEbUhLc0s4YoBTjx9aI9vRJsTPcemst6T6pu0BFp5A")
		   :render_errors (plist
				   view QWeb.ErrorView
				   accepts (~w "html json")
				   layout false)
		   :pubsub_server Q.PubSub
		   :live_view (plist signing_salt (string "gu7elorQ")))
	   (config @logger
		   @console
		   :format (string "$time $metadata[$level] $messag\\n")
		   :metadata (list @request_id))
	   (config @phoenix
		   @json_library
		   Jason)
	   (import_config (string "#{Mix.env()}.exs"))))
	 (config/dev.exs
	  (do0
	   (use Mix.Config)
	   (config @q
		   Q.Repo
		   :username (string "postgres")
		   :password (string "postgres")
		   :database (string "q_dev")
		   :hostname (string "localhost")
		   :show_sensitive_data_on_connection_error true
		   :pool_size 10)
	   (config @q
		   QWeb.Endpoint
		   :http (plist port 4000)
		   :debug_errors true
		   :code_reloader true
		   :check_origin false
		   :watchers (plist node (list (string "node_modules/webpack/bin/webpack.js")
					       (string "--mode")
					       (string "development")
					       (string "--watch-stdin")
					       "cd: Path.expand(\"../assets\",__DIR__)")))
	   ;; https cert config would go here
	   (config @q
		   QWeb.EndPoint
		   :live_reload (plist patterns
				       (list
					"~r\"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$\""
					"~r\"priv/gettext/.*(po)$\""
					"~r\"lib/q_web/(live|views)/.*(ex)$\""
					"~r\"lib/q_web/templatex/.*(eex)$\""

					)))
	   (config @logger
		   @console
		   :format (string "[$level] $message\\n"))
	   (config @phoenix
		   @stacktrace_depth 20)
	   (config @phoenix
		   @plug_init_mode
		   @runtime)
	   ))
	 ;; (config/prod.exs)
	 ;; (config/prod.secret.exs)
	 (config/test.exs
	  (do0
	   (config @q
		   Q.Repo
		   :username (string "postgres")
		   :password (string "postgres")
		   :database (string "q_test#{System.get_env(\"MIX_TEST_PARTITION\")}")
		   :hostname (string "localhost")
		   :pool Ecto.Adapters.SQL.Sandbox)
	   (config @q
		   QWeb.Endpoint
		   :http (plist port 4002)
		   :server false)
	   (config @logger :level @warn)
	   ))
	 (lib/q/application.ex
	  (do0
	   (defmodule Q.Application
	     "@moduledoc false"
	     (use Application)
	     (def start (_type _args)
	       (setf children (list Q.Repo
				    QWeb.Telemetry
				    (curly Phoenix.PubSub "name: Q.PubSub")
				    QWeb.EndPoint))
	       (setf opts (plist strategy @one_for_one
				 name Q.Supervisor))
	       (Supervisor.start_link children opts))
	     (def config_change (changed _new removed)
	       (QWeb.Endpoint.config_change changed removed)
	       @ok)
	    )
	   ))
	 (lib/q.ex
	  (defmodule Q))
	 (lib/q/repo.ex
	  (defmodule Q.Repo
	      ("use" Ecto.Repo
		     :otp_app @q
		     :adapter Ecto.Adapters.Postgres)))
	 (lib/q_web/channels/user_socket.ex
	  (defmodule QWeb.UserSocket
	      (use Phoenix.Socket)
	    "@impl true"
	    (def connect (_params socket _connect_info)
	      (tuple @ok
		     socket))
	    "@impl true"
	    (def id (_socket)
	      "nil")))
	 (lib/q_web/endpoint.ex
	  (defmodule QWeb.Endpoint
	      ("use" Phoenix.Endpoint
		     :otp_app @q)
	    (space "@ession_options"
		   (plist store @cookie
			  key (string "_q_key")
			  signing_salt (string "r0i/aYVY")))
	    (socket (string "/socket")
		    QWeb.UserSocket
		    :websocket true
		    :longpoll false)
	    (socket (string "/live")
		    Phoenix.LiveView.Socket
		    :websocket (plist connect_info (plist session "@session_options")))

	    (plug Plug.Static
		  :at (string "/")
		  :from @q
		  :gzip false ;; FIXME: true in production
		  :only (~w "css fonts images js favicon.ico robots.txt"))
	    (when code_reloading?
	      (socket (string "/phoenix/live_reload/socket")
		      Phoenix.LiveReloader.Socket)
	      (plug Phoenix.LiveReloader)
	      (plug Phoenix.CodeReloader)
	      (plug Phoenix.Ecto.CheckRepoStatus :otp_app @q))
	    (plug Phoenix.LiveDashboard.RequestLogger
		  :param_key (string "request_logger")
		  :cookie_key (string "request_logger"))
	    (plug Plug.RequestId)
	    (plug Plug.Telemetry :eventprefix (list @phoenix @endpoint))
	    (plug Plug.Parsers
		  :parsers (list @urlencoded @multipart @json)
		  :pass (list (string "*/*"))
		  :json_decoder (Phoenix.json_library))
	    (plug Plug.MethodOverride)
	    (plug Plug.Head)
	    (plug Plug.Session "@session_options")
	    (plug QWeb.Router)))
	 (lib/q_web.ex
	  (defmodule QWeb
	      (def controller ()
		  (space quote
			 (progn
			   ("use" Phoenix.Controller :namespace QWeb)
			   (import Plug.Conn
				   QWeb.Gettext)
			   (alias QWeb.Router.Helpers
				  :as Routes)))
		)
	    (def view ()
	      (space quote
		     (progn
		      ("use" Phoenix.View
			     :root (string "lib/q_web/templates")
			     :namespace QWeb)
		      ("import" Phoenix.Controller
				:only (plist get_flash 1
					     get_flash 2
					     view_module 1
					     view_template 1))
		      (unquote (view_helpers)))))
	    (def live_view ()
	      (space quote
		     (progn ("use" Phoenix.LiveView
				   :layout (tuple QWeb.LayoutView
						  (string "live.html")))
			    (unquote (view_helpers)))))
	     (def live_component ()
	      (space quote
		     (progn (use Phoenix.LiveComponent)
			    (unquote (view_helpers)))))
	    (def router ()
	      (space quote
		     (progn (use Phoenix.Router)
			    (import Phoenix.Controller
				    Phoenix.LiveView.Router))))
	    (def channel ()
	      (space quote
		     (progn (use Phoenix.Channel)
			    (import QWeb.Gettext))))
	    (defp view_helpers ()
	      (space quote
		     (progn
		       (use Phoenix.HTML)
		       (import Phoenix.LiveView.Helpers
			       Phoenix.View
			       QWeb.ErrorHelpers
			       QWeb.Gettext)
		       (alias QWeb.Router.Helpers :as Routes)))
	      )
	    (space defmacro
		   (__using__ which)
		   when
		   (is_atom which)
		   (progn
		     (apply __MODULE which (list))))))
	 (lib/q_web/gettext.ex
	  (defmodule QWeb.Gettext
	      ("use" Gettext :otp_app @q)
	    #+nil (do0
		   (import QWeb.Gettext)
		   (gettext (string "here is the string to translate"))
		 (ngettext (string "here is the string to translate")
			   (string "here are the strings to translate")
			   3)
		 (degttext (string "errors")
			   (string "here is the error message to translate")))
	    ))
	 
	 (lib/q_web/live/page_live.ex
	  (defmodule QWeb.PageLive
	      ("use" QWeb @liveview)
	    "@impl true"
	    (def mount (_params _session socket)
	      (tuple @ok
		     (assign socket
			     :results (map)
			     :query (string ""))))
	    "@impl true"
	    (def handle_event ((string "suggest")
			       (map (string "q")
				    query)
			       socket)
	      (tuple @noreply
		     (assign socket
			     :results (search query)
			     :query query)))
	    "@impl true"
	    (def handle_event ((string "search")
			       (map (string "q")
				    query)
			       socket)
	      (case (search query)
		((map ^query vsn)
		 (tuple @noreply
			(redirect socket @external (string "https://hexdocs.pm/#{query}/#{vsn}"))))
		(_ (tuple @noreply
			  (pipe socket
				(put_flash @error
					   (string "no dependencies found matching '#{query}'"))
				(assign :results (map)
					:query query))))))
	    (defp search (query)
	      (unless (QWeb.Endpoint.config @code_reloader)
		(raise (string "action disabled when not in development")))
	      (for ((tuple app desc vsn)
		    (Application.started_applications)
		    (setf app (to_string app))
		    (and (String.starts_with? app query)
			 (not (List.starts_with? desc "~c\"ERTS\"")))
		    (space "into:" (map)))
		   (tuple app vsn)
		   
		   ))))
	 (lib/q_web/router.ex
	  (defmodule QWeb.Router
	      ("use" QWeb @router)
	    (space pipeline @browser
		   (progn
		     (plug @accepts (list (string "html")))
		     (plug @fetch_session)
		     (plug @fetch_live_flash)
		     (plug @put_root_layout (tuple QWeb.LayoutView @root))
		     (plug @protect_from_forgery)
		     (plug @put_secure_browser_headers)))
	    (space pipeline @api
		   (progn
		     (plug @accepts (list (string "json")))))
	    (scope (string "/")
		   QWeb)
	    (progn
	      (pipe_through @browser)
	      (live (string "/")
		    PageLive
		    @index))
	    (when (in (Mix.env)
		      (list @dev @test))
	      (import Phoenix.LiveDashboard.Router)
	      (scope (string "/")
		     )
	      (progn (pipe_through @browser)
		     (live_dashboard (string "/dashboard")
				     :metrics QWeb.Telemetry)))))
	 (lib/q_web/telemetry.ex
	  (defmodule QWeb.Telemetry
	      (use Supervisor)
	    (import Telemetry.Metrics)
	    (def start_link (arg)
	      (Supervisor.start_link __MODULE__ args :name __MODULE__))
	    "@impl true"
	    (def init (_arg)
	      (setf children (list (tuple
				    @telemetry_poller
				    :measurements (periodic_measurements)
				    :period 10_000)))
	      (Supervisor.init children :strategy @one_for_one))
	    (def metrics
		(list (summary (string "phoenix.endpoint.stop.duration")
			       :unit (tuple @native @millisecond))
		      (summary (string "phoenix.router_dispatch.stop.duration")
			       :tags (list @route)
			       :unit (tuple @native @millisecond))
		      ,@(loop for e in `(total decode query queue idle)
			      collect
			      `(summary (string ,(format nil "q.repo.query.~a_time" e))
					:unit (tuple @native @millisecond)))
		      (summary (string "vm.memory.total")
			       :unit (tuple @byte @kilobyte))
		      ,@(loop for e in `(total cpu io)
			      collect
			      `(summary (string ,(format nil "vm.total_run_queue_length.~a" e))))
		      ))
	    (defp periodic_measurements ()
	      (list)))
	  )
	 (lib/q_web/views/error_helpers.ex
	  (defmodule QWeb.ErrorHelpers
	      (use Phoenix.HTML)
	    (def error_tag (form field)
	      (Enum.map
	       (Keyword.get_values form.errors field)
	       (lambda (error)
		 (content_tag @span (translate_error error)
			      :class (string "invalid-feedback")
			      :phx_feedback_for (input_id form field)))))
	    (def translate_error ((tuple msg opts))
	      (if (= count (aref opts @count))
		  (Gettext.dngettext QWeb.Gettext (string "errors")
				     msg msg count opts)
		  (Gettext.dngettext QWeb.Gettext (string "errors")
				     msg opts)))))
	 (lib/q_web/views/error_view.ex
	  (defmodule QWeb.ErrorView
	      ("use" QWeb @view)
	    (def template_not_found (template _assigns)
	      (Phoenix.Controller.status_message_from_template template))))
	 (lib/q_web/views/layout_view.ex
	  (defmodule QWeb.LayoutView
	    ("use" QWeb @view)))
	 (mix.exs
	  (defmodule Q.MixProject
	      (use Mix.Project)
	    (def project ()
	      (list
	       :app @q
	       :version (string "0.1.0")
	       :elixir (string "~> 1.7")
	       :elixirc_paths (elixirc_paths (Mix.env))
	       :compilers (++ (list @phoenix
				    @gettext)
			      (Mix.compilers))
	       :start_permanent (== (Mix.env)
				    @prod)
	       :aliases (aliases)
	       :deps (deps)))
	    (def application ()
	      (list :mod (tuple Q.Application (list))
		    :extra_applications (list @logger
					      @runtime_tools)))
	    (defp elixirc_paths (@test)
	      (list (string "lib")
		    (string "test/support")))
	    (defp elixirc_paths (_)
	      (list (string "lib")))
	    (defp deps ()
	      (list
	       ,@(loop for e in
		       `((phoenix 1.5.7)
			 (phoenix_ecto 4.1)
			 (ecto_sql 3.4)
			 (postgrex 0.0.0 :op >=)
			 (phoenix_live_view 0.15.0)
			 (floki 0.27.0 :op >= :only @test)
			 (phoenix_html 2.11)
			 (phoenix_live_reload 1.2 :only @dev  )
			 (phoenix_live_dashboard 0.4)
			 (telemetry_metrics 0.4)
			 (telemetry_poller 0.4)
			 (gettext 0.11)
			 (jason 1.0)
			 (plug_cowboy 2.0))
		       collect
		       (destructuring-bind (name version &key (op '~>) only) e
			 (if only
			     `(tuple ,(format nil ":~a" name)
				 (string ,(format nil "~a ~a" op version))
				 :only ,only)
			    `(tuple ,(format nil ":~a" name)
				 (string ,(format nil "~a ~a" op version))
				 ))))))
	    (defp aliases ()
		(list
		 :setup (list (string "deps.get")
			      (string "ecto.setup")
			      (string "cmd npm install --prefix assets"))
		 ;; if the following keyword is invalid, add code in elixir.lisp to write it as :"ecto.setup"
		 :ecto.setup (list (string "ecto.create")
				   (string "ecto.migrate")
				   (string "run priv/repo/seeds.exs"))
		 :ecto.reset (list (string "ecto.drop")
				   (string "ecto.setup")
				   )
		 :test (list (string "ecto.create --quiet")
			     (string "ecto.migrate --quiet")
			     (string "test"))
		 ))))
	 (priv/repo/migrations/.formatter.exs
	  (list :import_deps (list @ecto_sql)
		:inputs (list (string "*.exs"))))
	 (priv/repo/seeds.exs
	  (do0
	   ))
	 (test/q_web/live/page_live_test.exs
	  (defmodule QWeb.PageLiveTest
	      (use QWeb.ConnCase)
	    (import Phoenix.LiveViewTest)
	    (test (string "disconnected and connected render")
		  (map :conn conn))
	    (progn
	      (setf (tuple @ok
			   page_live
			   disconnected_html)
		    (live conn (string "/")))
	      (assert (=~ disconnected_html
			  (string "Welcome to Phoenix!")))
	      (assert (=~ (render page_live)
			  (string "Welcome to Phoenix!"))))
	   ))
	 (test/q_web/views/error_view_test.exs
	  (defmodule QWeb.ErrorViewTest
	      ("use" QWeb.ConnCase
		     :async true)
	    (import Phoenix.View)
	    (do0 (test (string "renders 404.html")
		       )
		 (progn (assert (== (render_to_string (QWeb.ErrorView (string "404.html") (list)))
				    (string "Notfound")))))
	    (do0 (test (string "renders 500.html")
		       )
		 (progn (assert (== (render_to_string (QWeb.ErrorView (string "500.html") (list)))
				    (string "Internal Server Error")))))))
	 (test/q_web/views/layout_view_test.exs
	  (defmodule QWeb.LayoutViewTest
	    ("use" QWeb.ConnCase :async true)))
	 (test/support/channel_case.ex
	  (defmodule QWeb.ChannelCase
	      (use ExUnit.CaseTemplate)
	    (space "using"
		   (progn
		     (space "quote"
			    (progn
			      (import Phoenix.ChannelTest
				      QWeb.ChannelCase)
			      "@endpoint QWeb.Endpoint"))))
	    (space setup tags
		   (progn
		     (setf @ok (Ecto.Adapters.SQL.Sandbox.checkout Q.Repo))
		     (unless (aref tags @async)
		       (Ecto.Adapters.SQL.Sandbox.mode Q.Repo
						       (tuple @shared (self))))
		     @ok))))
	 (test/support/conn_case.ex
	  (defmodule QWeb.ConnCase
	      (use ExUnit.CaseTemplate)
	    (space "using"
		   (progn
		     (space "quote"
			    (progn
			      (import Phoenix.Conn
				      Phoenix.ConnTest
				      QWeb.ConnCase)
			      (alias QWeb.Router.Helpers :as Routes)
			      "@endpoint QWeb.Endpoint"))))
	    (space setup tags
		   (progn
		     (setf @ok (Ecto.Adapters.SQL.Sandbox.checkout Q.Repo))
		     (unless (aref tags @async)
		       (Ecto.Adapters.SQL.Sandbox.mode Q.Repo
						       (tuple @shared (self))))
		     (tuple @ok :conn (Phoenix.ConnTest.build_conn))))))
	 (test/support/data_case.ex
	  (defmodule QWeb.DataCase
	      (use ExUnit.CaseTemplate)
	    (space "using"
		   (progn
		     (space "quote"
			    (progn
			      (alias Q.Repo)
			      (import Ecto
				      Ecto.Changeset
				      Ecto.Query
				      Q.DataCase)
			      ))))
	    (space setup tags
		   (progn
		     (setf @ok (Ecto.Adapters.SQL.Sandbox.checkout Q.Repo))
		     (unless (aref tags @async)
		       (Ecto.Adapters.SQL.Sandbox.mode Q.Repo
						       (tuple @shared (self))))
		     @ok))
	    (def error_on (changeset)
	      (Ecto.Changeset.traverse_errors
	       changeset
	       (lambda ((tuple message opts))
		 (Regex.replace "~r\"%{(\\w+)}\""
				message
				(lambda (_ key)
				  (pipe opts
					(Keyword.get (String.to_existing_atom key)
						     key)
					(to_string)))))))))
	 (test/test_helper.exs
	  (do0
	   (ExUnit.Start)
	   (Ecto.Adapters.SQL.Sandbox.mode Q.Repo @manual)))
	 )
       ))
  (loop for (fn code) in l
	do
	   (write-source
	    (format nil "~a/~a" *path* fn)
	    code)))
