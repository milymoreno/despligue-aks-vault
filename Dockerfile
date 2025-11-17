# Imagen base estable (puedes fijar minor/alpine si quieres aún más reproducibilidad)
FROM node:18-slim

# Variables de entorno y workdir
ENV NODE_ENV=production
WORKDIR /app

# Copiamos manifest de dependencias primero para cachear
COPY package.json package-lock.json ./

# Instalación determinística y solo prod
RUN npm ci --only=production

# Copiamos el código de la app
COPY server.js ./

# Crear usuario/grupo no root y asignar permisos
RUN addgroup -S appgroup \
    && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app
USER appuser

# Exponer puerto y comando de arranque
EXPOSE 8080
CMD ["npm", "start"]
