class ChefPropertyValidator < ActiveModel::Validator
  def validate(record)
    if record.value_type != "configure_optional"
      unless record.value != ""
        record.errors[:value] << "Value can't be blank"
      end
    end
  end
end

class ChefProperty < ActiveRecord::Base
  belongs_to :chef_resource
  validates_with ChefPropertyValidator
  default_scope { order("id ASC") }
end
