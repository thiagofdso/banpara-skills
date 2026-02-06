## 🎯 Plano de Implantação do Projeto Octopus

### **📌 Contexto de Áreas Envolvidas**

**Áreas da DITEC participantes:**
- **SUGOT/GEARQ** - Arquitetura, elaboração de scripts, manuais, artefatos Kubernetes e documentação para mudanças
- **NUSIF (SSI)** - Criação de token GitLab, cadastro de aplicação no Identity, Conjur e configuração de grupos
- **GCONF** - Criação de grupos e subgrupos no GitLab
- **SUPRO/GEINS** - DBAs, criação de bases de dados, usuários e execução de scripts de permissões
- **SUPRO/GEFAB** - Implantações no OpenShift via ArgoCD, execução de pipelines Jenkins, aprovação de merge requests
- **SUGOT/GEMUL** - Gestão de mudanças, aprovação de cada etapa de implantação
- **SUSIS** - Stakeholder, decisão sobre bases alvos e acompanhamento do processo

**Processos de Implantação:**
- **OpenShift (ArgoCD):** Merge request no repositório do Octopus → Aprovação GEMUL → Aprovação GEFAB → Deploy automático
- **Namespace:** Ticket de criação de namespace antes do merge request
- **Baseline:** Pipeline no Jenkins
- **Incremental:** CronJobs implantados via ArgoCD

---

## 📋 **Visão Geral das Fases**

| Fase | Descrição | Duração Estimada | Áreas Envolvidas |
|------|-----------|------------------|------------------|
| **Fase 1** | Preparação de Infraestrutura de Dados e Credenciais | 2-3 semanas | GEINS, SSI, GCONF, GEARQ, SUSIS |
| **Fase 2** | Implantação de Aplicações (Frontend e Backend) | 1-2 semanas | GEARQ, GEFAB, GEMUL |
| **Fase 3** | Validação da Trigger de Auditoria (1 cluster) | 1-2 semanas | GEINS, GEARQ, GEMUL |
| **Fase 4** | Expansão da Trigger para Demais Clusters | 2-3 semanas | GEINS, GEARQ, GEMUL |
| **Fase 5** | Execução de Baseline (1 cluster + expansão) | 2-3 semanas | GEINS, GEARQ, GEFAB, SUSIS |
| **Fase 6** | Implantação de CronJobs Incrementais | 1-2 semanas | GEARQ, GEFAB, GEMUL |

**Duração Total Estimada:** 9-15 semanas

---

## 🔷 **Fase 1: Preparação de Infraestrutura de Dados e Credenciais**

### **Objetivo**
Criar toda a estrutura de banco de dados, usuários, permissões e configurar todas as credenciais necessárias no cofre de senhas antecipadamente.

---

### **1.1 Comunicação e Alinhamento Inicial**

**Responsável:** GEARQ

**Atividades:**
- ✅ Emitir comunicado oficial para SUSIS sobre início do projeto
- ✅ Agendar reunião com SUSIS para:
  - Apresentar o projeto Octopus
  - Definir bases de dados alvos para baseline inicial de validação
  - Estabelecer critérios de priorização de clusters
  - Alinhar expectativas e cronograma
- ✅ Comunicar GEINS, SSI, GCONF e GEFAB sobre início das atividades
- ✅ Documentar decisões e acordos da reunião

**Entregáveis:**
- Comunicado oficial enviado
- Ata de reunião com SUSIS
- Lista de bases alvos para validação inicial

---

### **1.2 Criação de Bases de Dados e Usuários**

**Responsável:** GEINS (DBAs)

**Atividades:**
- ✅ Criar base central de controle (OctopusSrvConexao) em servidor centralizado
- ✅ Criar base de auditoria (Octopus) em todos os 6 clusters
- ✅ Criar usuário de aplicação (gen_octopus) em todos os servidores/instâncias
- ✅ Conceder permissões básicas ao usuário em cada base criada
- ✅ Conceder permissões especiais nas bases system (model, master)
- ✅ Validar conectividade e permissões iniciais do usuário

**Mudança GEMUL:** 
- Tipo: Criação de bases de dados e usuários
- Impacto: Baixo (não afeta operação)
- Documentação: Manuais, Scripts e documento para criação de usuário e banco de dados
---

### **1.3 Automação de Permissões em Todas as Bases**

**Responsável:** GEARQ (elaboração) + GEINS (execução)

**Contexto:** Devido ao grande número de bases de dados, é necessário automatizar o processo de concessão de permissões.

**Atividades:**

**Etapa 1 - Coleta de Bases (GEARQ elabora, GEINS executa):**
- ✅ Criar script de coleta de todos os bancos de dados de cada cluster
- ✅ Executar script em cada um dos 6 clusters
- ✅ Consolidar lista completa de bases de dados por cluster
- ✅ Revisar e validar lista (excluir bases de sistema ou temporárias, se necessário)

**Etapa 2 - Geração de Script de Permissões (GEARQ):**
- ✅ Desenvolver script que gera comandos GRANT para cada base coletada
- ✅ Script deve gerar comandos para:
  - Permissões de leitura (SELECT) em todas as bases
  - Permissões específicas conforme necessidade do Octopus
- ✅ Organizar script por cluster para facilitar execução

**Etapa 3 - Execução de Permissões (GEINS):**
- ✅ Revisar scripts gerados
- ✅ Executar scripts de GRANT em cada cluster
- ✅ Validar permissões concedidas
- ✅ Documentar bases processadas e eventuais exceções

