class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_listing
  before_action :set_locale
  before_action :set_account
  theme         :theme_resolver

  protected

    def default_url_options
      { theme: request.parameters['theme'], alias_id: params[:alias_id], locale: params[:locale] }
    end

    def extract_alias_id(text)
      text  = text.to_s.dup.force_encoding('ISO-8859-1')
      match = /^([A-Za-z]+-)?[A-Za-z]+\d+/.match(text)
      if match.present?
        match[0]
      else
        text
      end
    end

  private

    def set_listing
      @listing = Yoolk::Sandbox::Listing.find(params[:alias_id] || 'kh1')
    end

    def set_locale
      locale = (params[:locale].presence || @listing.locale).to_sym

      ::I18n.locale   = locale
    end

    def set_account
      @current_account = Yoolk::Sandbox::Account.find(params[:login])
    end

    def content_for_header
      Yoolk::Liquid::ContentHeader.new(@listing, view_context, seo).to_s
    end

    def seo
      class_name = "yoolk/seo/#{controller_path}/#{action_name}".classify
      @obj = [@announcement,
              @product, @product_category,
              @service, @service_category,
              @food, @food_category,
              @gallery].compact

      class_name.constantize.new(@listing, @obj.first)
    end

    def theme_resolver
      params[:theme].presence || 'sample'
    end

    def liquid_assigns
      view_assigns.merge('content_for_header' => content_for_header)
    end
end