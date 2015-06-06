class ProgramFilesController < ApplicationController
  def index
  end
  def show
    @files = params[:program_files].split("/")
  end
end
