class CreateMessageStatuses < ActiveRecord::Migration
  def self.up
    create_table :message_statuses do |t|
      t.integer :message_id
      t.integer :originator_inbox,  :default => 0
      t.integer :originator_outbox, :default => 0
      t.integer :follower_inbox,    :default => 0
      t.integer :follower_outbox,   :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :message_statuses
  end
end
