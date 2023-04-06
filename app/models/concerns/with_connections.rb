# Concern exclusivement utilisé pour les objets indirects
module WithConnections
  extend ActiveSupport::Concern

  included do
    include WithDependencies
    include WithReferences

    has_many :connections, as: :indirect_object, class_name: 'Communication::Website::Connection'
    has_many :websites, through: :connections
    # Ce serait super, mais Rails ne sait pas faire ça avec un objet polymorphe
    # has_many :sources, through: :connections

    after_save :sync_connections
    after_touch :sync_connections
  end

  def for_website?(website)
    website.has_connected_object?(self)
  end

  def direct_sources
    @direct_sources ||= begin
      # On initialise les direct_sources avec les connexions existantes
      direct_sources = direct_sources_from_existing_connections
      # On boucle sur les références pour récupérer les direct sources manquantes
      references.each do |reference|
        direct_sources += direct_sources_from_reference(reference)
      end
      direct_sources.uniq
    end
  end

  protected

  def direct_sources_from_existing_connections
    connections.collect &:direct_source
  end

  # Dans le cas d'un object
  def direct_sources_from_reference(reference)
    reference_is_a_direct_object = reference.respond_to?(:website_id)
    reference_is_a_direct_object  ? [reference] # Récupération de la connexion directe
                                  : reference.direct_sources # Récursivité sur les références
  end
  

  def sync_connections
    direct_sources.each do |direct_source|
      direct_source.website.connect self, direct_source
      direct_source.save_and_sync
    end
  end
end