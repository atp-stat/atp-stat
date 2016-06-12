class JobController < ApplicationController
  def index
    @jobs = ActivityJob.all.order("id")
  end
  
  def show
    @job = ActivityJob.find(params[:id])
  end

  def new
  end

  def edit
  end
end
