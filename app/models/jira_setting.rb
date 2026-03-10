class JiraSetting < ApplicationRecord
  encrypts :api_token

  validates :site_url, :email, :api_token, presence: true
  validates :site_url, format: { with: /\Ahttps:\/\/.+\.atlassian\.net\z/, message: "은(는) https://xxx.atlassian.net 형식이어야 합니다" }

  def self.current
    first
  end

  def self.configured?
    exists?
  end

  def connection_valid?
    Jira::Client.new(self).test_connection
  end
end
