class MessageStatus < ActiveRecord::Base

  STATUS = { 'deleted' => 0, 'read' => 1, 'unread' => 2 }

end
