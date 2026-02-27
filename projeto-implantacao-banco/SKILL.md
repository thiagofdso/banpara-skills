---
name: projeto-implantacao-banco
description: Detalhamento do projeto Versionamento e Automação de mudanças de banco de dados
version: 1.0.1
language: pt-BR
---

# Objetivo da skill
Detalhar o andamento e entregas realizadas do projeto Versionamento e Automação de mudanças de banco de dados

#	STACKEHOLDERS
-	GEMUL/SUGOT
-	GEARQ/SUGOT
-	SSI/NUSIF
-	SUPRO/GEINS
-	SUPRO/GESER
-	SUSIS


# Planejamento de Atividades

1.	FASE 1: DIAGNÓSTICO DETALHADO

1.1.	Atividade: Estudar o processo vigente

1.2.	Objetivo: Documentar formalmente fragilidades do processo atual, com análise de impacto e recomendações de melhoria

1.3.	Prazo: 37/07/2026

1.3.1.	Análise Documental

1.3.1.1.	Revisar MNP de Segurança da Informação

1.3.1.2.	Revisar MNP de Gestão de Mudança

1.3.1.3.	Revisar MNP de Padrões de Banco de Dados

1.3.1.4.	Analisar formulário de solicitação de script

1.3.1.5.	Analisar fluxos SVN + ITSM

1.3.1.6.	Entregável: Documentação do estado atual

1.3.2.	Entrevistas

1.3.2.1.	SSI/NUSIF

1.3.2.2.	GEMUL

1.3.2.3.	SUPRO/GEINS

1.3.2.4.	SUSIS

1.3.2.5.	Entregável: Documentação do estado atual atualizada com sessão sobre entrevistas

1.3.3.	Análise de conformidade

1.3.3.1.	Aderência ao processo de mudança ITIL

1.3.3.2.	Avaliar requisitos da gestão de mudança com base na ISO 20000-1

1.3.3.3.	Avaliar controles de acesso e trilha de auditoria com base na ISO 27001

1.3.3.4.	Avaliar Segregação de Funções

1.3.3.5.	Avaliar completude e rastreabilidade da trilha de auditoria

1.3.3.6.	Entregável: Documentação do estado atual atualizada com sessão sobre conformidade

1.3.4.	Identificar e validar fragilidades

1.3.4.1.	Avaliar duplicidade de diretrizes entre manuais

1.3.4.2.	Problema de formulário PDF

1.3.4.3.	Armazenamento disperso e redundante SVN, formulário

1.3.4.4.	Acesso limitado ao formulário

1.3.4.5.	Auditoria manual ou incompleta

1.3.4.6.	Falta de automatização

1.3.4.7.	Verificar outras fragilidades

1.3.4.8.	Preparar relatório de fragilidades

1.3.4.9.	Entregável: Documentação do estado atual atualizada com sessão sobre fragilidades

3.	FASE 2: PROSPECCÃO TECNOLÓGICA
   
2.1.	Atividade: Avaliar técnicas e tecnologias

2.2.	Prazo: 31/12/2026

2.3.	Objetivo: pesquisar e comparar soluções tecnológicas que suportam o processo integrado de mudanças em banco de dados com melhor prática do mercado

2.4.	Catálogo de Soluções por componente

2.4.1.	Formulário/Solicitação

2.4.2.	Repositório de Scripts

2.4.3.	Automação de fluxo

2.4.4.	Trilha de auditoria

2.4.5.	Esteira de implantação

2.4.6.	Entregável: planilha com alternativas analisadas comparando com solução atual

2.5.	Realizar pesquisa e análise detalhada das soluções

2.5.1.	Integração ITSM / formulário/ solicitação

2.5.1.1.	Suporta fluxos automatizados?

2.5.1.2.	Permite aprovação múltiplas?

2.5.1.3.	Gera RDM automaticamente?

2.5.1.4.	Permite auditar processo?

2.5.2.	Repositório git

2.5.2.1.	Definir estrutura de grupos e projetos

2.5.2.2.	Definir estrutura de branch

2.5.2.3.	Definir fluxo de versionamento de objetos de banco de dados

2.5.2.4.	Avaliar migração SVN > GIT para manter histórico

2.5.3.	Automação CI/CD

2.5.3.1.	Avaliar integração com ferramentas de banco de dados

2.5.3.2.	Avaliar rollback automatizado com cada ferramenta

2.5.3.3.	Avaliar logs de execução

2.5.3.4.	Avaliar processo de testes ou aprovação automática de merge quests

2.5.4.	Trilha de auditoria (log centralizado)

2.5.4.1.	Coletar logs/registros de todas fontes (banco de dados, ITSM, git, CI/CD)?

2.5.4.2.	Retenção 5 anos?

2.5.4.3.	Busca e relatórios em tempo real?

2.5.4.4.	Alertas de anomalias (execução fora da janela)?

2.5.5.	Avaliação de mercado

2.5.5.1.	Pesquisar melhores práticas (5 organizações similares)

