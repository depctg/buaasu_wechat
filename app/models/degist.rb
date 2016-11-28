class Degist < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :class, presence: true

  def Degist.count_by(subject, options = {})
    if options[:class]
      degists = Degist.where(subject: subject, class: options[:class])
    else
      degists = Degist.where(subject: subject)
    end

    if degists.nil? then 0 else degists.count end
  end
end
