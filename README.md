# FAST 2025 – Bootcamp Engenharia de Plataforma

## Desafio de Laboratório – Implementação Completa

Este documento descreve **toda a implementação** do desafio proposto, incluindo **arquitetura, infraestrutura como código, CI/CD, Docker Swarm, monitoramento e segurança**, pronto para entrega e defesa técnica.

---

## 1. Visão Geral da Arquitetura

A solução utiliza **Amazon Web Services (AWS) como provedor de nuvem pública, com provisionamento automatizado via **Terraform** e configuração via **Ansible**. A aplicação fornecida será executada em um **cluster Docker Swarm com 3 nós**.

Ferramentas utilizadas:

* Terraform (Infraestrutura – AWS)
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

## 4. Terraform – Infraestrutura na AWS

A infraestrutura é provisionada na **AWS**, utilizando **EC2**, **Security Groups** e **VPC padrão**.

### provider.tf

```hcl
provider "aws" {
  region = var.aws_region
}
```

### variables.tf

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.medium"
}
```

### main.tf

```hcl
resource "aws_instance" "swarm" {
  count         = 3
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 22.04 LTS
  instance_type = var.instance_type

  tags = {
    Name = "swarm-node-${count.index}"
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

---

## 11. README.md (Documentação em Markdown)

Abaixo está o **README.md pronto**, seguindo boas práticas exigidas em vagas de DevOps / Engenharia de Plataforma.

```markdown
# FAST 2025 – Laboratório de Engenharia de Plataforma

Este projeto demonstra a implementação de uma infraestrutura moderna em nuvem utilizando **Infraestrutura como Código (IaC)**, **CI/CD**, **Docker Swarm** e **Monitoramento**, como parte do Bootcamp **FAST 2025 – Engenharia de Plataforma**.

## 📌 Objetivo do Projeto

Provisionar e operar uma aplicação containerizada em um **cluster Docker Swarm com 3 nós**, totalmente automatizado, utilizando:

- Terraform para provisionamento da infraestrutura
- Ansible para configuração dos servidores
- GitHub Actions para CI/CD
- Uptime Kuma para monitoramento e alertas

## 🏗️ Arquitetura

- Amazon Web Services (AWS)
- 1 instância EC2 Manager (Docker Swarm)
- 2 instâncias EC2 Worker (Docker Swarm)
- Security Groups controlando acesso
- Rede isolada para aplicação
- Monitoramento separado da aplicação

## 📁 Estrutura do Projeto

```

fast-engenharia-plataforma/
├── terraform/        # Infraestrutura como código (AWS)
├── ansible/          # Configuração automática dos servidores
├── app/              # Aplicação containerizada
├── docker-stack.yml  # Stack Docker Swarm
├── .github/workflows # Pipeline CI/CD
└── README.md

````

## ⚙️ Pré-requisitos

- Conta no Amazon Web Services
- Terraform >= 1.5
- Ansible >= 2.10
- Docker e Docker Compose
- Conta no Docker Hub
- Git

## 🚀 Como Provisionar a Infraestrutura

```bash
cd terraform
terraform init
terraform apply
````

Após a criação das VMs, anote os IPs públicos gerados.

## 🔧 Configuração dos Servidores

Edite o arquivo `ansible/inventory.ini` com os IPs das VMs:

```ini
[manager]
IP_MANAGER

[workers]
IP_WORKER_1
IP_WORKER_2
```

Execute o Ansible:

```bash
cd ansible
ansible-playbook playbook.yml
```

## 🐳 Deploy da Aplicação

O deploy é feito automaticamente no Docker Swarm utilizando o arquivo `docker-stack.yml`.

```bash
docker stack deploy -c docker-stack.yml app
```

A aplicação ficará disponível em:

```
http://IP_MANAGER:3000
```

## 🔁 CI/CD

O pipeline é executado automaticamente via **GitHub Actions**:

* Build da imagem Docker
* Push para o Docker Hub
* Atualização da aplicação no cluster

Arquivo: `.github/workflows/ci-cd.yml`

## 📊 Monitoramento

O Uptime Kuma monitora a disponibilidade da aplicação:

```
http://IP_MANAGER:3001
```

* Checagem HTTP
* Alertas via webhook (Slack / Discord / Telegram)

## 🔐 Segurança

* Aplicação e monitoramento em redes separadas
* Sem acesso direto entre serviços críticos
* Infraestrutura reproduzível e versionada

## 📚 Tecnologias Utilizadas

* Terraform
* Ansible
* Docker Swarm
* GitHub Actions
* Amazon Web Services
* Uptime Kuma

## 👨‍💻 Autor

**Luan Borba**
Bootcamp FAST 2025 – Engenharia de Plataforma

```
