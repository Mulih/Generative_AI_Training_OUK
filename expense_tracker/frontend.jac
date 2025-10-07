# frontend.jac
import requests;
import streamlit as st;


def call_backend(action: str, payload: dict = {}) -> dict {
    try {
        response = requests.post(f"{INSTANCE_URL}/walker/expense_manager", json={"action": action, "payload": payload});
        if response.status_code == 200 {
            reports = data.get("reports", []);
            if len(reports) > 0 {
                first = reports[0];
                if isinstance(first, dict) and first.get("report") is not None {
                    rep = first.get("report");
                } else {
                    rep = first;
                }
            } else {
                rep = data;
            }
        } else {
            return {"status": "error", "message": f"HTTP {response.status_code}", "body": response.text};
        }
    } except Exception as e {
        return {"status": "error", "message": str(e)};
    }
}

with entry {
    INSTANCE_URL = "http://localhost:8000";

    st.set_page_config(page_title="Expense Manager (Jac)", layout="wide");

    st.title("Expense Manager");

    tabs = st.tabs(["Add", "List", "Update", "Delete", "Summary"]);

    # Add
    with tabs[0] {
        st.header("Add Expense");
        description = st.text_input("Description");
        amount = st.number_input("Amount", min_value=0.0, fomart="%f");
        date_in = st.text_input("Date (optional, ISO)", value="");
        if st.button("Add Expense") {
            payload = {"description": description, "amount": float(amount), "date": date_in};
            response = call_backend("add", payload);
            st.write(response);
        }
    }
}
