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
- **Kiali**: En la esquina superior derecha, cambia el selector de tiempo a **"Last 1 minute"** y presiona **Refresh** (icono circular). Deberías ver líneas conectando los servicios.
- **Grafana**: Deberías ver actividad en los gráficos
- **Jaeger**: Click "Find Traces" y deberías ver 5 trazas recientes

**⚠️ IMPORTANTE sobre las líneas ROJAS/NARANJAS en Kiali:**

Verás líneas **ROJAS o NARANJAS** entre `usuarios → notificaciones`. **Esto es NORMAL y ESPERADO**, NO es un problema.

El microservicio-notificaciones está diseñado intencionalmente para simular fallos aleatorios:
- **30% de probabilidad de error 500** (por eso ves líneas rojas)
- **30% de probabilidad de delay 5s**

Esto es parte del proyecto de resiliencia. En Kiali deberías ver:
- Error Rate: ~20-30% en la conexión usuarios → notificaciones
- Línea ROJA o NARANJA (depende del error rate en ese momento)

**Esto es correcto.** El objetivo del laboratorio es que observes cómo agregan fallos ADICIONALES con Istio sobre estos fallos naturales.

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
✓ Línea GREEN entre istio-ingressgateway → usuarios (sin errores en entrada)
✓ Línea ROJA/NARANJA entre usuarios → notificaciones (errores naturales ~20-30%)
✓ Request Rate: ~2 req/s (aprox)
✓ Error Rate: ~20-30% (NORMAL - errores simulados por el código)
✓ Response Time p95: ~100-5000ms (varía por delays aleatorios)
```

**Nota:** Los errores y delays que ves ahora son parte del código normal del microservicio. En las siguientes fases agregaremos fallos ADICIONALES con Istio.

En **Grafana**:
```
✓ Response Time: línea variable ~100-5000ms (por delays aleatorios)
✓ Error Rate: línea ~20-30% (errores naturales del código)
✓ Request Volume: línea consistente ~2 req/s
```

En **Jaeger**:
```
✓ ~70% trazas: ~100-200ms (normales)
✓ ~30% trazas: ROJAS o ~5000ms (errores/delays del código)
```

### 3. Documenta este estado "baseline"

Este es tu **baseline** (línea base). Toma una screenshot (Win+Shift+S) de cada dashboard como referencia.

**Recuerda:** Los errores y delays que ves ahora (20-30% error, algunos delays 5s) son NATURALES del código. En la siguiente fase agregaremos fallos ADICIONALES con Istio y verás cómo los números AUMENTAN.

---

## Fase 2: Aplicar Fault Injection - DELAYS (5 min)

### Objetivo
**AGREGAR** 5 segundos de delay en el 50% de peticiones al servicio de notificaciones (esto es ADICIONAL a los delays naturales del 30% que ya existen).

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
CAMBIO: Línea probablemente sigue ROJA (por errores naturales ~20-30%)
✓ Request Rate: sigue siendo ~2 req/s
✓ Error Rate: sigue siendo ~20-30% (no cambia, los delays no son errores)
✓ Response Time p95: AUMENTA aún más a ~5000-5200ms ⬆️⬆️⬆️ (¡IMPORTANTE!)
  └─ Antes: ~100-5000ms (variable por delays naturales)
  └─ Ahora: TODOS los que tienen delay están cerca de 5000ms
```

Hoverea la línea usuarios → notificaciones para ver números.

**En Grafana** (espera 30-60 segundos):
```
CAMBIO: Response Time sube y se vuelve MÁS CONSISTENTE
✓ Response Time: Más trazas cerca de ~5000ms ⬆️⬆️⬆️
  └─ Antes: algunas ~100ms, algunas ~5000ms (variable)
  └─ Ahora: 50% Istio + 30% natural = MÁS delays de 5000ms
✓ Error Rate: sigue en ~20-30% (no cambia)
✓ Request Volume: sigue en ~2 req/s
```

**En Jaeger** (click "Find Traces" cada 10 segundos):
```
CAMBIO: Ahora VES MÁS trazas largas (combinación de delays)
✓ ~20% trazas: ~100-200ms (sin delays)
✓ ~80% trazas: ~5000ms (Istio 50% + Natural 30% combinados)
  └─ Abre una, verás el span "Call notificaciones: 5000ms"
```

### 4. Análisis

**Preguntas:**
- ✅ ¿Ves que ahora HAY MÁS trazas con delay de 5000ms que antes?
- ✅ ¿Grafana muestra Response Time más alto y consistente?
- ✅ ¿Jaeger muestra ~80% de trazas con ~5000ms (antes era ~30%)?

