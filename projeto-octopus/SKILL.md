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


#### Objetos de servidor

##### Trigger

###### trg_track_DDL

https://raw.githubusercontent.com/thiagofdso/banpara-skills/refs/heads/main/projeto-octopus/trg_track_DDL.sql

#### Objetos OctopusSrvConexao

##### Tabelas

###### tbDadosConexaoServidor
| Coluna | Tipo | Nulo | Padrão/Constraint | Descrição oficial |
|--------|------|------|-------------------|-------------------|
| idSrv | INT IDENTITY (1,1) | NÃO | PK `PK__tbDadosC__024F714B8C0C4BAA` | Identificador unico do servidor e chave estrangeira em tbDadosBase |
| ip_Nome | VARCHAR(255) (Latin1_General_CI_AI) | SIM | — | Hostname ou IP usado para montar a string de conexao e o caminho do repositorio |
| instancia | VARCHAR(255) (Latin1_General_CI_AI) | SIM | — | Nome da Instância de Banco de Dados |
| porta | INT | SIM | — | Porta do Servidor de Banco de Dados |
| isVersioned | BIT | SIM | DEFAULT ((0)) via `defaultValueForIsVersioned` | Flag para Habiltiar Versionamento |
| srvRecursoOuGrupo | VARCHAR(255) | SIM | DEFAULT (NULL) | Agrupador ou cluster usado em filtros CLI e nos logs operacionais |
| scvGroupId | INT | SIM | — | NamespaceId do GitLab associado ao servidor para provisionar repositorios |
| idUser | VARCHAR(512) | SIM | — | Identificador do secret no Conjur que guarda o login SQL do servidor |
| idPassword | VARCHAR(512) | SIM | — | Identificador do secret no Conjur que guarda a senha SQL do servidor |

> **Chaves/Relacionamentos:** chave primária em `idSrv`. Não há FKs declaradas neste objeto.

###### tbDadosBase
| Coluna | Tipo | Nulo | Padrão/Constraint | Descrição oficial |
|--------|------|------|-------------------|-------------------|
| idBase | INT IDENTITY (1,1) | NÃO | PK `PK_tbDadosBase` | Identificador interno de cada base catalogada no metadata |
| nomeBase | VARCHAR(255) (SQL_Latin1_General_CP1_CI_AS) | SIM | — | Nome da base usado nas pastas e nas mensagens de commit |
| scvUrl | VARCHAR(2048) (SQL_Latin1_General_CP1_CI_AS) | SIM | — | URL do projeto GitLab |
| fkSrv | INT | SIM | FK → `tbDadosConexaoServidor(idSrv)` | Chave estrangeira para tbDadosConexaoServidor.idSrv |
| ultimaExecucao | DATETIME | SIM | — | Data e hora da ultima execucao que sincronizou a bas |
| isVersionado | BIT | NÃO | DEFAULT ((1)) | Flag para habilitar versionamento |
| isRemovido | BIT | NÃO | DEFAULT ((0)) | Indica soft delete para ocultar a base ate que seja restaurada |

> **Chaves/Relacionamentos:** chave primária em `idBase`; chave estrangeira `fkSrv` referenciando `tbDadosConexaoServidor(idSrv)`.

###### tbAuditoria
| Coluna | Tipo | Nulo | Padrão/Constraint | Descrição oficial |
|--------|------|------|-------------------|-------------------|
| AuditId | INT IDENTITY (1,1) | NÃO | PK `PK_tbAuditoria` | Id do registro de auditoria |
| EventTimeUtc | DATETIME2(3) | NÃO | DEFAULT (sysutcdatetime()) | TimeStamp do evento em UCT-3 |
| EventType | VARCHAR(50) (SQL_Latin1_General_CP1_CI_AS) | NÃO | — | Tipo de evento DDL |
| Mode | VARCHAR(20) (SQL_Latin1_General_CP1_CI_AS) | NÃO | — | Modo de execução do Octopus |
| ServerName | VARCHAR(255) (SQL_Latin1_General_CP1_CI_AS) | NÃO | — | Nome do Servidor de Banco de Dados |
| DatabaseName | VARCHAR(255) (SQL_Latin1_General_CP1_CI_AS) | SIM | — | Nome do Banco de Dados |
| SchemaName | VARCHAR(128) (SQL_Latin1_General_CP1_CI_AS) | SIM | — | Nome do Esquema de Banco de Dados |
| ObjectName | VARCHAR(256) (SQL_Latin1_General_CP1_CI_AS) | SIM | — | Nome do Objeto de Banco de Dados |
| ObjectType | VARCHAR(64) (SQL_Latin1_General_CP1_CI_AS) | SIM | — | Tipo do Objeto de Banco de Dados |
| TrackId | INT | SIM | — | Id de rastreamento do evento |
| SourceSubsystem | VARCHAR(64) (SQL_Latin1_General_CP1_CI_AS) | NÃO | — | Nome do componente da aplicação responsável pelo registro |
| AdditionalPayload | NVARCHAR(2000) (SQL_Latin1_General_CP1_CI_AS) | SIM | — | Mensagem detalhada do evento |
| InstanceName | VARCHAR(255) | SIM | — | Nome da Instância de Banco de Dados |

> **Índices adicionais:** `IX_tbAuditoria_EventTimeUtc` (nonclustered em `EventTimeUtc`) e `IX_tbAuditoria_Server_Database` (nonclustered em `ServerName`, `DatabaseName`).

