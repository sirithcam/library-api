class Api::PurchaseIntentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:index]

  def index
    @purchase_intents = PurchaseIntent.all
    render json: @purchase_intents, status: :ok
  end

  def show
    @purchase_intent = PurchaseIntent.find(params[:id])

    if user_can_access_purchase_intent?
      render json: @purchase_intent, status: :ok
    else
      render json: { error: 'Unauthorized. You do not have permission to access this purchase intent.' }, status: :unauthorized
    end
  end

  def create
    @purchase_intent = @current_user.purchase_intents.build(purchase_intent_params)

    if @purchase_intent.save
      render json: @purchase_intent, status: :created
    else
      render json: { errors: @purchase_intent.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @purchase_intent = PurchaseIntent.find(params[:id])

    unless user_can_access_purchase_intent?
      return render json: {
        error: 'Unauthorized. You do not have permission to perform this action.'
      }, status: :unauthorized
    end

    if @purchase_intent.update(purchase_intent_params)
      render json: @purchase_intent, status: :ok
    else
      render json: { errors: @purchase_intent.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    @purchase_intent = PurchaseIntent.find(params[:id])

    unless user_can_access_purchase_intent?
      return render json: {
        error: 'Unauthorized. You do not have permission to perform this action.'
      }, status: :unauthorized
    end

    if @purchase_intent.destroy
      head :no_content
    else
      render json: { errors: @purchase_intent.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def send_intent
    purchase_intent = PurchaseIntent.find(params[:id])

    payload = {
      purchase_intent: {
        purchase_id: purchase_intent.id,
        user_id: purchase_intent.user_id,
        book_id: purchase_intent.book_id,
        price: purchase_intent.price,
        currency: purchase_intent.currency,
        payment_method: purchase_intent.payment_method
      }
    }

    response = HTTParty.post('http://localhost:4444/api/purchase_intents', body: payload)
    response_body = JSON.parse(response.body)

    if response.success?
      purchase_values = payload[:purchase_intent].merge(token: response_body['token'], status: 'pending')
      purchase_values.reject! { |key, _value| key == :purchase_id }
      @purchase = @current_user.purchases.build(purchase_values)
      if @purchase.save
        purchase_intent.destroy
        render json: @purchase, status: :created
      else
        render json: { errors: @purchase_intent.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Failed to send purchase intent', response: response_body }, status: :unprocessable_entity
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

  def user_can_access_purchase_intent?
    @current_user.admin? || @current_user == @purchase_intent.user
  end
end
