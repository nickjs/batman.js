module.exports = ErrorMessages =
  errors:
    base:
      format: "%{message}"
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
      not_an_integer: "must be an integer"
      not_matching: "is not valid"
      invalid_association: "is not valid"
      not_included_in_list: "is not included in the list"
      included_in_list: "is included in the list"
      not_an_email: "is not a valid email address"
      confirmation_does_not_match: 'and confirmation do not match'
