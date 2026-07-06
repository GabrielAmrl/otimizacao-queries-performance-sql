# Análise Avançada de Performance de Atendimento e SLA com SQL

Este repositório apresenta o desenvolvimento de uma solução em SQL analítico focado em inteligência de negócios (_Business Intelligence_). O objetivo do projeto é mapear ineficiências operacionais em uma base de dados massiva de chamados de atendimento, analisando quebras de acordo de nível de serviço (SLA) e volumetria mês a mês.

## 📌 Problema de Negócio Simulado

Uma grande empresa prestadora de serviços públicos identificou um aumento na insatisfação dos clientes. A diretoria precisava identificar com precisão:

1. Quais submotivos de atendimento geram os maiores tempos de espera.
2. Quais regiões apresentam gargalos críticos de infraestrutura ou atendimento.
3. Se o volume de reclamações está crescendo de forma acelerada mês a mês (Variação Month-over-Month).

## 🛠️ Tecnologias e Técnicas Utilizadas

- **Linguagem:** SQL (PostgreSQL sintaxe padrão).
- **CTEs (Common Table Expressions):** Utilizadas para estruturar e modularizar a consulta em blocos lógicos, facilitando a manutenção e legibilidade do código.
- **Window Functions (`LAG`, `DENSE_RANK`, `OVER`):** Aplicadas para realizar cálculos comparativos de série temporal (MoM) e criar rankings de criticidade regional sem a necessidade de múltiplos JOINS custosos.
- **Lógica Condicional (`CASE WHEN`):** Utilizada para criar flags de estouro de SLA e mitigar erros de divisão por zero.

## 📈 Insights Gerados pelo Código

A query permite que a diretoria filtre rapidamente relatórios executivos para tomar decisões como:

- Alocação de força de trabalho em regiões onde o `ranking_criticidade_regional` aponta estouros frequentes.
- Identificação precoce de tendências de atrito de clientes analisando desvios na `variacao_volume_mom_pct`.

---

💡 _Projeto desenvolvido por Gabriel Amaral de Morais como portfólio técnico para posições de Análise de Dados Pleno/Sênior._
