# frozen_string_literal: true

class BitzlatoProfile < BitzlatoRecord
  self.table_name = 'p2p.user_profile'
  belongs_to :bitzlato_user, class_name: 'BitzlatoUser', foreign_key: :user_id
end
