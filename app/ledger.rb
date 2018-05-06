require 'json/add/struct'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)
  Record = Struct.new(:payee, :amount, :date)

  class Ledger
    def record(expense)

    end

    def expenses_on(date)

    end
  end
end
