module Mammoth::Api::V1::Timeline
  class TimelinesController < Api::BaseController
    before_action :require_user!
    before_action :set_max_id, only: [:primary, :federated, :newsmast, :my_community] 
    before_action :create_service, only: [:primary, :federated, :newsmast, :my_community] 
    before_action :create_policy, only: [:create]
    before_action -> { doorkeeper_authorize! :read , :write}

    def primary
      @statuses = @timeline_service.primary_timeline
      format_json
    end

    def my_community
      @statuses = @timeline_service.my_community_timeline
      format_json
    end

    def federated
      @statuses = @timeline_service.federated_timeline
      format_json
    end

    def newsmast
      @statuses = @timeline_service.newsmast_timeline
      format_json
    end

    private 

    def set_max_id
      @max_id = params[:max_id]
    end

    def format_json
      unless @statuses.empty?
        render json: @statuses, root: 'data', 
                                each_serializer: Mammoth::StatusSerializer, current_user: current_user, adapter: :json, 
                                meta: {
                                  pagination:
                                  { 
                                    total_objects: nil,
                                    has_more_objects: 5 <= @statuses.size ? true : false
                                  } 
                                }
      else
        render json: {
          data: [],
          meta: {
            pagination:
            { 
              total_objects: 0,
              has_more_objects: false
            } 
          }
        }
      end
    end

    def create_service
      @timeline_service = Mammoth::TimelineService.new(current_account, @max_id, current_user)
    end

    def create_policy
      @status_policy = Mammoth::StatusPolicy.new(current_account, status)
    end
  end
end