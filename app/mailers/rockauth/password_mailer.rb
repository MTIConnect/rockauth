class Rockauth::PasswordMailer < ActionMailer::Base
  def reset email, token, resource_owner=nil
    @token = token
    @resource_owner = resource_owner
    @reset_password_link = reset_password_link
    mail to: email, from: Rockauth::Configuration.email_from, subject: I18n.t('rockauth.forgot_password_email_subject')
  end

  def reset_password_link
    client_title = Rockauth::Configuration.session_client.title

    url_params = [:edit, @resource_owner.model_name.param_key, :session_password, user: { password_reset_token: @token }, subdomain: @resource_owner.subdomain]
    url_params.last.merge!(host: App.third_party_client_host[client_title]) if App.third_party_client_host.keys.include?(client_title)
    url_for(url_params)
  end
end
