FROM ollama/ollama:latest

RUN ollama serve > /tmp/ollama.log 2>&1 & \
    until ollama list > /dev/null 2>&1; do sleep 1; done; \
    ollama pull llama3.2:1b