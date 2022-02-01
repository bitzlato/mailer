# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Postmaster, type: :mailer do
  describe '#process_payload' do
    let!(:user) { OpenStruct.new(email: 'test1@gmail.com') }
    let(:record) { OpenStruct.new(currency: 'BTC', amount: 1.5, tid: 'TID', state: 'invoiced') }
    let(:locale) { :en }
    let(:payload) do
      {
        user: user,
        changes: nil,
        record: record,
        subject: 'Test Email',
        template_name: 'deposit_updated',
        logo: 'https://storage.googleapis.com/public_peatio/logo.png',
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
        expect(mail.body.encoded).to match('Your deposit #TID of 1.5 BTC has been <b>invoiced</b>')
      end
    end

    context 'with ru locale' do
      let(:locale) { :ru }

      it 'renders the body in ru language' do
        expect(mail.body.encoded).to match('Ваше пополнение #TID в размере 1.5 BTC сменило статус.')
        expect(mail.body.encoded).to match('Новый статус: <b>выставлен счет</b>')
      end
    end
  end
end
