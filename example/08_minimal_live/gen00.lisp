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
				    Q.Telemetry
				    (curly Phoenix.PubSub "name: Q.PubSub")
				    Q.EndPoint))
	       (setf opts (plist strategy @one_for_one
				 name Q.Supervisor))
	       (Supervisor.start_link children opts))
	     (def ))
	   ))
	 ;; (lib/q.ex)
	 ;; (lib/q/repo.ex)
	 ;; (lib/q_web/channels/user_socket.ex)
	 ;; (lib/q_web/endpoint.ex)
	 ;; (lib/q_web.ex)
	 ;; (lib/q_web/gettext.ex)
	 ;; (lib/q_web/live/page_live.ex)
	 ;; (lib/q_web/router.ex)
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
