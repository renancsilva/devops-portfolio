# Example app so the stack runs out of the box. Replace this folder with your own app.
FROM node:22-alpine
WORKDIR /app
COPY server.js .
ENV APP_PORT=3000
USER node
CMD ["node", "server.js"]
