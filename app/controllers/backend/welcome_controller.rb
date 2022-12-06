class WelcomeController < ApplicationController
    def index
        @ai_waifus = apply_filter.page(params[:page])
    end

    private

    def apply_filter
        case params[:filtered_by]
        when 'most_likes'
            AiWaifu.left_joins(:likes).group(:id).order('COUNT(likes.id) DESC')
        when 'least_likes'
            AiWaifu.left_joins(:likes).group(:id).order('COUNT(likes.id) ASC')
        when 'recent_upload'
            AiWaifu.includes(:likes, :downloads).order(created_at: :desc)
        when 'old_upload'
            AiWaifu.includes(:likes, :downloads).order(:created_at)
        else
            AiWaifu.includes(:likes, :downloads).order(created_at: :desc)
        end
    end
end
