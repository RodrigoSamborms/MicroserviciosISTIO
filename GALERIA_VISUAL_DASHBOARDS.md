# Galería Visual: Qué Esperar en los Dashboards

Esta guía muestra descripciones detalladas de lo que verás en cada dashboard bajo diferentes escenarios.

---

## Navegación

- [Kiali Normal](#kiali-estado-normal)
- [Kiali con Delays](#kiali-con-delays-5s)
- [Kiali con Errores](#kiali-con-errores-503)
- [Jaeger Normal](#jaeger-estado-normal)
- [Jaeger con Errores](#jaeger-con-errores)
- [Grafana Normal](#grafana-estado-normal)
- [Grafana con Delays](#grafana-con-delays)
- [Grafana con Errores](#grafana-con-errores)

---

## KIALI

### Kiali - Estado Normal

**Ubicación:** Graph → namespace: default

**Lo que ves:**

```
                    ┌─────────────────────────┐
                    │  istio-ingressgateway   │
                    └────────────┬────────────┘
                                 │
                           GREEN ✓ (LÍNEA)
                            2 req/s
                        Error: 0% | p95: 100ms
                                 │
                    ┌────────────▼────────────┐
                    │ microservicio-usuarios  │
                    └────────────┬────────────┘
                                 │
                           GREEN ✓ (LÍNEA)
                            2 req/s
                        Error: 0% | p95: 100ms
                                 │
                    ┌────────────▼────────────┐
                    │microserv-notificaciones │
                    └─────────────────────────┘
```

**Indicadores clave:**
- ✅ Líneas VERDE entre servicios
- ✅ Request Rate: ~2 req/s (según tu generador de tráfico)
- ✅ Error Rate: 0%
- ✅ Response Time p95: 80-150ms

**Dónde están los números:**
- Hoverea cualquier línea (sin hacer click)
- Aparece un popup con las métricas
- O haz click en la línea para más detalles

---

### Kiali - Con Delays (5s)

**Ubicación:** Igual (Graph)

**Lo que cambia:**

```
                    ┌─────────────────────────┐
                    │  istio-ingressgateway   │
                    └────────────┬────────────┘
                                 │
                           GREEN ✓ (LÍNEA)
                            2 req/s
                        Error: 0% | p95: 100ms
                                 │
                    ┌────────────▼────────────┐
                    │ microservicio-usuarios  │
                    └────────────┬────────────┘
                                 │
                        NARANJA ⚠ (LÍNEA) ← ¡CAMBIO!
                            2 req/s
                    Error: 0% | p95: 5000ms ← ¡CAMBIO!
                                 │
                    ┌────────────▼────────────┐
                    │microserv-notificaciones │
                    └─────────────────────────┘
```

**Cambios respecto a normal:**
- ❌ Línea usuarios → notificaciones: NARANJA (antes GREEN)
- ❌ p95: 5000ms (antes ~100ms)
- ✅ Error Rate: sigue siendo 0% (es correcto)
- ✅ Request Rate: sigue siendo 2 req/s (es correcto)

**Significado:**
- El color NARANJA indica latencia alta
- El p95 de 5000ms es exactamente el delay inyectado
- No hay errores porque Istio solo retarda, no rechaza

---

### Kiali - Con Errores (503)

**Ubicación:** Igual (Graph)

**Lo que cambia:**

```
                    ┌─────────────────────────┐
                    │  istio-ingressgateway   │
                    └────────────┬────────────┘
                                 │
                           GREEN ✓ (LÍNEA)
                            2 req/s
                        Error: 0% | p95: 100ms
                                 │
                    ┌────────────▼────────────┐
                    │ microservicio-usuarios  │
                    └────────────┬────────────┘
                                 │
                          RED ✗✗ (LÍNEA) ← ¡CAMBIO!
                            2 req/s
                    Error: 30% | p95: 100ms ← ¡CAMBIO!
                                 │
                    ┌────────────▼────────────┐
                    │microserv-notificaciones │
                    └─────────────────────────┘
```

**Cambios respecto a normal:**
- ❌ Línea usuarios → notificaciones: ROJA (antes GREEN)
- ❌ Error Rate: 30% (antes 0%)
- ✅ p95: sigue siendo ~100ms (es correcto, fallan rápido)
- ✅ Request Rate: sigue siendo 2 req/s (es correcto)

**Significado:**
- El color ROJO = hay errores
- 30% es exactamente el porcentaje de errores inyectados
- p95 bajo porque Istio rechaza sin esperar al servicio (falla rápida)

---

## JAEGER

### Jaeger - Estado Normal

**Ubicación:** Service dropdown, busca "microservicio-usuarios"

**Lo que ves:**

```
Service: microservicio-usuarios
Operation: (default)
Time range: Last 5 minutes
[Find Traces]

Resultados:
├─ Trace 1: 102ms    ← Duración total
├─ Trace 2: 98ms
├─ Trace 3: 105ms
├─ Trace 4: 100ms
└─ Trace 5: 101ms

(todos alrededor de 100ms)
```

**Si haces click en una traza (ejemplo Trace 1: 102ms):**

```
Timeline: |========================| 102ms

Spans (operaciones):
├─ [istio-ingressgateway] 5ms
│  └─ (muy rápido, la entrada)
│
└─ [microservicio-usuarios] 97ms
   ├─ [Call to notificaciones] 90ms
   │  └─ (llamada al servicio)
   │
   └─ [Save to Database] 7ms
      └─ (guardar resultado)
```

**Indicadores clave:**
- ✅ Todas las trazas: 90-110ms
- ✅ Ningún span rojo (sin errores)
- ✅ Todos los spans negros (síncronos, lo normal)

---

### Jaeger - Con Delays (5s)

**Ubicación:** Mismo lugar

**Lo que ves en la lista de trazas:**

```
Resultados:
├─ Trace 1: 104ms    ← Sin delay (50% de trazas)
├─ Trace 2: 5002ms   ← CON DELAY ← ¡CAMBIO!
├─ Trace 3: 101ms    ← Sin delay
├─ Trace 4: 5001ms   ← CON DELAY
└─ Trace 5: 103ms    ← Sin delay

(alternancia entre 100ms y 5000ms)
```

**Si haces click en una traza CON DELAY (Trace 2: 5002ms):**

```
Timeline: |==============================================| 5002ms
         (MUY LARGO comparado a antes)

Spans:
├─ [istio-ingressgateway] 5ms
│
└─ [microservicio-usuarios] 4997ms ← ¡MUCHO TIEMPO!
   ├─ [Call to notificaciones] 5000ms ← ¡AQUÍ ESTÁ EL DELAY!
   │  └─ (Istio inyecta 5 segundos aquí)
   │
   └─ [Save to Database] 7ms
```

**Cambios respecto a normal:**
- ❌ ~50% de trazas: ~5000ms (antes ~100ms)
- ✅ ~50% de trazas: ~100ms (normales, no afectadas)
- ✅ Ningún span rojo (sin errores, solo retraso)

---

### Jaeger - Con Errores

**Ubicación:** Mismo lugar

**Lo que ves en la lista de trazas:**

```
Resultados:
├─ Trace 1: 98ms     ← Normal
├─ ✗ Trace 2: ERROR  ← ¡ROJA! (color diferente)
├─ Trace 3: 101ms    ← Normal
├─ ✗ Trace 4: ERROR  ← ¡ROJA!
└─ Trace 5: 99ms     ← Normal

(~30% son ROJAS, ~70% son normales)
```

**Si haces click en una traza ROJA (Trace 2: ERROR):**

```
Timeline: |========| ERROR (barra roja)

Spans:
├─ [istio-ingressgateway] 5ms
│
└─ [microservicio-usuarios] 45ms
   ├─ [Call to notificaciones] 40ms ✗ ROJO ← ¡AQUÍ EL ERROR!
   │  └─ (Istio rechaza con 503)
   │
   └─ [RETRY] (no ocurrió porque falló)
```

**Detalles del span rojo:**
Si haces click en el span rojo, ves en el panel derecho:
```
error: true
http.status_code: 503
message: "Service Unavailable"
```

**Cambios respecto a normal:**
- ❌ ~30% de trazas: color ROJO o con ERROR
- ✅ ~70% de trazas: normales, color negro
- ✅ Duración: ~50ms (rápido porque rechaza antes)

---

## GRAFANA

### Grafana - Estado Normal

**Ubicación:** Dashboards → Istio Service Dashboard

**Lo que ves (ejemplos de gráficos):**

```
┌─ Request Volume ───────────────────┐
│                    ╱╱╱╱             │
│                  ╱╱      ╱╱╱╱       │
│   2.0 req/s    ╱          ╱╱       │
│   1.5          ╱                   │
│   1.0                      ╱╱╱     │
│   0.5                            │
│   0.0 └─────────────────────────┘ │
│       0m  2m  4m  6m  8m 10m     │
└────────────────────────────────────┘

Línea relativamente plana, consistente
```

```
┌─ Error Rate ───────────────────────┐
│                                   │
│   30%                             │
│   20%                             │
│   10%                             │
│   0% ═══════════════════════════ │ ← 0% (línea plana en cero)
│      0m  2m  4m  6m  8m 10m     │
└────────────────────────────────────┘

Línea en CERO, sin picos
```

```
┌─ Response Time (p95) ──────────────┐
│                                   │
│   500ms                           │
│   400ms                           │
│   300ms                           │
│   200ms                           │
│   100ms ═══════════════════════ │ ← ~100ms
│   0ms   0m  2m  4m  6m  8m 10m   │
└────────────────────────────────────┘

Línea plana alrededor de 100ms
```

**Indicadores clave:**
- ✅ Request Volume: línea plana, consistente
- ✅ Error Rate: línea en CERO
- ✅ Response Time: línea plana alrededor de 100ms

---

### Grafana - Con Delays (5s)

**Ubicación:** Mismo lugar

**Lo que cambia:**

```
┌─ Request Volume ───────────────────┐
│                                   │
│   2.0 req/s  ═════════════════  │ ← SIN CAMBIO (correcto)
│   1.5                           │
│   1.0                           │
│   0.5                           │
│   0.0 └─────────────────────────┘ │
│       0m  2m  4m  6m  8m 10m     │
└────────────────────────────────────┘
```

```
┌─ Error Rate ───────────────────────┐
│                                   │
│   30%                             │
│   20%                             │
│   10%                             │
│   0% ═════════════════════════  │ ← SIN CAMBIO (correcto)
│      0m  2m  4m  6m  8m 10m     │
└────────────────────────────────────┘
```

```
┌─ Response Time (p95) ──────────────┐
│                                   │
│   5000ms       ╱╱╱╱╱╱╱╱╱       │ ← ¡PICO ENORME!
│   4000ms    ╱╱╱╱╱╱╱╱╱╱╱╱╱╱   │
│   3000ms   ╱╱╱╱╱╱╱╱╱╱╱╱╱╱    │
│   2000ms  ╱╱╱╱╱╱╱╱╱╱╱╱╱      │
│   1000ms ╱╱╱╱╱╱╱╱╱╱╱╱╱       │
│   100ms ═══════════════════   │ ← Baseline normal
│   0ms   0m  2m  4m  6m  8m 10m   │
└────────────────────────────────────┘
```

**Cambios respecto a normal:**
- ✅ Request Volume: SIN CAMBIO (línea plana, correcto)
- ✅ Error Rate: SIN CAMBIO (sigue en 0%, correcto)
- ❌ Response Time: PICO a ~5000ms (¡EXACTO EL DELAY INYECTADO!)

---

### Grafana - Con Errores (503)

**Ubicación:** Mismo lugar

**Lo que cambia:**

```
┌─ Request Volume ───────────────────┐
│                                   │
│   2.0 req/s  ═════════════════  │ ← SIN CAMBIO (correcto)
│   1.5                           │
│   1.0                           │
│   0.5                           │
│   0.0 └─────────────────────────┘ │
│       0m  2m  4m  6m  8m 10m     │
└────────────────────────────────────┘
```

```
┌─ Error Rate ───────────────────────┐
│                                   │
│   30%          ╱╱╱╱╱╱╱           │ ← ¡PICO!
│   25%       ╱╱╱╱╱╱╱╱╱╱╱╱╱       │
│   20%     ╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱      │
│   15%    ╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱       │
│   10%   ╱╱╱╱╱╱╱╱╱╱╱╱╱╱         │
│   5% ╱╱╱╱╱╱╱╱╱╱╱╱╱╱           │
│   0% ═══════════════════════  │ ← Baseline (0%)
│      0m  2m  4m  6m  8m 10m     │
└────────────────────────────────────┘
```

```
┌─ Response Time (p95) ──────────────┐
│                                   │
│   500ms                           │
│   400ms                           │
│   300ms                           │
│   200ms                           │
│   100ms ═════════════════════  │ ← SIN CAMBIO (rápido porque rechaza)
│   0ms   0m  2m  4m  6m  8m 10m   │
└────────────────────────────────────┘
```

**Cambios respecto a normal:**
- ✅ Request Volume: SIN CAMBIO (correcto)
- ❌ Error Rate: PICO a ~30% (¡EXACTO EL PORCENTAJE INYECTADO!)
- ✅ Response Time: SIN CAMBIO (línea plana, correcto porque rechaza rápido)

---

## Resumen Visual

| Métrica | Normal | Con Delays 5s | Con Errores 30% |
|---------|--------|---------------|-----------------|
| **Kiali Color** | 🟢 GREEN | 🟠 ORANGE | 🔴 RED |
| **Kiali p95** | ~100ms | ~5000ms | ~100ms |
| **Grafana Response** | Línea plana | PICO 5000ms | Línea plana |
| **Grafana Error %** | Línea en 0% | Línea en 0% | PICO 30% |
| **Jaeger Duración** | ~100ms | 50% ~100ms, 50% ~5000ms | 70% ~100ms, 30% ERROR |
| **Jaeger Color** | ⚫ Negro | ⚫ Negro | 🔴 Rojo (30%) |

---

## Tips Para Reconocer Cambios

1. **Mira los PICOS** - Los cambios aparecen como picos o caídas en los gráficos
2. **Compara con baseline** - La línea plana ANTES del cambio es tu referencia
3. **Espera 15-30 segundos** - Los dashboards tardan en actualizar
4. **Múltiples vistas** - Los mismos cambios aparecen en 3 dashboards diferentes
5. **Busca números exactos** - Si inyectaste 5s, deberías ver ~5000ms en los números

---

Para más información, lee [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md)
