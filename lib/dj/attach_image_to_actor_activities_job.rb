class AttachImageToActorActivitiesJob < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    user_img = user.avatar_url(:thumb)
    user.activities.each { |a| a.update_attributes!(:actor_img => user_img) }
  end
end
