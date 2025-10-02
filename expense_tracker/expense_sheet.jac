obj ExpenseSheet {
    has expenses: dict[str, float] = {};

    def add_expense(title: str) -> None;
    def add_amount(expense: str, amount: float) -> None;
    def update_amount(student: str, amount: float) -> float;
    def list_expenses() -> dict[str, float];
    def delete_expenses() -> None;
    def delete_expenses(title: str) -> None;
}


with entry:__main__ {
    # Create expense sheet
    expense_sheet = ExpenseSheet();

    print("\n\n=== *** ===\n\n");
    # Add expenses
    expense_sheet.add_expense("Rent");
    expense_sheet.add_expense("Shoes");
    expense_sheet.add_expense("License");

    print("\n\n=== *** ===\n\n");

    # Add amount
    expense_sheet.add_amount("Rent", 35000);
    expense_sheet.add_amount("Shoes", 4500);
    expense_sheet.add_amount("License", 5000);

    print("\n\n=== *** ===\n\n");

    # update amount
    expense_sheet.update_amount("Rent", 40000);
    expense_sheet.update_amount("License", 6500);

}