**Exemplo de Fluxo:**
```
Script 1 (Coleta): Lista todas as bases do Cluster 1
↓
Script 2 (Geração): Gera GRANTs para gen_octopus em cada base listada
↓
Script 3 (Execução): Executa GRANTs no Cluster 1
↓
Repetir para Clusters 2-6
```

**Mudança GEMUL:** 
- Tipo: Concessão de permissões de usuário em bases de dados
- Impacto: Baixo
- Documentação: Scripts, manuais e solcitação de permissão de banco de dados
---

### **1.4 Criação de Grupos e Subgrupos no GitLab**

**Responsável:** GCONF

**Atividades:**
- ✅ Criar grupo principal do projeto no GitLab
- ✅ Criar subgrupos necessários para organização de repositórios (por cluster, por ambiente, etc.)
- ✅ Configurar políticas de proteção de branches
- ✅ Configurar estrutura de permissões iniciais
- ✅ Documentar estrutura criada

**Estrutura Sugerida:**
```
banco-de-dados/
├── sqlclust01/
├── sqlclust02/
├── sqlclust03/
├── sqlclust04/
├── sqlclust05/
└── sqlclust06/
```

---

### **1.5 Criação de Token de Aplicação GitLab**

**Responsável:** NUSIF (SSI)

**Atividades:**
- ✅ Utilizar credenciais do usuário de rede gen_Octopus (já existente)
- ✅ Criar token de aplicação no GitLab com permissões de nível **API**
- ✅ Permissão API permite criação dinâmica de repositórios
- ✅ Configurar escopo completo necessário para o Octopus
- ✅ Documentar token criado (ID, escopo, expiração)
- ✅ Entregar informações para cadastro no Conjur

**Escopo do Token:**
- `api` - Acesso completo à API para criação dinâmica de repositórios
- `read_repository` - Leitura de repositórios
- `write_repository` - Escrita em repositórios

---

### **1.6 Cadastro de Credenciais no Cofre de Senhas**

**Responsável:** NUSIF (SSI) em colaboração com GEARQ

**Atividades:**
- ✅ Criar políticas no Conjur para o namespace do octopus no OpenShift
- ✅ Cadastrar token do GitLab no cofre
- ✅ Cadastrar credenciais do usuário de rede gen_octopus
- ✅ Cadastrar credenciais do usuário gen_octopus para cada servidor/instância SQL Server (6 clusters)
- ✅ Criar manifesto da secret no Gitlab
- ✅ **Documentar IDs de todas as credenciais criadas no Conjur** (serão usados nos parâmetros dos artefatos)

**Entregável Crítico:**
- Manifesto de secret com as credenciais e apontamentos no Gitlab

---

### **1.7 Configuração de Autenticação (CyberArk Identity)**

**Responsável:** NUSIF (SSI) com apoio de GEARQ

**Atividades GEARQ (definição):**
- ✅ Definir papéis/roles necessários no sistema:
  - Administrador (acesso total)
  - AUDIN (Visualização total)
  - Operação (visualização apenas)
- ✅ Criar arquivos JSON de configuração de permissões (1 arquivo por papel)
- ✅ Commitar arquivos no repositório do GitLab
- ✅ Documentar estrutura de permissões

**Atividades SSI (execução):**
- ✅ Registrar aplicação Octopus no CyberArk Identity (ambiente de produção)
- ✅ Configurar Client ID e Client Secret
- ✅ Definir redirect URIs para produção
- ✅ Configurar escopos OAuth2/OIDC
- ✅ Criar grupos de usuários no Identity conforme papéis definidos
- ✅ Dar acesso aos grupos na aplicação
- ✅ Aplicar configurações de permissões via arquivos JSON do GitLab

**Exemplo de Estrutura de Permissões (JSON):**
```json
{
  "dashboard": {
    "visualizacao": true,
    "atualização": true
  },
  "servidor":{
    "consulta": true,
    "criacao": true,
    "exclusao": true,
    "alteracao": true
  },
  "banco-de-dados"{
    "consulta": true,
    "criacao": true,
    "exclusao": true,
    "alteracao": true
  },
  "auditoria": {
    "visualizacao": true
  },
  "trigger": {
    "visualizacao": true
  },
  "relatorio": {
    "visualizacao": true
  }
}
```

---

### **1.8 Atualização de Parâmetros dos Artefatos**

**Responsável:** GEARQ

**Contexto:** Os artefatos de produção diferem dos de desenvolvimento apenas em parâmetros de ambiente (IDs de credenciais, URLs, configurações específicas).

**Atividades:**
- ✅ Revisar todos os artefatos Kubernetes (Deployments, ConfigMaps, CronJobs, etc.)
- ✅ Atualizar parâmetros para produção:
  - IDs de credenciais do Conjur (usando documentação da atividade 1.6)
  - URLs de serviços (GitLab, Identity, APIs)
  - Configurações de recursos (CPU, memória, réplicas)
  - Configurações de logging e telemetria
- ✅ Validar sintaxe dos arquivos YAML
- ✅ Commitar atualizações no repositório
- ✅ Preparar documentação de parâmetros para processo de mudança

**Artefatos a atualizar:**
- ConfigMaps (backend, frontend, worker)
- Secrets (referências ao Conjur)
- Deployments (backend, frontend)
- CronJobs (incrementais por cluster)
- Services e Routes

---

