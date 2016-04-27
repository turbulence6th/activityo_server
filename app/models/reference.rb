class Reference < ActiveRecord::Base
  
    validates :from, :uniqueness => {
      :scope => :to
    }
    
    validates :from, :to, :text, :presence => true
    
    belongs_to :from, :class_name => 'User'
    belongs_to :to, :class_name => 'User'

end