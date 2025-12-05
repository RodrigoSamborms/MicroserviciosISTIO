# Laboratorio: Tu Primer Experimento de Fault Injection

Este laboratorio te guía paso a paso a través de tu primer experimento de inyección de fallos mientras observas los dashboards.

**Duración:** ~20 minutos
**Requisitos:** Tener los dashboards corriendo

---

## Fase 0: Preparación (3 min)

### 1. Abre los dashboards

Desde PowerShell:
```powershell
wsl -d Debian bash -lc "cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO && ./scripts/microservicios start"
```

Espera ~1 minuto a que se abran las 3 ventanas del navegador.

### 2. Organiza las ventanas

Tienes 3 tabs abiertos en el navegador. Abre cada uno en una ventana separada:

**Ventana 1 - Kiali:**
- URL: http://wsl.localhost:20001/kiali/console
- Navega a: **Graph** → namespace **default**
- Deberías ver: 3 nodos (ingressgateway, usuarios, notificaciones)

**Ventana 2 - Jaeger:**
- URL: http://wsl.localhost:16686
- Configura: Service = **microservicio-usuarios**
- No des click en "Find Traces" aún

**Ventana 3 - Grafana:**
- URL: http://wsl.localhost:3000
- Usuario: admin | Contraseña: admin
- Navega a: **Dashboards** → **Istio Service Dashboard**
- Configura Time Range a: **Last 5 minutes**

### 3. Verifica que todo funciona

En WSL, ejecuta:
```bash
# Genera algunas peticiones de prueba
for i in {1..5}; do
  curl -s -X POST http://$(minikube ip):31769/usuarios \
    -H "Content-Type: application/json" \
    -d "{\"nombre\":\"Init$i\"}" > /dev/null
done
```

**Espera 5 segundos.** Entonces:
- **Kiali**: Deberías ver líneas GREEN conectando los servicios
- **Grafana**: Deberías ver actividad en los gráficos
- **Jaeger**: Click "Find Traces" y deberías ver 5 trazas recientes

✅ Si ves esto, estamos listos.

---

## Fase 1: Estado Normal (3 min)

### Objetivo
Entender cómo se ve un sistema SIN problemas.

### 1. Genera tráfico continuo

Abre una **nueva terminal WSL** y ejecuta:
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

# Este script genera peticiones cada 0.5 segundos (20 peticiones/10 segundos)
while true; do
  curl -s -X POST http://$(minikube ip):31769/usuarios \
    -H "Content-Type: application/json" \
    -d "{\"nombre\":\"Test$(date +%s%N)\"}" > /dev/null 2>&1
  sleep 0.5
done
```

⚠️ **Deja esto corriendo en segundo plano** (no cierres la terminal)

### 2. Observa los dashboards

En **Kiali**:
```
✓ Línea VERDE entre usuarios → notificaciones
✓ Request Rate: ~2 req/s (aprox)
✓ Error Rate: 0%
✓ Response Time p95: ~100-200ms
```

En **Grafana**:
```
✓ Response Time: línea plana ~50-100ms
✓ Error Rate: línea plana 0%
✓ Request Volume: línea consistente ~2 req/s
```

En **Jaeger**:
```
✓ Trazas: todas ~100-200ms
✓ Ninguna roja (sin errores)
```

### 3. Documenta este estado

Toma una screenshot (Win+Shift+S) de cada dashboard como referencia.

---

## Fase 2: Aplicar Fault Injection - DELAYS (5 min)

### Objetivo
Inyectar 5 segundos de delay en el 50% de peticiones al servicio de notificaciones.

### 1. Aplica la configuración

En **otra terminal WSL** (NO la que genera tráfico):
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

# Aplicar el fault injection
kubectl apply -f k8s/fault-injection-delay.yaml

# Verificar que se aplicó
kubectl get virtualservice -n default
```

Deberías ver:
```
NAME                              HOSTS                           AGE
microservicio-usuarios-vs-fault   ["microservicio-usuarios"]      5s
```

### 2. Espera a que se propague

```bash
# Espera 5 segundos
sleep 5
```

### 3. Observa los cambios

**En Kiali** (espera 10-15 segundos):
```
CAMBIO: Línea se vuelve NARANJA/YELLOW
✓ Request Rate: sigue siendo ~2 req/s
✗ Error Rate: sigue siendo 0% (es correcto, delays no son errores)
✓ Response Time p95: AUMENTA a ~5000-5200ms ⬆️⬆️⬆️ (¡IMPORTANTE!)
```

Hoverea la línea usuarios → notificaciones para ver números.

**En Grafana** (espera 30-60 segundos):
```
CAMBIO: Response Time sube dramáticamente
✓ Response Time: ve un PICO a ~5000ms ⬆️⬆️⬆️
✓ Error Rate: sigue en 0%
✓ Request Volume: sigue en ~2 req/s
```

**En Jaeger** (click "Find Traces" cada 10 segundos):
```
CAMBIO: Las trazas ahora duran más
✓ ~50% de trazas: ~100-200ms (no afectadas)
✓ ~50% de trazas: ~5000ms (con delay) 
  └─ Abre una de las largas, verás el span "Call notificaciones: 5000ms"
```

### 4. Análisis

**Preguntas:**
- ✅ ¿Ves el delay claramente en Kiali?
- ✅ ¿Grafana muestra un pico en Response Time?
- ✅ ¿Jaeger muestra trazas de ~5000ms?

**Lo que esto significa:**
- El 50% de peticiones están siendo delayed 5 segundos
- El error rate es 0% porque Istio no está rechazando, solo retrasando
- El cliente (tu curl) espera esos 5 segundos antes de recibir respuesta

