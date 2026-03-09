module Progressable
  extend ActiveSupport::Concern

  def progress_color
    pct = progress_percentage
    if pct >= 70 then "green"
    elsif pct >= 40 then "yellow"
    else "red"
    end
  end
end
