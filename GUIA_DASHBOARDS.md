# Guía: Entender e Interpretar los Dashboards

Esta guía te ayuda a familiarizarte con **Kiali**, **Jaeger** y **Grafana** para observar y entender el comportamiento de los microservicios durante las pruebas de inyección de fallos.

---

## 1. Acceder a los Dashboards

Desde PowerShell, con minikube corriendo:

```powershell
wsl -d Debian bash -lc "cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO && ./scripts/microservicios start"
```

Se abrirán automáticamente en una ventana dedicada del navegador:
- **Kiali**: http://wsl.localhost:20001/kiali/console
- **Jaeger**: http://wsl.localhost:16686
- **Grafana**: http://wsl.localhost:3000

---

## 2. KIALI - Visualización de Topología y Tráfico

### ¿Qué es Kiali?
Es la **interfaz visual de Istio** que muestra:
- La topología de servicios (qué servicios se comunican entre sí)
- El flujo de tráfico en tiempo real
- Tasas de error y latencia
- Alertas de problemas

### Cómo Usar Kiali

#### Paso 1: Navegar al Graph
1. En el menú izquierdo, haz clic en **Graph**
2. En el dropdown de namespace, selecciona **default**
3. Verás la topología de tus microservicios

#### Paso 2: Entender la Topología
Ves 3 nodos principales:
- **istio-ingressgateway** (entrada desde Internet)
- **microservicio-usuarios** (tu API principal)
- **microservicio-notificaciones** (servicio interno)

Las flechas indican el flujo de tráfico (quién llama a quién).

#### Paso 3: Observar Métricas en Tiempo Real

Mientras ejecutas peticiones (ver sección 5 más abajo), verás:

**En las flechas (conexiones):**
- Grosor de la línea = volumen de tráfico
- Color de la línea:
  - **Verde**: Tráfico exitoso (2xx/3xx)
  - **Rojo**: Errores (4xx/5xx)
  - **Naranja**: Latencia alta o timeouts

**Números sobre las flechas:**
- Peticiones por segundo (req/s)
- Ejemplo: `5 req/s` significa 5 peticiones/segundo

**En los nodos (servicios):**
- Puedes ver el nombre del pod dentro
- Icono de error si hay problemas

#### Paso 4: Hacer Click en una Conexión
Si haces clic en una flecha, ves:
- **Traffic Distribution**: Porcentaje de tráfico que llega a cada destino
- **Response Times (quantiles)**:
  - `p50`: El 50% de peticiones responden en este tiempo
  - `p95`: El 95% de peticiones responden en este tiempo
  - `p99`: El 99% de peticiones responden en este tiempo
- **Error Rate**: % de peticiones que fallaron
- **Request Rate**: Peticiones por segundo

#### Paso 5: Configurar la Vista
En la parte superior derecha hay opciones:
- **Time Range**: Cambiar el período de tiempo (1m, 5m, 15m, etc.)
- **Refresh Rate**: Velocidad de actualización (auto, pausado, etc.)
- **Metric Type**: Cambiar entre Request Rate, Error Rate, Response Time

### Interpretando Resultados de Fault Injection en Kiali

#### Escenario 1: Inyección de Delays (5 segundos al 50%)

**Qué esperas ver:**
- Línea normal entre istio-ingressgateway → microservicio-usuarios (sin cambios)
- Línea de microservicio-usuarios → microservicio-notificaciones:
  - Color normal o ligeramente naranja (latencia aumentada)
  - Los números bajo Response Time (p95, p99) subirán a ~5000ms (5 segundos)

**Ejemplo de lectura:**
```
Conexión: usuarios → notificaciones
├─ Request Rate: 10 req/s
├─ Error Rate: 0%
└─ Response Time (p95): 5234ms  ← ¡AUMENTÓ DE ~100ms A ~5000ms!
```

**Lo que significa:**
- Las peticiones siguen llegando (0% error)
- Pero la mitad tiene un delay artificial de 5 segundos
- El p95 sube porque el 95% de peticiones sufren este delay

#### Escenario 2: Inyección de Errores (503 al 30%)

**Qué esperas ver:**
- Línea de microservicio-usuarios → microservicio-notificaciones:
  - **ROJA** (indica errores)
  - El Error Rate mostrará ~30%

**Ejemplo de lectura:**
```
Conexión: usuarios → notificaciones
├─ Request Rate: 10 req/s
├─ Error Rate: 30%  ← ¡Aparecen errores!
└─ Response Time (p50): 50ms  ← Rápidos porque fallan antes
```

**Lo que significa:**
- 3 de cada 10 peticiones fallan con error 503
- El tiempo es rápido porque Istio rechaza la petición antes de llegar al servicio
- La línea está roja porque hay errores

#### Escenario 3: Combinado (Delays 30% + Errores 20%)

**Qué esperas ver:**
- Línea ROJA (por los errores)
- Response Time (p95) alto (~3000ms por delays)
- Error Rate ~20%

