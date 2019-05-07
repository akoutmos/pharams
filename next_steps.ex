pharams :create do
  description("This describes the endpoint")

  header do
    # V2
  end

  path do
  end

  query do
  end

  body do
    required(:first_name, :string)
    required(:last_name, :string)
  end

  example do
    # V2
  end

  output :not_found do
    required :errors, :many do
      required(:message, :string)
    end
  end

  output :unauthorized do
  end
end

%EndpointDefinition{
  description: "thing",
  controller_function: :create,
  key_type: nil,
  drop_nil_fields: nil,
  error_view_module: nil,
  error_view_template: nil,
  error_status: nil,
  path: [
    %SimpleField{name: :first_name, type: :string, required: true, default: false, validators: []},
    %CompoundField{name: :address, cardinality: :one, required: false, fields: []}
  ],
  query: [],
  body: [],
  outputs: [%EndpointOutput{status_code: 200, fields: []}]
}

# Perhaps use monads to describe stuff user has/has not provided
# https://gist.github.com/keathley/bd6b31391f7e05dd8e44

# Self document the controller actions with exdoc
# https://revelry.co/self-documenting-code-elixir/

# To validate generated swagger schema
# https://www.npmjs.com/package/openapi-schema-validator
# -> https://github.com/APIDevTools/swagger-cli

# To get the routes
ModuleWeb.Router.__routes__()

# Use to find the correct validator:
# private: %{
#  ClioWeb.Router => {[],
#   %{
#     Bamboo.SentEmailViewerPlug => ["sent_emails"],
#     PhoenixSwagger.Plug.SwaggerUI => []
#   }},
#  :phoenix_action => :resend_verification_email,
#  :phoenix_controller => ClioWeb.REST.UserController,
#  :phoenix_endpoint => ClioWeb.Endpoint,
#  :phoenix_format => "json",
#  :phoenix_layout => {ClioWeb.LayoutView, :app},
#  :phoenix_pipelines => [:api, :unauthenticated_user],
#  :phoenix_recycled => false,
#  :phoenix_router => ClioWeb.Router,
#  :phoenix_template => "errors.json",
#  :phoenix_view => Pharams.ErrorView,
#  :plug_session => %{},
#  :plug_session_fetch => :done,
#  :plug_skip_csrf_protection => true
# },

assert_valid_response(conn)
%Plug.Conn{}
