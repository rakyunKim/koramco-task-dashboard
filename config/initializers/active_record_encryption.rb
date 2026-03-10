Rails.application.config.active_record.encryption.primary_key = ENV.fetch("AR_ENCRYPTION_PRIMARY_KEY", "COFIuhoJAtzDkTqsYh4ON4JO4w7yh8rt")
Rails.application.config.active_record.encryption.deterministic_key = ENV.fetch("AR_ENCRYPTION_DETERMINISTIC_KEY", "dX1pc6xTzqG7Vy0DKDZIeGDRg4O36ti0")
Rails.application.config.active_record.encryption.key_derivation_salt = ENV.fetch("AR_ENCRYPTION_KEY_DERIVATION_SALT", "tIGRm5QS2oY9U0XEXu1mZnx3fjHby7Lm")
