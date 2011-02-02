class AttachImageToUserActivitiesJob < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    user_img = user.avatar_url(:thumb)
    
    user.activities.each { |a| a.update_attributes!(:actor_img => user_img) }
    user.inv_activities.each { |a| a.update_attributes!(:subject_img => user_img) }
    
    activities = Activity.where(["kind in (?)", %w{ likes_comment follow_user }])
    puts "Found #{activities.count} activities"
    activities.each do |activity|
      activity_data = JSON.parse(activity.data)
      if activity.kind == "likes_comment" && activity.subject.likeable.user == user
        puts "[likes_comment] Old image = #{activity_data["comment_author_img"]}"
        activity_data["comment_author_img"] = user.avatar_url(:thumb)
        puts "[likes_comment] New image = #{activity_data["comment_author_img"]}"
      elsif activity.kind == "follow_user" && activity.subject.followable == user
        puts "[follow_user] Old image = #{activity_data["user_img"]}"
        activity_data["user_img"] = user.avatar_url(:thumb)
        puts "[follow_user] New image = #{activity_data["user_img"]}"
      end
      activity.update_attributes!(:data => activity_data.to_json)
    end
  end
end
