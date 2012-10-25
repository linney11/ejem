class AddTime < ActiveRecord::Migration
  def up
    change_table :gps_samples do |t|
      t.timestamp  'time'
    end
  end

  def down
  end
end
