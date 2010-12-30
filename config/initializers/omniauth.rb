Rails.application.config.middleware.use OmniAuth::Builder do
  case ENV['RAILS_ENV']
  when "production"
    provider :facebook, '162684943766137', '7479b090124cd92fd9a2e0e3a6164705'
  when "development"
    provider :facebook, '167134986663727', '5f27e44d789e0d0f6a70fd72c17fcea1'
  when "staging"
    provider :facebook, '177607928940255', 'd395d956faf4e492b08bb72e0db02a60'
  end
  provider :twitter, 'nhGn3N2Hrqw83ONs71XmA', 'QKSexZyX8XGdlst65vwytLtwUv64kwdmXoYHLuvJqJE'
end
