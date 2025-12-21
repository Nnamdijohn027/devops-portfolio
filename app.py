from flask import Flask, render_template_string, request, redirect
import os
import psycopg2
from dotenv import load_dotenv
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

load_dotenv() 

app = Flask(__name__)

# Prometheus metric
TODO_ADDED = Counter('todo_added_total', 'Total number of todos added')

# Database connection
def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        database=os.getenv('DB_NAME', 'todoapp'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password')
    )
    return conn

# Create table if not exists
def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS todos (
            id SERIAL PRIMARY KEY,
            task TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    cur.close()
    conn.close()

# HTML template
html_template = """<!DOCTYPE html>
<html><head><title>Todo App</title></head>
<body>
    <h1>My Todo List</h1>
    <form action="/add" method="POST">
        <input type="text" name="todo" placeholder="Enter todo">
        <button type="submit">Add</button>
    </form>
    <ul>
    {% for todo in todos %}
        <li>{{ todo[1] }}</li>
    {% endfor %}
    </ul>
</body></html>"""

@app.route('/')
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM todos ORDER BY created_at DESC')
    todos = cur.fetchall()
    cur.close()
    conn.close()
    return render_template_string(html_template, todos=todos)

@app.route('/add', methods=['POST'])
def add():
    todo = request.form.get('todo')
    if todo:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('INSERT INTO todos (task) VALUES (%s)', (todo,))
        conn.commit()
        cur.close()
        conn.close()
        TODO_ADDED.inc()  # Track metric
    return redirect('/')

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=8000)

# Add this if not present
from prometheus_client import Counter, generate_latest, REGISTRY
from prometheus_client.exposition import CONTENT_TYPE_LATEST

# Add metrics (after imports)
TODO_ADDED = Counter('todo_added_total', 'Total todos created')
PAGE_VIEWS = Counter('page_views_total', 'Total page views', ['page'])

# Add metrics endpoint (add this new route)
@app.route('/metrics')
def metrics():
    PAGE_VIEWS.labels(page='metrics').inc()
    return generate_latest(REGISTRY), 200, {'Content-Type': CONTENT_TYPE_LATEST}    