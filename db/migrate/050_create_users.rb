class CreateUsers < ActiveRecord::Migration

  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end

  def up
    create_table :users, id: :uuid do |t|
      t.string :password_digest

      t.string :login, null: false
      t.string :login_downcased, null: false
      t.string :last_name, null: false
      t.string :first_name, null: false

      t.boolean :is_admin, null: false, default: false
    end

    add_index :users, :login, unique: true
    add_index :users, :login_downcased, unique: true
    create_text_index :users, :login
    create_text_index :users, :login_downcased
    create_text_index :users, :first_name
    create_text_index :users, :last_name

    create_table :email_addresses, id: false do |t|
      t.uuid :user_id
      t.string :email_address
      t.string :searchable
      t.boolean :primary, default: false, null: false
    end
    execute "ALTER TABLE email_addresses ADD PRIMARY KEY (email_address)"
    create_text_index :email_addresses, :email_address
    create_text_index :email_addresses, :searchable
    add_foreign_key :email_addresses, :users, dependent: :delete
    add_index :email_addresses, :user_id

  end

  def down
    drop_table :email_addresses
    drop_table :users
  end

end
