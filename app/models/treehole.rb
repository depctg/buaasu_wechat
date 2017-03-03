class Treehole < ApplicationRecord
  has_many :treehole_messages, autosave: true

  def Treehole.sample_message
    Treehole.last.treehole_messages.sample
  end
  def Treehole.add_message(user, content)
    if (last = Treehole.last)
      reply = last.treehole_messages.sample 

      new_msg = last.treehole_messages.create content: content
      new_msg.user = user
      last.treehole_messages << new_msg
      
      if reply
        return true, reply.content
      else
        return false, '树洞里还没有消息..'
      end
    else
      return false, '这里没有树洞..'
    end

  end
end
