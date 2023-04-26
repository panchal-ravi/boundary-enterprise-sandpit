# Recovery KMS block: configures the recovery key for Boundary
# Use a production KMS such as AWS KMS for production installs
kms "aead"{
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "${recovery_kms}"
  key_id = "global_recovery"
}