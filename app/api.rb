require 'sinatra/base'
require 'json'

module ExpenseTracker

  class API < Sinatra::Base
    get '/expenses/:date' do
      JSON.generate([])
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      result = @ledger.record(expense)
      JSON.generate('expense_id' => result.expense_id)
    end
    # trailing colon indicates a required parameter, if missing will raise error
    # or we can provide a default value after the trailing colon
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end
  end
end
