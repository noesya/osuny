module Communication::Website::WithGitRepository
  extend ActiveSupport::Concern

  included do
    has_many :website_git_files,
             class_name: 'Communication::Website::GitFile',
             dependent: :destroy
  end

  def git_repository
    @git_repository ||= Git::Repository.new self
  end

  # Supprimer tous les git_files qui ne sont pas dans les recursive_dependencies_syncable
  def destroy_obsolete_git_files
    website_git_files.find_each do |git_file|
      dependency = git_file.about
      # Here, dependency can be nil (object was previously destroyed)
      is_obsolete = dependency.nil? || !dependency.in?(recursive_dependencies_syncable)
      if is_obsolete
        Communication::Website::GitFile.mark_for_destruction(self, git_file)
      end
    end
    self.git_repository.sync!
  end
  handle_asynchronously :destroy_obsolete_git_files, queue: :default

  # Le website devient data/website.yml
  # Les configs héritent du modèle website et s'exportent en différents fichiers
  def exportable_to_git?
    true
  end
end
