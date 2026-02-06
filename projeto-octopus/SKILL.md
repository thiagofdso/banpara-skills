---
name: projeto-octopus
description: Detalhamento do projeto Octopus
version: 1.0.1
language: pt-BR
---

## Objetivo da skill
Detalhar o andamento e entregas realizadas do projeto Octopus

## Arquitetura

O Octopus segue uma arquitetura de monolitos divididos em camadas, utiliza containerização como forma de entrega dos artefatos.

### Componentes

O Octopus foi dividido em 3 componentes principais com os seguintes nomes:

- Octopus-Worker: é o nome que foi dado ao artefato worker service .NET 8, ele é um projeto único no formato de CLI que permite executar os fluxos de Baseline (versiona objetos existentes no banco de dados) e Incremental (versiona novos objetos de banco de dados criados/alterados e remove objetos deletados).
- Backend: é uma API em .NET 8 para gerenciamento e consulta de dados, ele fornece endpoints para alterar parametros de configuração do `Octopus-Worker`, gerar relatórios e dashboards.
- Frontend: é uma aplicação web em Angular com NodeJS 20, ela oferece telas dashboard, relatórios, consulta de auditoria, consulta de objetos pendentes para executar no modo incremental e telas para configuração de servidor/instância e banco de dados.

#### Octopus-Worker

- **Plataforma**: Um único worker service .NET 8 (`OctopusWorker`) executado via Generic Host. Ele seleciona `BaselineModeProfile` ou `IncrementalModeProfile` conforme `--mode`.
- **Camadas**: `Core.Domain` (entidades/valores), `Core.Application` (Baseline/Delta services, Run DTOs, SharedGitWorkflow, ExecutionLogExporter), `Core.Infrastructure` (SQL, Git, Configuração, Observabilidade).
- **Monitoramento**: Utiliza OpenTelemetry para observabilidade e Elasticsearch via Serilog para registro de logs.
- **Segurança**: Os identificadores de secrets são armazenadas em banco de dados ou kubernetes e obtidas via cofre de senha.

#### Backend

The backend is a Minimal API host whose modules (`Modules/*.cs`) register feature slices (dashboard, servers, databases, audit, triggers, reports, auth). Each module talks to kept `Octopus.Core` application services built on Dapper repositories.

| Layer | Responsibilities | Key Artifacts |
| --- | --- | --- |
| **Program Startup** | Builds configuration, wires Serilog, HttpClient factories, OpenID Connect, cookies, authorization policies, problem details, Swagger, and module registration. | `backend/src/Octopus.Api/Program.cs` |
| **Modules** | Extension methods that map HTTP verbs/resources to handlers. Modules hydrate application services (dashboard, servers, etc.), validate inputs, and shape DTO responses. | `backend/src/Octopus.Api/Modules/*.cs` (e.g., `ServersModule.cs`, `DatabasesModule.cs`, `AuditModule.cs`, `TriggerDdlModule.cs`, `ReportsModule.cs`, `DashboardModule.cs`, `AuthModule.cs`) |
| **Application Services** | Copied from `backend/src/Core/Application/*`. Provide orchestrations for servers, databases, triggers, audit, dashboard, and reports; rely on repositories and domain models in `Octopus.Core`. | `backend/src/Core/Application/Servers`, `/Databases`, `/Dashboard`, `/Audit`, `/Reports`, `/Triggers`, `/TriggersDdl` |
| **Domain Models** | Legacy types mirrored from `temp` describing metadata entities (server registrations, database profiles, audit rows). | `backend/src/Core/Domain/**` |
| **Infrastructure** | Dapper-based repositories, SQL connection factories, Conjur credential loaders, and options providers reused by the new API. | `backend/src/Core/Infrastructure/Data`, `/Options`, `/Security` |
| **Cross-Cutting** | Serilog sinks, FluentValidation, health checks, Conjur integrations, background jobs (if baseline/delta automation launches). | `backend/src/Octopus.Api/Infrastructure`, `backend/src/Core/Application/Options` |

#### Frontend

The SPA is a standalone Angular 18 app bootstrapped via `src/main.ts`. It fetches runtime config before calling `bootstrapApplication`, enabling per-environment API/Auth endpoints without rebuilds.

