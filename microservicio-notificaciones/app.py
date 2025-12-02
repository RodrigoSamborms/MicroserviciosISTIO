from flask import Flask, request, jsonify
import random
import time

app = Flask(__name__)

@app.route('/notificar', methods=['POST'])
def notificar():
    # Simula fallo aleatorio o retardo
    if random.random() < 0.3:
        return jsonify({'error': 'Fallo simulado en notificaciones'}), 500
    if random.random() < 0.3:
        time.sleep(5)
    usuario = request.get_json().get('usuario')
    print(f"Notificación enviada para usuario: {usuario}")
    return jsonify({'mensaje': f'Notificación enviada a {usuario["nombre"]}'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
