import http.server
import socketserver

# Define the port number you want the server to listen on
PORT = 8000

# Specify the handler for incoming requests.
# SimpleHTTPRequestHandler serves files from the current directory.
Handler = http.server.SimpleHTTPRequestHandler

# Create a TCPServer. The first argument is the address (empty string means all available interfaces),
# and the second is the port. The third argument is the request handler.
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("good morning")
    # Start the server and keep it running indefinitely until interrupted (e.g., Ctrl+C)
    httpd.serve_forever()