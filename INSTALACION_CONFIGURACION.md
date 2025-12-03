# Instalación y Configuración del Entorno

Este documento describe los pasos necesarios para instalar y configurar todas las herramientas requeridas para el proyecto de microservicios **desde cero**.

## Tabla de contenidos
1. [Instalación de WSL2](#1-instalación-de-wsl2)
2. [Instalación de Docker Desktop](#2-instalación-de-docker-desktop)
3. [Instalación de kubectl](#3-instalación-de-kubectl)
4. [Instalación de minikube](#4-instalación-de-minikube)
5. [Instalación de Istio](#5-instalación-de-istio)
6. [Inyección de fallos con Istio](#6-inyección-de-fallos-con-istio)

---

## 1. Instalación de WSL2

### En Windows (PowerShell como Administrador):

```powershell
# Habilitar WSL
wsl --install

# Si ya tienes WSL instalado, actualiza a WSL2
wsl --set-default-version 2

# Instalar Debian (usado en este proyecto)
wsl --install -d Debian
```

Reinicia tu computadora si es necesario.

### Verificar instalación:
**Terminal: PowerShell (Windows)**
```powershell
wsl --list --verbose
```

---

## 2. Instalación de Docker Desktop

### En Windows:

1. Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop
2. Ejecuta el instalador
3. Asegúrate de habilitar la integración con WSL2 durante la instalación
4. Una vez instalado, abre Docker Desktop
5. Ve a Settings → Resources → WSL Integration
6. Habilita la integración con tu distribución de Debian

### Verificar instalación (en WSL):
```sh
docker --version
docker ps
```

---

## 3. Instalación de kubectl

### En WSL (Debian):

**Terminal: WSL (Debian)**
```bash
# Descargar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Hacer ejecutable
chmod +x kubectl

# Mover a directorio del PATH
sudo mv kubectl /usr/local/bin/

# Verificar instalación
kubectl version --client
```

---

## 4. Instalación de minikube

### En WSL (Debian):

**Terminal: WSL (Debian)**
```bash
# Descargar minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Instalar
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verificar instalación
minikube version
```

### Iniciar minikube:
**Terminal: WSL (Debian)**
```bash
minikube start --driver=docker
```

**⚠️ Nota sobre recursos:** Si tu sistema tiene memoria limitada (4GB o menos), es recomendable especificar los recursos explícitamente:
```bash
minikube start --driver=docker --memory=2048 --cpus=2
```

Para sistemas con más recursos (8GB+):
```bash
minikube start --driver=docker --memory=4096 --cpus=3
```

### Verificar que minikube está corriendo:
**Terminal: WSL (Debian)**
```bash
minikube status
```

---

## 5. Instalación de Istio

### En WSL (Debian):

**Terminal: WSL (Debian)**
```bash
# Descargar Istio
curl -L https://istio.io/downloadIstio | sh -

# Entrar al directorio descargado (reemplaza * con la versión descargada)
cd istio-*

# Agregar istioctl al PATH (temporal)
export PATH=$PWD/bin:$PATH

# Para hacerlo permanente, agrega istioctl a tu .bashrc
echo "export PATH=\$PATH:$PWD/bin" >> ~/.bashrc
source ~/.bashrc
```

### Instalar Istio en el clúster de Kubernetes:

**Terminal: WSL (Debian)**
```bash
# Instalar Istio con perfil demo (incluye todos los componentes)
istioctl install --set profile=demo -y
```

### Habilitar inyección automática de sidecar:

**Terminal: WSL (Debian)**
```bash
# Habilitar en el namespace default
kubectl label namespace default istio-injection=enabled
```

### Verificar instalación:

**Terminal: WSL (Debian)**
```bash
# Verificar versión
istioctl version

# Verificar pods de Istio
kubectl get pods -n istio-system
```

### Instalar addons de observabilidad:

Después de instalar Istio, es necesario instalar manualmente los addons de observabilidad (Kiali, Jaeger, Prometheus, Grafana):

**Terminal: WSL (Debian)**
```bash
# Navegar al directorio de Istio
cd istio-1.28.0

# Instalar todos los addons
kubectl apply -f samples/addons

# Esperar a que los pods estén listos (puede tomar 3-5 minutos)
kubectl get pods -n istio-system
```

**Nota:** Los pods pueden tardar varios minutos en iniciarse, especialmente con recursos limitados. Es normal ver el estado `ContainerCreating` mientras se descargan las imágenes (que pueden pesar más de 300MB en total).

---

## 6. Inyección de fallos con Istio

Para pruebas de resiliencia usaremos las capacidades nativas de Istio (Fault Injection), que son más ligeras y no requieren instalar componentes adicionales.

Archivos disponibles en `k8s/`:
- `fault-injection-delay.yaml`: Añade latencia controlada a las peticiones
- `fault-injection-abort.yaml`: Devuelve errores HTTP 503 de forma controlada
- `fault-injection-combined.yaml`: Combina latencia y errores
- `circuit-breaker.yaml`: Configura circuit breaker con DestinationRule

Guía completa: `GUIA_INYECCION_FALLOS.md`

**Ejemplo rápido:**

**Terminal: WSL (Debian)**
```bash
# Aplicar delay del 50% y 5s
kubectl apply -f k8s/fault-injection-delay.yaml

# Generar tráfico
for i in {1..10}; do
	time curl -X POST http://$(minikube ip):31769/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"Test$i\"}"
done

# Limpiar
kubectl delete -f k8s/fault-injection-delay.yaml
```

---

## 7. Verificación final de la instalación

Una vez completados todos los pasos anteriores, ejecuta las verificaciones del archivo `VERIFICACION_INSTALACION.md` para confirmar que todo está correctamente instalado y configurado.

---

## 8. Configurar acceso a dashboards de Istio

Istio incluye varios dashboards para observabilidad. **Primero verifica que los addons estén instalados:**

**Terminal: WSL (Debian)**
```bash
# Verificar que todos los addons estén corriendo
kubectl get pods -n istio-system
```

**Resultado esperado:** Debes ver pods de `grafana`, `jaeger`, `kiali`, y `prometheus` en estado `Running`.

**Si algún dashboard no está instalado,** consulta el Problema 2 en `RESOLUCION_PROBLEMAS.md`.

**Una vez que los pods estén corriendo, abre los dashboards:**

**Terminal: WSL (Debian)**
```bash
# Navegar al directorio de Istio
cd istio-1.28.0

# Abrir Kiali (dashboard de Istio)
./bin/istioctl dashboard kiali

# Abrir Jaeger (trazas distribuidas)
./bin/istioctl dashboard jaeger

# Abrir Grafana (métricas)
./bin/istioctl dashboard grafana
```

Estos dashboards te permiten ver en tiempo real:
- Tráfico entre microservicios
- Trazas de peticiones
- Métricas de latencia y errores
- Topología del sistema

## Notas importantes

- El comando `minikube tunnel` es necesario para exponer el Istio Ingress Gateway cuando uses minikube.
- Los dashboards de Istio se abren automáticamente en el navegador cuando ejecutas los comandos `istioctl dashboard`.
- La inyección automática de sidecar hace que Istio añada automáticamente el proxy Envoy a cada pod en el namespace `default`.
- Si reinicias tu máquina, deberás ejecutar `minikube start --driver=docker` nuevamente.
- Para detener minikube cuando no lo estés usando: `minikube stop`
- Para eliminar completamente el clúster: `minikube delete`

---

## Solución de problemas comunes

### Docker no funciona en WSL
- Verifica que Docker Desktop esté corriendo
- Asegúrate de tener habilitada la integración WSL2 en Docker Desktop → Settings → Resources → WSL Integration

### minikube no inicia
**Terminal: WSL (Debian)**
```bash
# Eliminar y recrear el clúster
minikube delete
minikube start --driver=docker
```

### Istio no se instala correctamente
**Terminal: WSL (Debian)**
```bash
# Desinstalar Istio
istioctl uninstall --purge

# Reinstalar
istioctl install --set profile=demo -y
```

### Los pods de Istio no inician
**Terminal: WSL (Debian)**
```bash
# Verificar recursos de minikube (puede necesitar más memoria)
minikube stop
minikube start --driver=docker --memory=4096 --cpus=4
```

---

Una vez completada la instalación, ejecuta las verificaciones del archivo `VERIFICACION_INSTALACION.md` y luego continúa con los pasos del archivo `README.md` para construir y desplegar los microservicios.
