require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    # by default JSON can not convert strings to struct
    # need to turn on a switch and require json/add/struct
    def parsed(payload, to_struct = false)
      return JSON.parse(payload) unless to_struct
      JSON.parse(payload, create_additions: to_struct)
    end

    # stubbing
    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'GET /expenses/:date' do
      let(:date) { '2017-06-10' }

      context 'when expenses exist on the given date' do
        let(:starbucks) { Record.new('Starbucks', 5.00, '2017-06-10') }
        let(:zoo) { Record.new('Zoo', 4.75, '2017-06-10') }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return([starbucks, zoo])
        end

        it 'returns the expense records' do
          get '/expenses/2017-06-10'

          expect(parsed(last_response.body, true)).to contain_exactly(starbucks, zoo)
        end

        it 'responds with a 200 (ok)' do
          get '/expenses/2017-06-10'

          expect(last_response.status).to eq 200
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return([])
        end

        it 'return an empty array as JSON' do
          get '/expenses/2017-06-10'

          expect(parsed(last_response.body)).to be_empty
        end

        it 'responds with 200 (ok)' do
          get '/expenses/2017-06-10'

          expect(last_response.status).to eq 200
        end
      end
    end

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

          expect(parsed(last_response.body)).to include('expense_id' => 417)
        end

        it 'responds with 200 (OK)' do
          # pending 'not with 200 yet'
          post '/expenses', JSON.generate(expense)
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

          expect(parsed(last_response.body)).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq 422
        end
      end
    end
  end
end
