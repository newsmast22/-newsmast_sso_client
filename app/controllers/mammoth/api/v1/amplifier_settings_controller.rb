# frozen_string_literal: true

class Mammoth::Api::V1::AmplifierSettingsController < Api::BaseController
    before_action :require_user!
    before_action :set_setting
  
    def show
      render json: @setting
    end
  
    def update
      @setting.update!(selected_filters: params[:selected_filters])
      current_user.account.update_excluded_and_domains_from_timeline_cache
      render json: @setting
    end
  
    private
  
    def set_setting
      @setting = Mammoth::UserTimelineSetting.where(user_id: current_user.id).first_or_initialize(user_id: current_user.id)
    end
  end
    