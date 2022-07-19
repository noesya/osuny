class Communication::Block::Template::Contact::Element < Communication::Block::Template::Base
  has_component :title, :string
  has_component :time_slot_morning, :time_slot
  has_component :time_slot_afternoon, :time_slot
end
