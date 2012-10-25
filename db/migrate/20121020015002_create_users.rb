class CreateUsers < ActiveRecord::Migration
  def up
    # Create table 'Users'
    # Since there is no specific type for 'double', we use :limit => 53,
    # this limit value corresponds to the precision of the column in bits
    create_table 'users' do |t|
      t.string 'name', :null => false
      t.integer 'edad'
    end
  end

  def down
    # Delete table 'users' and all its content
    drop_table 'users'
  end
end
