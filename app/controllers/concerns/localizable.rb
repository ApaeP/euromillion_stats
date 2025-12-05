module Localizable
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    if validated_locale(params[:locale])
      I18n.locale = params[:locale]
      session[:locale] = I18n.locale
    elsif validated_locale(session[:locale])
      I18n.locale = session[:locale]
    else
      I18n.locale = browser_locale || I18n.default_locale
    end
  end

  def browser_locale
    accepted = request.env['HTTP_ACCEPT_LANGUAGE']
    return unless accepted

    accepted.scan(/[a-z]{2}(?=-|;|,|$)/i).find do |locale|
      validated_locale(locale)
    end&.to_sym
  end

  def validated_locale(locale)
    return if I18n.available_locales.exclude?(locale&.to_sym)

    locale
  end
end