### **Entregáveis da Fase 1:**
- ✅ Comunicado oficial enviado para SUSIS
- ✅ Ata de reunião com bases alvos definidas
- ✅ Bases de dados criadas em todos os clusters
- ✅ Usuários criados com permissões configuradas (automatizadas)
- ✅ Grupos e subgrupos criados no GitLab
- ✅ Token GitLab criado com permissão API
- ✅ Todas as credenciais cadastradas no Conjur com IDs documentados
- ✅ Autenticação configurada no Identity com grupos e permissões
- ✅ Arquivos JSON de permissões commitados
- ✅ Artefatos Kubernetes atualizados para produção

**Critério de Sucesso:**
- Todas as credenciais acessíveis via Conjur
- Conectividade validada entre usuários e bases
- Token GitLab funcional com permissão API
- IDs de credenciais documentados para uso nos artefatos
- Grupos e permissões configurados no Identity

---

## 🔷 **Fase 2: Implantação de Aplicações no OpenShift**

### **Objetivo**
Implantar Frontend e Backend no OpenShift via ArgoCD, seguindo o processo de merge request e aprovações da GEMUL e GEFAB.

---

### **2.1 Preparação de Documentação para Mudança**

**Responsável:** GEARQ

**Atividades:**
- ✅ Preparar documentação completa para processo de mudança GEMUL:
  - Objetivo da mudança
  - Descrição técnica da implantação
  - Artefatos a serem implantados (listar todos os YAMLs)
  - Impacto e riscos
  - Plano de rollback
  - Procedimentos de validação pós-implantação
- ✅ Anexar artefatos Kubernetes atualizados
- ✅ Incluir manual de validação pós-deploy
- ✅ Documentar parâmetros e configurações

---

### **2.2 Criação de Namespace no OpenShift**

**Responsável:** GEFAB (execução) com solicitação de GEARQ

**Atividades:**
- ✅ GEARQ: Abrir ticket solicitando criação de namespace para o Octopus
- ✅ GEARQ: Especificar configurações necessárias (resource quotas, limit ranges, network policies)
- ✅ GEFAB: Criar namespace no cluster de produção
- ✅ GEFAB: Configurar políticas e limitações
- ✅ GEFAB: Configurar RBAC (Service Accounts, Roles, RoleBindings)
- ✅ GEFAB: Confirmar criação e disponibilizar namespace

**Mudança GEMUL:** 
- Tipo: Criação de namespace no OpenShift
- Impacto: Baixo

---

### **2.3 Criação de Merge Request para Implantação**

**Responsável:** GEARQ (criação) + GEFAB (aprovação e deploy)

**Atividades:**

**GEARQ:**
- ✅ Criar branch com artefatos finalizados
- ✅ Abrir merge request no repositório do Octopus
- ✅ Incluir descrição detalhada das mudanças
- ✅ Vincular documentação da mudança GEMUL
- ✅ Notificar GEFAB sobre MR criado

**Processo de Aprovação:**
1. GEARQ abre mudança na GEMUL
2. GEMUL analisa e aprova mudança
3. GEARQ notifica GEFAB sobre aprovação
4. GEFAB revisa merge request
5. GEFAB aprova MR
6. ArgoCD realiza deploy automático

**GEFAB (após aprovação GEMUL):**
- ✅ Revisar merge request
- ✅ Validar artefatos Kubernetes
- ✅ Aprovar merge request
- ✅ Acompanhar deploy via ArgoCD

**Mudança GEMUL:** 
- Tipo: Implantação de aplicações (Frontend e Backend) no OpenShift
- Impacto: Baixo (novos serviços)

---

### **2.4 Deploy via ArgoCD**

**Responsável:** GEFAB (monitoramento)

**Atividades:**
- ✅ ArgoCD detecta mudanças no repositório
- ✅ ArgoCD sincroniza e aplica artefatos no namespace
- ✅ GEFAB monitora logs de deploy
- ✅ GEFAB valida criação de recursos:
  - Deployments (Backend e Frontend)
  - Services
  - Routes
  - ConfigMaps
  - Secrets
- ✅ GEFAB valida health checks das aplicações

---

### **2.5 Validação Pós-Implantação**

**Responsável:** GEARQ com apoio de GEFAB

**Atividades:**
- ✅ Validar acesso ao Frontend via navegador (URL da Route)
- ✅ Testar autenticação via CyberArk Identity
- ✅ Validar acesso ao Backend (health checks, endpoints de API)
- ✅ Validar conectividade Backend → Base central (OctopusSrvConexao)
- ✅ Validar recuperação de credenciais via Conjur
- ✅ Testar funcionalidades básicas da interface
- ✅ Validar logs e métricas

---

### **2.6 Configuração de Servidores via Frontend**

**Responsável:** GEARQ com apoio de SSI

**Atividades:**
- ✅ Acessar interface web do Octopus
- ✅ Cadastrar informações dos 6 clusters via formulário do frontend:
  - Nome do servidor/instância
  - Porta de conexão
  - Referência à credencial no Conjur (ID)
  - Agrupamento por cluster



**Nota:** A população da tabela de banco de dados será feita automaticamente pelos jobs do Octopus (não requer cadastro manual).

---

### **Entregáveis da Fase 2:**
- ✅ Documentação de mudança preparada e aprovada pela GEMUL
- ✅ Namespace criado no OpenShift
- ✅ Merge request criado, aprovado e merged
- ✅ Frontend e Backend implantados via ArgoCD
- ✅ Aplicações operacionais e acessíveis
- ✅ Servidores SQL cadastrados via frontend
- ✅ Conectividade configurada

