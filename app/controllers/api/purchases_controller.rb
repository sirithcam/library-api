class Api::PurchasesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:index]

  def index
    @purchases = Purchase.all
    render json: @purchases, status: :ok
  end

  def process_purchase
    @purchase = Purchase.find(params[:id])

    payload = {
      purchase_id: @purchase.id,
      user_id: @purchase.user_id,
      book_id: @purchase.book_id,
      price: @purchase.price,
      currency: @purchase.currency,
      payment_method: @purchase.payment_method,
      token: @purchase.token
    }

    response = HTTParty.post('http://localhost:4444/api/purchase_intents/process_purchase', body: payload)
    response_body = JSON.parse(response.body)

    if response.success?
      @purchase.update(status: 'done')
      render json: { message: 'Book has been purchased' }, status: :ok
    else
      render json: { error: 'Failed to process purchase', response: response_body }, status: :unprocessable_entity
    end
  end

  private

  def purchase_params
    params.require(:purchase).permit(:user_id, :book_id, :currency, :status, :token, :payment_method)
  end
end

