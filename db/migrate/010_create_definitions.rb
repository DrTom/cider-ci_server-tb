class CreateDefinitions < ActiveRecord::Migration
  def up
    create_table :definitions, id: :uuid do  |t|
      t.string :name
      t.text :description

      t.uuid :specification_id, null: false
      t.index :specification_id
    end
  end

  def down
    drop_table :definitions
  end
end
