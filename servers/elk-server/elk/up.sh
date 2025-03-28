#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo ".env file not found. Please create it and define ELASTICSEARCH_PASSWORD and KIBANA_PASSWORD and ELK_VERSION."
  exit 1
fi

# Check if required environment variables are set
if [ -z "$ELASTICSEARCH_PASSWORD" ] || [ -z "$KIBANA_PASSWORD" ]; then
  echo "ELASTICSEARCH_PASSWORD or KIBANA_PASSWORD not defined in .env file."
  exit 1
fi

# Set DNS
read -p "Do you want to configure custom DNS? (y/n): " use_dns
if [ "$use_dns" == "y" ]; then
  read -p "Enter primary DNS: " dns1
  read -p "Enter secondary DNS (optional, press Enter to skip): " dns2

  echo "nameserver $dns1" > /etc/resolv.conf
  if [ -n "$dns2" ]; then
    echo "nameserver $dns2" >> /etc/resolv.conf
  fi
  echo "DNS has been configured."
fi

# Mirror registry
read -p "Do you want to use a mirror registry? (y/n): " use_mirror
if [ "$use_mirror" == "y" ]; then
  read -p "Enter the mirror registry URL (e.g., docker.arvancloud.ir): " mirror_registry
else
  mirror_registry=""
fi

# Pull Elasticsearch image
if [ -z "$(docker images -q elasticsearch:$ELK_VERSION)" ]; then
  echo "Pulling Elasticsearch image..."
  if [ -n "$mirror_registry" ]; then
    docker pull "$mirror_registry/elasticsearch:$ELK_VERSION" &&
    docker tag "$mirror_registry/elasticsearch:$ELK_VERSION" elasticsearch:$ELK_VERSION || {
      echo "Failed to pull Elasticsearch image. Exiting..."
      exit 1
    }
  else
    docker pull elasticsearch:$ELK_VERSION || {
      echo "Failed to pull Elasticsearch image. Exiting..."
      exit 1
    }
  fi
fi

# Pull Kibana image
if [ -z "$(docker images -q kibana:$ELK_VERSION)" ]; then
  echo "Pulling Kibana image..."
  if [ -n "$mirror_registry" ]; then
    docker pull "$mirror_registry/kibana:$ELK_VERSION" &&
    docker tag "$mirror_registry/kibana:$ELK_VERSION" kibana:$ELK_VERSION || {
      echo "Failed to pull Kibana image. Exiting..."
      exit 1
    }
  else
    docker pull kibana:$ELK_VERSION || {
      echo "Failed to pull Kibana image. Exiting..."
      exit 1
    }
  fi
fi

# Pull Log-stash image
if [ -z "$(docker images -q logstash:$ELK_VERSION)" ]; then
  echo "Pulling logstash image..."
  if [ -n "$mirror_registry" ]; then
    docker pull "$mirror_registry/logstash:$ELK_VERSION" &&
    docker tag "$mirror_registry/logstash:$ELK_VERSION" logstash:$ELK_VERSION || {
      echo "Failed to pull logstash image. Exiting..."
      exit 1
    }
  else
    docker pull logstash:$ELK_VERSION || {
      echo "Failed to pull logstash image. Exiting..."
      exit 1
    }
  fi
fi

# Starting elk
echo "Starting Elasticsearch and Kibana..."
docker compose up -d elasticsearch

echo "Waiting for Elasticsearch to be ready..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' elasticsearch)" == "healthy" ]; do
  echo "Elasticsearch is not healthy. Retrying in 5 seconds..."
  sleep 5
done

sleep 5

docker exec -it elasticsearch chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data > /dev/null 2>&1 || {
    echo "set kibana password"
}

(echo "y" && echo "${KIBANA_PASSWORD}" && echo "${KIBANA_PASSWORD}") | docker exec -i elasticsearch bin/elasticsearch-reset-password -u kibana_system -i

docker compose up -d

echo "Setup completed"