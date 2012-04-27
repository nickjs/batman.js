#= require validator

Batman.Validators = []

Batman.extend Batman.translate.messages,
  errors:
    format: "%{attribute} %{message}"
    messages:
      too_short: "must be at least %{count} characters"
      too_long: "must be less than %{count} characters"
      wrong_length: "must be %{count} characters"
      blank: "can't be blank"
      not_numeric: "must be a number"
