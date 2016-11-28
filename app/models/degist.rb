class Degist < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :class, presence: true

  def Degist.count_by(subject, options = {})
    if options[:class]
      Degist.find_by(subject: subject, class: options[:class]).count
    else
      Degist.find_by(subject: subject).count
    end
  end
end
