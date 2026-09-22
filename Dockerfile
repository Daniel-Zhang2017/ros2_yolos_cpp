FROM ros:humble-ros-base

ARG ROS_DISTRO=humble
ENV ROS_DISTRO=${ROS_DISTRO}
ENV DEBIAN_FRONTEND=noninteractive

# ---- 替换 Ubuntu 源为 USTC（archive + security 都要换）----
RUN sed -i 's|http://archive.ubuntu.com|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list

# ---- 导入 ROS 2 GPG 密钥 ----
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
        -o /usr/share/keyrings/ros-archive-keyring.gpg

# ---- 添加 USTC ROS 2 源（覆盖基础镜像自带的官方源）----
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.ustc.edu.cn/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
        > /etc/apt/sources.list.d/ros2.list

# ---- 安装依赖 ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        libopencv-dev \
        curl \
        ros-${ROS_DISTRO}-image-transport \
        ros-${ROS_DISTRO}-vision-msgs \
        ros-${ROS_DISTRO}-cv-bridge \
        ros-${ROS_DISTRO}-rclcpp-components \
        ros-${ROS_DISTRO}-lifecycle && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ros2_ws

CMD ["bash"]
