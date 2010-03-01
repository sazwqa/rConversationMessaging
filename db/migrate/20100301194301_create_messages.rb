class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :thread_id
      t.integer :originator_id
      t.integer :follower_id
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
