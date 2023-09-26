module Communication::Website::WithDeuxfleurs
  extend ActiveSupport::Concern

  attr_reader :deuxfleurs_first_load

  included do
    before_save :deuxfleurs_setup, if: :deuxfleurs_hosting
    after_save_commit :deuxfleurs_preload, if: :deuxfleurs_hosting
  end

  protected

  def deuxfleurs_setup_done?
    deuxfleurs_identifier.present?
  end

  def deuxfleurs_setup
    return if deuxfleurs_setup_done?
    self.deuxfleurs_identifier = deuxfleurs.create_bucket(deuxfleurs_host)
    self.url = deuxfleurs_default_url
    @deuxfleurs_first_load = true
  end

  def deuxfleurs_preload
    return unless deuxfleurs_first_load
    deuxfleurs_first_load_to_generate_certificate
  end
 
  def deuxfleurs_host
    "#{university.identifier}-#{to_s.parameterize}"
  end

  def deuxfleurs_first_load_to_generate_certificate
    Faraday.get url
  rescue
    # The certificate is not there yet, it is supposed to fail
    # This first call will generate it
  end
  handle_asynchronously :deuxfleurs_first_load_to_generate_certificate

  def deuxfleurs_default_url
    deuxfleurs.default_url_for(deuxfleurs_host)
  end

  def deuxfleurs
    @deuxfleurs ||= Deuxfleurs.new
  end
end