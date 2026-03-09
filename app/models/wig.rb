class Wig < ApplicationRecord
  has_many :lead_measures, dependent: :destroy

  validates :title, presence: true

  scope :active, -> { where(active: true) }

  def current_week_lead_measures
    monday = Date.current.beginning_of_week(:monday)
    if lead_measures.loaded?
      lead_measures.select { |lm| lm.week_start_date == monday }
    else
      lead_measures.current_week
    end
  end

  def total_lead_measures_count
    current_week_lead_measures.size
  end

  def completed_lead_measures_count
    current_week_lead_measures.count(&:completed?)
  end

  def progress_percentage
    total = total_lead_measures_count
    return 0 if total.zero?
    (completed_lead_measures_count.to_f / total * 100).round(1)
  end

  def progress_color
    pct = progress_percentage
    if pct >= 70 then "green"
    elsif pct >= 40 then "yellow"
    else "red"
    end
  end

  def recalculate!
    update!(current_value: completed_lead_measures_count)
  end
end
