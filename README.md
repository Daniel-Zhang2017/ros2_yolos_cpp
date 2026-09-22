<p align="center">
  <img src="https://raw.githubusercontent.com/Geekgineer/YOLOs-CPP/main/data/cover.png" alt="ros2_yolos_cpp" width="100%"/>
</p>

<h1 align="center">ROS 2 YOLOs-CPP</h1>
<h3 align="center">High-Performance ROS 2 Wrapper for YOLO Inference</h3>

<p align="center">
  <em>Production-grade, lifecycle-managed ROS 2 nodes for Object Detection, Segmentation, Pose, OBB, and Classification using <a href="[https://github.com/Geekgineer/YOLOs-CPP](https://github.com/Daniel-Zhang2017/ros2_yolos_cpp.git)">YOLOs-CPP</a>.</em>
</p>

<p align="center">
  <a href="https://github.com/Geekgineer/ros2_yolos_cpp/actions"><img src="https://img.shields.io/github/actions/workflow/status/Geekgineer/ros2_yolos_cpp/ci.yml?style=flat-square&label=CI" alt="CI"/></a>
  <a href="https://github.com/Geekgineer/ros2_yolos_cpp/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-AGPL--3.0-ef4444?style=flat-square" alt="License"/></a>
  <a href="https://index.ros.org/p/ros2_yolos_cpp/"><img src="https://img.shields.io/badge/ros-humble%20|%20jazzy-blue?style=flat-square&logo=ros" alt="ROS 2 Versions"/></a>
</p>

---

## 🚀 Overview

