Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'nhGn3N2Hrqw83ONs71XmA', 'QKSexZyX8XGdlst65vwytLtwUv64kwdmXoYHLuvJqJE'
  provider :facebook, '162684943766137', '7479b090124cd92fd9a2e0e3a6164705'
end
