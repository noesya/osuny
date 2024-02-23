class Git::Repository
  attr_reader :website, :commit_message

  def initialize(website)
    @website = website
  end

  def url
    provider.url
  end

  def add_git_file(git_file)
    puts "Adding #{git_file.path}"
    if git_files.empty?
      # The first file gives the commit name
      analyzer.git_file = git_file
      @commit_message = analyzer.commit_message
    end
    analyze_git_file(git_file)
  end

  def sync!
    return if git_files.empty?
    # mark_as_synced if provider.push(commit_message)
  end

  def update_theme_version!
    provider.update_theme
    theme_name = ENV["GITHUB_WEBSITE_THEME_REPOSITORY"].to_s.split("/").last
    provider.push("Updated #{theme_name} version")
  end

  # Based on content, with the provider's algorithm (sha1 or sha256)
  def computed_sha(string)
    provider.computed_sha(string)
  end

  def git_sha(path)
    provider.git_sha path
  end

  def valid?
    provider.valid?
  end

  def init_from_template(name)
    provider.init_from_template(name)
  end

  protected

  def provider
    @provider ||= provider_class.new self
  end

  def provider_class
    @provider_class ||= "Git::Providers::#{website.git_provider.titleize}".constantize
  end

  def git_files
    @git_files ||= []
  end

  def analyzer
    @analyzer ||= Git::Analyzer.new self
  end

  def analyze_git_file(git_file)
    analyzer.git_file = git_file
    if analyzer.should_create?
      puts "Syncing - Creating #{git_file.path}"
      provider.create_file git_file.path, git_file.to_s
      git_files << git_file
    elsif analyzer.should_update?
      puts "Syncing - Updating #{git_file.path}"
      provider.update_file git_file.path, git_file.previous_path, git_file.to_s
      git_files << git_file
    elsif analyzer.should_destroy?
      puts "Syncing - Destroying #{git_file.previous_path}"
      provider.destroy_file git_file.previous_path
      git_files << git_file
    else
      puts "Syncing - Nothing to do with #{git_file.path}"
    end
  end

  def mark_as_synced
    puts "Marking as synced"
    git_files.each do |git_file|
      analyzer.git_file = git_file
      if analyzer.should_destroy?
        puts "Destroying #{git_file.previous_path}"
        git_file.destroy
      else
        path = git_file.path
        puts "Marking #{path}"
        git_file.update previous_path: path, previous_sha: computed_sha(git_file.to_s)
      end
    end
  end
end
