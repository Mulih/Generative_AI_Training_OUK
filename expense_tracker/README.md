# Expense Tracker (Jac)

This repository contains a small expense-tracking example implemented using the Jac programming language for the backend logic and a Streamlit-based frontend. The project demonstrates a Walker-based API implemented in `expense_manager.jac` and a frontend interface in `frontend.jac` that talks to the walker over HTTP.

## Repository structure

- `expense_manager.jac` — Jac program containing the Expense data model, the `ExpenseHandling` node which manages expenses, and the `expense_manager` walker that exposes the functionality to an HTTP front-end.
- `frontend.jac` — Frontend code (Streamlit-like UI logic) that calls the walker at `/walker/expense_manager` using HTTP POST to perform add/list/update/delete/summary actions.
- `README.md` — This file.

## Concepts and components

### Data model (`Expense`)

The core data model is the `Expense` node. Each expense contains:

- `id` (int) — unique identifier assigned when an expense is added.
- `description` (str) — a short text description of the expense.
- `amount` (float) — expense amount.
- `date` (str) — ISO-like date string (the code stores `str(datetime.now())` by default when none is provided).

### Expense manager (`ExpenseHandling`)

`ExpenseHandling` is a Jac node that stores expenses as child nodes. Key capabilities implemented in `expense_manager.jac`:

- add_expense(description, amount, expense_date="") -> dict — create an Expense node and update running totals.
- list_expenses() -> list — return all stored expenses as a list of dictionaries.
- update_expense(id, amount) -> dict — find an expense by id and update its amount; adjusts totals.
- delete_expense(id) -> dict — (deletes an expense) returns error if not found.
- summary(month=0) -> dict — compute totals and list expenses optionally filtered by month (month=0 = all months).

The node also exposes a `can execute` ability under the `expense_manager` walker entry which inspects `visitor.action` and `visitor.payload` to decide which internal method to call and then places the result in `visitor.response`.

### Walker: `expense_manager`

The walker is intended to be hosted by a Jac runtime that exposes walkers over HTTP. The frontend sends a POST to the walker endpoint with a JSON body like:

```
{
	"action": "add",
	"payload": { "description": "Lunch", "amount": 12.5, "date": "" }
}
```

The walker populates a `response` structure and a `node_type` identifying what operation ran. The frontend then reflects that response to the user.

## Frontend (`frontend.jac`)

`frontend.jac` contains UI logic that uses Streamlit primitives (e.g., `st.title`, `st.button`, `st.text_input`) and uses `requests.post` to call the walker endpoint at `http://localhost:8000/walker/expense_manager` (configured by `INSTANCE_URL` in the file).

Notes:
- The frontend expects the walker to be available at `/walker/expense_manager`.
- The code uses the JSON field names `action` and `payload` as described above.

## HTTP API examples

Below are example requests and the expected shapes of responses based on the current Jac code.

- Add an expense

	Request body:

	```json
	{"action":"add","payload":{"description":"Coffee","amount":3.5,"date":""}}
	```

	Possible response (walker response set into HTTP response body by the Jac runtime):

	```json
	{"status":"ok","id":1,"description":"Coffee","amount":3.5,"date":"2025-10-07 12:34:56.789012"}
	```

- List expenses

	Request body:

	```json
	{"action":"list","payload":{}}
	```

	Response shape:

	```json
	{"expenses":[{"id":1,"description":"Coffee","amount":3.5,"date":"..."}, ...]}
	```

- Update expense

	Request body:

	```json
	{"action":"update","payload":{"id":1,"amount":4.0}}
	```

	Response (success):

	```json
	{"status":"ok","id":1,"old amount":3.5,"new amount":4.0}
	```

- Delete expense

	Request body:

	```json
	{"action":"delete","payload":{"id":1}}
	```

	Response if expense not found:

	```json
	{"status":"error","message":"expense not found","id":1}
	```

- Summary (month filter)

	Request body:

	```json
	{"action":"summary","payload":{"month":10}}
	```

	Response shape:

	```json
	{"month":10,"total":123.45,"expenses":[ ... ]}
	```

## Running locally (notes & prerequisites)

Prerequisites (suggested):

- Jac runtime installed and configured to host walkers and accept HTTP requests.
- Python 3 (if you plan to run any Python or Streamlit-based code outside of Jac).
- `streamlit` and `requests` Python packages if you convert or run the frontend as Python code.

Because Jac tooling and commands can vary depending on your installation, this document avoids prescribing an exact command to start the Jac runtime. In general:

1. Start the Jac runtime and load `expense_manager.jac` so the walker `expense_manager` is reachable via HTTP (commonly hosted at `http://localhost:8000/walker/expense_manager`). Consult your Jac runtime documentation for the exact command to host walkers over HTTP.
2. Start the frontend. If your Jac environment supports running `frontend.jac` directly, use that. Alternatively, you can port the `frontend.jac` Streamlit UI into a small Python `frontend.py` that sends POST requests to the walker endpoint and run it with Streamlit:

```bash
# Example (if you port frontend.jac to a Python file named frontend.py)
pip install streamlit requests
streamlit run frontend.py
```

3. Use the UI or curl/postman to call the walker endpoint with the JSON shapes shown above.

Example curl (replace with your runtime's actual host/port):

```bash
curl -X POST http://localhost:8000/walker/expense_manager \
	-H "Content-Type: application/json" \
	-d '{"action":"list","payload":{}}'
```

## Anomaly detection (in progress)

Work is underway to add an anomaly detection capability that uses Jac's AI-related features. High-level goals and approach:

- Purpose: detect unusual expenses (e.g., spikes, duplicate/near-duplicate descriptions with large amounts, or outliers compared to historical spending patterns) and surface them to the user.
- Data flow: the existing `ExpenseHandling` node will optionally emit summarized expense records (or the full expenses list) to an `AnomalyDetector` node. The detector will use a combination of lightweight statistical methods (z-score, rolling-window deviations) and AI-assisted techniques available in Jac (embeddings, similarity, or model-assisted scoring) to identify anomalies.
- Implementation notes (planned):
	- Compute baseline statistics per user / per category / per month.
	- Use Jac's AI primitives to compute semantic similarity between expense descriptions (to detect near-duplicates or suspicious patterns).
	- Flag and score anomalies with a configurable threshold and return structured results (score, reason, related expenses).
	- Provide an API endpoint or include anomalies in the existing walker's `summary` response under a separate key (e.g. `anomalies`).

This feature is currently in design/implementation and will be added to the codebase as a separate Jac node and walker-API extension. Because Jac's AI APIs evolve, the final implementation will reference the Jac runtime's AI primitives for embeddings/similarity or call out to a small model if required.

## Contributing

If you want to contribute:

1. Open an issue to discuss significant changes (e.g., change of API shapes, persistent storage, or anomaly detection design).
2. Create a branch, make small, focused changes, and open a pull request when ready.

## Next steps

- Finalize and test deletion semantics in `expense_manager.jac` (ensure nodes are detached correctly).
- Harden date parsing and validate inputs at the walker boundary.
- Implement and test the AnomalyDetector node and expose anomaly summaries via the walker.


---

<img width="2927" height="1045" alt="Screenshot From 2025-10-07 19-59-22" src="https://github.com/user-attachments/assets/c9ede046-bc8f-4cfe-9922-fab51bcb17b3" />

