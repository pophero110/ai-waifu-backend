module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      re_err(e.message, status: :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      re_err(e.record.errors.full_messages, status: :unprocessable_entity)
    end

    rescue_from ActionController::ParameterMissing do |e|
      Rails.logger.warn("Missing Required Parameter: #{e.message}")
      re_err(e.message, status: :unprocessable_entity)
    end

    # rescue_from AccessDisabledException do |e|
    #   re_err('forbidden', status: :forbidden)
    # end

    # rescue_from ActionPolicy::Unauthorized do |e|
    #   re_err('forbidden', status: :forbidden)
    # end
  end
end
