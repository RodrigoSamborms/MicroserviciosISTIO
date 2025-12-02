# Proyecto de Microservicios: Resiliencia y Observabilidad

## Estructura
- microservicio-usuarios: CRUD de usuarios (Flask)
- microservicio-notificaciones: Simula fallos y retardo (Flask)
- k8s/: Manifiestos de Kubernetes, Istio y Chaos Engineering

## Requisitos previos
- Docker
- Kubernetes (minikube recomendado en WSL)
- Istio instalado en el clúster
- Chaos Mesh instalado para pruebas de resiliencia

## Pasos para probar

### 1. Construir imágenes Docker
```sh
cd microservicio-usuarios
sudo docker build -t microservicio-usuarios:latest .
cd ../microservicio-notificaciones
sudo docker build -t microservicio-notificaciones:latest .
```

### 2. Subir imágenes a un registry accesible por Kubernetes (opcional si usas minikube con `docker-env`)

### 3. Desplegar en Kubernetes
```sh
kubectl apply -f k8s/usuarios.yaml
kubectl apply -f k8s/notificaciones.yaml
kubectl apply -f k8s/istio.yaml
```

### 4. Habilitar Istio Ingress y obtener IP
```sh
kubectl get svc istio-ingressgateway -n istio-system
```

### 5. Probar la API
```sh
# Crear usuario
curl -X POST http://<INGRESS_IP>/usuarios -H "Content-Type: application/json" -d '{"nombre": "Juan"}'

# Listar usuarios
curl http://<INGRESS_IP>/usuarios
```

### 6. Observar métricas y trazas
- Accede a Kiali, Jaeger o Grafana según la instalación de Istio.

### 7. Probar resiliencia
```sh
kubectl apply -f k8s/chaos-notificaciones.yaml
```
Esto simulará fallos en el microservicio de notificaciones cada 2 minutos.

## Notas
- Puedes modificar la probabilidad de fallo en `microservicio-notificaciones/app.py`.
- Los readiness/liveness probes permiten que Kubernetes recupere pods caídos.
- El manifiesto de Chaos Mesh requiere que esté instalado en el clúster.

---

¡Listo para experimentar y aprender sobre resiliencia y observabilidad en microservicios!
