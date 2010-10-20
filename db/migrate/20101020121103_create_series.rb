class CreateSeries < ActiveRecord::Migration
  def self.up
    create_table :series do |t|
      t.integer :tvdb_id
      t.string  :air_day
      t.string  :air_time
      t.string  :content_rating
      t.date    :first_aired
      t.string  :imdb_id
      t.string  :language
      t.string  :network
      t.string  :description
      t.decimal :rating, :scale => 1
      t.integer :rating_count
      t.integer :runtime
      t.integer :series_id
      t.string  :name
      t.string  :status
      t.string  :banner
      t.string  :fanart
      t.string  :poster
      t.timestamps
    end
  end

  def self.down
    drop_table :series
  end
end
