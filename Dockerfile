# Dockerfile
ARG ROS_DISTRO=humble
FROM ros:${ROS_DISTRO}-ros-base

ARG ROS_DISTRO
ENV ROS_DISTRO=${ROS_DISTRO}
ENV DEBIAN_FRONTEND=noninteractive

# ---- 换国内镜像源（中科大 USTC）----
# Ubuntu 源（兼容新旧格式）
RUN if [ -f /etc/apt/sources.list ]; then \
        sed -i 's|http://archive.ubuntu.com|https://mirrors.ustc.edu.cn|g; \
                s|http://security.ubuntu.com|https://mirrors.ustc.edu.cn|g' \
            /etc/apt/sources.list; \
    fi && \
    if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
        sed -i 's|http://archive.ubuntu.com|https://mirrors.ustc.edu.cn|g; \
                s|http://security.ubuntu.com|https://mirrors.ustc.edu.cn|g' \
            /etc/apt/sources.list.d/ubuntu.sources; \
    fi && \
    # ROS 2 源
    for f in /etc/apt/sources.list.d/ros2*.list /etc/apt/sources.list.d/ros*.list; do \
        [ -f "$f" ] && sed -i 's|http://packages.ros.org|https://mirrors.ustc.edu.cn/ros2|g' "$f" || true; \
    done && \
    # 兼容 ROS 2 新版 .sources 格式
    if [ -f /etc/apt/sources.list.d/ros2.sources ]; then \
        sed -i 's|http://packages.ros.org|https://mirrors.ustc.edu.cn/ros2|g' \
            /etc/apt/sources.list.d/ros2.sources; \
    fi

# ---- 安装依赖（这一层会被缓存）----
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

# ---- 自动 source ROS ----
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

WORKDIR /ros2_ws

# 默认命令（可被 docker run 覆盖）
CMD ["/bin/bash"]
