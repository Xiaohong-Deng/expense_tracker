require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    # stubbing
    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data'} }

        # stubbing method call with the help of RecordResult
        # if we do not have a Ledger class defined we can stub
        # the method call. If we have it defined it must have
        # the method defined its called Verifying Doubles
        # which is provided by RSpec
        # though ledger is always the stub we defined in let()
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        # test a method of API which is public to other components of the app at a time
        it 'returns the expense id' do
          # pending 'not with correct id yet'
          # post is not a stub it is real
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with 200 (OK)' do
          # pending 'not with 200 yet'
          post '/expense', JSON.generate(expense)
          expect(last_response.status).to eq 200
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data'} }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq 422
        end
      end
    end
  end
end