**Critério de Sucesso:**
- Usuários conseguem acessar o sistema via navegador
- Backend responde às requisições da API
- Autenticação via Identity funcional
- Integração com Conjur recuperando credenciais corretamente
- Interface exibe servidores configurados e status de conexão

---

## 🔷 **Fase 3: Validação da Trigger de Auditoria (1 Cluster)**

### **Objetivo**
Implantar a trigger de auditoria DDL em **1 cluster piloto** e acompanhar o comportamento por **1 semana** antes de expandir.

---

### **3.1 Seleção do Cluster Piloto**

**Responsável:** GEARQ com validação de GEINS e SUSIS

**Atividades:**
- ✅ Realizar reunião com GEINS e SUSIS para selecionar cluster piloto
- ✅ Critérios de seleção:
  - Menor criticidade operacional
  - Bases de dados representativas (variedade de objetos)
  - Bases definidas na Fase 1 como alvos de validação
- ✅ Documentar decisão e justificativa
- ✅ Comunicar stakeholders sobre início do piloto

---

### **3.2 Elaboração de Script da Trigger**

**Responsável:** GEARQ

**Atividades:**
- ✅ Preparar script de criação da trigger de nível de servidor
- ✅ Preparar script de validação pós-implantação
- ✅ Preparar script de remoção (rollback)
- ✅ Documentar funcionamento e filtros da trigger
- ✅ Incluir scripts na documentação de mudança

---

### **3.3 Implantação da Trigger no Cluster Piloto**

**Responsável:** GEINS (execução) com scripts de GEARQ

**Atividades:**
- ✅ Revisar script de criação
- ✅ Executar script no servidor/instância do cluster piloto
- ✅ Validar criação da trigger
- ✅ Executar script de validação (comandos DDL de teste)
- ✅ Confirmar registros na tabela de auditoria (track_ddl)
- ✅ Validar filtros de eventos

**Mudança GEMUL:** 
- Tipo: Implantação de trigger de auditoria em cluster piloto
- Impacto: Médio (captura eventos DDL)
- Plano de Rollback: Script de remoção da trigger

---

### **3.4 Período de Observação (1 Semana)**

**Responsável:** GEINS e GEARQ

**Atividades:**
- ✅ Monitorar logs de erro do SQL Server
- ✅ Acompanhar crescimento da tabela track_ddl
- ✅ Validar performance do servidor (comparar métricas antes/depois)
- ✅ Coletar feedback dos DBAs sobre comportamento operacional
- ✅ Analisar eventos capturados versus eventos esperados
- ✅ Verificar se há eventos indesejados ou falsos positivos
- ✅ Documentar observações diárias

**Métricas de Acompanhamento:**
- Volume de eventos capturados por dia
- Tempo de resposta de comandos DDL (antes vs depois)
- Impacto em performance (CPU, memória, I/O)
- Taxa de crescimento da tabela track_ddl
- Incidentes ou erros relacionados à trigger

---

### **3.5 Avaliação e Go/No-Go para Expansão**

**Responsável:** GEARQ com participação de GEINS e GEMUL

**Atividades:**
- ✅ Consolidar relatório de observação de 1 semana
- ✅ Analisar métricas coletadas
- ✅ Realizar reunião de avaliação com stakeholders
- ✅ Decisão de expansão ou ajustes necessários
- ✅ Documentar lições aprendidas e recomendações

**Critérios para Go (Expansão):**
- Trigger operando sem erros críticos
- Impacto de performance aceitável (< 5% de degradação)
- Eventos capturados corretamente e conforme esperado
- Sem incidentes operacionais reportados
- Aprovação de GEINS, GEARQ e GEMUL

**Em caso de No-Go:**
- Identificar problemas específicos
- GEARQ ajusta scripts se necessário
- GEINS aplica correções
- Repetir período de observação

---

### **Entregáveis da Fase 3:**
- ✅ Cluster piloto selecionado e documentado
- ✅ Scripts elaborados (criação, validação, rollback)
- ✅ Trigger implantada no cluster piloto
- ✅ Relatório de acompanhamento de 1 semana com métricas
- ✅ Análise de impacto e performance
- ✅ Decisão documentada de Go/No-Go para expansão

**Critério de Sucesso:**
- Trigger operando sem impacto operacional significativo
- Eventos DDL capturados corretamente
- Performance do servidor mantida (< 5% degradação)
- Aprovação para expansão obtida

---

## 🔷 **Fase 4: Expansão da Trigger para os Demais Clusters**

### **Objetivo**
Expandir a implantação da trigger de auditoria para os **5 clusters restantes** de forma gradual e controlada.

---

### **4.1 Planejamento da Expansão**

**Responsável:** GEARQ com apoio de GEINS

**Atividades:**
- ✅ Definir ordem de implantação dos clusters restantes (por criticidade)
- ✅ Estabelecer janelas de implantação (horários de menor carga)
- ✅ Preparar cronograma detalhado
- ✅ Comunicar cronograma para GEINS, GEMUL e stakeholders

**Sugestão de Ordem (do menor para o maior criticidade):**
1. Cluster 2 (semana 1)
2. Cluster 3 (semana 1)
3. Cluster 4 (semana 2)
4. Cluster 5 (semana 2)
5. Cluster 6 (semana 3)

---

### **4.2 Implantação por Cluster**

**Responsável:** GEINS (execução) com scripts de GEARQ

