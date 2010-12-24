class AttachImageToRoleJob < Struct.new(:role_id, :image_url)
  def perform
    role = Role.find(role_id)
    role.image = RemoteFile.new("http://thetvdb.com/banners/#{@image_url}") if @image_url
    role.image_url = nil
    role.save
  end
end