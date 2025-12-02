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

### ⚠️ Antes de continuar

1. **Verifica tu instalación:** Ejecuta las verificaciones del archivo `VERIFICACION_INSTALACION.md` para confirmar que tienes todas las herramientas necesarias.

2. **Si te falta alguna herramienta:** Consulta el archivo `INSTALACION_CONFIGURACION.md` que contiene instrucciones paso a paso para instalar todo desde cero.

3. **Verifica que los addons de Istio estén instalados:** Ejecuta `kubectl get pods -n istio-system` y asegúrate de ver pods de `kiali`, `jaeger`, `grafana`, y `prometheus` en estado `Running`. Si no están instalados, consulta la sección de addons en `INSTALACION_CONFIGURACION.md`.

---

## Pasos para probar

### 1. Construir imágenes Docker
**Terminal: WSL (Debian)**
```bash
cd microservicio-usuarios
sudo docker build -t microservicio-usuarios:latest .
cd ../microservicio-notificaciones
sudo docker build -t microservicio-notificaciones:latest .
```

### 2. Subir imágenes a un registry accesible por Kubernetes (opcional si usas minikube con `docker-env`)

### 3. Desplegar en Kubernetes
**Terminal: WSL (Debian)**
```bash
kubectl apply -f k8s/usuarios.yaml
kubectl apply -f k8s/notificaciones.yaml
kubectl apply -f k8s/istio.yaml
```

### 4. Habilitar Istio Ingress y obtener IP
**Terminal: WSL (Debian)**
```bash
kubectl get svc istio-ingressgateway -n istio-system
```

### 5. Probar la API
**Terminal: WSL (Debian)**
```bash
# Crear usuario
curl -X POST http://<INGRESS_IP>/usuarios -H "Content-Type: application/json" -d '{"nombre": "Juan"}'

# Listar usuarios
curl http://<INGRESS_IP>/usuarios
```

### 6. Observar métricas y trazas
- Accede a Kiali, Jaeger o Grafana según la instalación de Istio.

### 7. Probar resiliencia
**Terminal: WSL (Debian)**
```bash
kubectl apply -f k8s/chaos-notificaciones.yaml
```
Esto simulará fallos en el microservicio de notificaciones cada 2 minutos.

## Notas
- Puedes modificar la probabilidad de fallo en `microservicio-notificaciones/app.py`.
- Los readiness/liveness probes permiten que Kubernetes recupere pods caídos.
- El manifiesto de Chaos Mesh requiere que esté instalado en el clúster.

---

¡Listo para experimentar y aprender sobre resiliencia y observabilidad en microservicios!
