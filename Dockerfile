FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app source code
COPY . .

# App listens on port 3000
EXPOSE 3000

CMD ["node", "app.js"]
