class Rockauth::PasswordMailer < ActionMailer::Base
  def reset email, token, resource_owner=nil, client_id=nil
    @client_id = client_id
    @token = token
    @resource_owner = resource_owner
    @reset_password_link = reset_password_link
    mail to: email, from: Rockauth::Configuration.email_from, subject: I18n.t('rockauth.forgot_password_email_subject')
  end

  def reset_password_link
    # url_params = [:edit, @resource_owner.model_name.param_key, :session_password, user: { password_reset_token: @token }, subdomain:  @resource_owner.subdomain]
    url_params = [:edit, @resource_owner.model_name.param_key, :session_password, user: { password_reset_token: @token }, subdomain: 'mti-web-development']
    url_params.last.merge!(host: App.third_party_client_host[client.title]) if client.present? && App.third_party_client_host.keys.include?(client.title)
    url_for(url_params)
  end

protected
  def client
    @client ||= Rockauth::Configuration.clients.find { |c| c.id == @client_id }
  end
end
