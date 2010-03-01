class Message < ActiveRecord::Base

  belongs_to :originator, :class_name => 'User', :foreign_key => 'originator_id'
  belongs_to :follower,   :class_name => 'User', :foreign_key => 'follower_id'
  
  has_one :status, :class_name => 'MessageStatus'

end
