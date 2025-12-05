# Proyecto de Microservicios: Resiliencia y Observabilidad

## Estructura
- microservicio-usuarios: CRUD de usuarios (Flask)
- microservicio-notificaciones: Simula fallos y retardo (Flask)
- k8s/: Manifiestos de Kubernetes, Istio y Chaos Engineering

## Requisitos previos
- Inyección de fallos con Istio (Fault Injection) para pruebas de resiliencia

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

### 6. Obtener IP y puerto del Ingress Gateway

**Terminal: WSL (Debian)**
```bash
# Obtener la IP de minikube
minikube ip

# Obtener el puerto del Ingress Gateway (buscar el puerto NodePort para el puerto 80)
kubectl get svc istio-ingressgateway -n istio-system
```

Anota la IP de minikube (ejemplo: `192.168.49.2`) y el puerto NodePort mapeado al puerto 80 (ejemplo: `31769` en la columna `PORT(S)` mostrado como `80:31769/TCP`).

### 7. Probar la API
**Terminal: WSL (Debian)**

Reemplaza `<MINIKUBE_IP>` con la IP obtenida (ej: 192.168.49.2) y `<NODEPORT>` con el puerto obtenido (ej: 31769):

```bash
# Crear usuario
curl -X POST http://<MINIKUBE_IP>:<NODEPORT>/usuarios -H "Content-Type: application/json" -d '{"nombre":"Juan"}'

# Listar usuarios
curl http://<MINIKUBE_IP>:<NODEPORT>/usuarios
```

**Ejemplo con valores reales:**
```bash
curl -X POST http://192.168.49.2:31769/usuarios -H "Content-Type: application/json" -d '{"nombre":"Juan"}'
curl http://192.168.49.2:31769/usuarios
```

**Resultado esperado:** Deberías ver la respuesta JSON con el usuario creado y la lista de usuarios.

### 8. Observar métricas y trazas

**Terminal: PowerShell (recomendado - abre dashboards automáticamente)**

Desde la raíz del proyecto, ejecuta:
```powershell
wsl -d Debian bash -lc "cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO && ./scripts/microservicios start"
```

Este comando:
- Espera a que los pods de observabilidad estén listos (30-60 segundos)
- Inicia port-forwards para los 3 dashboards
- **Abre automáticamente** 3 ventanas del navegador con:
  - Kiali:   http://wsl.localhost:20001/kiali/console
  - Jaeger:  http://wsl.localhost:16686
  - Grafana: http://wsl.localhost:3000

**Alternativa: Terminal WSL (si prefieres abrir manualmente)**

Ejecuta desde WSL:
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO
./scripts/microservicios start
```

Luego abre manualmente en tu navegador:
- Kiali:   http://wsl.localhost:20001/kiali/console
- Jaeger:  http://wsl.localhost:16686
- Grafana: http://wsl.localhost:3000

**Troubleshooting de dashboards:**
- Si los dashboards no se abren automáticamente, consulta [RESOLUCION_PROBLEMAS.md](RESOLUCION_PROBLEMAS.md) - Problema 1
- Si ves "connection refused", consulta [RESOLUCION_PROBLEMAS.md](RESOLUCION_PROBLEMAS.md) - Problema 2
- Para verificar logs de port-forward (WSL):
  ```bash
  tail -n 40 /tmp/microservicios_kiali.log
  tail -n 40 /tmp/microservicios_grafana.log
  ```

**Cerrar dashboards (desde PowerShell):**
```powershell
wsl -d Debian bash -lc "cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO && ./scripts/microservicios stop"
```

Este comando cierra automáticamente las ventanas del navegador y detiene los port-forwards.

### 9. Probar resiliencia con Istio Fault Injection

**Terminal: WSL (Debian)**

Istio incluye capacidades nativas de inyección de fallos sin necesidad de herramientas adicionales. Ver la [Guía Completa de Inyección de Fallos](GUIA_INYECCION_FALLOS.md) para todos los experimentos.

**⚠️ Importante:** Antes de empezar, familiarízate con los dashboards leyendo:
1. **[📚 Índice de Dashboards y Observabilidad](INDICE_DASHBOARDS_OBSERVABILIDAD.md)** - Punto de entrada para todas las guías
2. **[LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md)** - Tu primer experimento paso a paso (~20 min)
3. **[REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md)** - Cheat sheet para consultas rápidas durante pruebas

**Ejemplo rápido - Inyectar delays:**
```bash
# Aplicar delays del 50% en las peticiones
kubectl apply -f k8s/fault-injection-delay.yaml

# Generar tráfico y observar latencias
for i in {1..10}; do
	echo "Petición $i:"
	time curl -X POST http://192.168.49.2:31769/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"Test$i\"}"
	echo ""
done

# Ver efectos en Kiali: http://localhost:20001/kiali/console/graph

# Limpiar
kubectl delete -f k8s/fault-injection-delay.yaml
```

**Otros experimentos disponibles:**
- `fault-injection-abort.yaml`: Inyectar errores HTTP 503 (30% de fallos)
- `fault-injection-combined.yaml`: Combinar delays y errores
- `circuit-breaker.yaml`: Configurar circuit breaker para aislar fallos

Consulta [GUIA_INYECCION_FALLOS.md](GUIA_INYECCION_FALLOS.md) para instrucciones detalladas de cada experimento.

## Notas
- Puedes modificar la probabilidad de fallo en `microservicio-notificaciones/app.py`.
- Los readiness/liveness probes permiten que Kubernetes recupere pods caídos.
- La inyección de fallos de Istio es más ligera que Chaos Mesh y no requiere componentes adicionales.
- El manifiesto de Chaos Mesh requiere que esté instalado en el clúster.

---

¡Listo para experimentar y aprender sobre resiliencia y observabilidad en microservicios!
