FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------------------------
# Install build/runtime dependencies
# --------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        cmake \
        build-essential \
        curl \
        jq \
        libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Build llama.cpp once inside the Docker image
#
# 86 = A40 / RTX A6000
# 89 = RTX 6000 Ada / L40S
# --------------------------------------------------

RUN git clone --depth 1 \
        https://github.com/ggml-org/llama.cpp.git \
        /opt/llama.cpp \
    && cmake \
        -S /opt/llama.cpp \
        -B /opt/llama.cpp/build \
        -DGGML_CUDA=ON \
        -DCMAKE_CUDA_ARCHITECTURES="86;89" \
        -DCMAKE_BUILD_TYPE=Release \
    && cmake --build \
        /opt/llama.cpp/build \
        --config Release \
        -j"$(nproc)" \
        --target llama-server llama-cli llama-bench

# --------------------------------------------------
# Startup script
# --------------------------------------------------

COPY run.sh /usr/local/bin/run-qwen-lab.sh

RUN chmod +x /usr/local/bin/run-qwen-lab.sh

# Keep RunPod NVIDIA entrypoint from the base image.
# This CMD replaces /start.sh, so run.sh will start
# the normal RunPod services first, then llama-server.
CMD ["/usr/local/bin/run-qwen-lab.sh"]
