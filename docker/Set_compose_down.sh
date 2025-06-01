#!/bin/bash

echo "尋找所有運行中的 Docker containers..."

# 找出所有正在運行的 container IDs
running_containers=$(docker ps -q)

# 檢查是否有正在運行的容器
if [ -z "$running_containers" ]; then
    echo "目前沒有任何正在運行的容器。"
else
    echo "以下容器將被關閉與移除："
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"

    # 停止所有運行中的容器
    echo "停止容器中..."
    docker stop $running_containers

    # 移除所有容器
    echo "移除容器中..."
    docker rm $running_containers

    echo "所有容器已關閉並移除完畢。"
fi