FROM ros:humble-ros-base

ENV ROS_DISTRO=humble
ENV DEBIAN_FRONTEND=noninteractive

# ---- 替换 Ubuntu 源为 USTC ----
RUN if [ -f /etc/apt/sources.list ]; then \
        sed -i 's|http://archive.ubuntu.com|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list; \
    fi

# ---- 导入 ROS 2 GPG 密钥 ----
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# ---- 添加 USTC ROS 2 源（路径已修正为 /ros2/ubuntu）----
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.ustc.edu.cn/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2.list

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

# ---- 后续步骤（根据你的实际项目补充）----
# WORKDIR /ros2_ws
# COPY . .
# RUN . /opt/ros/${ROS_DISTRO}/setup.sh && colcon build

CMD ["bash"]
