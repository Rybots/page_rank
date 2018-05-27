class CuratorsController < ApplicationController
  def index
    @curator = Curator.new
    @csvs = CsvFile.all
    @curators = Curator.all
  end

  def create
    @curator = Curator.new(curator_params)
    if @curator.save
      redirect_to action: 'index'
    else

    end
  end

  def cron
    Rails.application.load_tasks
    Rake::Task["curator:cron"].execute
    Rake::Task["curator:cron"].clear
    redirect_to action: 'index'
  end
  private
  def curator_params
    params.require(:curator).permit(:word, :cron)
  end
end