2.5.5.2.	Stack tecnológica utilizada

2.5.5.3.	Identificar lições aprendidas

2.5.5.4.	Levantar tempo de implantação

2.5.5.5.	Identificar ganhos

2.5.5.6.	Criar relatório da análise de mercado

2.5.6.	Prototipagem / Prova de conceito para os 3 principais candidatos

2.5.6.1.	Setup de ambiente de teste

2.5.6.2.	Integração ITSM

2.5.6.3.	Teste fluxo completo (5 scripts)

2.5.6.4.	Teste da trilha de auditoria

2.5.6.5.	Documentação das provas de conceito e resultados obtidos

2.5.7.	Análise financeira

2.5.7.1.	Analisar custo de licenciamento

2.5.7.2.	Analisar custo de suporte

2.5.8.	Go-live

2.5.8.1.	Comunicado oficial

2.5.8.2.	Go-live (1 semana acompanhamento)

2.5.8.3.	Fall-back para fluxo atual em caso de problemas

2.5.8.4.	Validação/feedback com stackeholders

2.5.8.5.	Corte do fluxo atual

2.5.9.	Entregáveis

2.5.9.1.	Catálogo de soluções com análise detalhada

2.5.9.2.	Avaliação de mercado

2.5.9.3.	Análise financeira

2.5.9.4.	Relatórios das provas de conceito

2.5.9.5.	Recomendação

3.	FASE 3: IMPLEMENTAÇÃO TÉCNICA
   
3.1.	Atividade: Construir/adquirir e implantar solução
  	
3.2.	Objetivo: implantar a solução selecionada em produção com todos os controles, integrações e treinamento necessário

3.3.	Design detalhado

3.3.1.	Integração do git com processo de solicitação

3.3.2.	Integração do processo de solicitação com ITSM

3.3.3.	Integração com ferramenta de auditoria

3.3.4.	Automação de implantação e rollback

3.4.	Implementação

3.4.1.	Aquisição/licenciamento -> contrato assinado ou open source ou usar ferramentas existentes

3.4.2.	Setup de infraestrutura -> ambientes prontos

3.4.3.	Implementação de integrações -> integrações testadas

3.4.4.	Migração SVN>Git > artefatos migrados

3.4.5.	Configuração de CI/CD -> pipelines testados

3.4.6.	Integração de auditoria -> auditoria testada

3.5.	Testes e validação

3.5.1.	Teste de funcionalidade -> rdms processadas sem erro

3.5.2.	Teste de trilha de auditoria -> 100% de ações registradas

3.5.3.	Teste de rollback -> scripts revertidos com sucesso

3.5.4.	Teste de integração -> solicitações registradas e rdms criadas

3.5.5.	Teste de usabilidade -> formulários intuitivos

3.5.6.	Teste de aceitação -> stakeholders aprovaram todas etapas

3.6.	Treinamento

3.6.1.	Guias, apresentações, vídeos

3.6.2.	Documentação oficial

3.6.3.	Feedbacks pós-treinamento

4.	FASE 4: FORMALIZAÇÃO
   
4.1.	Atividade: Desenhar e formalizar a evolução do processo

4.2.	Objetivo: Documentar formalmente o novo processo integrado em um único MNP unificado e atualizar os demais MNPs

4.3.	Desenho do processo integrado

4.3.1.	Desenhar fluxo git -> itsm -> rdm

4.3.2.	Desenhar fluxo de auditoria

4.3.3.	Desenhar processo de implantação

4.4.	Consolidação de MNPs

4.4.1.	Remover regras dos mnps atuais e criar um novo unificado?

4.4.2.	Adaptar regras dos mnps atuais e criar mnp que integra processos?

4.5.	Aprovação e publicação de mnps

# Andamento

## Fase 1

Os manuais foram analisados, as entrevistas foram feitas, foi feita comparação com o COBIT, ITIL e ISO, por fim foi elaborado o relatório abaixo com todos os pontos levantados.

https://raw.githubusercontent.com/thiagofdso/banpara-skills/refs/heads/main/projeto-implantacao-banco/Parecer_sobre_Processos_de_Implantação_de_Banco_de_Dados.pdf

## Fase 2

Na fase dois fizemos uma pesquisa e comparação de ferramentas de mercado para versionar mudançcas de banco de dados no arquivo abaixo.

https://raw.githubusercontent.com/thiagofdso/banpara-skills/refs/heads/main/projeto-implantacao-banco/Analise_de_Ferramentas_de_Implantação_de_Banco_de_dados.pdf

Selecionamos flyway, liquibase e SQL Server Data Tools para realizar provas de conceito e foi criada o relatório abaixo.

https://raw.githubusercontent.com/thiagofdso/banpara-skills/refs/heads/main/projeto-implantacao-banco/PROVA_DE_CONCEITO_FERRAMENTAS_DE_IMPLANTAÇÃO_DE_BANCO_DE_DADOS.pdf
