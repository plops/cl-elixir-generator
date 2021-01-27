(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-elixir-generator"))
(in-package :cl-elixir-generator)

(defparameter *path* "/home/martin/stage/cl-elixir-generator/example/08_minimal_live/source")

(let
    ((l
       `((config/config.exs
	  (do0
	   (use Mix.Config)
	   (config @live_view_studio
		   :ecto_repos (list LiveViewStudio.Repo))
	   (config @live_view_studio
		   LiveViewStudioWeb.Endpoint
		   :url (plist host (string "localhost"))
		   :secret_key_base (string "Wy+j/oXYSmC2gLpNSuAz8XCEbUhLc0s4YoBTjx9aI9vRJsTPcemst6T6pu0BFp5A")
		   :render_errors (plist
				   view LiveViewStudioWeb.ErrorView
				   accepts (~w "html json")
				   layout false)
		   :pubsub_server LiveViewStudio.PubSub
		   :live_view (plist signing_salt (string "gu7elorQ")))
	   (config @logger
		   @console
		   :format (string "$time $metadata[$level] $messag\\n")
		   :metadata (list @request_id))
	   (config @phoenix
		   @json_library
		   Jason)
	   (import_config (string "#{Mix.env()}.exs"))))
	 ;; (config/dev.exs)
	 ;; (config/prod.exs)
	 ;; (config/prod.secret.exs)
	 ;; (config/test.exs)
	 ;; (lib/live_view_studio/application.ex)
	 ;; (lib/live_view_studio.ex)
	 ;; (lib/live_view_studio/repo.ex)
	 ;; (lib/live_view_studio_web/channels/user_socket.ex)
	 ;; (lib/live_view_studio_web/endpoint.ex)
	 ;; (lib/live_view_studio_web.ex)
	 ;; (lib/live_view_studio_web/gettext.ex)
	 ;; (lib/live_view_studio_web/live/page_live.ex)
	 ;; (lib/live_view_studio_web/router.ex)
	 ;; (lib/live_view_studio_web/telemetry.ex)
	 ;; (lib/live_view_studio_web/views/error_helpers.ex)
	 ;; (lib/live_view_studio_web/views/error_view.ex)
	 ;; (lib/live_view_studio_web/views/layout_view.ex)
	 ;; (mix.exs)
	 ;; (priv/repo/migrations/.formatter.exs)
	 ;; (priv/repo/seeds.exs)
	 ;; (test/live_view_studio_web/live/page_live_test.exs)
	 ;; (test/live_view_studio_web/views/error_view_test.exs)
	 ;; (test/live_view_studio_web/views/layout_view_test.exs)
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
