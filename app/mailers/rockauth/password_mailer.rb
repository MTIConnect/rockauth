class Rockauth::PasswordMailer < ActionMailer::Base
  def reset email, token, resource_owner=nil, origin=nil, subdomain=nil
    @origin = origin
    @subdomain = subdomain
    @token = token
    @resource_owner = resource_owner
    @reset_password_link = reset_password_link
    mail to: email, from: Rockauth::Configuration.email_from, subject: I18n.t('rockauth.forgot_password_email_subject')
  end

  def reset_password_link
    subdomain = @subdomain
    host = App.domain
    if subdomain.nil? && @origin.present?
      host = @origin
      url_array = URI.parse(@origin).host.split('.')
      url_array.pop(2)
      subdomain = url_array.join('.')
    end
    url_params = [:edit, @resource_owner.model_name.param_key, :session_password, user: { password_reset_token: @token }, subdomain: subdomain, host: host]
    url_for(url_params)
  end
end
