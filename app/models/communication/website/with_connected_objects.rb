module Communication::Website::WithConnectedObjects
  extend ActiveSupport::Concern

  included do
    has_many :connections

    after_save :connect_about, if: :saved_change_to_about_id?
  end

  # Appelé
  # - par un objet avec des connexions lorsqu'il est destroyed
  # - par le website lui-même au changement du about
  def destroy_obsolete_connections
    up_to_date_dependencies = recursive_dependencies
    deletable_connection_ids = []
    connections.find_each do |connection|
      has_living_connection = up_to_date_dependencies.detect { |dependency|
        dependency.class.name == connection.indirect_object_type &&
        dependency.id == connection.indirect_object_id
      }
      deletable_connection_ids << connection.id unless has_living_connection
    end
    # On utilise delete_all pour supprimer les connexions obsolètes en une unique requête DELETE FROM
    # Cependant, on peut le faire car les connexions n'ont pas de callback.
    # Dans le cas où on en rajoute au destroy, il faut repasser sur un appel de destroy sur chaque
    connections.where(id: deletable_connection_ids).delete_all
  end

  def has_connected_object?(indirect_object)
    connections.for_object(indirect_object).exists?
  end

  def connect(indirect_object, direct_source, direct_source_type: nil)
    connect_object indirect_object, direct_source, direct_source_type: direct_source_type
    return unless indirect_object.respond_to?(:recursive_dependencies)
    indirect_object.recursive_dependencies.each do |dependency|
      connect_object dependency, direct_source
    end
  end

  def connect_and_sync(indirect_object, direct_source, direct_source_type: nil)
    connect(indirect_object, direct_source, direct_source_type: direct_source_type)
    direct_source.sync_with_git
  end

  def disconnect(indirect_object, direct_source, direct_source_type: nil)
    direct_source_type ||= direct_source.class.base_class.to_s
    connections.where(university: university,
                      indirect_object: indirect_object,
                      direct_source_id: direct_source.id,
                      direct_source_type: direct_source_type)
                .delete_all
  end

  def disconnect_and_sync(indirect_object, direct_source, direct_source_type: nil)
    disconnect(indirect_object, direct_source, direct_source_type: direct_source_type)
    direct_source.sync_with_git
    destroy_obsolete_git_files
  end

  # TODO factoriser avec les extranets
  def connected_people
    ids = connections.where(indirect_object_type: 'University::Person').pluck(:indirect_object_id)
    University::Person.where(id: ids)
  end

  def connected_organizations
    ids = connections.where(indirect_object_type: 'University::Organization').pluck(:indirect_object_id)
    University::Organization.where(id: ids)
  end

  # ensure the object "website" respond to both is_direct_object? and is_indirect_object? as website doesn't include neither as_direct_object nor as_indirect_object
  def is_direct_object?
    true
  end

  def is_indirect_object?
    false
  end

  protected

  def connect_about
    self.connect(about, self) if about.present? && about.try(:is_indirect_object?)
    destroy_obsolete_connections
  end

  def connect_object(indirect_object, direct_source, direct_source_type: nil)
    return unless should_connect?(indirect_object, direct_source)
    # puts "connect #{object} (#{object.class})"
    direct_source_type ||= direct_source.class.base_class.to_s
    connection = connections.where( university: university,
                                    indirect_object: indirect_object,
                                    direct_source_id: direct_source.id,
                                    direct_source_type: direct_source_type)
                            .first_or_create
    connection.touch if connection.persisted?
  end

  def should_connect?(indirect_object, direct_source)
    # Ce cas se produit quand on save un new website et qu'on ne passe pas un validateur
    persisted? &&
    # On ne connecte pas les objets inexistants
    indirect_object.present? &&
    # On ne connecte pas les objets sans source
    direct_source.present? &&
    # On ne connecte pas le site à lui-même
    !indirect_object.is_a?(Communication::Website) &&
    # On ne connecte pas les objets directs (en principe ça n'arrive pas)
    !indirect_object.try(:is_direct_object?) &&
    # On ne connecte pas des objets qui ne sont pas issus de modèles ActiveRecord (comme les composants des blocs)
    indirect_object.is_a?(ActiveRecord::Base)
  end
end