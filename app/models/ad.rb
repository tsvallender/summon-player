class Ad < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 30 }
  validates :text, presence: true, length: { maximum: 1000 }

  has_many :adtags, class_name: "AdTag", foreign_key: "ad_id"
  has_many :tags, through: :adtags, :source => :tag
  
  has_many :messages do
    def user(user)
      where(:to_id => user.id).or(where(:from_id => user.id))
    end
  end

  scope :active, -> { where(archived: false) }
  scope :desc, -> { order(created_at: :desc) }

  def interested
    user_ids = self.messages.where.not(from: user).distinct.pluck(:from_id)
    users = []
    user_ids.each do |u|
      users.append(User.find(u))
    end
    users
  end
end
