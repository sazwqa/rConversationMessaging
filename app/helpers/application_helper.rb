module ApplicationHelper
  
  def new_messages(id)
    count = User.find_by_id(id).new_messages
    count == 0 ? 'no new messages' : "(#{link_to( count, {:controller => 'messages', :action => 'inbox'}, {:id => 'new_count'})}) unread messages."
  end
  
  def read_item(user, id)
    page.replace_html 'new_count', user.new_messages.size
    page["read_#{id}"].remove
    page.visual_effect :highlight, "message_#{id}"
  end
  
  def destroy_item(id)
    page.visual_effect :highlight, "message_#{id}", {:startcolor =>"'#ED1C24'"}
    page.delay(1) { page["message_#{id}"].remove }
  end  
  
end