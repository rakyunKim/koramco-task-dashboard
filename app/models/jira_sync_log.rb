class JiraSyncLog < ApplicationRecord
  belongs_to :task, optional: true

  validates :direction, :action, :status, presence: true

  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :failed, -> { where(status: "failed") }
end
