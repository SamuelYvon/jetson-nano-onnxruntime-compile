#!/bin/bash
# Compile ONNX runtime with TensorRT support on a Jetson Nano
# author: Samuel Yvon
set -e

py3_ver=$(python3 --version)

echo "Hello!"
echo "This script will build onnxruntime for a jetson nano"
echo "Specifically, it builds onnxruntime 1.6.0 with the tensorrt"
echo "execution provider for trt version 7.1"

echo "You will need a CMake version that is supported by the"
echo "onnxruntime. It will tell you if it's not OK, don't worry"

echo "Be wary that on a Jetson nano 2GB, this takes around 3h"
echo "to build."



echo "The python version for 'python3' is $py3_ver. Is this your target python version?"
select yn in "Yes" "No"; do
    case $yn in
        Yes)
            break
            ;;
        No)
            echo "Then fix it!"
            exit 1 ;;
    esac
done


export CUDACXX="/usr/local/cuda/bin/nvcc"
sudo apt install -y --no-install-recommends \
    build-essential software-properties-common libopenblas-dev \
    libpython3.6-dev python3-pip python3-dev python3-setuptools \
    python3-wheel



git clone --recursive -b v1.6.0 https://github.com/Microsoft/onnxruntime
pushd onnxruntime	

pushd cmake/external

pushd onnx-tensorrt
git remote update
git checkout release/7.1
popd

pushd protobuf
git remote update
git checkout v3.9.0
popd

popd

./build.sh \
    --config Release \
    --update \
    --build \
    --parallel \
    --build_wheel \
    --use_tensorrt \
    --skip_submodule_sync \
    --cuda_home /usr/local/cuda \
    --cudnn_home /usr/lib/aarch64-linux-gnu \
    --tensorrt_home /usr/lib/aarch64-linux-gnu

