# Métodos de Autenticación de Qwen

Este proyecto ahora soporta **dos métodos de autenticación** para conectarse a los servicios de Qwen:

## 1. API Key (dashscope-intl.aliyuncs.com) 🔑

### Ventajas
- ✅ **Límites de velocidad más altos**: Mejor para uso intensivo
- ✅ **Conexión más estable**: Menos problemas de rate limiting
- ✅ **Más confiable**: Para proyectos en producción
- ✅ **Prueba gratuita**: Generalmente incluye **1 millón de tokens gratis** por modelo para cuentas nuevas (vía región Internacional/Singapur)

### Desventajas
- ⚠️ **Requiere API key de pago**: Una vez agotada la prueba, se cobra por uso
- ⚠️ **Uso de múltiples modelos**: Los tokens gratis se cuentan por modelo; ¡ten cuidado si usas varios!
- ⚠️ **Necesitas una cuenta en Alibaba Cloud**: Más configuración inicial

### Cómo obtener tu API Key
1. Ve a [DashScope International (Alibaba Cloud Singapur)](https://dashscope-intl.aliyuncs.com/)
2. Inicia sesión o crea una cuenta
3. Ve a la sección de API Keys
4. Genera una nueva API key
5. Copia la key (formato: `sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)

### Cuando renovar
Si tu API key expira o es revocada, simplemente ejecuta el script de instalación nuevamente y proporciona una nueva key cuando se te solicite.

---

## 2. Bearer Token (portal.qwen.ai) - Recomendado ✨ 🎁

### Ventajas
- ✅ **Recomendado**: El límite se resetea diariamente, ideal para uso personal constante
- ✅ **Totalmente gratuito**: No requiere pago
- ✅ **1000 solicitudes/día**: (Recientemente reducido de 2000 a 1000)
- ✅ **60 solicitudes/minuto**: Buen límite para uso moderado

### Desventajas
- ⚠️ **Rate limiting**: Puede fallar con uso intensivo
- ⚠️ **Menos estable**: Más propenso a errores 429 (Too Many Requests)
- ⚠️ **Tokens expiran**: Necesitas renovar periódicamente

### Cómo obtener tu Bearer Token
1. Instala el CLI de Qwen (si no lo tienes):
   ```bash
   npm install -g @qwenai/qwen-cli
   ```

2. Ejecuta el CLI:
   ```bash
   qwen
   ```

3. Dentro del CLI, escribe:
   ```
   /auth
   ```

4. Se abrirá tu navegador automáticamente
5. Inicia sesión con tu cuenta de qwen.ai
6. Cuando veas "Success", regresa al CLI y escribe:
   ```
   /exit
   ```

7. El token se guarda automáticamente en `~/.qwen/oauth_creds.json`

### Cuando renovar
Si tu token expira (generalmente después de algunos días), verás errores de autenticación. Para renovarlo:

```bash
qwen
# Dentro del CLI:
/auth
# Inicia sesión nuevamente
/exit
# Luego reejecuta el script de instalación
```

---

## Comparación Rápida

| Característica | API Key | Bearer Token |
|---|---|---|
| **Costo** | 💰 Pago (con 1M tokens gratis) | 🆓 Gratuito |
| **Límite diario** | ⚡ Alto | 📊 1000 req/día (Recurrente) |
| **Límite por minuto** | ⚡ Alto | 📊 60 req/min |
| **Estabilidad** | ✅ Excelente | ⚠️ Moderada |
| **Rate limiting** | ✅ Raro | ⚠️ Común con uso intensivo |
| **Configuración** | 🔧 Simple | 🔧 Requiere CLI |
| **Renovación** | 📅 Una vez agotados los tokens | 📅 Diaria/Semanal |
| **Recomendado para** | Usuarios pesados o producción | **Uso personal (Recomendado)** |

---

## Cambiar de Método

Si quieres cambiar de un método a otro, simplemente reejecuta el script de instalación:

```bash
./install.sh
```

El script te preguntará qué método prefieres usar y configurará todo automáticamente.

---

## Solución de Problemas

### API Key
- **Error: Invalid API key**: Verifica que copiaste la key completa
- **Error 401 Unauthorized**: La key puede haber expirado, genera una nueva

### Bearer Token
- **Error 429 Too Many Requests**: Has alcanzado el límite de rate, espera unos minutos
- **Error 401 Unauthorized**: El token expiró, ejecuta `qwen` → `/auth` de nuevo
- **Archivo no encontrado**: Asegúrate de haber completado el proceso `/auth` correctamente

---

## Recomendación

- **Para desarrollo personal y pruebas**: Usa Bearer Token (gratis)
- **Para producción o uso intensivo**: Usa API Key (más confiable)
- **Si experimentas rate limiting**: Cambia a API Key