**Lectura combinada:**
```
Conexión: usuarios → notificaciones
├─ Request Rate: 10 req/s
├─ Error Rate: 20%  ← Algunos errores
└─ Response Time (p95): 3156ms  ← Latencia aumentada
```

---

## 3. JAEGER - Trazas Distribuidas

### ¿Qué es Jaeger?
Es el **rastreador de trazas distribuidas**. Muestra:
- El viaje completo de UNA petición a través de todos los servicios
- Tiempos de cada operación
- Errores en puntos específicos

### Cómo Usar Jaeger

#### Paso 1: Acceder a Jaeger
Ve a http://wsl.localhost:16686

#### Paso 2: Buscar Trazas
1. En el menú izquierdo, selecciona:
   - **Service**: `microservicio-usuarios` (o `istio-ingressgateway`)
   - **Operation**: Deja el default o selecciona una operación
2. Haz clic en **Find Traces**

#### Paso 3: Entender una Traza
Verás una lista de trazas. Cada una es el viaje de UNA petición. Click en una:

**Información en la traza:**
- **Timeline**: Línea horizontal mostrando el tiempo total
- **Spans**: Cuadros que representan operaciones en cada servicio
  - El grosor/tamaño = cuánto tiempo tomó esa operación
- **Duración**: Tiempo total de la petición

**Ejemplo de traza normal (~100ms):**
```
GET /usuarios (total: 100ms)
├─ istio-ingressgateway: 5ms
└─ microservicio-usuarios: 95ms
   └─ Query DB: 90ms
```

**Ejemplo de traza con DELAY (~5100ms):**
```
POST /usuarios (total: 5100ms)
├─ istio-ingressgateway: 5ms
└─ microservicio-usuarios: 5095ms
   ├─ Call notificaciones: 5000ms  ← ¡DELAY INJECTED!
   └─ Guardar en DB: 95ms
```

**Ejemplo de traza con ERROR:**
```
POST /usuarios (total: 50ms)  [ERROR]
├─ istio-ingressgateway: 5ms
└─ microservicio-usuarios: 45ms
   ├─ Call notificaciones: 40ms  [ERROR: 503]
   └─ Retry: (no ocurrió)
```

### Interpretando Errores en Jaeger

Busca **Spans rojos** (indican error):
- Haz click en el span rojo
- En el panel derecho verás:
  - `error: true`
  - Mensaje de error (ej: "503 Service Unavailable")
  - Stack trace si está disponible

---

## 4. GRAFANA - Métricas Históricas

### ¿Qué es Grafana?
Es la **base de datos de métricas históricas**. Muestra:
- Gráficos de línea con tendencias
- Promedio, máximo, mínimo de métricas
- Alertas configuradas

### Cómo Usar Grafana

#### Paso 1: Acceder
Ve a http://wsl.localhost:3000
- Usuario: `admin`
- Contraseña: `admin`

#### Paso 2: Ir a Dashboards
1. Click en el icono de **Dashboards** (4 cuadros) en el menú izquierdo
2. Selecciona **Istio Service Dashboard**

#### Paso 3: Entender el Dashboard
Verás varios gráficos. Los más importantes:

**Request Volume (Volumen de Peticiones):**
- Eje Y: Peticiones por segundo
- Eje X: Tiempo
- Línea ascendente = más tráfico
- Línea plana = sin tráfico

**Error Rate (Tasa de Errores):**
- Eje Y: Porcentaje (0-100%)
- Un pico = momento en que ocurrieron errores
- Sin línea = 0% errores

**Response Time (Tiempo de Respuesta):**
- Eje Y: Milisegundos
- Pico alto = peticiones lentgas
- Línea plana = respuestas rápidas consistentes

**Request Duration (Duración de Peticiones) - Histograma:**
- Muestra la distribución:
  - Cuántas peticiones tardaron 0-50ms
  - Cuántas tardaron 50-100ms
  - Cuántas tardaron 100-500ms
  - Etc.

### Interpretando Resultados en Grafana

#### Antes de Inyección de Fallos:
```
Request Volume: línea plana ~10 req/s
Error Rate: línea plana 0%
Response Time: línea plana ~50ms
```

#### Durante Inyección de DELAYS (5s al 50%):
```
Request Volume: línea plana ~10 req/s (igual)
Error Rate: línea plana 0% (no hay errores, solo lentitud)
Response Time: PICO a ~5000ms  ← ¡Aumentó enormemente!
```

#### Durante Inyección de ERRORES (503 al 30%):
```
Request Volume: línea plana ~10 req/s (igual)
Error Rate: PICO a ~30%  ← ¡Aparecen errores!
Response Time: línea plana ~50ms (rápidos porque fallan)
```

#### Durante Inyección COMBINADA:
```
Request Volume: línea plana ~10 req/s (igual)
Error Rate: PICO a ~20%  ← Algunos errores
Response Time: PICO a ~3000ms  ← Latencia por delays
```

---

## 5. Guía Práctica: Ejecutar una Prueba Completa

