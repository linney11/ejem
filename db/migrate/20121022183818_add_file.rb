class AddFile < ActiveRecord::Migration
  def up
     change_table :gps_samples do |t|
       t.integer 'file'
     end
  end

  def down
  end
end