**ros2_yolos_cpp** brings the blazing speed and unified API of [YOLOs-CPP](https://github.com/Geekgineer/YOLOs-CPP) to the robot operating system. It provides composable, lifecycle-managed nodes for the entire YOLO family (v5, v8, v11, v26, etc.).

---

## 🎬 Demo on Rviz

<table align="center" cellpadding="10">
  <tr>
    <td align="center" style="border:1px solid #ccc">
      <b>Pose Estimation</b><br>
      <img src="assets/pose.gif" width="400">
    </td>
    <td align="center" style="border:1px solid #ccc">
      <b>Object Detection</b><br>
      <img src="assets/object.gif" width="400">
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center" style="border:1px solid #ccc">
      <b>Image Segmentation</b><br>
      <img src="assets/segment.gif" width="400">
    </td>
  </tr>
</table>


---

### Key Features
- **⚡ Zero-Copy Transport**: Optimized for high-throughput image pipelines using `rclcpp::Subscription`.
- **🔄 Lifecycle Management**: Full support for `configure`, `activate`, `deactivate`, `shutdown` transitions.
- **🛠️ Composable Nodes**: Run multiple models in a single container for efficient resource usage.
- **📦 All Tasks Supported**: Detection, Segmentation, Pose, OBB, and Classification.
- **🏗️ Production Ready**: CI/CD tested, strictly typed parameters, and standardized messages (`vision_msgs`).

---

## 📥 Installation

### Prerequisites
- **ROS 2**: Humble or Jazzy
- **OpenCV**: 4.5+
- **ONNX Runtime**: 1.16+ (Auto-downloaded during build)

### Build from Source
```bash
# Create workspace
mkdir -p ~/ros2_ws/src && cd ~/ros2_ws/src

# Clone package
git clone https://github.com/Daniel-Zhang2017/ros2_yolos_cpp.git

# Install dependencies
cd ~/ros2_ws
rosdep update && rosdep install --from-paths src --ignore-src -y

# Build (Release mode recommended for performance)
colcon build --packages-select ros2_yolos_cpp --cmake-args -DCMAKE_BUILD_TYPE=Release
source install/setup.bash
```

---

## 🛠️ Usage

This package provides a launch file for each task. You **must** provide paths to your ONNX model and (optionally) labels file.

### 1. Object Detection
Publishes `vision_msgs/Detection2DArray` with bounding boxes and class IDs.

```bash
ros2 launch ros2_yolos_cpp detector.launch.py \
    model_path:=/path/to/yolo11n.onnx \
    labels_path:=/path/to/coco.names \
    use_gpu:=true \
    image_topic:=/camera/image_raw
```

### 2. Instance Segmentation
Publishes `vision_msgs/Detection2DArray` and a synchronized mask image.

```bash
ros2 launch ros2_yolos_cpp segmentor.launch.py \
    model_path:=/path/to/yolo11n-seg.onnx \
    labels_path:=/path/to/coco.names \
    image_topic:=/camera/image_raw
```

### 3. Pose Estimation
Publishes `vision_msgs/Detection2DArray` with keypoints.

```bash
ros2 launch ros2_yolos_cpp pose.launch.py \
    model_path:=/path/to/yolo11n-pose.onnx \
    image_topic:=/camera/image_raw
```

### 4. Oriented Bounding Boxes (OBB)
Publishes custom `ros2_yolos_cpp/OBBDetection2DArray` with rotated bounding boxes.

```bash
ros2 launch ros2_yolos_cpp obb.launch.py \
    model_path:=/path/to/yolo11n-obb.onnx \
    labels_path:=/path/to/dota.names \
    image_topic:=/camera/image_raw
```

### 5. Image Classification
Publishes `vision_msgs/Classification`.

```bash
ros2 launch ros2_yolos_cpp classifier.launch.py \
    model_path:=/path/to/yolo11n-cls.onnx \
    labels_path:=/path/to/imagenet.names \
    image_topic:=/camera/image_raw
```

---
## 🔄 Nodes Configuration

Replace `<node_name>` with the appropriate name for your task:
- **Detection**: `/yolos_detector`
- **Segmentation**: `/yolos_segmentor`
- **Pose**: `/yolos_pose`
- **OBB**: `/yolos_obb`
- **Classification**: `/yolos_classifier`

### 1. Run Nodes
```bash
ros2 lifecycle set <node_name> configure
ros2 lifecycle set <node_name> activate
```

### 2. Close Nodes
```bash
ros2 lifecycle set <node_name> deactivate
ros2 lifecycle set <node_name> shutdown
```

---

## ⚙️ Configuration

Nodes can be configured via launch arguments or a YAML parameter file. See `config/default_params.yaml` for a template.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `model_path` | string | **Required** | Absolute path to `.onnx` model file. |
| `labels_path` | string | "" | Path to text file with class names (one per line). |
| `use_gpu` | bool | `false` | Enable CUDA acceleration (requires GPU build). |
| `conf_threshold` | double | `0.4` | Minimum confidence score to output detection. |
| `nms_threshold` | double | `0.45` | IoU threshold for Non-Maximum Suppression. |
| `image_topic` | string | `/camera/image_raw` | Topic to subscribe for input images. |
| `publish_debug_image` | bool | `true` | Publish standard `sensor_msgs/Image` with visualizations. |

### Topics

| Node Type | Subscriptions | Publications |
|-----------|---------------|--------------|
| **Detector** | `~/image_raw` | `~/detections` (Detection2DArray)<br>`~/debug_image` (Image) |
| **Segmentor** | `~/image_raw` | `~/detections` (Detection2DArray)<br>`~/masks` (Image)<br>`~/debug_image` |
| **Pose** | `~/image_raw` | `~/detections` (Detection2DArray)<br>`~/debug_image` |
| **OBB** | `~/image_raw` | `~/detections` (OBBDetection2DArray)<br>`~/debug_image` |
| **Classifier** | `~/image_raw` | `~/classification` (Classification)<br>`~/debug_image` |

---

## 🐳 Docker

# 🐳 Docker

Run the stack without installing dependencies locally. The provided `Dockerfile` uses [USTC mirrors](https://mirrors.ustc.edu.cn/) for fast package installation in China.

## Build the image

```bash
# Make the build script executable
chmod +x docker_build.sh

# Build for ROS 2 Humble
./docker_build.sh humble

# ...or for ROS 2 Jazzy
./docker_build.sh jazzy
```

The first build installs all dependencies (a few minutes). Subsequent builds reuse the Docker layer cache and only recompile your code (seconds).

## You can also directly pull the image using the code below.## 

```bash
docker push hhzhang6/ros2_yolos_builder:tagname
```
## Run

### Basic (CPU)

```bash
docker run --rm -it \
    -v /path/to/models:/models \
    ros2_yolos_cpp \
    ros2 launch ros2_yolos_cpp detector.launch.py model_path:=/models/yolov8n.onnx
```

### With GPU

```bash
docker run --gpus all --rm -it \
    -v /path/to/models:/models \
    ros2_yolos_cpp \
    ros2 launch ros2_yolos_cpp detector.launch.py model_path:=/models/yolov8n.onnx
```

### With live workspace (edit code on host, rebuild in container)

```bash
docker run --rm -it --network=host \
    -v "$(pwd):/ros2_ws/src/ros2_yolos_cpp" \
    -w /ros2_ws \
    ros2_yolos_builder:humble \
    bash
```

Then inside the container:

```bash
source /opt/ros/humble/setup.bash
colcon build --packages-select ros2_yolos_cpp
source install/setup.bash
ros2 launch ros2_yolos_cpp detector.launch.py
```

### With a USB camera

```bash
docker run --rm -it --network=host \
    --device=/dev/video0 \
    -v /path/to/models:/models \
    ros2_yolos_cpp \
    ros2 launch ros2_yolos_cpp detector.launch.py
```

### With GUI (RViz / rqt)

```bash
xhost +local:docker

docker run --rm -it --network=host \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    ros2_yolos_cpp \
    rviz2
```

## Full example (GPU + host network + GUI)

```bash
docker run --rm -it \
    --name yolos_run \
    --gpus all \
    --network=host \
    --ipc=host \
    --shm-size=2g \
    -e ROS_DOMAIN_ID=0 \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v /path/to/models:/models:ro \
    -v "$(pwd)/config:/config:ro" \
    ros2_yolos_cpp \
    ros2 launch ros2_yolos_cpp detector.launch.py \
        model_path:=/models/yolov8n.onnx \
        params_file:=/config/params.yaml
```

## Flag reference

| Flag | Purpose |
|---|---|
| `--rm` | Auto-delete container on exit |
| `-it` | Interactive + TTY |
| `-d` | Detached (run in background) |
| `--name` | Give container a name |
| `--gpus all` | Enable NVIDIA GPUs |
| `--network=host` | Share host network (needed for ROS 2 DDS discovery) |
| `--ipc=host` | Share host IPC (helps OpenCV / large shared memory) |
| `--shm-size=2g` | Increase `/dev/shm` (if not using `--ipc=host`) |
| `-v host:container` | Mount a volume |
| `-v ...:ro` | Read-only mount |
| `-w /path` | Set working directory inside the container |
| `-e VAR=value` | Set an environment variable |
| `--device=/dev/video0` | Pass through a device (e.g. camera) |
| `-e DISPLAY=$DISPLAY` | GUI display forwarding |

## Notes

> [!NOTE]
> GPU support requires the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and a compatible NVIDIA driver. Drop `--gpus all` to run on CPU.

> [!TIP]
> Use `--network=host` if you want ROS 2 nodes on the host and inside the container to discover each other automatically.

> [!WARNING]
> `xhost +local:docker` relaxes X11 access control. Revert with `xhost -local:docker` when done.

## Cleanup

```bash
docker ps -a                 # list all containers
docker rm <container_id>     # remove one
docker rm $(docker ps -aq)   # remove all stopped containers

docker images                # list images
docker rmi ros2_yolos_cpp    # remove image
docker system prune -a       # nuke unused images / containers / networks
```
## open another terminal and check
```bash
docker ps                      # find the container ID
docker exec -it <id> bash
# look inside
ps aux | grep apt
cat /etc/apt/sources.list
```
**Docker part is updated by Dan Z.**

## 📄 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**. See [LICENSE](LICENSE) for details.


  Made with ❤️ by the <a href="https://github.com/Geekgineer/YOLOs-CPP">YOLOs-CPP Team</a>
</p>
