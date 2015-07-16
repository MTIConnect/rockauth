require 'spec_helper'

module Rockauth
  RSpec.describe AuthenticationsController, type: :controller do
    controller do
    end
    routes { Engine.routes }

    describe 'POST authenticate' do
      let(:authentication_parameters) do
        {}
      end

      let!(:client) { create(:client) }
      let(:parsed_response) { JSON.parse(response.body) }

      context 'when missing basic authentication data' do
        let(:authentication_parameters) do
          { authentication: { } }
        end

        it 'is not successful' do
          post :authenticate, authentication_parameters
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        it 'provides a meaningful error' do
          post :authenticate, authentication_parameters
          expect(parsed_response['error']['validation_errors']).not_to be_blank
          %w(client_id client_secret auth_type).each do |key|
            expect(parsed_response['error']['validation_errors']).to have_key key
            expect(parsed_response['error']['validation_errors'][key]).to include 'can\'t be blank'
          end
        end
      end

      context "when authenticating with a password" do
        let!(:user) { create(:user) }
        let(:client) { create(:client) }

        let(:authentication_parameters) do
          { authentication: { auth_type: 'password', client_id: client.id, client_secret: client.secret, username: user.email, password: user.password } }
        end

        it "authenticates the user" do
          expect do
            post :authenticate, authentication_parameters
          end.to change { Rockauth::Authentication.count }.by 1
          expect(response).to be_success
          expect(assigns(:auth_response).resource_owner).to eq user
        end

        it 'includes the authentication token in the response' do
          post :authenticate, authentication_parameters
          expect(parsed_response['authentication']).to have_key 'token'
        end

        it 'includes the authentication token in the response' do
          post :authenticate, authentication_parameters
          expect(parsed_response['authentication']).to have_key 'resource_owner'
        end

        context "when missing authentication parameters" do
          let(:authentication_parameters) do
            { authentication: { auth_type: 'password' } }
          end

          it "is not successful" do
            post :authenticate, authentication_parameters
            expect(response).not_to be_success
            expect(response.status).to eq 400
          end

          it "provides a meaningful error" do
            post :authenticate, authentication_parameters
            expect(parsed_response['error']['validation_errors']).not_to be_blank
            expect(parsed_response['error']['validation_errors']).to have_key 'username'
            expect(parsed_response['error']['validation_errors']).to have_key 'password'
            expect(parsed_response['error']['validation_errors']['username'].join(' ')).to match /can't be blank/
            expect(parsed_response['error']['validation_errors']['password'].join(' ')).to match /can't be blank/
          end
        end
      end

      context "when authenticating with an assertion", social_auth: true do
        let!(:user) { create(:user) }
        let(:client) { create(:client) }
        let(:provider) { }
        let!(:provider_authentication) { create(:provider_authentication, resource_owner: user, provider: provider, provider_user_id: provider_user_id) }

        let(:authentication_parameters) do
          { authentication: { auth_type: 'assertion', provider: provider, client_id: client.id, client_secret: client.secret, access_token: 'foo', access_token_secret: 'bar' } }
        end

        context "facebook" do
          let(:provider) { 'facebook' }

          it "authenticates" do
            post :authenticate, authentication_parameters
            expect(response).to be_success
          end
        end

        context "twitter" do
          let(:provider) { 'twitter' }

          it "authenticates" do
            post :authenticate, authentication_parameters
            expect(response).to be_success
          end
        end

        context "instagram" do
          let(:provider) { 'instagram' }

          it "authenticates" do
            post :authenticate, authentication_parameters
            expect(response).to be_success
          end
        end

        context "google_plus" do
          let(:provider) { 'google_plus' }

          it "authenticates" do
            post :authenticate, authentication_parameters
            expect(response).to be_success
          end
        end
      end
    end
  end
end
