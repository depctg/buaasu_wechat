class SignRecord < ApplicationRecord
  belongs_to :user
  serialize :days
end