###### tbError
| Coluna | Tipo | Nulo | Padrão/Constraint | Descrição oficial |
|--------|------|------|-------------------|-------------------|
| ErrorId | BIGINT IDENTITY (1,1) | NÃO | PK `PK_tbError` | Identificador único de registros de erros |
| LoggedAtUtc | DATETIME2(3) | NÃO | DEFAULT (sysutcdatetime()) | Timestamp do log |
| Mode | VARCHAR(20) | NÃO | — | Modo de execução do Octopus |
| ServerName | VARCHAR(255) | SIM | — | Nome do servidor |
| DatabaseName | VARCHAR(255) | SIM | — | Nome do Banco de Dados |
| ObjectName | VARCHAR(255) | SIM | — | Nome do Objeto |
| ObjectType | VARCHAR(50) | SIM | — | Tipo do Objeto |
| ErrorType | VARCHAR(200) | NÃO | — | Tipo de Erro |
| ErrorMessage | NVARCHAR(2000) | NÃO | — | Mensagem do Erro |
| StackTrace | NVARCHAR(MAX) | SIM | — | StackTrace do Erro |
| CorrelationId | VARCHAR(100) | SIM | — | Identificador de correlação |
| BatchId | UNIQUEIDENTIFIER | SIM | — | Identificador do lote |
| GitBranch | VARCHAR(255) | SIM | — | Branch do gitlab |
| GitRepository | VARCHAR(500) | SIM | — | Repositório do Gitlab |
| PayloadJson | NVARCHAR(MAX) | SIM | — | Payload da mensagem |
| InstanceName | VARCHAR(255) | SIM | — | Nome da Instância |

> **Índices adicionais:** `IX_tbError_Mode_LoggedAtUtc` (nonclustered em `Mode`, `LoggedAtUtc`) e `IX_tbError_Server_Database` (nonclustered em `ServerName`, `DatabaseName`).

###### tbTeste
| Coluna | Tipo | Nulo | Padrão/Constraint | Descrição oficial |
|--------|------|------|-------------------|-------------------|
| Id | INT | NÃO | PK (inline) | Identificador numerico usado como chave primaria da tabela de teste. |
| nome | VARCHAR(50) | SIM | — | Nome ou descricao livre armazenada apenas para cenarios de teste. |

##### Views

###### vwAuditoriaEventos
View agrupada sobre `tbAuditoria` que retorna métricas de eventos por data. Estrutura atual:

| Coluna | Origem/Tipo | Descrição |
|--------|-------------|-----------|
| EventDate | `CONVERT(DATE, a.EventTimeUtc)` | Data derivada do timestamp UTC de `tbAuditoria`. |
| EventWeekDay | `DATENAME(WEEKDAY, a.EventTimeUtc)` | Nome do dia da semana correspondente ao evento. |
| Mode | `a.Mode` | Propaga o modo de execução registrado. |
| EventCategory | `CASE` sobre `EventType` | Classifica como `Create`, `Drop`, `Baseline` ou `Other`. |
| EventType | `a.EventType` | Tipo DDL detalhado. |
| ServerName | `a.ServerName` | Servidor de origem. |
| InstanceName | `a.InstanceName` | Instância reportada no evento. |
| DatabaseName | `a.DatabaseName` | Base relacionada (quando houver). |
| ObjectType | `a.ObjectType` | Tipo do objeto afetado. |
| EventsCount | `COUNT(*)` | Número de linhas agregadas para a combinação chave. |

> **Observação:** a view agrupa por todas as colunas listadas e não possui propriedades estendidas registradas no script atual.

#### Objetos Octopus

##### Tabela

###### track_ddl

| Coluna | Tipo / Tamanho / Collation | Nulo? | Padrão / Constraint | Descrição |
|--------|---------------------------|-------|---------------------|-----------|
| TRACK_ID | INT IDENTITY(1,1) | Não | PK PK__track_DD__24ECC82E86D9E742 | Identificador do evento. |
| EVENTTYPE | VARCHAR(100) Latin1_General_CI_AI | Não | — | Tipo de evento (ex.: CREATE_TABLE, DROP_DATABASE). |
| EVENTTIME | DATETIME | Não | DF__track_DDL__event__6FE99F9F → GETDATE() | Timestamp do evento no momento da captura.
| SERVERNAME | VARCHAR(100) Latin1_General_CI_AI | Sim | — | Nome do servidor onde o DDL ocorreu. |
| WHODIDIT | VARCHAR(100) Latin1_General_CI_AI | Sim | — | Usuário executor registrado pelo trigger de auditoria. |
| TSQL_TEXT | VARCHAR(4000) Latin1_General_CI_AI | Sim | — | Texto completo do script DDL capturado. |
| SCHEMANAME | VARCHAR(100) Latin1_General_CI_AI | Sim | — | Nome do esquema do objeto afetado. |
| OBJECTNAME | VARCHAR(100) Latin1_General_CI_AI | Sim | — | Nome do objeto (tabela, view, etc.) impactado. |
| OBJECTTYPE | VARCHAR(100) Latin1_General_CI_AI | Sim | — | Tipo do objeto associado ao evento (TABLE, VIEW,  PROCEDURE…). |
| DATABASENAME | VARCHAR(100) Latin1_General_CI_AI | Sim | — | Nome da base de dados onde o evento ocorreu. |
| WHEREITFROM | VARCHAR(100) Latin1_General_CI_AI | Sim | — | Host / origem da execução que disparou o DDL. |
| ISNEW | BIT | Sim | DF__track_DDL__isNew__70DDC3D8 → 1 | Flag que marca o registro como pendente de processamento (1  = novo). |