**Atividades (repetir para cada cluster):**
- ✅ GEARQ: Abrir mudança na GEMUL para o cluster específico
- ✅ GEINS: Executar script de criação da trigger
- ✅ GEINS: Validar criação e executar testes iniciais
- ✅ GEINS: Confirmar registros na track_ddl
- ✅ GEARQ + GEINS: Monitorar por 24-48h antes do próximo cluster
- ✅ GEARQ: Documentar implantação e observações

**Mudança GEMUL (para cada cluster):** 
- Tipo: Implantação de trigger de auditoria
- Impacto: Médio
- Plano de Rollback: Remoção da trigger via script

---

### **4.3 Monitoramento Consolidado**

**Responsável:** GEARQ com apoio de GEINS

**Atividades:**
- ✅ Acompanhar métricas de todos os clusters com trigger ativa
- ✅ Comparar comportamento entre clusters
- ✅ Identificar padrões, anomalias ou diferenças
- ✅ Ajustar processos se necessário
- ✅ Consolidar relatório de expansão

---

### **Entregáveis da Fase 4:**
- ✅ Trigger implantada em todos os 6 clusters
- ✅ Relatório de implantação por cluster (observações, métricas, incidentes)
- ✅ Métricas consolidadas de performance de todos os clusters
- ✅ Sistema de auditoria operacional em toda a infraestrutura

**Critério de Sucesso:**
- Todos os 6 clusters com trigger ativa e funcional
- Eventos DDL sendo capturados em todos os servidores
- Sem incidentes operacionais críticos
- Tabelas de auditoria populadas corretamente em todos os clusters
- Performance mantida dentro dos limites aceitáveis

---

## 🔷 **Fase 5: Execução de Baseline (1 Cluster + Expansão)**

### **Objetivo**
Executar o processo de Baseline via pipeline Jenkins para versionar todos os objetos existentes, primeiro em **1 cluster piloto**, validar e depois expandir para os **5 clusters restantes**.

---

### **5.1 Preparação do Pipeline Jenkins**

**Responsável:** GEARQ (elaboração) + GEFAB (configuração no Jenkins)

**Atividades GEARQ:**
- ✅ Desenvolver pipeline Jenkins para execução de Baseline
- ✅ Parametrizar pipeline para aceitar cluster específico
- ✅ Incluir etapas de validação e logging
- ✅ Preparar documentação do pipeline
- ✅ Commitar código do pipeline no repositório

**Atividades GEFAB:**
- ✅ Configurar pipeline no Jenkins de produção
- ✅ Configurar credenciais necessárias
- ✅ Validar integração com Conjur
- ✅ Configurar notificações (sucesso/falha)
- ✅ Testar execução em ambiente de teste (se disponível)

---

### **5.2 Seleção de Cluster Piloto e Bases Alvos**

**Responsável:** GEARQ com validação de SUSIS

**Atividades:**
- ✅ Reunir com SUSIS para confirmar bases alvos de validação
- ✅ Selecionar cluster piloto (preferencialmente o mesmo da Fase 3)
- ✅ Definir subconjunto de bases para primeira execução (se necessário limitar escopo)
- ✅ Documentar bases alvos e critérios de validação
- ✅ Comunicar início da execução de Baseline

---

### **5.3 Execução de Baseline no Cluster Piloto**

**Responsável:** GEFAB (execução) com monitoramento de GEARQ

**Atividades:**
- ✅ GEFAB: Executar pipeline Jenkins para o cluster piloto
- ✅ GEARQ: Monitorar logs de execução em tempo real
- ✅ GEARQ: Validar processamento de objetos
- ✅ GEARQ: Verificar commits criados no GitLab (branch baseline)
- ✅ GEARQ: Validar estrutura de pastas e arquivos no repositório
- ✅ GEARQ: Confirmar registros de auditoria na base central
- ✅ GEINS: Validar que todos os objetos das bases alvos foram versionados

**Mudança GEMUL:** 
- Tipo: Execução de processo de versionamento (Baseline) em cluster piloto
- Impacto: Baixo (operação de leitura)

---

### **5.4 Validação e Análise do Baseline Piloto**

**Responsável:** GEARQ com apoio de GEINS e SUSIS

**Atividades:**
- ✅ Comparar objetos versionados versus objetos existentes nas bases
- ✅ Validar completude do versionamento
- ✅ Analisar logs de erro (se houver)
- ✅ Validar formatação e organização dos arquivos no GitLab
- ✅ Validar que população da tabela de bancos de dados ocorreu dinamicamente
- ✅ Realizar reunião de validação com SUSIS
- ✅ Decisão de Go/No-Go para expansão

**Critérios para Go (Expansão):**
- 100% dos objetos das bases alvos versionados com sucesso
- Estrutura de repositório correta e organizada
- Sem erros críticos no processo
- Auditoria registrada corretamente
- Aprovação de SUSIS e GEINS

---

### **5.5 Expansão do Baseline para os Demais Clusters**

**Responsável:** GEFAB (execução) com monitoramento de GEARQ

**Atividades:**
- ✅ Definir ordem de execução dos clusters restantes
- ✅ GEFAB: Executar pipeline Jenkins para cada cluster de forma sequencial ou em lotes
- ✅ GEARQ: Monitorar execução de cada pipeline
- ✅ GEARQ: Validar versionamento em cada cluster
- ✅ GEARQ: Documentar estatísticas por cluster (objetos versionados, tempo de execução, erros)

**Sugestão de Execução:**
- **Lote 1:** Clusters 2 e 3 (se infraestrutura permitir execução simultânea)
- **Lote 2:** Clusters 4 e 5
- **Lote 3:** Cluster 6

