# Pharams

[![Hex.pm](https://img.shields.io/hexpm/v/pharams.svg)](http://hex.pm/packages/pharams)

**WORK IN PROGRESS**

Define Phoenix parameter validations declaratively. Under the hood, the Pharams macros make use of Ecto.Schema and so errors are provided in the form of changesets. These error changesets can then be sent to any error view of your choosing (Pharams comes with a very basic error view out of the box). In addition, the usage of the Pharams macro will inject a Plug in your controller so that the `params` variable passed to your Phoenix controller has already already been validated. The `params` variable passed to your function controller is a plain map with atoms as keys.

## Installation

[Available in Hex](https://hex.pm/packages/pharams), the package can be installed
by adding `pharams` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pharams, "~> 0.1.0"}
  ]
end
```

If you would like the formatter to not add parenthesis to `required` and `optional` you can add the following to you `.formatter.exs`:

```
[
  import_deps: [:pharams]
]
```

Documentation can be found at [https://hexdocs.pm/pharams](https://hexdocs.pm/pharams).

## Usage

To get started, add the following to your Phoenix Controller:

```elixir
use Pharams
```

If you would like to configure the Pharams module to use an error view of your choosing you can do something like this (shown with defaults):

```elixir
# error_status takes an atom (see https://github.com/elixir-plug/plug/blob/master/lib/plug/conn/status.ex for full list of supported statuses)
use Pharams, view_module: Pharams.ErrorView, view_template: "errors.json", error_status: :unprocessable_entity
```

Next you can use the pharams macro to define the validation that should take place against incoming requests. Below is a simple example:

```elixir
pharams :index do
  required :terms_conditions, :boolean
  required :password, :string
  required :password_confirmation, :string
  optional :age, :integer
end

def index(conn, params) do
  # You will only get into this function if the request
  # parameters have passed the above validation. The params
  # variable is now just a plain old map with atoms as keys.

  render(conn, "index.html")
end
```

Let's break down what is happening here. Before the `do` block, we specify to which action the validator will apply. In this case the `:index` atom is provided because we want the validation to take place against the `def index` action in the controller. Next, we define which fields are required/optional in the request, and what their types are. Simple enough so far :), let's look at a more complex example.

In the following example, we will create a validator with a bit more functionality:

```elixir
pharams :index do
  required :terms_conditions, :boolean, acceptance: []
  required :password, :string, confirmation: [], length: [min: 8, max: 16]
  required :password_confirmation, :string, []
  required :age, :integer, number: [greater_than: 16, less_than: 110]

  optional :interests, {:array, :string},
    subset: ["art", "music", "technology"],
    length: [max: 2]

  optional(:favorite_programming_language, :string,
    exclusion: ~w(Java Perl PHP),
    default: "Elixir"

  required :addresses, :one do
    required :billing_address, :one do
      required :street_line_1, :string
      optional :street_line_2, :string
      required :zip_code, :string, format: ~r/\d{5}/

      required :coordinates, :one do
        required :lat, :float
        required :long, :float
      end
    end

    required :shipping_address, :one do
      required :street_line_1, :string
      optional :street_line_2, :string
      required :zip_code, :string, format: ~r/\d{5}/

      required :coordinates, :one do
        required :lat, :float
        required :long, :float
      end
    end
  end
end

def index(conn, params) do
  # You will only get into this function if the request
  # parameters have passed the above validation. The params
  # variable is now just a plain old map with atoms as keys.

  render(conn, "index.html")
end
```

Let's break this one down as well to make things clear. As you can see, you can also have embedded required/optional schemas in your validation declaration (for example the `:addresses` schema contains both `:billing_address` and `:shipping_address` schemas). You can also pass in a keyword list of additional options for fields. For example the `:favorite_programming_language` field can have a default value of `Elixir`, and using the `Ecto.Changeset.validate_exclusion/4` via the `exclusion: ~w(Java Perl PHP)` keyword entry, you can validate that the string is not in the provided list. All of the `Ecto.Changeset.validate_*` functions are supported, with the caveat that you call them with out their `validate_` prefix. You can also get fairly involved with your validations using the `validate_change` Ecto.Changeset function:

```elixir
pharams :index do
  required(:rand, :string,
    change: [
      :something,
      fn :rand, rand ->
        if rand == "foo" do
          [rand: "cannot be foo"]
        else
          []
        end
      end
    ]
  )
end
```

When using the `Ecto.Changeset.validate_*/3` functions, all you have to provide is the last argument. The Pharams macro will populate the first two params under the hood for you. When using the `Ecto.Changeset.validate_*/4` functions, you have to pass the last two parameters as a list. See below the two different uses of `validate_subset`:

```elixir
# Using Ecto.Changeset.validate_subset/3
optional(:interests, {:array, :string},
  subset: ["art", "music", "technology"],
  length: [max: 2]
)

# Using Ecto.Changeset.validate_subset/4
optional(:interests, {:array, :string},
  subset: [["art", "music", "technology"], [message: "Only 3 cool interests to pick from!"]],
  length: [max: 2]
)
```
