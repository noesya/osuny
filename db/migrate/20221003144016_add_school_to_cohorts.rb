class AddSchoolToCohorts < ActiveRecord::Migration[6.1]
  def change
    add_reference :education_cohorts, :school, foreign_key: {to_table: :education_schools}, type: :uuid
    Education::Cohort.all.each do |cohort|
      if cohort.program.schools.any?
        cohort.update(school_id: cohort.program.schools.first.id)
      else
        cohort.destroy
      end
    end
    change_column_null :education_cohorts, :school_id, false
  end
end
