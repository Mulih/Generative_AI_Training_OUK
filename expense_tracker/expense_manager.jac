# expense_manager.jac
import from datetime { now, date };

# Expense nde
node Expense {
    has id: int = 0;
    has description: str = "";
    has amount: float = 0.0;
    has date: str = "";
}

# Node that manages expenses
node ExpenseHandling {
    has next_id: int = 1;
    has total: float = 0.0;

    # Helper function
    def iso_now() -> {
        return str(now());
    }

    # Add an expense
    def add_expense(description: str, amount: float, expense_date: str = "") -> dict {
        if expense_date == "" {
            expense_Date = self.iso_now();
        }
        exp = Expense(id=self.next_id, description=description, amount=amount, date=expense_date);
        self ++> exp;
        self.next_id = self.next_id + 1;
        self.total = self.total + amount;
        return {"status": "ok", "id": exp.id, "description": exp.description, "amount": exp.amount, "date": exp.date};
    }
}