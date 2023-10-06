module WithTree
  extend ActiveSupport::Concern

  included do

    scope :root, -> { where(parent_id: nil) }

    def has_children?
      children.any?
    end

    def has_parent?
      parent_id.present?
    end

    def ancestors
      has_parent? ? parent.ancestors.push(parent)
                  : []
    end

    def ancestors_and_self
      ancestors + [self]
    end

    def descendants
      has_children? ? children.ordered.map { |child| [child, child.descendants].flatten }.flatten
                    : []
    end

    def siblings
      self.class.unscoped.where(parent: parent, university: university).where.not(id: id).ordered
    end

    def self_and_children(level)
      elements = []
      label = "&nbsp;&nbsp;&nbsp;" * level + self.to_s
      elements << { label: label, id: self.id, parent_id: self.parent_id }
      children.ordered.each do |child|
        elements.concat(child.self_and_children(level + 1))
      end
      elements
    end

  end


end