**Mudança GEMUL (para cada lote ou cluster):** 
- Tipo: Execução de Baseline em clusters de produção
- Impacto: Baixo (operação de leitura em horário de baixa carga)

---

### **5.6 Consolidação e Validação Final**

**Responsável:** GEARQ

**Atividades:**
- ✅ Consolidar relatório de Baseline de todos os clusters
- ✅ Validar integridade do repositório GitLab (todos os objetos de todos os clusters)
- ✅ Revisar logs de auditoria consolidados
- ✅ Gerar estatísticas gerais:
  - Total de objetos versionados
  - Distribuição por tipo de objeto (tabelas, views, procedures, etc.)
  - Tempo total de execução
  - Taxa de sucesso
- ✅ Comunicar conclusão do Baseline para stakeholders

---

### **Entregáveis da Fase 5:**
- ✅ Pipeline Jenkins configurado e funcional
- ✅ Baseline executado com sucesso em todos os 6 clusters
- ✅ Repositório GitLab com versionamento completo de todos os objetos
- ✅ Tabelas de banco de dados populadas dinamicamente pelo processo
- ✅ Relatório consolidado com estatísticas e métricas
- ✅ Auditoria completa registrada na base central

**Critério de Sucesso:**
- Todos os objetos de banco de dados dos 6 clusters versionados
- Repositório GitLab organizado, completo e acessível
- Sem erros críticos no processo
- Tabelas populadas automaticamente sem intervenção manual
- Auditoria registrada para todas as operações

---

## 🔷 **Fase 6: Implantação de CronJobs Incrementais**

### **Objetivo**
Implantar CronJobs via ArgoCD para execução **diária** do processo Incremental (versionamento de novos objetos e alterações) em todos os 6 clusters.

---

### **6.1 Elaboração de Artefatos dos CronJobs**

**Responsável:** GEARQ

**Atividades:**
- ✅ Criar artefatos Kubernetes para CronJobs (1 por cluster, total de 6)
- ✅ Configurar agendamento para execução diária
- ✅ Parametrizar cada CronJob com cluster específico
- ✅ Configurar recursos (CPU, memória) apropriados
- ✅ Configurar política de concorrência (Forbid)
- ✅ Configurar histórico de Jobs (últimos 3 sucessos e 3 falhas)
- ✅ Atualizar parâmetros com IDs de credenciais do Conjur
- ✅ Commitar artefatos no repositório

**Sugestão de Agendamento Diário:**
- **Cluster 1:** 02:00
- **Cluster 2:** 02:30
- **Cluster 3:** 03:00
- **Cluster 4:** 03:30
- **Cluster 5:** 04:00
- **Cluster 6:** 04:30

---

### **6.2 Preparação de Documentação para Mudança**

**Responsável:** GEARQ

**Atividades:**
- ✅ Preparar documentação completa para processo de mudança GEMUL:
  - Descrição dos CronJobs
  - Agendamento e justificativa dos horários
  - Impacto operacional
  - Plano de rollback (desativação de CronJobs)
  - Procedimentos de validação
- ✅ Anexar artefatos Kubernetes
- ✅ Incluir manual de monitoramento

---

### **6.3 Criação de Merge Request**

**Responsável:** GEARQ (criação) + GEFAB (aprovação e deploy)

**Atividades:**

**GEARQ:**
- ✅ Criar branch com artefatos dos CronJobs
- ✅ Abrir merge request no repositório do Octopus
- ✅ Incluir descrição detalhada
- ✅ Vincular documentação da mudança GEMUL

**Processo de Aprovação:**
1. GEARQ abre mudança na GEMUL
2. GEMUL analisa e aprova mudança
3. GEARQ notifica GEFAB sobre aprovação
4. GEFAB revisa e aprova merge request
5. ArgoCD realiza deploy dos CronJobs

**GEFAB:**
- ✅ Revisar merge request
- ✅ Validar artefatos
- ✅ Aprovar merge request
- ✅ Acompanhar deploy via ArgoCD

**Mudança GEMUL:** 
- Tipo: Implantação de CronJobs para processamento incremental
- Impacto: Baixo (execução em horário de baixa carga)

---

### **6.4 Deploy via ArgoCD e Ativação**

**Responsável:** GEFAB

**Atividades:**
- ✅ ArgoCD sincroniza e aplica CronJobs no namespace
- ✅ GEFAB valida criação dos 6 CronJobs
- ✅ GEFAB confirma agendamento configurado
- ✅ Aguardar primeira execução agendada

---

### **6.5 Monitoramento da Primeira Execução**

**Responsável:** GEARQ com apoio de GEFAB

**Atividades:**
- ✅ Monitorar logs da primeira execução de cada CronJob
- ✅ Validar processamento de eventos incrementais
- ✅ Verificar commits no GitLab (branch incremental)
- ✅ Validar registros de auditoria
- ✅ Confirmar que não há erros críticos

---

### **6.6 Testes de Captura Incremental**

**Responsável:** GEINS com apoio de GEARQ

**Atividades:**
- ✅ Executar operações DDL de teste em cada cluster:
  - **Criação:** `CREATE TABLE`, `CREATE VIEW`, `CREATE PROCEDURE`
  - **Alteração:** `ALTER TABLE`, `ALTER PROCEDURE`, `ALTER FUNCTION`
  - **Remoção:** `DROP TABLE`, `DROP VIEW`, `DROP FUNCTION`
