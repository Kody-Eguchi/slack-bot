class EnablePgsqlExtension < ActiveRecord::Migration[7.2]
  def change
    enable_extension "plpgsql"
  end
end
