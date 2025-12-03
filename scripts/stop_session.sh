#!/usr/bin/env bash
set -euo pipefail

echo "== Cierre de sesión: limpiando configuraciones y procesos =="

# 1) Eliminar configuraciones de inyección de fallos de Istio (si existen)
echo "- Eliminando VirtualServices/DestinationRules de fault injection (si están presentes)"
kubectl delete -f k8s/fault-injection-delay.yaml --ignore-not-found
kubectl delete -f k8s/fault-injection-abort.yaml --ignore-not-found
kubectl delete -f k8s/fault-injection-combined.yaml --ignore-not-found
kubectl delete -f k8s/circuit-breaker.yaml --ignore-not-found

# 2) Cerrar dashboards abiertos via istioctl (Kiali/Jaeger/Grafana) si hay procesos corriendo
echo "- Cerrando dashboards abiertos (kiali/jaeger/grafana)"
pkill -f "istioctl dashboard kiali" || true
pkill -f "istioctl dashboard jaeger" || true
pkill -f "istioctl dashboard grafana" || true

# 3) Detener minikube
echo "- Deteniendo minikube"
minikube stop || true

echo "== Listo: sesión cerrada de forma segura =="
