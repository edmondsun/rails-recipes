class ImportWorkerJob < ApplicationJob
  queue_as :default

  # def perform(*args)
  #   # Do something later
  # end

  def perform(import_id)
    import = RegistrationImport.find(import_id)
    import.process!
  end
end
