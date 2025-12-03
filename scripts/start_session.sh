#!/usr/bin/env bash
set -euo pipefail

echo "== Inicio de sesión: preparando entorno =="

# 0) Variables y ubicación del proyecto
REPO_ROOT="/mnt/c/Users/sambo/Documents/Programacion/GitHub/MicroserviciosISTIO"
ISTIO_DIR="$REPO_ROOT/istio-1.28.0"

# 1) Iniciar minikube (ajustar recursos si es necesario)
echo "- Iniciando minikube (driver=docker, memoria=2048MB, cpus=2)"
minikube start --driver=docker --memory=2048 --cpus=2

# 2) Verificar que Istio esté desplegado
echo "- Verificando pods de Istio"
kubectl get pods -n istio-system

# 3) Asegurar inyección automática de sidecar en 'default'
echo "- Asegurando label de inyección automática en namespace default"
kubectl label namespace default istio-injection=enabled --overwrite

# 4) (Opcional) Aplicar addons si faltan (Kiali/Jaeger/Grafana/Prometheus)
if [ -d "$ISTIO_DIR" ]; then
  echo "- Directorio de Istio encontrado: $ISTIO_DIR"
  echo "  Puedes reinstalar addons si faltan: kubectl apply -f samples/addons (manual)"
else
  echo "- Advertencia: No se encontró $ISTIO_DIR; asegúrate de tener istioctl y addons instalados"
fi

# 5) Obtener IP y NodePort del Ingress Gateway
echo "- Obteniendo IP de minikube y NodePort del Ingress Gateway"
MINIKUBE_IP=$(minikube ip)
NODEPORT=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')
echo "  Ingress disponible en: http://$MINIKUBE_IP:$NODEPORT"

# 6) Probar API básica (GET usuarios)
echo "- Probando API: GET /usuarios"
curl -s "http://$MINIKUBE_IP:$NODEPORT/usuarios" || true

echo "== Listo: entorno iniciado. Usa GUIA_INYECCION_FALLOS.md para experimentos =="
