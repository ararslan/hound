class RecentBuildsByRepoQuery
  def self.run(*args)
    new(*args).run
  end

  def initialize(user:)
    @user = user
  end

  def run
    query = Build.select(<<-SQL).to_sql
      builds.*,
      dense_rank() OVER (
        PARTITION BY repo_id, pull_request_number
        ORDER BY created_at DESC
      ) AS rank
    SQL

    @user.builds.
      includes(:repo).
      select("builds.*").
      from(Arel.sql("(#{query}) AS builds")).
      where("rank = 1").
      order("builds.created_at DESC")
  end
end
