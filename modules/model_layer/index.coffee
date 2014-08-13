ModelLayer = {
  Association:                require './associations/association'
  SingularAssociation:        require './associations/singular_association'
  BelongsToAssociation:       require './associations/belongs_to_association'
  PolymorphicBelongsToAssociation: require './associations/polymorphic_belongs_to_association'
  HasOneAssociation:          require './associations/has_one_association'
  PluralAssociation:          require './associations/plural_association'
  HasManyAssociation:         require './associations/has_many_association'
  PolymorphicHasManyAssociation: require './associations/polymorphic_has_many_association'

  AssociationSet:             require './associations/association_set'
  PolymorphicAssociationSet:  require './associations/polymorphic_association_set'
  AssociationSetIndex:        require './associations/association_set_index'
  PolymorphicAssociationSetIndex: require './associations/polymorphic_association_set_index'
  UniqueAssociationSetIndex:  require './associations/unique_association_set_index'
  UniquePolymorphicAssociationSetIndex: require './associations/polymorphic_unique_association_set_index'

  AssociationProxy:           require './associations/association_proxy'
  BelongsToProxy:             require './associations/belongs_to_proxy'
  PolymorphicBelongsToProxy:  require './associations/polymorphic_belongs_to_proxy'
  HasOneProxy:                require './associations/has_one_proxy'

  AssociationCurator:         require './associations/association_curator'

  StorageAdapter:             require './storage_adapters/storage_adapter'
  LocalStorage:               require './storage_adapters/local_storage'
  SessionStorage:             require './storage_adapters/session_storage'
  RestStorage:                require './storage_adapters/rest_storage'

  Transaction:                require './transaction/transaction'
  TransactionAssociationSet:  require './transaction/transaction_association_set'

  ValidationError:            require './validations/validation_error'
  ErrorsSet:                  require './validations/errors_set'
  Validator:                  require './validations/validator'
  Validators:                 require './validations/validators'
  # Mix them in here for minification-safety
  AssociatedFieldValidator:   require './validations/associated_field_validator'
  AssociatedValidator:        require './validations/associated_validator'
  ConfirmationValidator:      require './validations/confirmation_validator'
  EmailValidator:             require './validations/email_validator'
  ExclusionValidator:         require './validations/exclusion_validator'
  InclusionValidator:         require './validations/inclusion_validator'
  LengthValidator:            require './validations/length_validator'
  NumericValidator:           require './validations/numeric_validator'
  PresenceValidator:          require './validations/presence_validator'
  RegExpValidator:            require './validations/reg_exp_validator'


  # vv has to be mixed in later on vv
  ErrorMessages:              require './validations/error_messages'
  Encoders:                   require './encoders'
  Model:                      require './model'
  Translate:                  require './translate'
}


module.exports = ModelLayer