FROM ros:humble as base
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    libclang-dev \
    vim \
    neovim \
    python3-pip \
    net-tools 


# -----Personal ROS settings-----
RUN echo "-----Personal ROS settings-----"
RUN mkdir -p /root/Programs/Settings
COPY docker_settings/ros/.ros_config /.ros_config
COPY docker_settings/ros/rosSetup.txt  /root/Programs/Settings/rosSetup_CRLF.txt
RUN sed "s/\r//g" /root/Programs/Settings/rosSetup_CRLF.txt > /root/Programs/Settings/rosSetup.txt && \
    cat /root/Programs/Settings/rosSetup.txt >> /root/.bashrc && \
    echo "" >> /root/.bashrc


# -----Install powerline-shell-----
RUN echo "-----Install powerline-shell-----"
RUN pip3 install powerline-shell
COPY docker_settings/powerline/powerlineSetup.txt /root/Programs/Settings/powerlineSetup_CRLF.txt
RUN sed "s/\r//g" /root/Programs/Settings/powerlineSetup_CRLF.txt > /root/Programs/Settings/powerlineSetup.txt && \
    cat /root/Programs/Settings/powerlineSetup.txt >> /root/.bashrc && \
    echo "" >> /root/.bashrc
RUN mkdir -p /root/.config/powerline-shell
COPY docker_settings/powerline/config.json /root/.config/powerline-shell/config.json

# Install Rust and the cargo-ament-build plugin
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain 1.62.0 -y
ENV PATH=/root/.cargo/bin:$PATH
RUN cargo install cargo-ament-build

RUN pip install --upgrade pytest 

# Install the colcon-cargo and colcon-ros-cargo plugins
RUN pip install git+https://github.com/colcon/colcon-cargo.git git+https://github.com/colcon/colcon-ros-cargo.git

RUN mkdir -p /workspace && echo "Did you forget to mount the repository into the Docker container?" > /workspace/HELLO.txt
WORKDIR /workspace