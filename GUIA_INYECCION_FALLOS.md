# Guía de Inyección de Fallos con Istio

Esta guía explica cómo usar las capacidades nativas de Istio para inyectar fallos y probar la resiliencia de los microservicios, **sin necesidad de instalar herramientas adicionales** como Chaos Mesh.

---

## Quick Start

Para una prueba rápida de inyección de fallos (latencia) sin leer toda la guía:

**Terminal: WSL (Debian)**
```bash
# 1) Aplicar delay del 50% (5s) al servicio de notificaciones
kubectl apply -f k8s/fault-injection-delay.yaml

# 2) Generar tráfico y ver tiempos de respuesta
for i in {1..10}; do
  echo "Petición $i:";
  time curl -s -X POST http://$(minikube ip):31769/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"Quick$i\"}" > /dev/null;
done

# 3) Observar métricas en Kiali (Graph)
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO/istio-1.28.0
./bin/istioctl dashboard kiali

# 4) Limpiar la configuración aplicada
kubectl delete -f k8s/fault-injection-delay.yaml
```

Para escenarios de errores (503) o combinados, ver más abajo o aplicar:
```bash
# Errores 503 (30%)
kubectl apply -f k8s/fault-injection-abort.yaml
# Combinado delays+errores
kubectl apply -f k8s/fault-injection-combined.yaml
# Limpiar
kubectl delete -f k8s/fault-injection-abort.yaml
kubectl delete -f k8s/fault-injection-combined.yaml
```

---

## Ventajas de usar Istio Fault Injection

- ✅ **Cero overhead**: No requiere componentes adicionales
- ✅ **Ya instalado**: Viene con Istio
- ✅ **Ligero**: No consume recursos extra
- ✅ **Fácil de usar**: Solo archivos YAML
- ✅ **Reversible**: Se puede activar/desactivar fácilmente

---

## Archivos de Configuración Disponibles

### 1. `fault-injection-delay.yaml` - Inyectar Latencia
Simula delays de red en el 50% de las peticiones al servicio de notificaciones.

**Efectos:**
- 50% de las peticiones tendrán un delay de 5 segundos
- El resto funcionará normal
- Útil para probar timeouts y comportamiento bajo latencia

### 2. `fault-injection-abort.yaml` - Inyectar Errores
Simula fallos del servicio retornando HTTP 503 en el 30% de las peticiones.

**Efectos:**
- 30% de las peticiones fallarán con error 503 (Service Unavailable)
- El resto funcionará normal
- Útil para probar manejo de errores y reintentos

### 3. `fault-injection-combined.yaml` - Combinado
Combina delays (30%) y errores (20%) en el mismo servicio.

**Efectos:**
- 30% de las peticiones tendrán delay de 3 segundos
- 20% de las peticiones fallarán con error 503
- El resto funcionará normal
- El escenario más realista de problemas de red

### 4. `circuit-breaker.yaml` - Circuit Breaker
Configura un circuit breaker que aísla el servicio cuando detecta fallos.

**Efectos:**
- Limita conexiones simultáneas a 1
- Después de 1 error consecutivo, expulsa el pod por 30 segundos
- Previene cascadas de fallos
- Útil para probar patrones de resiliencia

---

## Cómo Usar

### Experimento 1: Probar Delays (Latencia)

**Terminal: WSL (Debian)**
```bash
# 1. Aplicar inyección de delay
kubectl apply -f k8s/fault-injection-delay.yaml

# 2. Esperar unos segundos para que Istio propague la configuración
sleep 5

# 3. Crear varios usuarios y observar los tiempos de respuesta
for i in {1..10}; do
  echo "Petición $i:"
  time curl -X POST http://192.168.49.2:31769/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"Test$i\"}"
  echo ""
done

# 4. Ver los resultados en Kiali
# Ve al navegador: http://localhost:20001/kiali/console/graph
# Deberías ver latencias altas en las conexiones a notificaciones

# 5. Limpiar cuando termines
kubectl delete -f k8s/fault-injection-delay.yaml
```