**Lo que esto significa:**
- Antes: 30% de peticiones con delay natural
- Ahora: 50% Istio + 30% natural = ~80% con delays (algunos se superponen)
- El error rate sigue igual (~20-30%) porque Istio solo retrasa, no rechaza
- Los delays de Istio son ADICIONALES a los naturales del código

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

### 3. Observa que vuelve al baseline (con errores naturales)

**En Kiali:**
```
✓ Línea vuelve a ROJA/NARANJA (errores naturales ~20-30%)
✓ p95 vuelve a ~100-5000ms variable (solo delays naturales del 30%)
```

**En Grafana:**
```
✓ Response Time vuelve a variable ~100-5000ms (solo delays naturales)
  └─ Ya no ves el 80% con delays, solo el 30% natural
```

**En Jaeger:**
```
✓ Nuevas trazas: ~70% normales ~100ms, ~30% con delay/error natural
  └─ Ya no ves el 80% con delays de antes
```

---

## Fase 4: Aplicar Fault Injection - ERRORES (5 min)

### Objetivo
**AGREGAR** HTTP 503 en el 30% de peticiones (esto es ADICIONAL a los errores 500 naturales del 30% que ya existen).

**Resultado esperado:** ~60% de error rate total (30% Istio + 30% natural, algunos se superponen = ~50-60%)

### 1. Aplica la configuración

```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

kubectl apply -f k8s/fault-injection-abort.yaml

sleep 5
```

### 2. Observa los cambios

**En Kiali** (espera 10-15 segundos):
```
CAMBIO: Línea sigue ROJA pero Error Rate AUMENTA significativamente
✓ Request Rate: sigue siendo ~2 req/s
✗ Error Rate: AUMENTA de ~20-30% a ~50-60% ⬆️⬆️⬆️ (¡IMPORTANTE!)
  └─ Antes: ~20-30% (errores naturales)
  └─ Ahora: ~50-60% (30% Istio + 30% natural, con superposición)
✓ Response Time p95: ~50-100ms (más rápido porque ahora más peticiones fallan antes)
```

**En Grafana** (espera 30-60 segundos):
```
CAMBIO: Error Rate sube DRAMÁTICAMENTE
✓ Response Time: ~50-100ms (más consistente porque más errores rápidos)
✓ Error Rate: PICO a ~50-60% ⬆️⬆️⬆️ (antes ~20-30%)
```

**En Jaeger** (click "Find Traces"):
```
CAMBIO: Ahora VES MÁS trazas ROJAS
✓ ~40-50% de trazas: normales ~100ms
✓ ~50-60% de trazas: ROJAS (combinación 503 Istio + 500 natural)
  └─ Abre una roja con 503: error "HTTP 503 Service Unavailable" (Istio)
  └─ Abre una roja con 500: error "Fallo simulado" (código natural)
```

### 3. Análisis

**Preguntas:**
- ✅ ¿Ves línea ROJA más intensa en Kiali?
- ✅ ¿Grafana muestra Error Rate aumentó de ~30% a ~50-60%?
- ✅ ¿Jaeger muestra ~50-60% trazas rojas (antes era ~20-30%)?
- ✅ ¿Puedes distinguir errores 503 (Istio) vs 500 (natural) en Jaeger?

**Lo que esto significa:**
- Antes: ~20-30% errores naturales (500)
- Ahora: 30% Istio (503) + 30% natural (500) = ~50-60% total
- Los usuarios verían ~5-6 de cada 10 peticiones fallando (en lugar de 2-3)
- Los errores de Istio (503) son ADICIONALES a los naturales (500)

---

## Fase 5: Limpiar Errores (2 min)

```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO

kubectl delete -f k8s/fault-injection-abort.yaml

sleep 10
```

Verifica que todo vuelve al baseline (línea ROJA con ~20-30% error natural, no 0%).

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

| Escenario | Error Rate | Response Time p95 | Trazas con Delay | Trazas con Error |
|-----------|------------|-------------------|------------------|------------------|
| **Baseline (natural)** | ~20-30% | Variable ~100-5000ms | ~30% | ~20-30% |
| **+ Delays 50% Istio** | ~20-30% | ~5000ms consistente | ~80% | ~20-30% |
| **+ Errores 30% Istio** | ~50-60% | ~50-100ms | ~30% | ~50-60% |
| **+ Combinado Istio** | ~40-50% | ~3000ms | ~60-70% | ~40-50% |

**Lección clave:** Los fallos de Istio se **SUMAN** a los fallos naturales del código. Por eso ves porcentajes más altos que los configurados en los manifiestos.

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
