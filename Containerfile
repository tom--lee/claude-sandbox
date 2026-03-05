FROM node:lts-slim
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /workspace
ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