**Resultado esperado:**
- Aproximadamente 5 peticiones tardarán ~5 segundos
- Las otras 5 serán rápidas (< 1 segundo)

---

### Experimento 2: Probar Errores (Aborts)

**Terminal: WSL (Debian)**
```bash
# 1. Aplicar inyección de errores
kubectl apply -f k8s/fault-injection-abort.yaml

# 2. Esperar unos segundos
sleep 5

# 3. Crear varios usuarios
for i in {1..10}; do
  echo "Petición $i:"
  curl -X POST http://192.168.49.2:31769/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"Test$i\"}"
  echo ""
done

# 4. Ver trazas en Jaeger
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO/istio-1.28.0
./bin/istioctl dashboard jaeger
# Busca "microservicio-usuarios" y verás errores en rojo

# 5. Limpiar
kubectl delete -f k8s/fault-injection-abort.yaml
```

**Resultado esperado:**
- Aproximadamente 3 peticiones fallarán (30%)
- Verás mensajes de error en la respuesta
- Las otras 7 funcionarán correctamente

---

### Experimento 3: Escenario Realista (Combinado)

**Terminal: WSL (Debian)**
```bash
# 1. Aplicar inyección combinada
kubectl apply -f k8s/fault-injection-combined.yaml

# 2. Esperar
sleep 5

# 3. Generar tráfico continuo
for i in {1..20}; do
  echo "Petición $i - $(date +%H:%M:%S):"
  time curl -s -X POST http://192.168.49.2:31769/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"User$i\"}"
  echo ""
done

# 4. Observar en Kiali el grafo de servicios
# Deberías ver:
# - Líneas rojas (errores)
# - Números de latencia altos
# - Tasa de éxito reducida

# 5. Limpiar
kubectl delete -f k8s/fault-injection-combined.yaml
```

**Resultado esperado:**
- ~6 peticiones tendrán delay (30%)
- ~4 peticiones fallarán (20%)
- ~10 peticiones funcionarán normal (50%)

---

### Experimento 4: Circuit Breaker

**Terminal: WSL (Debian)**
```bash
# 1. Aplicar circuit breaker
kubectl apply -f k8s/circuit-breaker.yaml

# 2. También aplicar inyección de errores para provocar el circuit breaker
kubectl apply -f k8s/fault-injection-abort.yaml

# 3. Esperar
sleep 5

# 4. Generar múltiples peticiones simultáneas (esto sobrepasará el límite)
for i in {1..20}; do
  curl -X POST http://192.168.49.2:31769/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"CB$i\"}" &
done
wait

# 5. Ver las métricas en Grafana
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO/istio-1.28.0
./bin/istioctl dashboard grafana
# Ve a Dashboards > Istio > Istio Service Dashboard
# Busca "microservicio-notificaciones"

# 6. Limpiar
kubectl delete -f k8s/circuit-breaker.yaml
kubectl delete -f k8s/fault-injection-abort.yaml
```

**Resultado esperado:**
- Verás rechazos de conexión cuando se alcance el límite
- El circuit breaker protegerá el servicio de sobrecarga
- Algunas peticiones recibirán error 503 de Envoy (no de la app)

---

## Observabilidad Durante los Experimentos

### Kiali - Visualización de Tráfico
**Terminal: WSL (Debian)**
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO/istio-1.28.0
./bin/istioctl dashboard kiali
```

**Qué observar:**
- **Graph**: Conexiones entre servicios con porcentajes de error
- **Líneas rojas**: Indicadores de errores
- **Números sobre las líneas**: Latencias (ej: "p50: 5.2s")
- **Health**: Estado de los servicios

### Jaeger - Trazas Distribuidas
**Terminal: WSL (Debian)**
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO/istio-1.28.0
./bin/istioctl dashboard jaeger
```

**Qué observar:**
- **Search**: Busca "microservicio-usuarios"
- **Traces con errores**: Aparecen en rojo
- **Duración**: Spans que muestran dónde ocurre el delay
- **Timeline**: Secuencia de llamadas entre servicios

