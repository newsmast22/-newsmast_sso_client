module Mammoth::Api::V1
  class UsersController < Api::BaseController
		before_action -> { doorkeeper_authorize! :read , :write}
    before_action :require_user!

    def suggestion
      @user  = Mammoth::User.find(current_user.id)
      @users = Mammoth::User.joins(:user_communities).where.not(id: @user.id).where(user_communities: {community_id: @user.communities.ids}).distinct
      account_followed = Follow.where(account_id: current_account).pluck(:target_account_id).map(&:to_i)

      data   = []
      @users.each do |user|
        data << {
          account_id: user.account_id.to_s,
          is_followed: account_followed.include?(user.account_id), 
          user_id: user.id.to_s,
          username: user.account.username,
          display_name: user.account.display_name.presence || user.account.username,
          email: user.email
        }
      end
      render json: {data: data}
    end

    def update
      time = Time.new
      @account = current_account
      unless params[:avatar].nil?
				image = Paperclip.io_adapters.for(params[:avatar])
        @account.avatar = image
			end
      unless params[:header].nil?
				image = Paperclip.io_adapters.for(params[:header])
        @account.header = image
      end
      UpdateAccountService.new.call(@account, account_params, raise_error: true)
      UserSettingsDecorator.new(current_user).update(user_settings_params) if user_settings_params
      ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
      render json: @account, serializer: Mammoth::CredentialAccountSerializer
    end

    def get_user_profile_details
      @account = current_account
      @statuses = Status.where(account_id: @account.id, reply: false)
      account_data = single_serialize(@account, Mammoth::CredentialAccountSerializer)
      render json: @statuses,root: 'statuses_data', each_serializer: Mammoth::StatusSerializer,adapter: :json,
      meta:{
      account_data: account_data
      }
    end

    def show
      @account = current_account
      render json: @account, serializer: Mammoth::CredentialAccountSerializer
    end

    def logout
      Doorkeeper::AccessToken.where(resource_owner_id: current_user.id).destroy_all
      render json: {message: 'logout successed'}
    end

    private

    def account_params
      params.permit(
        :display_name,
        :note,
        :avatar,
        :header,
        :locked,
        :bot,
        :discoverable,
        :hide_collections,
        fields_attributes: [:name, :value]
      )
    end

    def user_settings_params
      return nil if params[:source].blank?
  
      source_params = params.require(:source)
  
      {
        'setting_default_privacy' => source_params.fetch(:privacy, @account.user.setting_default_privacy),
        'setting_default_sensitive' => source_params.fetch(:sensitive, @account.user.setting_default_sensitive),
        'setting_default_language' => source_params.fetch(:language, @account.user.setting_default_language),
      }
    end

    def single_serialize(collection, serializer, adapter = :json)
      ActiveModelSerializers::SerializableResource.new(
        collection,
        serializer: serializer,
        adapter: adapter
        ).as_json
    end

  end
end