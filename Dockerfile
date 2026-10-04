# Reuse the official prebuilt CUDA llama.cpp server image so GitHub Actions
# does not need an NVIDIA driver or GPU to compile/link llama.cpp.
FROM ghcr.io/ggml-org/llama.cpp:server-cuda AS llama

# RunPod development base: CUDA 12.8 + PyTorch + Jupyter + SSH.
FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Small runtime utilities used by the Lab/Jupyter environment.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        jq \
        libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy the official prebuilt CUDA llama.cpp runtime (binary + shared libraries).
# Both images use Ubuntu 24.04 / CUDA 12.8, which keeps the runtime compatible.
COPY --from=llama /app /opt/llama-runtime

# Make the copied llama.cpp shared libraries discoverable at runtime.
ENV LD_LIBRARY_PATH=/opt/llama-runtime:${LD_LIBRARY_PATH}

# Preserve the path expected by run.sh from the first Lab version.
RUN mkdir -p /opt/llama.cpp/build/bin && \
    ln -sf /opt/llama-runtime/llama-server /opt/llama.cpp/build/bin/llama-server

# Startup script: start RunPod's Jupyter/SSH services, then llama-server.
COPY run.sh /usr/local/bin/run-qwen-lab.sh
RUN chmod +x /usr/local/bin/run-qwen-lab.sh

CMD ["/usr/local/bin/run-qwen-lab.sh"]
