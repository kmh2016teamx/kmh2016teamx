class Issue < ActiveRecord::Base
  belongs_to :lecture
  belongs_to :user
  has_many :discussions
end
