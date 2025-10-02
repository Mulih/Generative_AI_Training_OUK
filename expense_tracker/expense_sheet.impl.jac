impl ExpenseSheet.add_expense(title: str) -> None {
    if title not in self.expenses {
        self.expenses[title] = [];
        print(f"Added expense: {title}");
    } else {
        print(f"Expense {title} already exists");
    }
}

impl ExpenseSheet.add_amount(expense: str, amount: float) -> None {
    if amount < 0 {
        print(f"Invalid amount: {amount}");
        return;
    }

    if expense in self.expenses {
        self.expenses[expense].append(amount);
        print(f"Added amount {amount} for {expense}");
    } else {
        print(f"Expense {expense} not found");
    }
}

impl ExpenseSheet.update_amount(title: str, amount: float) -> None {
    for expense in self.expenses {
        if strcmp(expense[title], title) {
            expense[amount] = amount;
            print(f"Expense {title} updated to amount ${amount}");
            return;
        }
    }
    print(f"Expense {title} not found");
}

impl ExpenseSheet.delete_expenses() -> None {
    self.expenses = {};
    print("Expenses deleted!");
    return;
}

impl ExpenseSheet.delete_expense(title) {
    expenses = [expense for expense in expenses if expense["title"] != title];
    print(f"Expense {title} deleted");
}