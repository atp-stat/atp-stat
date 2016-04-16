class JobController < ApplicationController
  def index
    @jobs = ActivityJob.all.order("id")
  end
end
