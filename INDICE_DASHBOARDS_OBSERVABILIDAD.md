# 📚 Documentación: Dashboards y Observabilidad

Índice completo de guías para aprender a usar los dashboards de observabilidad e interpretar resultados de experimentos de fault injection.

---

## 🚀 Comienza Aquí

**¿Por dónde empiezo?**

1. **Si es tu primera vez con los dashboards:**
   - → Lee: [LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md)
   - Duración: ~20 minutos
   - Qué obtienen: Experiencia práctica completa de un experimento end-to-end

2. **Si quieres ver qué esperar en cada dashboard:**
   - → Lee: [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md)
   - Duración: ~5-10 minutos
   - Qué obtienen: Descripciones visuales de cada escenario

3. **Si ya corriste un experimento y quieres entender mejor:**
   - → Lee: [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md)
   - Duración: ~15 minutos de lectura
   - Qué obtienen: Comprensión profunda de cada dashboard

4. **Si necesitas respuestas rápidas durante pruebas:**
   - → Usa: [REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md)
   - Duración: 2-3 minutos para encontrar lo que busca
   - Qué obtienen: Cheat sheets y tablas de comparación

5. **Si quieres experimentar con diferentes escenarios:**
   - → Lee: [GUIA_INYECCION_FALLOS.md](GUIA_INYECCION_FALLOS.md)
   - Duración: Variable según escenarios
   - Qué obtienen: Instrucciones para todos los tipos de fallos

---

## 📖 Documentos Disponibles

### [1. LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md)
**Guía práctica paso a paso para tu primer experimento**

- ✅ Preparación de dashboards
- ✅ Observación de estado normal
- ✅ Inyección de delays (5 segundos)
- ✅ Inyección de errores (503)
- ✅ Experimento combinado
- ✅ Análisis de resultados

**Duración:** ~20 minutos  
**Requisitos:** Minikube corriendo, dashboards accesibles  
**Resultado:** Entiendes cómo interpretar cambios en los dashboards

---

### [2. GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md)
**Descripciones detalladas de lo que verás en cada dashboard**

**Secciones:**
- Kiali: Estado normal, con delays, con errores
- Jaeger: Estado normal, con delays, con errores
- Grafana: Estado normal, con delays, con errores
- Comparativas visuales
- Tips para reconocer cambios

**Duración:** 5-10 minutos (consulta rápida)  
**Resultado:** Sabes exactamente qué esperar en cada escenario

---

### [3. GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md)
**Guía completa y detallada de cada dashboard**

**Secciones:**
1. Acceder a los dashboards
2. KIALI - Visualización de topología y tráfico
   - Qué es, cómo usarla, qué esperar
3. JAEGER - Trazas distribuidas
   - Qué es, cómo leer trazas, qué significa cada span
4. GRAFANA - Métricas históricas
   - Qué es, qué gráficos buscar, cómo interpretarlos
5. Guía práctica: ejecutar prueba completa
6. Troubleshooting

**Duración:** ~15-20 minutos de lectura  
**Resultado:** Experto en leer e interpretar cada dashboard

---

### [4. REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md)
**Cheat sheet para consultas rápidas durante pruebas**

**Secciones:**
- Tabla comparativa de dashboards
- Checklist antes de ejecutar prueba
- Indicadores clave para cada escenario
- Menú rápido de navegación
- FAQ interpretación
- Comandos útiles
- Pro tips
- Valores normales (tabla de referencia)

**Duración:** 2-3 minutos por consulta  
**Resultado:** Referencia rápida sin perder tiempo

---

### [5. GUIA_INYECCION_FALLOS.md](GUIA_INYECCION_FALLOS.md)
**Guía detallada de experimentación con Istio Fault Injection**

**Escenarios cubiertos:**
- Delays (latencia)
- Errores (HTTP 503)
- Combinado (delays + errores)
- Circuit breaker
- Configuración personalizada

**Duración:** Variable según escenarios (5-30 minutos)  
**Resultado:** Capacidad de diseñar y ejecutar experimentos personalizados

---

## 🎯 Roadmap de Aprendizaje

### Nivel 1: Principiante
```
1. Ejecuta: LABORATORIO_PRIMER_EXPERIMENTO.md
   └─ Resultado: Completaste un experimento end-to-end
   
2. Consulta: GALERIA_VISUAL_DASHBOARDS.md
   └─ Resultado: Sabes qué esperar ver en cada dashboard
   
3. Lee: GUIA_DASHBOARDS.md (secciones 2-5)
   └─ Resultado: Entiendes cada dashboard en profundidad
   
4. Descarga: REFERENCIA_RAPIDA_DASHBOARDS.md
   └─ Resultado: Tienes cheat sheet de bolsillo
```

### Nivel 2: Intermedio
```
1. Experimenta: GUIA_INYECCION_FALLOS.md (todos los escenarios)
   └─ Resultado: Dominas todos los tipos de fallos
   
2. Consulta: GALERIA_VISUAL_DASHBOARDS.md para comparar resultados
   
3. Diseña tu propio experimento
   └─ Consulta REFERENCIA_RAPIDA_DASHBOARDS.md mientras pruebas
   
4. Documenta tus hallazgos
   └─ Resultado: Entiendes patrones de comportamiento
```

