class CreateSpecifications < ActiveRecord::Migration
  def up
    create_table :specifications, id: :uuid do |t|
      t.text :data, null: false
      t.timestamps
    end
  end

  def down
    drop_table :specifications
  end

    
end
