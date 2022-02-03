# frozen_string_literal: true

class BitzlatoUser < BitzlatoRecord
  self.table_name = :user

  has_one :profile, class_name: 'BitzlatoProfile', foreign_key: :user_id
end
