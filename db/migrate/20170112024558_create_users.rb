class CreateUsers < ActiveRecord::Migration
  def up
    unless users_table_exists?
      create_table :users do |t|
        t.timestamps null: false
      end
    end
  end

  def down
    if users_table_exists? && !user_table_has_more_than_base_columns?
      drop_table :users
    end
  end

  def users_table_exists?
    ActiveRecord::Base.connection.tables.include?('users')
  end

  # 3 Includes id, created_at, updated_at
  def user_table_has_more_than_base_columns?
    ActiveRecord::Base.connection.columns('users').count > 3
  end
end
