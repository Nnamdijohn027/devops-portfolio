from flask import Flask, render_template_string, request, redirect

app = Flask(__name__)
todos = []

# Simple HTML template
html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Todo App</title>
</head>
<body>
    <h1>My Todo List</h1>
    <form action="/add" method="POST">
        <input type="text" name="todo" placeholder="Enter todo">
        <button type="submit">Add</button>
    </form>
    <ul>
    {% for todo in todos %}
        <li>{{ todo }}</li>
    {% endfor %}
    </ul>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(html_template, todos=todos)

@app.route('/add', methods=['POST'])
def add():
    todo = request.form.get('todo')
    if todo:
        todos.append(todo)
    return redirect('/')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5005)