class RecentBuildsByRepoQuery
  NUMBER_OF_BUILDS = 20

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
      from(Arel.sql("(#{query}) AS builds")).
      where("rank = 1").
      order("builds.created_at DESC").
      limit(NUMBER_OF_BUILDS)
  end
end
