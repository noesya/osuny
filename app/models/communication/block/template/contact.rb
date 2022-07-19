class Communication::Block::Template::Contact < Communication::Block::Template::Base

  has_component :name, :string
  has_component :phone_numbers, :array
  has_component :emails, :array
  has_component :address, :text

  has_elements

end
