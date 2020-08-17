class Filter < ApplicationRecord
  include Rails.application.routes.url_helpers

  def url
    records_path(load_filter: self.name)
  end
end