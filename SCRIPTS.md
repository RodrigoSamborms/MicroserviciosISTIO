# Guía de Scripts

Esta guía documenta todos los scripts disponibles en la carpeta `scripts/` para facilitar la gestión del entorno de microservicios con Kubernetes, Istio y la inyección de fallos.

---

## Índice de Scripts

1. [microservicios](#1-microservicios) - Script principal de gestión
2. [start_session.sh](#2-start_sessionsh) - Inicio manual de sesión
3. [stop_session.sh](#3-stop_sessionsh) - Cierre manual de sesión

---

## 1. microservicios

**Ubicación:** `scripts/microservicios`

**Descripción:** Script principal unificado para gestionar el ciclo de vida completo del entorno de microservicios. Maneja minikube, dashboards de Istio (Kiali, Jaeger, Grafana) y proporciona comandos de diagnóstico.

**Terminal recomendada:** WSL (Debian). Ejecuta los comandos desde `/mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO`.

### Uso

```bash
./scripts/microservicios <comando> [opciones]
```

### Comandos Principales

#### `start` - Iniciar sesión

Inicia el entorno completo en segundo plano:
- Arranca minikube con recursos configurados (2048MB RAM, 2 CPUs)
- Verifica pods de Istio
- Asegura inyección de sidecar en namespace `default`
- Obtiene IP y NodePort del Ingress Gateway
- Inicia dashboards de observabilidad (Kiali, Jaeger, Grafana) en segundo plano con puertos fijos (20001, 16686, 3000) y reintentos de port-forward
- Realiza prueba de conectividad al API

**Ejemplo:**
```bash
./scripts/microservicios start
```

**Comportamiento:**
- Si ya hay una sesión activa, muestra mensaje y no reinicia
- Reintenta el port-forward de dashboards y escribe logs en `/tmp/microservicios_{kiali,jaeger,grafana}.log`
- Todos los procesos corren en background

---

#### `stop` - Detener sesión

Detiene todos los componentes de forma ordenada:
- Elimina configuraciones de fault injection activas
- Cierra dashboards de Istio (Kiali, Jaeger, Grafana)
- Detiene minikube
- Limpia archivos PID temporales

**Ejemplo:**
```bash
./scripts/microservicios stop
```

**Comportamiento:**
- Si no hay sesión activa, informa al usuario
- Elimina VirtualServices y DestinationRules de fault injection
- Mata procesos de dashboards por PID

---

#### `status` - Ver estado del entorno

Muestra el estado actual del entorno sin opciones adicionales:
- Estado de minikube (Running/Stopped)
- Dashboards activos (PIDs y puertos)
- IP y NodePort del Ingress Gateway

**Ejemplo:**
```bash
./scripts/microservicios status
```

**Salida típica:**
```
=== Estado de Minikube ===
minikube: Running
IP: 192.168.49.2

=== Dashboards Activos ===
Kiali:   PID 12345 - http://localhost:20001/kiali
Jaeger:  PID 12346 - http://localhost:16686
Grafana: PID 12347 - http://localhost:3000

=== Ingress Gateway ===
http://192.168.49.2:31769
```

---

#### `status --pods` - Ver estado de pods

Muestra todos los pods en los namespaces principales:
- `istio-system`: Control plane de Istio y addons
- `default`: Microservicios desplegados

**Ejemplo:**
```bash
./scripts/microservicios status --pods
```

**Salida incluye:**
- Nombre del pod
- Estado (Running, Pending, CrashLoopBackOff, etc.)
- Número de reinicios
- Edad del pod

---

#### `status --services` - Ver servicios y endpoints

Muestra información de servicios Kubernetes:
- Services en `istio-system` (Ingress Gateway, Egress, control plane)
- Services en `default` (microservicios)
- ClusterIP, External IP, puertos

**Ejemplo:**
```bash
./scripts/microservicios status --services
```

---

#### `status --istio` - Análisis de configuración Istio

Ejecuta diagnóstico de configuración de Istio:
- `istioctl analyze -n default`: Detecta errores de configuración
- Lista VirtualServices activos
- Lista DestinationRules activos
- Verifica port naming conventions

**Ejemplo:**
```bash
./scripts/microservicios status --istio
```

**Útil para:**
- Verificar que VirtualServices estén bien configurados
- Detectar problemas de enrutamiento
- Validar fault injection aplicado

**Comandos rápidos de inspección (Terminal: WSL - Debian):**
```bash
kubectl get virtualservice -n default
kubectl get destinationrule -n default
```

---

#### `status --faults` - Ver inyecciones de fallos activas

Lista las configuraciones de fault injection actualmente aplicadas:
- VirtualServices con delays o aborts
- DestinationRules con circuit breakers
- Detalles de cada configuración

**Ejemplo:**
```bash
./scripts/microservicios status --faults
```

**Salida típica:**
```
=== Configuraciones de Fault Injection ===
VirtualService: microservicio-notificaciones-fault-delay
  - Delay: 50% con 5s
  - Host: microservicio-notificaciones
```

---

#### `status --all` - Información completa

Ejecuta todas las verificaciones anteriores en un solo comando:
- Estado de minikube
- Dashboards activos
- Pods en todos los namespaces
- Servicios
- Configuración de Istio
- Fault injection activo

**Ejemplo:**
```bash
./scripts/microservicios status --all
```

---

### Archivos de PID

El script utiliza archivos temporales para rastrear procesos en background:

- `/tmp/microservicios_kiali.pid` - PID del dashboard de Kiali
- `/tmp/microservicios_jaeger.pid` - PID del dashboard de Jaeger
- `/tmp/microservicios_grafana.pid` - PID del dashboard de Grafana

Estos archivos se eliminan automáticamente con `./scripts/microservicios stop`.

### Dashboards de Istio

**Terminal: WSL (Debian)**
```bash
# Desde la raíz del repo
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

# Abre Kiali, Jaeger y Grafana en segundo plano con puertos fijos
./scripts/microservicios dashboards

# URLs
# Kiali:   http://localhost:20001/kiali/console
# Jaeger:  http://localhost:16686
# Grafana: http://localhost:3000

# Logs de port-forward (útiles si no abre)
tail -n 40 /tmp/microservicios_kiali.log
tail -n 40 /tmp/microservicios_grafana.log
```

---

### Ejemplo de Flujo de Trabajo

**Inicio del día:**
```bash
# Iniciar todo el entorno
./scripts/microservicios start

# Verificar que todo esté bien
./scripts/microservicios status --all

# Aplicar fault injection
kubectl apply -f k8s/fault-injection-delay.yaml

# Generar tráfico
for i in {1..10}; do
  curl -X POST http://$(minikube ip):31769/usuarios \
    -H "Content-Type: application/json" -d "{\"nombre\":\"User$i\"}"
done

# Ver métricas en Kiali (ya abierto en http://localhost:20001/kiali)
```

**Durante el trabajo:**
```bash
# Ver qué fault injection está activo
./scripts/microservicios status --faults

# Ver estado de los pods
./scripts/microservicios status --pods

# Verificar configuración de Istio
./scripts/microservicios status --istio
```

**Fin del día:**
```bash
# Detener todo limpiamente
./scripts/microservicios stop
```

---

## 2. start_session.sh

**Ubicación:** `scripts/start_session.sh`

**Descripción:** Script original de inicio de sesión. Realiza configuración básica del entorno sin iniciar dashboards en background.

### Uso

```bash
bash scripts/start_session.sh
```

### Funciones

1. Inicia minikube con `--driver=docker --memory=2048 --cpus=2`
2. Verifica pods de Istio en `istio-system`
3. Asegura label de inyección automática en namespace `default`
4. Obtiene IP de minikube y NodePort del Ingress Gateway
5. Realiza prueba GET `/usuarios` para verificar conectividad

### Cuándo Usar

- Si prefieres iniciar dashboards manualmente
- Para debugging del proceso de inicio
- Como referencia de los pasos individuales
- Si el script `microservicios` presenta problemas

### Diferencias con `microservicios start`

| Característica | start_session.sh | microservicios start |
|---------------|------------------|---------------------|
| Dashboards | No inicia | Inicia en background |
| Verificación | Básica | Completa con reintentos |
| Background | No | Sí |
| Gestión de PIDs | No | Sí |
| Detección de sesión activa | No | Sí |

---

## 3. stop_session.sh

**Ubicación:** `scripts/stop_session.sh`

**Descripción:** Script original de cierre de sesión. Limpia configuraciones y detiene minikube sin gestión avanzada de procesos.

### Uso

```bash
bash scripts/stop_session.sh
```

### Funciones

1. Elimina VirtualServices de fault injection:
   - `fault-injection-delay.yaml`
   - `fault-injection-abort.yaml`
   - `fault-injection-combined.yaml`
   - `circuit-breaker.yaml`

2. Cierra dashboards mediante `pkill`:
   - Kiali
   - Jaeger
   - Grafana

3. Detiene minikube

### Cuándo Usar

- Como alternativa al comando `microservicios stop`
- Si necesitas un cierre más agresivo (pkill busca por nombre de proceso)
- Para debugging

### Diferencias con `microservicios stop`

| Característica | stop_session.sh | microservicios stop |
|---------------|-----------------|-------------------|
| Método de cierre | pkill por nombre | kill por PID |
| Verificación previa | No | Sí (verifica sesión activa) |
| Limpieza de PIDs | No | Sí |
| Mensajes informativos | Básicos | Detallados |

---

## Solución de Problemas

### Problema: "Ya hay una sesión activa"

**Causa:** Minikube ya está corriendo o hay PIDs guardados.

**Solución:**
```bash
# Ver estado actual
./scripts/microservicios status

# Si minikube está detenido pero quedan PIDs
./scripts/microservicios stop
./scripts/microservicios start
```

---

### Problema: Dashboards no se abren

**Causa:** Los procesos de `istioctl dashboard` murieron o los puertos están ocupados.

**Solución:**
```bash
# Ver PIDs y puertos
./scripts/microservicios status

# Reiniciar dashboards (detener y volver a iniciar)
./scripts/microservicios stop
./scripts/microservicios start
```

---

### Problema: "No hay sesión activa" pero minikube está corriendo

**Causa:** Minikube se inició manualmente fuera del script.

**Solución:**
```bash
# Detener minikube manualmente
minikube stop

# Iniciar con el script
./scripts/microservicios start
```

---

### Problema: Puertos ocupados (20001, 16686, 3000)

**Causa:** Procesos previos no se cerraron correctamente.

**Solución:**
```bash
# Ver qué proceso usa cada puerto
lsof -i :20001
lsof -i :16686
lsof -i :3000

# Matar procesos específicos
kill <PID>

# O usar el script
./scripts/microservicios stop
```

---

## Mejores Prácticas

### 1. Usar `microservicios` como herramienta principal

```bash
# Flujo recomendado
./scripts/microservicios start       # Al inicio
./scripts/microservicios status --all # Verificación
# ... trabajo con fault injection ...
./scripts/microservicios stop        # Al finalizar
```

### 2. Verificar estado antes de aplicar cambios

```bash
# Antes de aplicar fault injection
./scripts/microservicios status --istio
kubectl apply -f k8s/fault-injection-delay.yaml
./scripts/microservicios status --faults
```

### 3. Monitorear pods durante experimentos

```bash
# Terminal 1: Observar pods en tiempo real
watch -n 2 "./scripts/microservicios status --pods"

# Terminal 2: Generar tráfico
for i in {1..100}; do
  curl -X POST http://$(minikube ip):31769/usuarios \
    -H "Content-Type: application/json" -d "{\"nombre\":\"User$i\"}"
  sleep 1
done
```

### 4. Limpiar fault injection después de cada experimento

```bash
# Aplicar, probar, limpiar
kubectl apply -f k8s/fault-injection-delay.yaml
# ... pruebas ...
kubectl delete -f k8s/fault-injection-delay.yaml

# Verificar limpieza
./scripts/microservicios status --faults
```

---

## Accesos Rápidos a Dashboards

Una vez ejecutado `./scripts/microservicios start`, los dashboards están disponibles en:

- **Kiali:** http://localhost:20001/kiali/console
  - Visualización de topología
  - Métricas en tiempo real
  - Health de servicios

- **Jaeger:** http://localhost:16686
  - Trazas distribuidas
  - Latencias por span
  - Errores de peticiones

- **Grafana:** http://localhost:3000
  - Dashboards de Istio predefinidos
  - Métricas de Prometheus
  - Request rate, latency, error rate

---

## Integración con Otros Documentos

- **README.md:** Guía de inicio rápido del proyecto
- **GUIA_INYECCION_FALLOS.md:** Experimentos de fault injection
- **VERIFICACION_INSTALACION.md:** Checklist de herramientas
- **RESOLUCION_PROBLEMAS.md:** Troubleshooting común

---

**Nota:** Para cualquier problema no documentado, usa `./scripts/microservicios status --all` para recopilar información de diagnóstico completa.
