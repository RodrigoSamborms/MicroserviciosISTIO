# Resolución de Problemas

Este documento contiene soluciones a problemas comunes encontrados durante la instalación y ejecución del proyecto.

---

## Problema 1: Chaos Mesh - ImagePullBackOff en chaos-daemon

### Síntoma
Durante la instalación de Chaos Mesh, el pod `chaos-daemon` muestra el estado `ImagePullBackOff` y la instalación se queda esperando indefinidamente:

```
chaos-daemon-sjpsq   0/1   ImagePullBackOff   0     6m35s
Waiting for pod running
```

### Causa
El pod `chaos-daemon` no puede descargar su imagen del registro de contenedores. Esto puede deberse a:
- Problemas de conectividad con el registry
- Limitaciones de recursos en minikube
- Problemas con mirrors de imágenes de China

### Solución

**Opción 1: Detener la instalación y continuar (Recomendado)**

1. Detén el proceso de instalación con `Ctrl+C` en la terminal WSL
2. Verifica el estado de los pods:

**Terminal: WSL (Debian)**
```bash
kubectl get pods -n chaos-mesh
```

3. Si ves que la mayoría de los pods están en estado `Running`, Chaos Mesh está funcionalmente instalado:
   - ✅ chaos-controller-manager: Necesario para experimentos de caos
   - ✅ chaos-dashboard: Interfaz web para gestionar experimentos
   - ✅ chaos-dns-server: Para experimentos de DNS
   - ⚠️ chaos-daemon: Solo necesario para ciertos experimentos avanzados

**Puedes continuar con el proyecto** - Las funcionalidades básicas de Chaos Engineering funcionarán correctamente.

**Opción 2: Intentar reinstalar Chaos Mesh**

**Terminal: WSL (Debian)**
```bash
# Desinstalar Chaos Mesh completamente
kubectl delete namespace chaos-mesh

# Esperar unos segundos y reinstalar
curl -sSL https://mirrors.chaos-mesh.org/v2.6.0/install.sh | bash
```

**Opción 3: Aumentar recursos de minikube**

Si el problema persiste, puede ser por falta de recursos:

**Terminal: WSL (Debian)**
```bash
# Detener minikube
minikube stop

# Reiniciar con más recursos
minikube start --driver=docker --memory=6144 --cpus=4

# Reinstalar Chaos Mesh
curl -sSL https://mirrors.chaos-mesh.org/v2.6.0/install.sh | bash
```

### Impacto
- **Bajo:** Puedes realizar experimentos básicos de Chaos Engineering sin el daemon
- El manifiesto `k8s/chaos-notificaciones.yaml` debería funcionar correctamente
- Algunas funcionalidades avanzadas pueden no estar disponibles

### Verificación
Para confirmar que Chaos Mesh está funcionando:

**Terminal: WSL (Debian)**
```bash
# Ver todos los pods
kubectl get pods -n chaos-mesh

# Verificar que los CRDs de Chaos Mesh estén instalados
kubectl get crd | grep chaos-mesh
```

**Resultado esperado:** Deberías ver múltiples Custom Resource Definitions (CRDs) de Chaos Mesh.

---

## Problema 2: Dashboards de Kiali y Jaeger no están disponibles

### Síntoma
Al intentar abrir los dashboards con `istioctl dashboard kiali` o `istioctl dashboard jaeger`, obtienes el error:

```
Error: no pods found with selector app=kiali
Error: no pods found with selector app=jaeger
```

### Causa
Los addons de observabilidad de Istio (Kiali, Jaeger, Prometheus) no se instalan automáticamente con el perfil `demo`. Solo Grafana se instala por defecto.

### Solución

**Instalar los addons de observabilidad manualmente:**

**Terminal: WSL (Debian)**
```bash
# Navegar al directorio de Istio
cd istio-1.28.0

# Instalar todos los addons
kubectl apply -f samples/addons

# Esperar a que los pods estén listos (puede tomar 2-3 minutos)
kubectl get pods -n istio-system -w
```

Presiona `Ctrl+C` para detener el watch cuando veas que los pods están en estado `Running`.

### Verificación

**Terminal: WSL (Debian)**
```bash
# Verificar que todos los addons estén corriendo
kubectl get pods -n istio-system

# Navegar al directorio de Istio
cd istio-1.28.0

# Ahora deberías poder abrir los dashboards
./bin/istioctl dashboard kiali
./bin/istioctl dashboard jaeger
./bin/istioctl dashboard grafana
```

**Nota importante:** Los pods pueden tardar 3-5 minutos en estar completamente listos después de aplicar los addons. Si ves estado `ContainerCreating`, espera unos minutos más.

### Impacto
Sin estos addons, no podrás visualizar las métricas y trazas distribuidas, que son fundamentales para la observabilidad.

---

## Problema 3: Minikube se queda sin recursos (API server stopped)

### Síntoma
Al verificar el estado de minikube:
```
minikube status
apiserver: Stopped
```

O al ejecutar comandos `kubectl`:
```
Unable to connect to the server: net/http: TLS handshake timeout
```

### Causa
Minikube se quedó sin recursos (memoria o CPU) al intentar correr todos los componentes de Istio, Chaos Mesh y los addons de observabilidad.

### Solución

**Opción 1: Reiniciar minikube (sin cambiar recursos)**

**Terminal: WSL (Debian)**
```bash
minikube stop
minikube start --driver=docker
```

**Opción 2: Recrear minikube con ajuste de recursos**

Si tienes suficiente memoria en tu sistema (recomendado 8GB+):

**Terminal: WSL (Debian)**
```bash
# Eliminar el clúster actual
minikube delete

# Recrear con más recursos
minikube start --driver=docker --memory=4096 --cpus=3
```

Si tienes memoria limitada (4GB o menos):

**Terminal: WSL (Debian)**
```bash
# Eliminar el clúster actual
minikube delete

# Recrear con recursos mínimos
minikube start --driver=docker --memory=2048 --cpus=2
```

**⚠️ Importante:** Después de recrear minikube, deberás reinstalar Istio y los addons:

**Terminal: WSL (Debian)**
```bash
# Reinstalar Istio
cd istio-1.28.0
istioctl install --set profile=demo -y

# Habilitar inyección de sidecar
kubectl label namespace default istio-injection=enabled

# Reinstalar addons
kubectl apply -f samples/addons

# Reinstalar Chaos Mesh (opcional)
curl -sSL https://mirrors.chaos-mesh.org/v2.6.0/install.sh | bash
```

### Prevención
- Monitorea el uso de recursos de tu sistema
- Considera cerrar aplicaciones innecesarias mientras trabajas con Kubernetes
- Si el problema persiste, evalúa instalar más RAM o usar una máquina virtual dedicada

---

## Problema 4: [Espacio para futuros problemas]

*Se agregarán más problemas y soluciones según se encuentren durante la implementación del proyecto.*

---

## Comandos útiles para diagnóstico

### Ver logs de un pod con error
**Terminal: WSL (Debian)**
```bash
kubectl logs <nombre-del-pod> -n <namespace>
```

### Describir un pod para ver eventos
**Terminal: WSL (Debian)**
```bash
kubectl describe pod <nombre-del-pod> -n <namespace>
```

### Ver todos los recursos en un namespace
**Terminal: WSL (Debian)**
```bash
kubectl get all -n <namespace>
```

### Reiniciar un deployment
**Terminal: WSL (Debian)**
```bash
kubectl rollout restart deployment <nombre-deployment> -n <namespace>
```

---

**Nota:** Si encuentras un problema que no está documentado aquí, por favor documéntalo siguiendo el formato de este archivo.