| Layer | Responsibilities | Key Artifacts |
| --- | --- | --- |
| **Bootstrap & Runtime Config** | Loads `assets/app-config.json` before `bootstrapApplication`, registers zone-coalesced change detection, router, HTTP client with `authInterceptor`, NgRx store/devtools, router-store, and Lucide icons. | `src/main.ts`, `src/app/app.config.ts`, `src/app/core/config/**` |
| **Shell & Navigation** | `ShellComponent` drives the layout (sidebar, header, theme toggle, auth prompts, system banner) while gating content based on `AuthService` signals. | `src/app/core/layout/shell/**`, `src/app/core/theme/theme.service.ts`, `src/app/core/auth/auth.service.ts` |
| **Routing & Lazy Features** | `app.routes.ts` lazy-loads each page as a standalone component and scopes its NgRx `provideState`/`provideEffects` providers so feature slices initialize only when the route is activated. | `src/app/app.routes.ts`, `src/app/features/*/pages/**` |
| **State & Facades (NgRx)** | Every domain registers a reducer, selectors, and functional effects under `features/*/store`. Facade services wrap the NgRx `Store`, expose selectors as Signals with `toSignal`, and provide command methods such as `ServersFacade.saveServer`. | `src/app/features/*/store/**`, `src/app/features/*/services/*-facade.service.ts`, `src/app/store/**` |
| **Domain API Gateways** | Strongly-typed HTTP services translate table filters to query params, call backend endpoints relative to `AppConfigService.apiBaseUrl()`, and throw domain-specific errors consumed by effects. | `src/app/features/*/services/*-api.service.ts`, `src/app/core/auth/auth.interceptor.ts` |
| **Cross-Cutting Core** | Runtime config, safe storage, auth flows, and theme synchronization remain centralized. `AppConfigService` merges defaults with runtime payloads, `AuthService` orchestrates login/logout/user info, and `ThemeService` persists theme preference via `SafeStorageService`. | `src/app/core/config/**`, `src/app/core/auth/**`, `src/app/core/services/safe-storage.service.ts`, `src/app/core/theme/**` |
| **Shared UI & Styling** | Standalone UI primitives (tables, dialogs, banner, versioning toggle) plus Tailwind tokens and CSS variables keep look-and-feel consistent. Icons are tree-shaken via `LucideAngularModule.pick`. | `src/app/shared/**`, `tailwind.config.ts`, `src/styles.css` |

##### Fluxo de Dependências
```
OctopusWorker (Program/Worker/Profiles)
        │
        ├── OctopusWorker.Services (CLI args → ExecutionRequest)
        │
        ├── Core.Application (BaselineService, DeltaService, Git workflows,
        │                     ExecutionLogExporter, TrackDdl repositories)
        │
        └── Core.Infrastructure (SqlConnectionFactory, GitCommandService,
                              ConfigurationModule, ObservabilityModule)
```
- O worker injeta os serviços via DI. Não há referência direta às camadas inferiores fora do Host.
- `ExecutionRequest` contém `Mode`, `OutputRoot`, `GitBranch`, `DryRun`, `ObjectsPerCommit`, `BatchSize`, além de listas de servidores/bases.
- `SchemaObjectDefinition` e `DatabaseEndpoint` vivem em `Core.Domain/Shared` e encapsulam todo dado vindo de `tbDadosConexaoServidor`, `tbDadosBase` e `track_DDL`, impedindo que `Core.Application` fale com `DbDataReader` ou objetos de infraestrutura.
- `MetadataSqlOptions` mora na infraestrutura (`Octopus:Sql`) e é exposta ao restante da solução via `IMetadataSqlOptionsProvider`. Toda credencial/timeout específico deve ser modelado como perfil dentro desse provider, nunca diretamente pela aplicação.
- `SharedGitWorkflow` centraliza `git init → remote add/set-url → config core.sparseCheckout true + .git/info/sparse-checkout → fetch --depth=1 origin <branch>:<branch> → checkout FETCH_HEAD → add --sparse . → push --set-upstream origin HEAD:<branch>`. Baseline/Delta apenas definem escopo (`baseline`/`delta`), mensagens e usuários.
- `ExecutionLogExporter` inclui `GitScope`, `GitBranch`, `GitProject` e metadados de dry-run/output, permitindo reconciliar execuções com pipelines GitLab.

