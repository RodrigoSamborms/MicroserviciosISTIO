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

**Terminal: WSL (Debian)**
```bash
# Cargar imágenes en minikube
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO
minikube image load microservicio-usuarios:latest
minikube image load microservicio-notificaciones:latest
```

### 3. Verificar que minikube esté corriendo

**Terminal: WSL (Debian)**
```bash
minikube status
```

**Si minikube no está corriendo**, inícialo con:
```bash
minikube start --driver=docker --memory=2048 --cpus=2
```

### 4. Desplegar en Kubernetes

**Importante:** Asegúrate de estar en el directorio raíz del proyecto.

**Terminal: WSL (Debian)**
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO
kubectl apply -f k8s/usuarios.yaml
kubectl apply -f k8s/notificaciones.yaml
kubectl apply -f k8s/istio.yaml
```

### 5. Verificar que los pods estén listos

**Terminal: WSL (Debian)**
```bash
kubectl get pods
```

Espera hasta que todos los pods estén en estado `2/2 Running`. Esto puede tomar 2-3 minutos.

### 6. Habilitar Istio Ingress Gateway con túnel

**Terminal: WSL (Debian) - Mantén esta terminal abierta**
```bash
minikube tunnel
```

**Nota:** Este comando debe permanecer ejecutándose. Abre otra terminal WSL para los siguientes pasos.

En otra terminal, verifica la IP del Ingress:
```bash
kubectl get svc istio-ingressgateway -n istio-system
```

La `EXTERNAL-IP` debe ser `127.0.0.1`.

### 7. Probar la API
**Terminal: WSL (Debian) - En otra terminal (no la del túnel)**
```bash
# Crear usuario
curl -X POST http://127.0.0.1/usuarios -H "Content-Type: application/json" -d '{"nombre":"Juan"}'

# Listar usuarios
curl http://127.0.0.1/usuarios
```

**Resultado esperado:** Deberías ver la respuesta JSON con el usuario creado y la lista de usuarios.

### 8. Observar métricas y trazas

**Terminal: WSL (Debian)**
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO/istio-1.28.0

# Abrir dashboards (cada comando abre un navegador)
./bin/istioctl dashboard kiali
./bin/istioctl dashboard jaeger
./bin/istioctl dashboard grafana
```

### 9. Probar resiliencia
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
