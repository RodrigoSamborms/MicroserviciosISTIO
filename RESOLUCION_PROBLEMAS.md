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

## Problema 2: [Espacio para futuros problemas]

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
