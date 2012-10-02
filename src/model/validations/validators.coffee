#= require ./validator

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
      greater_than: "must be greater than %{count}"
      greater_than_or_equal_to: "must be greater than or equal to %{count}"
      equal_to: "must be equal to %{count}"
      less_than: "must be less than %{count}"
      less_than_or_equal_to: "must be less than or equal to %{count}"
      not_matching: "is not valid"
      invalid_association: "is not valid"
