# Instalación y Configuración del Entorno

Este documento describe los pasos necesarios para instalar y configurar todas las herramientas requeridas para el proyecto de microservicios **desde cero**.

## Tabla de contenidos
1. [Instalación de WSL2](#1-instalación-de-wsl2)
2. [Instalación de Docker Desktop](#2-instalación-de-docker-desktop)
3. [Instalación de kubectl](#3-instalación-de-kubectl)
4. [Instalación de minikube](#4-instalación-de-minikube)
5. [Instalación de Istio](#5-instalación-de-istio)
6. [Instalación de Chaos Mesh](#6-instalación-de-chaos-mesh-opcional)

---

## 1. Instalación de WSL2

### En Windows (PowerShell como Administrador):

```powershell
# Habilitar WSL
wsl --install

# Si ya tienes WSL instalado, actualiza a WSL2
wsl --set-default-version 2

# Instalar Ubuntu (recomendado)
wsl --install -d Ubuntu-22.04
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
6. Habilita la integración con tu distribución de Ubuntu

### Verificar instalación (en WSL):
```sh
docker --version
docker ps
```

---

## 3. Instalación de kubectl

### En WSL (Ubuntu):

**Terminal: WSL (Ubuntu)**
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

### En WSL (Ubuntu):

**Terminal: WSL (Ubuntu)**
```bash
# Descargar minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Instalar
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verificar instalación
minikube version
```

### Iniciar minikube:
**Terminal: WSL (Ubuntu)**
```bash
minikube start --driver=docker
```

### Verificar que minikube está corriendo:
**Terminal: WSL (Ubuntu)**
```bash
minikube status
```

---

## 5. Instalación de Istio

### En WSL (Ubuntu):

**Terminal: WSL (Ubuntu)**
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

**Terminal: WSL (Ubuntu)**
```bash
# Instalar Istio con perfil demo (incluye todos los componentes)
istioctl install --set profile=demo -y
```

### Habilitar inyección automática de sidecar:

**Terminal: WSL (Ubuntu)**
```bash
# Habilitar en el namespace default
kubectl label namespace default istio-injection=enabled
```

### Verificar instalación:

**Terminal: WSL (Ubuntu)**
```bash
# Verificar versión
istioctl version

# Verificar pods de Istio
kubectl get pods -n istio-system
```

---

## 6. Instalación de Chaos Mesh (opcional)

**Nota:** Solo instala Chaos Mesh si deseas realizar pruebas avanzadas de Chaos Engineering.

### En WSL (Ubuntu):

**Terminal: WSL (Ubuntu)**
```bash
# Instalar Chaos Mesh
curl -sSL https://mirrors.chaos-mesh.org/v2.6.0/install.sh | bash
```

### Verificar instalación:

**Terminal: WSL (Ubuntu)**
```bash
# Verificar pods de Chaos Mesh
kubectl get pods -n chaos-mesh
```

---

## 7. Verificación final de la instalación

Una vez completados todos los pasos anteriores, ejecuta las verificaciones del archivo `VERIFICACION_INSTALACION.md` para confirmar que todo está correctamente instalado y configurado.

---

## 8. Configurar acceso a dashboards de Istio

Istio incluye varios dashboards para observabilidad:

**Terminal: WSL (Ubuntu)**
```bash
# Abrir Kiali (dashboard de Istio)
istioctl dashboard kiali

# Abrir Jaeger (trazas distribuidas)
istioctl dashboard jaeger

# Abrir Grafana (métricas)
istioctl dashboard grafana
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
**Terminal: WSL (Ubuntu)**
```bash
# Eliminar y recrear el clúster
minikube delete
minikube start --driver=docker
```

### Istio no se instala correctamente
**Terminal: WSL (Ubuntu)**
```bash
# Desinstalar Istio
istioctl uninstall --purge

# Reinstalar
istioctl install --set profile=demo -y
```

### Los pods de Istio no inician
**Terminal: WSL (Ubuntu)**
```bash
# Verificar recursos de minikube (puede necesitar más memoria)
minikube stop
minikube start --driver=docker --memory=4096 --cpus=4
```

---

Una vez completada la instalación, ejecuta las verificaciones del archivo `VERIFICACION_INSTALACION.md` y luego continúa con los pasos del archivo `README.md` para construir y desplegar los microservicios.
