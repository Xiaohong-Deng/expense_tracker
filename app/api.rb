require 'sinatra/base'
require 'json'

module ExpenseTracker

  class API < Sinatra::Base
    get '/expenses/:date' do
      JSON.generate([])
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      # result in unit tests is a stub
      result = @ledger.record(expense)

      if result.success?
        JSON.generate('expense_id' => result.expense_id)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end
    # trailing colon indicates a required parameter, if missing will raise error
    # or we can provide a default value after the trailing colon
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end
  end
end
