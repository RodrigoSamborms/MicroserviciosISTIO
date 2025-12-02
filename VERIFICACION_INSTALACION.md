# Verificación de Instalación

Este documento te ayudará a verificar que tienes todas las herramientas necesarias antes de comenzar con el proyecto.

## Checklist de verificación

Ejecuta los siguientes comandos en WSL para verificar que tienes todo instalado y configurado correctamente:

### 1. Verificar WSL2
```sh
wsl --list --verbose
```
**Resultado esperado:** Debes ver tu distribución de Linux con versión 2.

---

### 2. Verificar Docker
```sh
docker --version
docker ps
```
**Resultado esperado:** 
- Versión de Docker (ej: Docker version 24.x.x)
- Lista de contenedores (puede estar vacía)

Si el comando `docker ps` falla, verifica que Docker Desktop esté corriendo y tenga integración WSL2 habilitada.

---

### 3. Verificar kubectl
```sh
kubectl version --client
```
**Resultado esperado:** Versión de kubectl (ej: Client Version: v1.28.x)

---

### 4. Verificar minikube
```sh
minikube version
```
**Resultado esperado:** Versión de minikube (ej: minikube version: v1.32.x)

---

### 5. Verificar que minikube está corriendo
```sh
minikube status
```
**Resultado esperado:**
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

Si minikube no está corriendo, inícialo con:
```sh
minikube start --driver=docker
```

---

### 6. Verificar Istio
```sh
istioctl version
```
**Resultado esperado:** Versiones del cliente y del control plane de Istio

Si solo ves la versión del cliente pero no del control plane, significa que Istio no está instalado en el clúster.

---

### 7. Verificar que Istio está desplegado en el clúster
```sh
kubectl get pods -n istio-system
```
**Resultado esperado:** Lista de pods de Istio en estado `Running`:
- istiod-xxxxx
- istio-ingressgateway-xxxxx
- istio-egressgateway-xxxxx

---

### 8. Verificar inyección automática de Istio
```sh
kubectl get namespace default --show-labels
```
**Resultado esperado:** El namespace `default` debe tener el label `istio-injection=enabled`

---

### 9. Verificar Chaos Mesh (opcional)
```sh
kubectl get pods -n chaos-mesh
```
**Resultado esperado:** Lista de pods de Chaos Mesh en estado `Running`

Si no planeas usar Chaos Engineering, puedes omitir esta verificación.

---

## Resumen de verificación

✅ **Todo listo:** Si todos los comandos anteriores devuelven resultados exitosos, puedes continuar con las instrucciones del `README.md`.

❌ **Falta algo:** Si alguna verificación falló, consulta el archivo `INSTALACION_CONFIGURACION.md` para instalar las herramientas faltantes.

---

## Comandos rápidos de verificación (todos en uno)

Puedes ejecutar este script para verificar todo de una vez:

```sh
echo "=== Verificando WSL ==="
wsl --list --verbose

echo -e "\n=== Verificando Docker ==="
docker --version

echo -e "\n=== Verificando kubectl ==="
kubectl version --client

echo -e "\n=== Verificando minikube ==="
minikube version
minikube status

echo -e "\n=== Verificando Istio ==="
istioctl version

echo -e "\n=== Verificando pods de Istio ==="
kubectl get pods -n istio-system

echo -e "\n=== Verificando inyección de Istio ==="
kubectl get namespace default --show-labels

echo -e "\n=== Verificando Chaos Mesh (opcional) ==="
kubectl get pods -n chaos-mesh
```

Copia y pega todo el bloque anterior en tu terminal WSL para ejecutar todas las verificaciones.
