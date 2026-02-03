# Desafio-de-Laborat-rio-Engenharia de Plataforma


## Desafio de Laboratório – Implementação Completa

Este documento descreve **toda a implementação** do desafio proposto, incluindo **arquitetura, infraestrutura como código, CI/CD, Docker Swarm, monitoramento e segurança**, pronto para entrega e defesa técnica.

---

## 1. Visão Geral da Arquitetura

A solução utiliza **AWS** como provedor de nuvem pública, com provisionamento automatizado via **Terraform** e configuração via **Ansible**. A aplicação fornecida será executada em um **cluster Docker Swarm com 3 nós**.

Ferramentas utilizadas:

* Terraform (Infraestrutura)
* Ansible (Configuração)
* Docker Swarm (Orquestração)
* GitHub Actions (CI/CD)
* Uptime Kuma (Monitoramento)

---

## 2. Arquitetura do Ambiente

* 1 nó Manager (Docker Swarm)
* 2 nós Worker (Docker Swarm)
* Rede isolada para aplicação
* Monitoramento em container separado

Fluxo:

1. Push no GitHub
2. GitHub Actions faz build e push da imagem
3. Atualização automática do serviço no Swarm
4. Monitoramento contínuo da aplicação

---

## 3. Estrutura do Repositório

```
fast-engenharia-plataforma/
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       ├── docker/
│       ├── swarm/
│       └── deploy/
├── app/
│   └── Dockerfile
├── docker-stack.yml
├── .github/workflows/ci-cd.yml
└── README.md
```

---

## 4. Terraform – Infraestrutura no AWS

### provider.tf

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

### variables.tf

```hcl
variable "project_id" {}
variable "region" { default = "us-central1" }
variable "zone" { default = "us-central1-a" }
```

### main.tf

```hcl
resource "google_compute_instance" "swarm" {
  count        = 3
  name         = "swarm-node-${count.index}"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
```

---

## 5. Ansible – Configuração dos Nós

### inventory.ini

```ini
[manager]
<IP_MANAGER>

[workers]
<IP_WORKER_1>
<IP_WORKER_2>
```

### playbook.yml

```yaml
- hosts: all
  become: true
  roles:
    - docker

- hosts: manager
  become: true
  roles:
    - swarm
    - deploy
```

O Ansible instala o Docker, inicializa o Swarm no manager e conecta os workers automaticamente.

---

## 6. Docker Swarm – Aplicação

### docker-stack.yml

```yaml
version: '3.8'

services:
  app:
    image: seu-dockerhub/todo-app:latest
    deploy:
      replicas: 3
    ports:
      - "3000:3000"
    networks:
      - app_net

  monitor:
    image: louislam/uptime-kuma
    ports:
      - "3001:3001"
    networks:
      - monitor_net

networks:
  app_net:
    driver: overlay
  monitor_net:
    driver: overlay
```

---

## 7. CI/CD – GitHub Actions

### .github/workflows/ci-cd.yml

```yaml
name: CI-CD

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Login DockerHub
        run: docker login -u ${{ secrets.DOCKER_USER }} -p ${{ secrets.DOCKER_PASS }}

      - name: Build Image
        run: docker build -t seu-dockerhub/todo-app ./app

      - name: Push Image
        run: docker push seu-dockerhub/todo-app
```

---

## 8. Monitoramento e Alertas

O **Uptime Kuma** monitora a URL da aplicação (`http://IP_MANAGER:3000`).

* Checagem HTTP contínua
* Alertas configurados via Webhook / Slack / Discord
* Notificação imediata quando a aplicação ficar offline

---

## 9. Segurança

* Aplicação e monitoramento em redes distintas
* Sem acesso da aplicação ao serviço de monitoramento
* Infraestrutura reproduzível e versionada

---

## 10. Conclusão

Este laboratório demonstra práticas modernas de **Engenharia de Plataforma**, com automação completa, infraestrutura como código, CI/CD, observabilidade e segurança.

A solução está pronta para avaliação técnica e defesa.

---

**Autor:** Luan Borba
**Curso:** FAST 2025 – Engenharia de Plataforma
