from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

usuarios = []

@app.route('/usuarios', methods=['POST'])
def crear_usuario():
    data = request.get_json()
    usuario = {
        'id': len(usuarios) + 1,
        'nombre': data.get('nombre')
    }
    usuarios.append(usuario)
    # Notificar al microservicio de notificaciones
    try:
        requests.post('http://microservicio-notificaciones:5001/notificar', json={'usuario': usuario})
    except Exception as e:
        print(f"Error notificando: {e}")
    return jsonify(usuario), 201

@app.route('/usuarios', methods=['GET'])
def listar_usuarios():
    return jsonify(usuarios)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