- ✅ Validar captura pela trigger na tabela track_ddl
- ✅ Aguardar próxima execução do CronJob (execução diária)
- ✅ Validar processamento pelo Worker
- ✅ Validar versionamento no GitLab
- ✅ Validar registro de auditoria na base central
- ✅ Confirmar que objetos removidos foram excluídos do repositório

---

### **6.7 Documentação Operacional e Handover**

**Responsável:** GEARQ

**Atividades:**
- ✅ Documentar procedimentos operacionais:
  - Execução manual de CronJob via Jenkins (se necessário processar fora do agendamento)
  - Troubleshooting de falhas comuns
  - Interpretação de logs e métricas
  - Procedimentos de rollback (desativação)
  - Procedimentos de reprocessamento
- ✅ Criar runbook para equipe de operações
- ✅ Preparar materiais de treinamento
- ✅ Realizar sessões de treinamento para:
  - Equipe GEFAB (operação de pipelines e CronJobs)
  - DBAs da GEINS (uso do sistema, interpretação de auditoria)
  - Equipe de suporte
- ✅ Transferir responsabilidade operacional para SUPRO/GEFAB

---

### **6.8 Comunicado de Conclusão**

**Responsável:** GEARQ

**Atividades:**
- ✅ Emitir comunicado oficial de conclusão do projeto
- ✅ Informar stakeholders (DITEC, SUSIS, GEINS, GEFAB)
- ✅ Disponibilizar documentação completa
- ✅ Comunicar canais de suporte e pontos de contato

---

### **Entregáveis da Fase 6:**
- ✅ 6 CronJobs implantados via ArgoCD e operacionais (1 por cluster)
- ✅ Execução diária validada e funcionando
- ✅ Testes de captura incremental bem-sucedidos
- ✅ Documentação operacional completa (procedimentos, runbooks, troubleshooting)
- ✅ Treinamento realizado para todas as equipes envolvidas
- ✅ Handover para equipe de operações concluído
- ✅ Comunicado oficial de conclusão emitido

**Critério de Sucesso:**
- CronJobs executando diariamente sem falhas
- Eventos incrementais (CREATE, ALTER, DROP) capturados e versionados corretamente
- Equipe de operações (GEFAB) treinada e apta a gerenciar o sistema
- Documentação completa, acessível e compreensível
- Sistema em operação estável e monitorado

---

## 📊 **Indicadores de Sucesso do Projeto**

### **Métricas de Implantação:**
- ✅ 100% dos 6 clusters com trigger de auditoria operacional
- ✅ 100% dos objetos de banco de dados versionados (Baseline)
- ✅ 6 CronJobs executando diariamente com taxa de sucesso > 95%
- ✅ Tempo de resposta de comandos DDL sem degradação significativa (< 5%)
- ✅ 0 incidentes críticos de segurança ou perda de dados
- ✅ 100% das bases de dados populadas automaticamente

### **Métricas Operacionais (pós-implantação):**
- Taxa de sucesso de execuções incrementais diárias
- Tempo médio de execução de Baseline/Incremental
- Volume de objetos versionados por dia
- Taxa de erro de versionamento
- Disponibilidade do sistema (Frontend/Backend)
- Crescimento do repositório GitLab

---

## 🔄 **Gestão de Riscos**

### **Principais Riscos e Mitigações:**

| Risco | Impacto | Probabilidade | Mitigação |
|-------|---------|---------------|-----------|
| Trigger causar degradação de performance | Alto | Médio | Piloto com 1 cluster + monitoramento de 1 semana antes de expansão |
| Falha na integração com Conjur | Alto | Baixo | Testes antecipados na Fase 1, credenciais validadas antes de uso |
| Volume excessivo de eventos DDL | Médio | Médio | Filtros configurados na trigger, monitoramento de crescimento da track_ddl |
| Falha no push para GitLab | Médio | Baixo | Retry logic implementado no Worker, validação de token com permissão API |
| Baseline com tempo de execução longo | Médio | Médio | Execução via pipeline Jenkins em horário de baixa carga, execução por lotes |
| Resistência de DBAs à mudança | Baixo | Médio | Comunicação antecipada, treinamento, envolvimento desde a Fase 1 |
| Atraso nas aprovações GEMUL | Médio | Médio | Planejamento antecipado, documentação completa, comunicação proativa |
| Falha na população automática de bases | Médio | Baixo | Validação durante baseline piloto, logs detalhados para troubleshooting |

---

## ✅ **Checklist Consolidado de Implantação**

### **Fase 1: Preparação**
- [X] Comunicado oficial enviado para SUSIS
- [ ] Reunião com SUSIS realizada e bases alvos definidas
- [ ] Bases de dados criadas (OctopusSrvConexao + Octopus em 6 clusters)
- [ ] Usuários gen_Octopus criados
- [ ] Scripts de coleta de bases executados
- [ ] Scripts de permissões gerados e executados
- [ ] Grupos e subgrupos criados no GitLab (GCONF)
- [ ] Token GitLab criado com permissão API (SSI)
- [ ] Todas as credenciais cadastradas no Conjur (SSI)
- [ ] IDs de credenciais documentados
- [ ] Aplicação cadastrada no Identity (SSI)
- [ ] Grupos e permissões configurados no Identity (SSI)
- [ ] Arquivos JSON de permissões commitados (GEARQ)
- [ ] Artefatos Kubernetes atualizados para produção (GEARQ)

