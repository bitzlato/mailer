# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Postmaster, type: :mailer do
  describe '#process_payload' do
    let!(:user) { OpenStruct.new(email: 'test1@gmail.com') }
    let(:record) { OpenStruct.new(domain: 'barong.com', token: 'blah-blah' ) }
    let(:locale) { :en }
    let(:payload) do
      {
        user: user,
        changes: nil,
        record: record,
        subject: 'Test Email',
        template_name: 'email_confirmation',
        logo: 'https://storage.googleapis.com/public_peatio/logo.png',
        signature: '<span>Company Inc, 3 Abbey Road, San Francisco CA 94102, USA</span><br><a href="http://opendax.io">opendax.io</a>'.html_safe,
        locale: locale,
      }
    end
    let(:mail) { Postmaster.process_payload(payload) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Test Email')
      expect(mail.to).to eq(['test1@gmail.com'])
      expect(mail.from).to eq(['noreply@barong.io'])
    end

    context 'with en locale' do
      it 'renders the body in en language' do
        expect(mail.body.encoded).to match('Use this unique link to confirm your email test1@gmail.com')
      end
    end

    context 'with ru locale' do 
      let(:locale) { :ru }

      it 'renders the body in ru language' do
        expect(mail.body.encoded).to match('Используйте эту уникальную ссылку для подтверждения вашей почты test1@gmail.com')
      end
    end
  end
end
