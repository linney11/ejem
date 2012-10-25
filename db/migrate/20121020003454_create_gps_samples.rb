class CreateGpsSamples < ActiveRecord::Migration
  def up
    # Create table 'Gps_Samples'
    # Since there is no specific type for 'double', we use :limit => 53,
    # this limit value corresponds to the precision of the column in bits
    create_table 'gps_samples' do |t|
      t.float 'latitude', :null => false, :limit => 53
      t.float 'longitude', :null => false, :limit => 53
      t.timestamps 'timestamp', :null => false
      t.integer 'user_id'

    end

  end

  def down
    # Delete table 'Gps_Samples' and all its content
    drop_table 'gps_samples'
  end
end
