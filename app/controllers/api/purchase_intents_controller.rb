class Api::PurchaseIntentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @purchase_intent = @current_user.purchase_intents.build(purchase_intent_params)

    if @purchase_intent.save
      render json: @purchase_intent, status: :created
    else
      render json: { errors: @purchase_intent.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def purchase_intent_params
    params.require(:purchase_intent).permit(:book_id, :price, :currency, :payment_method)
  end
end
