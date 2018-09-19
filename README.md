# Pharams

**WORK IN PROGRESS**

Define Phoenix parameter validations declaratively. Under the hood, the macros make use of Ecto.Schema and so a errors are provided in the form of changesets. These error changesets can then be sent to any error view of your choosing (Pharams comes with a very basic error view out of the box). In addition, the macro also makes use of Plug, and so, the `params` passed to your action controllers are already cast and validated as to clean up the controller file and supporting logic.

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pharams` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pharams, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pharams](https://hexdocs.pm/pharams).

## Usage

In your Phoenix Controller add the following:

```
use Pharams, view_module: Pharams.ErrorView, view_template: "errors.json", error_status: :unprocessable_entity

pharams :index do
  required(:terms_conditions, :boolean, acceptance: [])
  required(:password, :string, confirmation: [], length: [min: 8, max: 16])
  required(:password_confirmation, :string, [])
  required(:age, :integer, number: [greater_than: 16, less_than: 110])

  optional(:interests, {:array, :string},
    subset: ["art", "music", "technology"],
    length: [max: 2]
  )

  optional(:favorite_programming_language, :string,
    exclusion: ~w(Java Perl PHP),
    default: "Elixir"
  )

  required :addresses, :one do
    required :billing_address, :one do
      required(:street_line_1, :string)
      optional(:street_line_2, :string)
      required(:zip_code, :string, format: ~r/\d{5}/)

      required :coordinates, :one do
        required(:lat, :float)
        required(:long, :float)
      end
    end

    required :shipping_address, :one do
      required(:street_line_1, :string)
      optional(:street_line_2, :string)
      required(:zip_code, :string, format: ~r/\d{5}/)

      required :coordinates, :one do
        required(:lat, :float)
        required(:long, :float)
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
