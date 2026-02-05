---
name: projeto-octopus
description: Detalhamento do projeto Octopus
version: 1.0.1
language: pt-BR
---

## Objetivo da skill
Detalhar o andamento e entregas realizadas do projeto Octopus

## Arquitetura

### Componentes

O Octopus foi dividido em 3 componentes principais com os seguintes nomes:

- Octopus-Worker: é o nome que foi dado ao artefato worker service .NET 8, ele é um projeto único no formato de CLI que permite executar os fluxos de Baseline (versiona objetos existentes no banco de dados) e Incremental (versiona novos objetos de banco de dados criados/alterados e remove objetos deletados).
- Backend: é uma API em .NET 8 para gerenciamento e consulta de dados, ele fornece endpoints para alterar parametros de configuração do `Octopus-Worker`, gerar relatórios e dashboards.
- Frontend: é uma aplicação web em Angular com NodeJS 20, ela oferece telas dashboard, relatórios, consulta de auditoria, consulta de objetos pendentes para executar no modo incremental e telas para configuração de servidor/instância e banco de dados.

### Integração

O sistema como um todo se integra com alguns componentes externos:

- Cyberark Conjur: É um serviço de cofre de senha responsável por fornecer credenciais de usuário de rede, token do Gitlab e credenciais de banco de dados.
- Cybeark Identity: É um serviço de autenticação e autorização de usuário utilizado no `Backend` e `Frontend` para implementar o controle de acesso e permissão de acesso nas páginas.
- Gitlab: É o servidor utilizado para armazenar os objetos a serem versionados.

### Banco de Dados

O sistema utiliza dois bancos de dados principais:

- OctopusSrvConexão: essa é a base principal do servidor onde estão armazenados todas configurações, logs de auditoria e erro, registro de servidores e banco de dados, visões para relatórios. Está implantada apenas em um servidor.
- Octopus: essa é a base que armazena o rastreamento de mudanças de DDL nos banco de dados. Ela está implantada em todos servidores.

Além das bases uma trigger é implantada em cada servidor que vai ter objetos de banco de dados versionados.

#### Permissões

Obedecendo ao princípio do privilégio mínimo o usuário de banco de dados (*gen_Octopus*) usado pelo sistema ***OCTOPUS*** deve obrigatoriamente possuir os seguintes privilégios a nível de banco de dados e sua autenticação será controlada, a princípio, por uma variável de ambiente. Futuramente, pretende-se que esse controle seja feito por meio de cofre de senha:
- **Nas bases de sistemas e na Base de Sistema Model**:
  - grant view database state
- **Na Base de Sistema Master**:
  - grant view any definition
- **Nas Bases Octopus e OctopusSrvConexao**:
  - db_owner
 
#### Objetos OctopusSrvConexao
