class SignRecord < ApplicationRecord
  belongs_to :user, autosave: true
  serialize :days
end
