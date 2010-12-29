class AttachImageToRoleJob < Struct.new(:role_id, :image_url)
  def perform
    role = Role.find(role_id)
    role.image = RemoteFile.new("http://thetvdb.com/banners/#{image_url}")
    role.save
  end
end