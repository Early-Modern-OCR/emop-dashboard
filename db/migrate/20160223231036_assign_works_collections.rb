class AssignWorksCollections < ActiveRecord::Migration
  def up
    ecco_works = Work.where.not(wks_ecco_number: [nil, ''])
    if ecco_works.present?
      collection = WorksCollection.find_or_create_by(name: 'ECCO')
      ecco_works.update_all(collection_id: collection.id)
    end

    eebo_works = Work.where(wks_ecco_number: [nil, ''])
    if eebo_works.present?
      collection = WorksCollection.find_or_create_by(name: 'EEBO')
      eebo_works.update_all(collection_id: collection.id)
    end
  end

  def down
  end
end
