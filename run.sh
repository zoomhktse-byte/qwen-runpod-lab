#!/usr/bin/env bash

set -euo pipefail

echo "======================================="
echo " Qwen RunPod AI Lab"
echo "======================================="

echo
echo "Starting standard RunPod services..."
echo "Jupyter / SSH / NGINX"

/start.sh &

# Give the RunPod base services a moment to initialize
sleep 5

echo
echo "======================================="
echo " GPU"
echo "======================================="

nvidia-smi || true

echo
echo "======================================="
echo " llama.cpp"
echo "======================================="

/opt/llama.cpp/build/bin/llama-server --version

echo
echo "======================================="
echo " Starting llama-server"
echo "======================================="

exec /opt/llama.cpp/build/bin/llama-server
