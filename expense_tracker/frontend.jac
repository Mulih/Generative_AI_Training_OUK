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

    if not st.session_state.get("expenses")  {
            st.session_state.expenses = [];
    }

    # Add
    with tabs[0] {
        st.header("Add Expense");
        description = st.text_input("Description");
        amount = st.number_input("Amount", min_value=0.0, format="%f");
        date_in = st.text_input("Date (optional, ISO)", value="");
        if st.button("Add Expense") {
            payload = {"description": description, "amount": float(amount), "date": date_in};
            response = call_backend("add", payload);
            st.write(response);
        }
    }

    # List
    with tabs[1] {
        st.header("List Expenses");
        if st.button("Refresh") {
            response = call_backend("list", {});
            if response.get("expenses") != None {
                st.session_state.expenses = response.get("expenses");
            } elif isinstance(response, list) {
                st.session_state.expenses = response;
            } else {
                st.session_state.expenses = [];
            }
        }

        for exp in st.session_state.expenses {
            st.write(f"ID: {exp.get('id')} - {exp.get('description')} - ${exp.get('amount')} - {exp.get('date')}");
        }
    }

    # Update
    with tabs[2] {
        st.header("Update Expense");
        upd_id = st.number_input("Expense ID", min_value=1, step=1, key="upd_id");
        upd_amount = st.number_input("New amount", min_value=0.0, format="%f", key="upd_amount");
        if st.button("Update Expense") {
            response = call_backend("update", {"id": int(upd_id), "amount": float(upd_amount)});
            st.write(response);
        }
    }

    # Delete
    with tabs[3] {
        st.header("Delete Expense");
        del_id = st.number_input("Expense ID to delete", min_value=1, step=1, key="del_id");
        if st.button("Delete Expense") {
            response = call_backend("delete", {"id": int(del_id)});
            st.write(response);
        }
    }
}
