# frozen_string_literal: true

require 'rails_helper'

describe User do
  describe '#language' do
    let(:user) { create :user, email: 'member@example.com' }
    let(:email_verified) { true }
    let!(:bitzlato_user) do
      create :bitzlato_user,
        real_email: bitzlato_user_email,
        email_verified: email_verified
    end

    context 'when user has bitzlato profile' do
      let(:bitzlato_user_email) { 'member@example.com' }
      let!(:bitzlato_profile) do
        create :bitzlato_profile,
          lang: 'de',
          bitzlato_user: bitzlato_user
      end

      it { expect(user.language).to eq :de }

      context 'when user profile with unverified email' do
        let(:email_verified) { false }

        it { expect(user.language).to eq :en }
      end

      context 'when has second user with the same email' do
        let(:doubled_bitzlato_user) do
          create :bitzlato_user,
            real_email: bitzlato_user_email,
            email_verified: true
        end

        let!(:doubled_bitzlato_profile) do
          create :bitzlato_profile,
            lang: 'fr',
            bitzlato_user: doubled_bitzlato_user,
            generated_name: 'Gérard Depardieu'
        end

        it 'takes last bitzlato_user record' do
          expect(user.language).to eq :fr
        end
      end
    end

    context 'when user has not bitzlato profile' do
      let(:bitzlato_user_email) { 'admin@example.com' }

      it { expect(user.language).to eq :en }
    end
  end
end
