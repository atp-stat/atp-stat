class JobController < ApplicationController
  def index
    @jobs = ActivityJob.all
  end
end
