class AddColmunToPicture < ActiveRecord::Migration[5.1]
  def change
    add_column :pictures, :status, :string
  end
end
