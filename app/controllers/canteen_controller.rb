class CanteenController < ApplicationController
  def use
    degist =  CanteenDegist.find_by(degist: params[:degist])
    if degist.is_used
      render 'canteen/error'
    else
      degist.is_used = true
      degist.save
      render 'canteen/success'
    end
  end
end
