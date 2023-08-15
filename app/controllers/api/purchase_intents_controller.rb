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

  # We can add amount later here
  def purchase_intent_params
    book = Book.find(params[:purchase_intent][:book_id])
    {
      user_id: @current_user.id,
      book_id: params[:purchase_intent][:book_id],
      price: book.price,
      currency: book.currency,
      payment_method: params[:purchase_intent][:payment_method]
    }
  end
end
