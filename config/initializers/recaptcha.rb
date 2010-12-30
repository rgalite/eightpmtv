Recaptcha.configure do |config|
  case ENV['RAILS_ENV']
  when "development"
    config.public_key  = '6LdZB8ASAAAAAGNfoOuDWBnKdl7F58cBsVHMMkCk'
    config.private_key = '6LdZB8ASAAAAACYJ9CBecSPs58cMBK7H6yBGWi4_'
  when "staging"
    config.public_key  = '6LdbB8ASAAAAAOjW8OXL3FUxslhT9tfDr26557ZA'
    config.private_key = '6LdbB8ASAAAAACBK856koaxF7HIrP40tS2E0tXU_'
  when "production"
    config.public_key  = '6LevB8ASAAAAAAyQAyH19gvNy6ZN5QobTRUQLCCb'
    config.private_key = '6LevB8ASAAAAAPe9o6SmtGHWetWgWHpGoloPXZtu'
  end
end