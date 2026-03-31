class ApplicationController < ActionController::API
  before_action :authenticate_reader

  private

  def authenticate_reader
    token = request.headers['Authorization']&.sub('Bearer ', '')
    @current_api_key = ApiKey.find_by(token: token)

    unless @current_api_key
      render json: { error: 'UNAUTHORIZED', message: 'Valid API key required', code: 'UNAUTHORIZED' }, status: :unauthorized
    end
  end

  def current_api_key
    @current_api_key
  end

  def render_error(code:, message:, status:, details: nil)
    response = { error: code.downcase, message: message, code: code }
    response[:details] = details if details
    render json: response, status: status
  end
end