### Grafana - Métricas
**Terminal: WSL (Debian)**
```bash
cd /mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO/istio-1.28.0
./bin/istioctl dashboard grafana
```

**Dashboards recomendados:**
1. **Istio Service Dashboard**: Métricas por servicio
2. **Istio Workload Dashboard**: Métricas por pod
3. **Istio Performance Dashboard**: Latencias y throughput

---

## Verificar Configuraciones Activas

**Terminal: WSL (Debian)**
```bash
# Ver todas las VirtualServices
kubectl get virtualservice -n default

# Ver detalles de una configuración específica
kubectl describe virtualservice microservicio-notificaciones-fault-delay

# Ver DestinationRules activas
kubectl get destinationrule -n default
```

---

## Limpiar Todas las Configuraciones

**Terminal: WSL (Debian)**
```bash
# Eliminar todas las inyecciones de fallos
kubectl delete -f k8s/fault-injection-delay.yaml
kubectl delete -f k8s/fault-injection-abort.yaml
kubectl delete -f k8s/fault-injection-combined.yaml
kubectl delete -f k8s/circuit-breaker.yaml

# O eliminar todo de una vez (si existen)
kubectl delete virtualservice microservicio-notificaciones-fault-delay -n default
kubectl delete virtualservice microservicio-notificaciones-fault-abort -n default
kubectl delete virtualservice microservicio-notificaciones-fault-combined -n default
kubectl delete destinationrule microservicio-notificaciones-circuit-breaker -n default

# Verificar que se hayan eliminado
kubectl get virtualservice,destinationrule -n default
```

---

## Mejores Prácticas

1. **Aplicar solo una configuración a la vez**: Para entender mejor el comportamiento
2. **Esperar 5-10 segundos después de aplicar**: Istio necesita tiempo para propagar la configuración
3. **Observar en Kiali en tiempo real**: Mantén el dashboard abierto mientras generas tráfico
4. **Limpiar después de cada experimento**: Evita confusiones con configuraciones activas
5. **Generar suficiente tráfico**: Al menos 10-20 peticiones para ver estadísticas significativas

---

## Comparación con el Código de la Aplicación

Nota que el `microservicio-notificaciones/app.py` ya tiene fallos aleatorios programados:
- 30% de probabilidad de error 500
- 30% de probabilidad de delay de 5 segundos

Con Istio Fault Injection puedes:
- **Controlar externamente** estos comportamientos sin modificar código
- **Activar/desactivar** fácilmente con kubectl
- **Combinar** con los fallos de la aplicación para escenarios más complejos
- **Aplicar a cualquier servicio** sin cambios de código

---

## Troubleshooting

### Los fallos no se están aplicando

**Problema**: Apliqué el archivo pero no veo efectos.

**Solución:**
```bash
# Verificar que el VirtualService se haya creado
kubectl get virtualservice -n default

# Verificar que no haya conflictos con otros VirtualServices
kubectl get virtualservice microservicio-notificaciones -n default -o yaml

# Esperar más tiempo (Istio puede tardar hasta 30 segundos)
sleep 30
```

### El servicio no responde

**Problema**: Después de aplicar circuit breaker, el servicio no responde.

**Solución:**
```bash
# Eliminar circuit breaker
kubectl delete -f k8s/circuit-breaker.yaml

# Esperar a que los pods se recuperen
sleep 10

# Verificar estado de los pods
kubectl get pods
```

### Conflicto de VirtualServices

**Problema**: Error "VirtualService already exists".

**Solución:**
```bash
# Ver el VirtualService existente
kubectl get virtualservice microservicio-notificaciones -o yaml

# Eliminar el existente
kubectl delete virtualservice microservicio-notificaciones

# Aplicar el nuevo
kubectl apply -f k8s/fault-injection-delay.yaml
```

---

**Nota**: Estos experimentos son seguros y no dañan tus servicios. Puedes ejecutarlos y revertirlos en cualquier momento con `kubectl delete`.
