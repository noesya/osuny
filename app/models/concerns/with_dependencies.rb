# Les objets ont souvent besoin de WithGit et WithDependencies, mais pas toujours :
# - les blocks ont des dépendances, mais ne sont pas envoyés sur Git en tant qu'objets, ils passent par leur 'about'
# - les menu items passent par le menu
# - les templates et les components de blocks passent par les blocks qui passent par les 'about'
module WithDependencies
  extend ActiveSupport::Concern

  included do
    attr_accessor :previous_dependencies

    if self < ActiveRecord::Base
      before_save :snapshot_dependencies
      after_save :clean_websites_if_necessary
      after_destroy :clean_websites
    end
  end


  # Cette méthode doit être définie dans chaque objet,
  # et renvoyer un tableau de ses références directes.
  # Jamais de référence indirecte !
  # Elles sont gérées récursivement.
  def dependencies
    []
  end

  # Method is often overriden
  def syncable?
    if respond_to? :published_now?
      published_now?
    elsif respond_to? :published
      published
    else
      true
    end
  end

  # On ne liste pas les objets en cours de suppression
  # return array if respond_to?(:mark_for_destruction?) && mark_for_destruction
  # On renvoie l'array tel quel, non modifié, si on demande les contenus syncable_only et que le contenu ne l'est pas
  def recursive_dependencies(array: [], syncable_only: false)
    return array unless dependency_should_be_synced?(self, syncable_only)
    dependencies.each do |dependency|
      # Si l'objet ne doit pas être ajouté on n'ajoute pas non plus ses dépendances récursives
      # C'est le fait de couper ici qui évite la boucle infinie
      next unless dependency_should_be_added?(array, dependency, syncable_only)
      array << dependency
      next unless dependency.respond_to?(:recursive_dependencies)
      array = dependency.recursive_dependencies(array: array, syncable_only: syncable_only)
    end
    array.compact
  end

  def recursive_dependencies_syncable
    @recursive_dependencies_syncable ||= recursive_dependencies(syncable_only: true)
  end

  protected
  
  # Si l'objet est déjà là, on ne doit pas l'ajouter
  # Si l'objet n'est pas syncable, on ne doit pas l'ajouter non plus
  def dependency_should_be_added?(array, dependency, syncable_only)
    !dependency.in?(array) && dependency_should_be_synced?(dependency, syncable_only)
  end
  
  # Si on n'est pas en syncable only on liste tout, sinon, il faut analyser
  def dependency_should_be_synced?(dependency, syncable_only)
    !syncable_only || (dependency.respond_to?(:syncable?) && dependency.syncable?)
  end

  # Stockage en RAM des dépendances avant enregistrement
  def snapshot_dependencies
    @previous_dependencies = persisted? ? reloaded_recursive_dependencies_syncable_filtered : []
  end

  def clean_websites_if_necessary
    # Debug :)
    # puts self
    # puts "  previous_dependencies           #{ @previous_dependencies }"
    # puts "  recursive_dependencies_syncable #{ reloaded_recursive_dependencies_syncable_filtered }"
    # puts "  missing_dependencies_after_save #{ missing_dependencies_after_save }"
    # puts
    clean_websites if missing_dependencies_after_save.any?
  end

  def clean_websites
    return unless respond_to?(:is_direct_object?)
    
    if is_direct_object?
      website.destroy_obsolete_git_files
    elsif is_indirect_object?
      websites.each(&:destroy_obsolete_git_files)
    end
  end

  def missing_dependencies_after_save
    @previous_dependencies - reloaded_recursive_dependencies_syncable_filtered
  end

  def reloaded_recursive_dependencies_syncable_filtered
    reloaded_object = self.class.unscoped.find(id)
    reloaded_dependencies = reloaded_object.recursive_dependencies_syncable
    DependenciesFilter.filtered(reloaded_dependencies)
  end
end