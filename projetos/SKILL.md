---
name: projetos
description: Contexto dos projetos em andamento
version: 1.0.1
language: pt-BR
---

## Objetivo da skill
Fornecer contexto estruturado sobre os projetos em andamento

## Octopus

Esse projeto visa implementar um sistema que versiona objetos de banco de dados do SQL Server através de um servidor Gitlab.

O sistema é reativo, ele realiza o baseline dos objetos, gerando todos scripts DDL de criação dos objetos e versionando e de forma incremental através de uma tabela alimentada a partir de uma trigger que detecta todas as alterações de DDL.

## Automação em mudanças de banco de dados

Esse projeto visa implementar o versionamento e automatização de mudanças de banco de dados.


## GEMUD-PO-T005_02 - Versionamento de banco de dados

Esse é o registro de auditoria que levou a criação dos projetos Octopus, de versionamento e automação de mudanças de banco de dados.

Ele aponta o seguinte:
```
No que diz respeito à rastreabilidade de informações, foram identificadas as fragilidades:
2) Inexistência de controle de versão no processo de implantação/alteração de objetos de banco de dados.

Base normativa: 
	ISO 20000-2:2021 item 8.5.3
	Processo BAI07 COBIT 5
	Política de TI e MNP de Mudança

Evoluir processo de implantação/alteração de objetos de banco de dados relacionais​
a) Estudar o processo vigente, levantando os pontos de fragilidade;​ (31/07/2026​)
b) Avaliar e prospectar técnicas e tecnologias relevantes para garantir o controle de alterações;​ (31/12/2026)​
c) Construir/desenvolver/adquirir e implantar solução que suportará o processo;​ (30/07/2027​)
d) Desenhar e formalizar a evolução do processo. (28/05/2027)
```


## CL01.01-SUGOT25 - Implementar automatização de mudanças de banco de dados

Essa é a ação do Plano Diretor de TI (PDTI) com o objetivo de controlar as mudanças em bases de dados, documentando/versionando as alterações, automatizando as execuções e garantindo a replicabilidade.
