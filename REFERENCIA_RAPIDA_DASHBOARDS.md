# Referencia Rápida: Dashboards

Usa esta hoja de referencia mientras ejecutas pruebas de fault injection.

---

## Dashboard Comparison Table

| Aspecto | Kiali | Jaeger | Grafana |
|--------|-------|--------|---------|
| **Muestra** | Topología en tiempo real | Trazas individuales | Métricas históricas |
| **Actualización** | Casi real-time (1-5s) | Real-time | Cada 30-60 segundos |
| **Mejor para** | Ver flujo de tráfico | Depurar requests específicas | Detectar tendencias |
| **Nivel de detalle** | Alto nivel (servicios) | Muy detallado (spans) | Agregado (promedios) |

---

## Checklist: Antes de Ejecutar una Prueba

- [ ] Tengo 3 tabs/ventanas abiertas: Kiali, Jaeger, Grafana
- [ ] Kiali está en: **Graph** → namespace **default**
- [ ] Jaeger está en: Service **microservicio-usuarios** → **Find Traces**
- [ ] Grafana está en: **Istio Service Dashboard**
- [ ] Todos los dashboards muestran datos (no están vacíos)

---

## Indicadores Clave

### Normal (sin fault injection)
```
KIALI:
├─ Línea GREEN: usuarios → notificaciones
├─ Numbers: p95 ≈ 100ms, Error Rate ≈ 0%
└─ Request Rate ≈ 10 req/s

GRAFANA:
├─ Response Time: línea plana ≈ 50ms
├─ Error Rate: línea plana ≈ 0%
└─ Request Volume: línea plana ≈ 10 req/s

JAEGER:
└─ Trazas: todas ≈ 100ms sin spans rojos
```

### Con Delay 50% / 5s
```
KIALI:
├─ Línea ORANGE/YELLOW: usuarios → notificaciones
├─ Numbers: p95 ≈ 5000ms ⬆️⬆️⬆️, Error Rate ≈ 0%
└─ Request Rate ≈ 10 req/s

GRAFANA:
├─ Response Time: PICO a ≈ 5000ms ⬆️⬆️⬆️
├─ Error Rate: línea plana ≈ 0%
└─ Request Volume: línea plana ≈ 10 req/s

JAEGER:
├─ 50% de trazas: ≈ 100ms
└─ 50% de trazas: ≈ 5000ms (en span "Call notificaciones")
```

### Con Errores 30% / 503
```
KIALI:
├─ Línea RED: usuarios → notificaciones
├─ Numbers: p95 ≈ 50ms, Error Rate ≈ 30% ⬆️⬆️⬆️
└─ Request Rate ≈ 10 req/s

GRAFANA:
├─ Response Time: línea plana ≈ 50ms (fallan rápido)
├─ Error Rate: PICO a ≈ 30% ⬆️⬆️⬆️
└─ Request Volume: línea plana ≈ 10 req/s

JAEGER:
├─ ~70% trazas: normales ≈ 100ms
└─ ~30% trazas: ROJAS (error: 503)
```

### Combinado: Delay 30% / 3s + Error 20% / 503
```
KIALI:
├─ Línea RED: usuarios → notificaciones
├─ Numbers: p95 ≈ 3000ms ⬆️⬆️⬆️, Error Rate ≈ 20% ⬆️
└─ Request Rate ≈ 10 req/s

GRAFANA:
├─ Response Time: PICO a ≈ 3000ms ⬆️⬆️
├─ Error Rate: PICO a ≈ 20% ⬆️⬆️
└─ Request Volume: línea plana ≈ 10 req/s

JAEGER:
├─ ~30% trazas: ROJAS (error 503)
├─ ~30% trazas: ≈ 3000ms (delayed)
└─ ~40% trazas: normales ≈ 100ms
```

---

## Menú Rápido: Dónde Encontrar Cada Cosa

### Kiali
```
Menú Izquierdo
├─ Graph (aquí) → ver topología y tráfico
├─ Applications
├─ Services
├─ Workloads
└─ Istio Config
```

### Jaeger
```
Buscador Superior
├─ Service: microservicio-usuarios
├─ Operation: (default o específica)
├─ Time range: Last 5 minutes / Last hour
└─ Find Traces
```

### Grafana
```
Menú Izquierdo
├─ Dashboards (click aquí)
│  └─ Istio Service Dashboard (seleccionar)
└─ Explore (para queries personalizadas)
```

---

## Preguntas Frecuentes al Interpretar

**P: ¿Veo línea GREEN en Kiali pero Grafana Error Rate está alto?**
- A: Posiblemente es retraso en actualización. Espera 1 minuto y recarga.

**P: ¿Los números en Kiali muestran p95=100ms pero parece más lento?**
- A: El p95 es el percentil 95. El p99 o máximo pueden ser mucho más altos.

**P: ¿En Jaeger veo spans GRISES además de los negros?**
- A: Los grises son operaciones asincrónicas. Los negros son síncronos.

**P: ¿El Response Time en Grafana no sube aunque inyecté 5s de delay?**
- A: Espera 2-3 minutos para que lleguen las métricas. Recarga la página.

**P: ¿Veo línea ROJA pero Error Rate en Grafana es 0%?**
- A: Posiblemente es reintentos que después triunfan. Verifica Jaeger para el detalle.

---

## Comandos Útiles Mientras Pruebas

```bash
# Ver fault injection aplicado
kubectl get virtualservice,destinationrule -n default

# Limpiar TODO
kubectl delete virtualservice,destinationrule -n default

# Ver logs de un pod
kubectl logs -n default <nombre-pod> -f

# Verificar pods running
kubectl get pods -n default

# Generar tráfico rápidamente
for i in {1..100}; do curl -s http://$(minikube ip):31769/usuarios > /dev/null; done
```

---

## Pro Tips

1. **Recarga el dashboard mientras genera tráfico** para ver cambios en tiempo real
2. **Usa "Last 5 minutes" en Grafana** al hacer pruebas cortas (no "Last 1 hour")
3. **En Kiali, hoverea las conexiones** para ver estadísticas sin hacer click
4. **Jaeger: usa "Find Traces" después de cada cambio** para ver trazas recientes
5. **Abre Jaeger en otra ventana** mientras mantienes Kiali visible para comparar

---

## Referencia: Valores Normales

| Métrica | Normal | Con Delays 5s | Con Errores 30% |
|---------|--------|---------------|-----------------|
| Request Rate | 10 req/s | 10 req/s | 10 req/s |
| Response Time p50 | ~50ms | 50-2500ms | ~50ms |
| Response Time p95 | ~100ms | ~5000ms | ~100ms |
| Response Time p99 | ~150ms | ~5000ms | ~150ms |
| Error Rate | 0% | 0% | ~30% |
| Error 4xx | 0% | 0% | 0% (son 5xx) |
| Error 5xx | 0% | 0% | ~30% |

---

Para más detalles, lee [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md)
