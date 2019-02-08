# Used by "mix format"
[
  line_length: 120,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  export: [
    locals_without_parens: [required: :*, optional: :*]
  ]
]