##### Workflow – Modo Baseline
- `ExecutionRequestFactory` interpreta `--mode` (ou default). Para baseline, resolve `ObjectsPerCommit` a partir da CLI ou `OctopusWorker:Baseline`.
- `BaselineModeProfile` constrói `BaselineRunRequest` e registra em log `ObjectsPerCommit`, `OutputRoot`, `DryRun` antes de delegar ao `BaselineService`.
- `BaselineService`:
  - Usa `BaselineMetadataRepository` para obter servidores/bases (`tbDadosConexaoServidor`, `tbDadosBase`).
  - Stream de objetos via `SchemaScriptGenerator` → escreve `data/<servidor>/<base>/<schema>/<tipo>/<objeto>.sql`.
  - Git workflow (opcional quando `ObjectsPerCommit` > 0): delega ao `BaselineGitWorkflow`, que chama `SharedGitWorkflow` para executar `git init`, configurar `origin`, habilitar sparse-checkout (`core.sparseCheckout=true` + `.git/info/sparse-checkout` contendo a branch solicitada), `fetch --depth=1 origin <branch>:<branch>`, `checkout FETCH_HEAD`, `git add --sparse .`, `git commit -m "baseline(<base>): snapshot <timestamp>"` e `git push --set-upstream origin HEAD:<branch>`.
  - Sempre reinicia `track_DDL` após completar todas as bases.
- Logs e ExecutionLogExporter classificam a execução como `Mode = Baseline` e publicam `GitScope=baseline`, `GitBranch`, `GitProject` (lista csv quando múltiplos repositórios participam da mesma execução).

##### Workflow – Modo Incremental
- `ExecutionRequestFactory` valida `--mode=incremental` (ou alias) e exige `BatchSize` > 0 (CLI ou `OctopusWorker:Incremental`).
- `IncrementalModeProfile` constrói `DeltaRunRequest`, registra `BatchSize`, `OutputRoot`, `DryRun` e chama `DeltaService`.
- `DeltaService`:
  - `TrackDdlRepository` lê `track_DDL` pendentes, respeitando filtros `--servers` e o `BatchSize` informado.
  - `ChangeDetectionService` agrupa por servidor/base → cria lotes (`ChangeBatch`).
  - `DeltaScriptService` escreve apenas objetos alterados, mantendo layout idêntico ao baseline.
  - `DeltaGitWorkflow` reaproveita `SharedGitWorkflow`, portanto segue o mesmo pipeline `init → remote add/set-url → sparse-checkout da branch → fetch --depth=1 → checkout FETCH_HEAD → add --sparse . → commit delta(...) → push HEAD:<branch>`. O certificado CA temporário ainda é injetado por `GitCommandService`.
  - Após sucesso, marca as entradas de `track_DDL` como processadas.
- ExecutionLogExporter marca `Mode = Incremental` e inclui metadados `BatchesProcessed`, `DryRun`, `OutputRoot`.

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


## Implantação desenvolvimento

- Ambiente: Openshift - `https://api.ocp.desenv.com:6443`
- Namespace: octopus
- Resources: `service/backend`, `service/frontend`, `deployment/backend`, `deployment.apps/frontend`, `cronjob/octopus-incremental-cronjob-dev-clust01`, `cronjob/octopus-incremental-cronjob-dev-clust02`, ` cronjob/octopus-incremental-cronjob-dev-clust03`, `cronjob/octopus-incremental-cronjob-dev-clust04`, `cronjob/octopus-incremental-cronjob-dev-clust05`, `cronjob/octopus-incremental-cronjob-dev-clust06`, `job/octopus-baseline-job`, `route/backend`, `route/frontendesenv.com`
- Servidor de Banco de Dados: DESENV-SRVSQL.desenv.com
- Instâncias/Porta:  SQLCLUST01/1434, SQLCLUST02/1433, SQLCLUST03/50163, SQLCLUST04/50242, SQLCLUST05/50322, SQLCLUST06/53679
- URL Cybeark Conjur: https://conjur-follower-cyberark-conjur.apps.ocp.desenv.com
- URL Cybeark Identity: https://workforce.banpara.b.br/OAuth2/Authorize/octopus

## Implantação produção

Está pendente a implantação.

### Plano de Implantação

https://raw.githubusercontent.com/thiagofdso/banpara-skills/refs/heads/main/projeto-octopus/plano-implantacao.md