---

## Fase 3: Limpiar Delays (2 min)

### 1. Remove the fault injection

En la terminal WSL (no la de tráfico):
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

# Limpiar
kubectl delete -f k8s/fault-injection-delay.yaml

# Verificar que se limpió
kubectl get virtualservice -n default
# Debería estar vacío
```

### 2. Espera a que se propague

```bash
sleep 10
```

### 3. Observa que vuelve a la normalidad

**En Kiali:**
```
✓ Línea vuelve a VERDE
✓ p95 vuelve a ~100-200ms
```

**En Grafana:**
```
✓ Response Time vuelve a línea plana ~50-100ms
```

**En Jaeger:**
```
✓ Nuevas trazas: todas ~100-200ms nuevamente
```

---

## Fase 4: Aplicar Fault Injection - ERRORES (5 min)

### Objetivo
Inyectar HTTP 503 en el 30% de peticiones.

### 1. Aplica la configuración

```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

kubectl apply -f k8s/fault-injection-abort.yaml

sleep 5
```

### 2. Observa los cambios

**En Kiali** (espera 10-15 segundos):
```
CAMBIO: Línea se vuelve ROJA
✓ Request Rate: sigue siendo ~2 req/s
✗ Error Rate: AUMENTA a ~30% ⬆️⬆️⬆️ (¡IMPORTANTE!)
✓ Response Time p95: vuelve a ~50-100ms (rápido porque rechaza antes)
```

**En Grafana** (espera 30-60 segundos):
```
CAMBIO: Error Rate sube, Response Time baja
✓ Response Time: vuelve a ~50-100ms (rápido porque fallan antes)
✓ Error Rate: PICO a ~30% ⬆️⬆️⬆️
```

**En Jaeger** (click "Find Traces"):
```
CAMBIO: ~30% de trazas ahora están ROJAS
✓ ~70% de trazas: normales ~100ms
✓ ~30% de trazas: ROJAS (error HTTP 503)
  └─ Abre una roja, verás error: "HTTP 503 Service Unavailable"
```

### 3. Análisis

**Preguntas:**
- ✅ ¿Ves línea ROJA en Kiali?
- ✅ ¿Grafana muestra Error Rate ~30%?
- ✅ ¿Jaeger muestra ~30% trazas rojas?

**Lo que esto significa:**
- El 30% de peticiones están siendo rechazadas con 503
- El 70% siguen llegando normalmente
- Los usuarios verían ~3 de cada 10 peticiones fallando
- La respuesta es RÁPIDA (solo ~50ms) porque Istio rechaza sin esperar al servicio

---

## Fase 5: Limpiar Errores (2 min)

```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

kubectl delete -f k8s/fault-injection-abort.yaml

sleep 10
```

Verifica que todo vuelve a la normalidad (línea VERDE, 0% error).

---

## Fase 6: Challenge - Combinado (3 min)

### Objetivo
Aplicar delays Y errores simultáneamente.

### 1. Aplica

```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

kubectl apply -f k8s/fault-injection-combined.yaml

sleep 5
```

### 2. Observa

**Esperado en Kiali:**
```
✓ Línea ROJA
✓ Error Rate: ~20%
✓ Response Time p95: ~3000ms (delays del 30%)
```

**Esperado en Grafana:**
```
✓ Response Time: PICO a ~3000ms
✓ Error Rate: PICO a ~20%
```

**Esperado en Jaeger:**
```
✓ ~30% trazas: ~3000ms (delays)
✓ ~20% trazas: ROJAS (errores)
✓ ~50% trazas: normales ~100ms
```

### 3. Limpiar

```bash
kubectl delete -f k8s/fault-injection-combined.yaml
sleep 10
```

---

## Resumen: Qué Aprendiste

| Escenario | Síntoma en Kiali | Síntoma en Grafana | Síntoma en Jaeger |
|-----------|------------------|-------------------|-------------------|
| **Delays 50%** | Línea NARANJA, p95 ↑ a 5000ms | Response Time ↑ a 5000ms | 50% trazas ~5000ms |
| **Errores 30%** | Línea ROJA, Error Rate ↑ 30% | Error Rate ↑ 30% | 30% trazas ROJAS |
| **Combinado** | Línea ROJA, p95 ↑ 3000ms | Ambos indicadores ↑ | Ambos síntomas |

---

## Próximos Pasos

1. ✅ **Lee la [Guía Completa de Dashboards](GUIA_DASHBOARDS.md)** para entender más detalles
2. ✅ **Lee la [Guía de Inyección de Fallos](GUIA_INYECCION_FALLOS.md)** para escenarios avanzados
3. ✅ **Experimenta por tu cuenta** combinando diferentes porcentajes y tiempos
4. ✅ **Observa cómo Istio propaga cambios** (normalmente 5-10 segundos)

---

## Troubleshooting

**P: No veo cambios en los dashboards después de aplicar fault injection**
- A: Espera 15-20 segundos. Los dashboards tardan en actualizarse.

**P: Kiali muestra un servicio desconectado**
- A: Genera más tráfico con tu terminal de curl. Los servicios sin tráfico desaparecen de la vista.

**P: Jaeger no muestra las nuevas trazas**
- A: Recarga Jaeger (F5) y haz click en "Find Traces" nuevamente.

**P: Mi terminal de tráfico se congela**
- A: Es normal durante los delays. Presiona Ctrl+C para detener, o déjala corriendo.

---

¡Felicidades! 🎉 Ya completaste tu primer experimento de fault injection con Istio y entiendes cómo interpretar los dashboards. Eres capaz de observar, analizar y depurar sistemas distribuidos.
