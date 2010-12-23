class AddIndexToForeignKeys < ActiveRecord::Migration
  def self.up
    add_index :subscriptions, :series_id, :name => 'subscriptions_series_id_ix'
    add_index :subscriptions, :user_id, :name => 'subscriptions_user_id_ix'
    add_index :comments, :user_id, :name => 'comments_user_id_ix'
    add_index :comments, :commentable_id, :name => 'comments_commentable_id_ix'
    add_index :comments, :commentable_type, :name => 'comments_commentable_type_ix'
    add_index :comments, [:commentable_type, :commentable_id], :name => 'comments_commentable_type_commentable_id_ix'
    add_index :authentications, :user_id, :name => 'authentications_user_id_ix'
    add_index :roles, :series_id, :name => "roles_series_id_ix"
    add_index :roles, :actor_id, :name => "roles_actor_id_ix"
    add_index :friendships, :user_id, :name => "friendships_user_id_ix"
    add_index :friendships, :friend_id, :name => "friendships_friend_id_ix"
    add_index :likes, :user_id, :name => "likes_user_id_ix"
    add_index :likes, :likeable_id, :name => "likes_likeable_id_ix"
    add_index :likes, :likeable_type, :name => "likes_likeable_type_ix"
    add_index :likes, [:likeable_type, :likeable_id], :name => "likes_likeable_type_likeable_id_ix"
    add_index :genres_series, :genre_id, :name => "genres_series_genre_id_ix"
    add_index :genres_series, :series_id, :name => "genres_series_series_id_ix"
    add_index :seasons, :series_id, :name => "seasons_series_id_ix"
    add_index :episodes, :season_id, :name => "episodes_season_id_ix"
  end

  def self.down
    remove_index :subscriptions, 'subscriptions_series_id_ix'
    remove_index :subscriptions, 'subscriptions_user_id_ix'
    remove_index :comments, 'comments_user_id_ix'
    remove_index :comments, 'comments_commentable_id_ix'
    remove_index :comments, 'comments_commentable_type_ix'
    remove_index :comments, 'comments_commentable_type_commentable_id_ix'
    remove_index :authentications, 'authentications_user_id_ix'
    remove_index :roles, 'roles_series_id_ix'
    remove_index :roles, 'roles_actor_id_ix'
    remove_index :friendships, 'friendships_user_id_ix'
    remove_index :friendships, 'friendships_friend_id_ix'
    remove_index :likes, 'likes_user_id_ix'
    remove_index :likes, 'likes_likeable_id_ix'
    remove_index :likes, 'likes_likeable_type_ix'
    remove_index :likes, 'likes_likeable_type_likeable_id_ix'
    remove_index :genres_series, 'genres_series_genre_id_ix'
    remove_index :genres_series, 'genres_series_series_id_ix'
    remove_index :seasons, 'seasons_series_id_ix'
    remove_index :episodes, 'episodes_season_id_ix'
  end
end
