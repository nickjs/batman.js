# /api/App Components/Batman.StorageAdapter/Batman.StorageAdapter Errors

When a [`Batman.StorageAdapter`](/docs/api/batman.storageadapter.html) fails to complete an operation, it throws a specific error. `Batman.Controller` can set up handlers for these errors with `@catchError`. Each error class prototype has:

- `name`, which matches its class name (eg, `Batman.StorageAdapter.RecordExistsError::name` is `"RecordExistsError"`)
- `message`, which describes the error

## Storage Errors and HTTP Status Codes

`Batman.RestStorage` (and, by inheritance, `Batman.RailsStorage`) throws storage errors according to to the HTTP status codes. Each code is mapped to an error:

HTTP Code | Storage Error
-- | --
`0` |   `Batman.StorageAdapter.CommunicationError`
`401` | `Batman.StorageAdapter.UnauthorizedError`
`403` | `Batman.StorageAdapter.NotAllowedError`
`404` | `Batman.StorageAdapter.NotFoundError`
`406` | `Batman.StorageAdapter.NotAcceptableError`
`409` | `Batman.StorageAdapter.RecordExistsError`
`413` | `Batman.StorageAdapter.EntityTooLargeError`
`422` | `Batman.StorageAdapter.UnprocessableRecordError`
`500` | `Batman.StorageAdapter.InternalStorageError`
`501` | `Batman.StorageAdapter.NotImplementedError`
`502` | `Batman.StorageAdapter.BadGatewayError`

## Batman.StorageAdapter.StorageError

The base class for all other storage errors.

## Batman.StorageAdapter.RecordExistsError

Default message: `"Can't create this record because it already exists in the store!"`.

## Batman.StorageAdapter.NotFoundError

Default message: `"Record couldn't be found in storage!"`.

## Batman.StorageAdapter.UnauthorizedError

Default message: `"Storage operation denied due to invalid credentials!"`.

## Batman.StorageAdapter.NotAllowedError

Default message: `"Storage operation denied access to the operation!"`.

## Batman.StorageAdapter.NotAcceptableError

Default message: `"Storage operation permitted but the request was malformed!"`.

## Batman.StorageAdapter.EntityTooLargeError

Default message: `"Storage operation denied due to size constraints!"`.

## Batman.StorageAdapter.UnprocessableRecordError

Default message: `"Storage adapter could not process the record!"`.

## Batman.StorageAdapter.InternalStorageError

Default message: `"An error occurred during the storage operation!"`.

## Batman.StorageAdapter.NotImplementedError

Default message: `"This operation is not implemented by the storage adapter!"`.

## Batman.StorageAdapter.BadGatewayError

Default message: `"Storage operation failed due to unavailability of the backend!"`.
