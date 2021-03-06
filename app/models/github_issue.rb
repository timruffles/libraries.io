class GithubIssue < ActiveRecord::Base
  belongs_to :github_repository
  belongs_to :github_user, primary_key: :github_id

  API_FIELDS = [:number, :state, :title, :body, :locked, :closed_at, :created_at, :updated_at]

  def github_client(token = nil)
    AuthToken.fallback_client(token)
  end

  def self.create_from_hash(repo, issue_hash)
    issue_hash = issue_hash.to_hash
    i = repo.github_issues.find_or_create_by(github_id: issue_hash[:id])
    i.github_user_id = issue_hash[:user][:id]
    i.github_repository_id = repo.id
    i.pull_request = issue_hash[:pull_request].present?
    i.comments_count = issue_hash[:comments]
    i.assign_attributes issue_hash.slice(*GithubIssue::API_FIELDS)
    i.last_synced_at = Time.now
    i.save! if i.changed?
    i
  end
end
