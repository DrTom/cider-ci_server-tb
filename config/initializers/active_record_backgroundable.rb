# Enable backgroundable methods for ActiveRecord classes. Provides:
# class AModel < ActiveRecord::Base
#   always_background :a_method
# end
# 
# a_model_instance.background.another_method
if defined?(TorqueBox::Messaging::Backgroundable) && defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, TorqueBox::Messaging::Backgroundable)
else
  class ActiveRecord::Base
    def background
      self
    end
    def self.background
      self
    end
  end
end