### **Fase 2: Aplicações**
- [ ] Documentação de mudança preparada (GEARQ)
- [ ] Ticket de criação de namespace aberto (GEARQ)
- [ ] Namespace criado no OpenShift (GEFAB)
- [ ] Merge request criado (GEARQ)
- [ ] Mudança aprovada pela GEMUL
- [ ] Merge request aprovado pela GEFAB
- [ ] Deploy via ArgoCD concluído
- [ ] Backend operacional
- [ ] Frontend operacional
- [ ] Validação pós-implantação concluída
- [ ] Servidores SQL cadastrados via frontend (GEARQ)

### **Fase 3: Validação Trigger (1 Cluster)**
- [ ] Cluster piloto selecionado e comunicado
- [ ] Scripts de trigger elaborados (GEARQ)
- [ ] Mudança aprovada pela GEMUL
- [ ] Trigger implantada no cluster piloto (GEINS)
- [ ] Monitoramento de 1 semana concluído
- [ ] Relatório de observação consolidado
- [ ] Análise de métricas realizada
- [ ] Aprovação para expansão obtida (Go decision)

### **Fase 4: Expansão Trigger (5 Clusters)**
- [ ] Planejamento de expansão definido
- [ ] Trigger implantada no Cluster 2 (GEINS)
- [ ] Trigger implantada no Cluster 3 (GEINS)
- [ ] Trigger implantada no Cluster 4 (GEINS)
- [ ] Trigger implantada no Cluster 5 (GEINS)
- [ ] Trigger implantada no Cluster 6 (GEINS)
- [ ] Relatório de expansão consolidado

### **Fase 5: Baseline**
- [ ] Pipeline Jenkins elaborado (GEARQ)
- [ ] Pipeline configurado no Jenkins (GEFAB)
- [ ] Bases alvos confirmadas com SUSIS
- [ ] Mudança aprovada pela GEMUL
- [ ] Baseline executado no cluster piloto (GEFAB)
- [ ] Validação do piloto aprovada
- [ ] Baseline executado nos Clusters 2 e 3 (GEFAB)
- [ ] Baseline executado nos Clusters 4 e 5 (GEFAB)
- [ ] Baseline executado no Cluster 6 (GEFAB)
- [ ] Tabelas de bases populadas automaticamente
- [ ] Relatório consolidado gerado

### **Fase 6: CronJobs Incrementais**
- [ ] Artefatos de CronJobs elaborados (GEARQ)
- [ ] Documentação de mudança preparada (GEARQ)
- [ ] Merge request criado (GEARQ)
- [ ] Mudança aprovada pela GEMUL
- [ ] Merge request aprovado pela GEFAB
- [ ] 6 CronJobs implantados via ArgoCD
- [ ] Primeira execução monitorada e validada
- [ ] Testes de captura incremental realizados (GEINS + GEARQ)
- [ ] Documentação operacional entregue
- [ ] Runbooks criados
- [ ] Treinamento realizado (GEFAB, GEINS, Suporte)
- [ ] Handover concluído
- [ ] Comunicado de conclusão emitido

---

## 📞 **Matriz de Responsabilidades (RACI) - Revisada**

| Atividade | GEARQ | GEINS | NUSIF (SSI) | GCONF | GEFAB | GEMUL | SUSIS |
|-----------|-------|-------|-------------|-------|-------|-------|-------|
| Comunicação e alinhamento | **R/A** | I | I | I | I | I | **C** |
| Criação de bases e usuários | C | **R/A** | I | I | I | A | I |
| Scripts de automação de permissões | **R** | **A** | I | I | I | A | I |
| Criação de grupos/subgrupos GitLab | C | I | I | **R/A** | I | I | I |
| Criação de token GitLab | C | I | **R/A** | I | I | I | I |
| Configuração de credenciais no Conjur | C | I | **R/A** | I | I | I | I |
| Configuração Identity | **C** | I | **R/A** | I | I | I | I |
| Elaboração de artefatos Kubernetes | **R/A** | I | I | I | C | I | I |
| Criação de namespace | C | I | I | I | **R/A** | A | I |
| Implantação Frontend/Backend (ArgoCD) | **C** | I | I | I | **R/A** | A | I |
| Cadastro de servidores via Frontend | **R/A** | C | I | I | I | I | I |
| Elaboração de scripts de trigger | **R/A** | C | I | I | I | I | I |
| Implantação de triggers | C | **R/A** | I | I | I | A | I |
| Pipeline Jenkins para Baseline | **R** | C | I | I | **A** | A | I |
| Execução de Baseline | C | C | I | I | **R/A** | A | **C** |
| Elaboração de CronJobs | **R/A** | I | I | I | C | I | I |
| Implantação de CronJobs (ArgoCD) | C | I | I | I | **R/A** | A | I |
| Documentação e treinamento | **R/A** | C | I | I | C | I | I |
| Gestão de mudanças | C | C | I | I | C | **R/A** | I |

**Legenda:**
- **R** (Responsible): Executa a atividade
- **A** (Accountable): Aprova e é responsável final
- **C** (Consulted): Consultado durante execução
- **I** (Informed): Informado sobre progresso/conclusão

---

## 🎯 **Próximos Passos Imediatos**

1. **Validar e aprovar este planejamento** com stakeholders (DITEC, GEINS, SSI, GCONF, GEFAB, GEMUL, SUSIS)
2. **Definir datas específicas** para cada fase considerando disponibilidade das equipes
3. **Emitir comunicado oficial** para SUSIS sobre início do projeto
4. **Agendar reunião de kickoff** com todas as áreas envolvidas
5. **Abrir mudança na GEMUL** para Fase 1 (criação de bases e usuários)
6. **Iniciar Fase 1** com atividades de preparação
