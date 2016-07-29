class RemoveKuUserRefFromProgram < ActiveRecord::Migration
  def change
    remove_reference :programs, :ku_user
  end
end
