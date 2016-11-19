class AddFkUsersIdToContracts < ActiveRecord::Migration[5.0]
  def change
    add_reference :contracts, :user, foreign_key: true
  end
end
