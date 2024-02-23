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
    end
  end

  def destroy
    # On est obligés d'overwrite la méthode destroy pour éviter un problème d'œuf et de poule.
    # On a besoin que les websites puissent recalculer leurs recursive_dependencies
    # et on a besoin que ces recursive_dependencies n'incluent pas l'objet courant, puisqu'il est "en cours de destruction" (ni ses propres recursive_dependencies).
    # Mais si on détruit juste l'objet et qu'on fait un `after_destroy :clean_website_connections`
    # on ne peut plus accéder aux websites (puisque l'objet est déjà détruit et ses connexions en cascades).
    # Egalement, quand on supprime un objet indirect, il faut synchroniser ses anciennes sources directes pour supprimer toute référence éventuelle
    # Donc :
    # 1. on stocke les websites (et les sources directes si nécessaire)
    # 2. on laisse la méthode destroy normale faire son travail
    # 3. PUIS on demande aux websites stockés de nettoyer leurs connexions et leurs git files (et on synchronise les potentielles sources directes)
    self.transaction do
      snapshot_direct_sources = try(:direct_sources).to_a || []
      website_ids = websites_to_clean.pluck(:id)
      super
      snapshot_direct_sources.each do |direct_source|
        direct_source.sync_with_git
      end
      clean_websites(website_ids)
      # TODO: Actuellement, on ne nettoie pas les références
      # Exemple : Quand on supprime un auteur, il n'est pas nettoyé dans le static de ses anciens posts.
      # Un save du website le fera en nocturne pour l'instant.
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
  def recursive_dependencies(array: [], syncable_only: false, follow_direct: false)
    if dependency_should_be_synced?(self, syncable_only)
      dependencies.each do |dependency|
        array = recursive_dependencies_add(array, dependency, syncable_only, follow_direct)
      end
    end
    array.compact
  end

  def recursive_dependencies_syncable
    @recursive_dependencies_syncable ||= recursive_dependencies(syncable_only: true)
  end

  def recursive_dependencies_syncable_following_direct
    @recursive_dependencies_syncable_following_direct ||= recursive_dependencies(syncable_only: true, follow_direct: true)
  end

  protected

  def recursive_dependencies_add(array, dependency, syncable_only, follow_direct)
    # Si l'objet ne doit pas être ajouté on n'ajoute pas non plus ses dépendances récursives
    # C'est le fait de couper ici qui évite la boucle infinie
    return array unless dependency_should_be_added?(array, dependency, syncable_only)
    if dependency.is_a?(ActiveRecord::Base)
      dependency_global_id = dependency.to_global_id.to_s
      array << dependency_global_id
    end
    return array if !follow_direct && dependency.try(:is_direct_object?)
    return array unless dependency.respond_to?(:recursive_dependencies)
    dependency.recursive_dependencies(array: array, syncable_only: syncable_only, follow_direct: follow_direct)
  end

  # Si l'objet est déjà là, on ne doit pas l'ajouter
  # Si l'objet n'est pas syncable, on ne doit pas l'ajouter non plus
  def dependency_should_be_added?(array, dependency, syncable_only)
    return true unless dependency.is_a?(ActiveRecord::Base)
    dependency_global_id = dependency.to_global_id.to_s
    !dependency_global_id.in?(array) && dependency_should_be_synced?(dependency, syncable_only)
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
    if missing_dependencies_after_save.any? || unpublished_by_last_save?
      clean_websites(websites_to_clean.pluck(:id))
    end
  end

  def clean_websites(websites_ids)
    # Les objets directs et les objets indirects (et les websites) répondent !
    return unless respond_to?(:is_direct_object?)
    Communication::CleanWebsitesJob.perform_later(websites_ids)
  end

  def websites_to_clean
    is_direct_object? ? [website] : websites
  end

  def missing_dependencies_after_save
    @previous_dependencies - reloaded_recursive_dependencies_syncable_filtered
  end

  def reloaded_recursive_dependencies_syncable_filtered
    reloaded_object = self.class.unscoped.find(id)
    reloaded_dependencies = reloaded_object.recursive_dependencies_syncable
    DependenciesFilter.filtered(reloaded_dependencies)
  end

  def unpublished_by_last_save?
    return unless respond_to?(:published)
    return true if saved_change_to_published? && !published?
    if respond_to?(:published_at)
      return saved_change_to_published_at? && published_at > Time.now
    end
    false
  end
end