### Nivel 3: Avanzado
```
1. Crea manifiestos YAML personalizados
   └─ Lee: GUIA_INYECCION_FALLOS.md (sección de configuración)
   
2. Combina múltiples tipos de fallos
   
3. Predice resultados antes de ejecutar
   └─ Usa: GALERIA_VISUAL_DASHBOARDS.md como referencia
   
4. Enseña a otros lo que aprendiste
```

---

## 🔍 Casos de Uso Específicos

### "Quiero hacer mi primer experimento completo"
→ [LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md)

### "No entiendo qué significa la línea naranja en Kiali"
→ [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md) - Sección 2.3

### "¿Qué valores son normales para Response Time?"
→ [REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md) - Valores Normales

### "Quiero inyectar errores 503 en el 50% de peticiones"
→ [GUIA_INYECCION_FALLOS.md](GUIA_INYECCION_FALLOS.md) - Cambiar porcentaje

### "¿Por qué Jaeger no muestra mis trazas?"
→ [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md) - Troubleshooting

### "Necesito interpretar resultados en 2 minutos"
→ [REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md)

---

## 📊 Tabla Rápida: Dashboard por Propósito

| Necesito... | Usa... | Razón |
|-------------|--------|-------|
| Ver topología de servicios | Kiali | Es su especialidad |
| Depurar una petición específica | Jaeger | Trazas detalladas |
| Ver tendencias históricas | Grafana | Gráficos de línea |
| Entender conexión entre servicios | Kiali | Flechas conectan servicios |
| Encontrar qué servicio es lento | Grafana | Promedios y percentiles |
| Ver duración exacta de cada operación | Jaeger | Spans mostrar operaciones |
| Detectar picos de latencia | Grafana | Gráficos temporales |
| Ver si hay errores ahora | Kiali | Línea roja = errores |

---

## ⚡ Quick Links

- [README.md](README.md) - Instrucciones de inicio rápido
- [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md) - Guía completa de dashboards
- [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md) - Lo que verás en pantalla
- [REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md) - Cheat sheet
- [LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md) - Paso a paso
- [GUIA_INYECCION_FALLOS.md](GUIA_INYECCION_FALLOS.md) - Experimentación
- [SCRIPTS.md](SCRIPTS.md) - Comandos disponibles
- [RESOLUCION_PROBLEMAS.md](RESOLUCION_PROBLEMAS.md) - Troubleshooting general

---

## 💡 Tips Antes de Empezar

1. **Abre 3 ventanas del navegador** (una por dashboard) para observar simultáneamente
2. **Mantén un terminal generando tráfico** mientras experimentas
3. **Toma screenshots** de cada escenario para comparar
4. **Consulta REFERENCIA_RAPIDA_DASHBOARDS.md** mientras haces pruebas
5. **Lee LABORATORIO_PRIMER_EXPERIMENTO.md primero** aunque tengas experiencia

---

## 📝 Convenciones Usadas en las Guías

- ✅ = Comportamiento esperado / Correctamente configurado
- ✗ = Comportamiento inesperado / Error
- ⬆️⬆️⬆️ = Métrica aumentó significativamente
- ⬇️⬇️⬇️ = Métrica disminuyó significativamente
- **Bold** = Elemento de interfaz o métrica importante
- `Código` = Comandos o valores técnicos
- 💡 = Consejo o insight importante

---

## 🤔 FAQ

**P: ¿Por dónde empiezo si nunca usé estos dashboards?**
- A: [LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md) - Te guía paso a paso

**P: ¿Qué se supone que debo ver en Kiali cuando inyecto delays?**
- A: [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md) - Kiali Con Delays

**P: ¿Cuánto tiempo tarda en actualizar Kiali después de aplicar cambios?**
- A: ~10-15 segundos. Grafana tarda ~30-60 segundos. Ver [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md) - Sección 6

**P: ¿Es normal que Jaeger muestre 0 trazas?**
- A: No. Deberías ver trazas si estás generando tráfico. Ver troubleshooting en [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md)

**P: ¿Qué diferencia hay entre Kiali y Grafana?**
- A: Ver tabla en [REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md) - Dashboard Comparison

**P: ¿Cómo sé si un experimento funcionó correctamente?**
- A: Ver [LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md) - Fase 2-4 (Análisis)

**P: ¿Dónde veo exactamente qué esperar en cada dashboard?**
- A: [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md) - Descripciones y ejemplos visuales

---

## 📚 Orden de Lectura Recomendado

**Primera vez:**
1. Este archivo (índice)
2. [LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md) (lee y ejecuta)
3. [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md) (para futuras consultas)
4. [REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md) (aprende los atajos)

**Segunda vez (experimentación):**
1. [REFERENCIA_RAPIDA_DASHBOARDS.md](REFERENCIA_RAPIDA_DASHBOARDS.md) (consulta rápida)
2. [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md) (compara tus resultados)
3. [GUIA_INYECCION_FALLOS.md](GUIA_INYECCION_FALLOS.md) (elige experimento)
4. Ejecuta el experimento

**Tercera vez (profundizar):**
1. [GUIA_DASHBOARDS.md](GUIA_DASHBOARDS.md) (lee sección sobre dashboard específico)
2. [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md) (compara con tus observaciones)
3. Experimenta interpretando los datos

---

**¡Listo para empezar?** 

→ [LABORATORIO_PRIMER_EXPERIMENTO.md](LABORATORIO_PRIMER_EXPERIMENTO.md) 🚀

**O si prefieres ver primero qué esperar:**

→ [GALERIA_VISUAL_DASHBOARDS.md](GALERIA_VISUAL_DASHBOARDS.md) 👀
