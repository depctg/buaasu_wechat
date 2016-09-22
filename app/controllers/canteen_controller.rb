class CanteenController < ApplicationController
  def use
    if CanteenDegist.find_by(degist: params[:degist])
      render 'canteen/error'
    else
      CanteenDegist.create(degist: params[:degist])
      render 'canteen/success'
    end
  end
end
