#!/bin/bash
apt-get install -y docker.io docker-compose
systemctl enable --now docker
