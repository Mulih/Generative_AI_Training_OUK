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
}