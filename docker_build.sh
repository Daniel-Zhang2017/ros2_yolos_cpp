#!/bin/bash
# Build ros2_yolos_cpp in a ROS 2 Docker container (Dockerfile version)
# Usage: ./docker_build.sh [humble|jazzy]

set -e

ROS_DISTRO="${1:-humble}"
IMAGE="ros2_yolos_builder:${ROS_DISTRO}"
WORKSPACE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "Building ros2_yolos_cpp in Docker"
echo "ROS Distro: ${ROS_DISTRO}"
echo "Workspace:  ${WORKSPACE_DIR}"
echo "APT mirror: USTC (mirrors.ustc.edu.cn)"
echo "=========================================="

# ---- 1. 构建（或复用）镜像 ----
echo ">>> Building docker image (${IMAGE})..."
DOCKER_BUILDKIT=1 docker build \
    --build-arg ROS_DISTRO="${ROS_DISTRO}" \
    -t "${IMAGE}" \
    -f "${WORKSPACE_DIR}/Dockerfile" \
    "${WORKSPACE_DIR}"

# ---- 2. 在容器里编译 ----
echo ">>> Running colcon build..."
docker run --rm -it \
    --network=host \
    -v "${WORKSPACE_DIR}:/ros2_ws/src/ros2_yolos_cpp:rw" \
    -w /ros2_ws \
    "${IMAGE}" \
    /bin/bash -c "
        set -e
        source /opt/ros/${ROS_DISTRO}/setup.bash
        echo '>>> colcon build...'
        colcon build --packages-select ros2_yolos_cpp \
            --cmake-args -DCMAKE_BUILD_TYPE=Release \
            --event-handlers console_direct+
        echo '>>> Build complete!'
        echo '>>> Install dir: /ros2_ws/install (mapped to ${WORKSPACE_DIR}/install)'
    "