### Paso 1: Preparar los Dashboards
```powershell
# Desde PowerShell
wsl -d Debian bash -lc "cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO && ./scripts/microservicios start"
```

Espera a que se abran los 3 dashboards en la ventana dedicada.

### Paso 2: Tener 3 Ventanas/Tabs Abiertas
- Tab 1: **Kiali** (http://wsl.localhost:20001/kiali/console)
  - Navega a Graph → namespace default
- Tab 2: **Jaeger** (http://wsl.localhost:16686)
  - Service: microservicio-usuarios
- Tab 3: **Grafana** (http://wsl.localhost:3000)
  - Abre Istio Service Dashboard

### Paso 3: Aplicar Inyección de Delays
```bash
# Desde WSL (nueva terminal)
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO
kubectl apply -f k8s/fault-injection-delay.yaml

# Espera 5 segundos para que Istio propague
sleep 5
```

### Paso 4: Generar Tráfico
```bash
# Desde WSL
for i in {1..20}; do
  echo "Petición $i:"
  time curl -s -X POST http://$(minikube ip):31769/usuarios \
    -H "Content-Type: application/json" \
    -d "{\"nombre\":\"Test$i\"}" | head -c 100
  echo ""
  sleep 0.5
done
```

### Paso 5: Observar en Tiempo Real

**En Kiali:**
- La línea usuarios → notificaciones debe estar NARANJA
- Los números deben mostrar p95 ~5000ms
- Error Rate debe seguir siendo 0%

**En Grafana:**
- Response Time debe tener un PICO a ~5000ms
- Error Rate debe estar en 0%

**En Jaeger:**
- Busca nuevas trazas (click "Find Traces")
- Algunas trazas mostrarán Call notificaciones ~5000ms
- Otras mostrarán ~100ms (las que no fueron afectadas por el delay)

### Paso 6: Limpiar
```bash
# Desde WSL
kubectl delete -f k8s/fault-injection-delay.yaml

# Espera a que se propague (5-10 segundos)
sleep 10
```

**Qué esperas ver ahora:**
- Kiali: Línea vuelve a VERDE, p95 vuelve a ~100ms
- Grafana: Response Time vuelve a la línea plana ~50ms
- Jaeger: Las nuevas trazas muestran duración normal ~100ms

---

## 6. Troubleshooting: Qué Hacer Si No Ves Cambios

### Problema 1: Los dashboards no muestran tráfico
**Solución:**
```bash
# 1. Verifica que el fault injection esté aplicado
kubectl get virtualservice -n default

# 2. Verifica que los pods estén listos
kubectl get pods -n default
```

### Problema 2: Kiali muestra línea ROJA aunque no inyecté errores
**Posible causa:**
- Los pods se acaban de crear (conexiones fallando mientras inician)
- Los dashboards tardan en actualizarse

**Solución:**
- Espera 30 segundos y recarga Kiali
- Genera más tráfico

### Problema 3: Jaeger no muestra nuevas trazas
**Solución:**
```bash
# 1. Busca explícitamente en Jaeger:
# - Service: microservicio-usuarios
# - Operation: (default)
# - Time range: Last 5 minutes
# - Click "Find Traces"

# 2. Si aún no ves nada, verifica servicios en Jaeger
# El dropdown de "Service" debe mostrar:
# - istio-ingressgateway
# - microservicio-usuarios
# - microservicio-notificaciones
```

### Problema 4: Grafana muestra métricas vacías
**Causa:**
- Grafana tarda 1-2 minutos en recibir las primeras métricas
- Los dashboards pueden estar vacíos inicialmente

**Solución:**
- Espera 2-3 minutos después de generar tráfico
- Recarga el dashboard (F5)
- Verifica que el rango de tiempo sea "Last 1 hour"

---

## 7. Resumen Rápido: Qué Esperar en Cada Escenario

| Escenario | Kiali | Grafana Response Time | Error Rate | Jaeger |
|-----------|-------|------------------------|------------|--------|
| **Normal** | Verde, p95~100ms | Línea plana ~50ms | 0% | Duración ~100ms |
| **Delays 50% / 5s** | Naranja, p95~5000ms | Pico a ~5000ms | 0% | Algunas trazas ~5000ms |
| **Errores 30% / 503** | ROJA, p95~50ms | Línea plana ~50ms | Pico 30% | Spans rojos |
| **Combinado** | ROJA, p95~3000ms | Pico latencia + error | Pico 20% | Rojo + latencia |

---

## 8. Próximos Pasos

Una vez domines esto:
1. Experimenta con `fault-injection-abort.yaml`
2. Prueba `fault-injection-combined.yaml`
3. Observa cómo cambia la topología y las métricas
4. Lee la [GUIA_INYECCION_FALLOS.md](GUIA_INYECCION_FALLOS.md) para escenarios avanzados

¡Ahora eres capaz de interpretar correctamente los dashboards y entender el comportamiento de tus microservicios! 🎉
