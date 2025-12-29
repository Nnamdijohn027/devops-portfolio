# services/users-service/app.py
from flask import Flask, jsonify
import socket
import os
import time

app = Flask(__name__)

# Simple in-memory database
users = {
    "1": {"id": "1", "name": "Alice", "email": "alice@example.com"},
    "2": {"id": "2", "name": "Bob", "email": "bob@example.com"}
}

@app.route('/')
def home():
    return jsonify({
        "service": "users-service",
        "hostname": socket.gethostname(),
        "timestamp": time.time()
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/users')
def get_users():
    return jsonify(list(users.values()))

@app.route('/users/<user_id>')
def get_user(user_id):
    user = users.get(user_id)
    if user:
        return jsonify(user)
    return jsonify({"error": "User not found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)