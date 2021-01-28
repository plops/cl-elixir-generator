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
					       "cd: Patch.expand(\"../assets\",__DIR__)")))
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
		    @index))))
	 ;; (lib/q_web/telemetry.ex)
	 ;; (lib/q_web/views/error_helpers.ex)
	 ;; (lib/q_web/views/error_view.ex)
	 ;; (lib/q_web/views/layout_view.ex)
	 ;; (mix.exs)
	 ;; (priv/repo/migrations/.formatter.exs)
	 ;; (priv/repo/seeds.exs)
	 ;; (test/q_web/live/page_live_test.exs)
	 ;; (test/q_web/views/error_view_test.exs)
	 ;; (test/q_web/views/layout_view_test.exs)
	 ;; (test/support/channel_case.ex)
	 ;; (test/support/conn_case.ex)
	 ;; (test/support/data_case.ex)
	 ;; (test/test_helper.exs)
	 )
       ))
  (loop for (fn code) in l
	do
	   (write-source
	    (format nil "~a/~a" *path* fn)
	    code)))
