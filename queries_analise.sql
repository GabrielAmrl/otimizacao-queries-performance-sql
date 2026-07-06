-- ==================================================================================
-- PROJETO: Análise Avançada de Performance de Atendimento e Eficiência Operacional
-- AUTOR: Gabriel Amaral de Morais
-- OBJETIVO: Identificar gargalos de tempo de atendimento (SLA), calcular o churn 
--           potencial de clientes e analisar tendências mês a mês.
-- ==================================================================================

WITH BaseChamadosTratada AS (
    -- Etapa 1: Limpeza, padronização e cálculo do tempo de atendimento em dias
    SELECT 
        id_solicitacao,
        id_cliente,
        regiao,
        UPPER(submotivo) AS submotivo_padrao,
        data_abertura,
        data_conclusao,
        (data_conclusao::DATE - data_abertura::DATE) AS dias_atendimento,
        -- Define se o atendimento estourou o prazo regulamentar da empresa (ex: 5 dias)
        CASE 
            WHEN (data_conclusao::DATE - data_abertura::DATE) > 5 THEN 1 
            ELSE 0 
        END AS estouro_sla
    FROM operacao.bt_solicitacoes
    WHERE data_abertura >= '2025-01-01'
      AND status = 'CONCLUIDO'
),

MetricasPorMes AS (
    -- Etapa 2: Agrupamento mensal e cálculo de volumetria e taxas de estouro de SLA
    SELECT 
        DATE_TRUNC('month', data_abertura)::DATE AS mes_ano,
        regiao,
        submotivo_padrao,
        COUNT(id_solicitacao) AS total_chamados,
        SUM(estouro_sla) AS total_estouros_sla,
        ROUND((SUM(estouro_sla)::NUMERIC / COUNT(id_solicitacao)) * 100, 2) AS taxa_estouro_sla_pct,
        ROUND(AVG(dias_atendimento), 1) AS media_dias_resolucao
    FROM BaseChamadosTratada
    GROUP BY 1, 2, 3
),

AnaliseTendencia AS (
    -- Etapa 3: Uso de Window Functions para comparar o volume atual com o mês anterior
    SELECT 
        mes_ano,
        regiao,
        submotivo_padrao,
        total_chamados,
        taxa_estouro_sla_pct,
        media_dias_resolucao,
        -- Recupera o volume do mês anterior para a mesma região e submotivo
        LAG(total_chamados) OVER(
            PARTITION BY regiao, submotivo_padrao 
            ORDER BY mes_ano
        ) AS volume_mes_anterior
    FROM MetricasPorMes
)

-- Etapa Final: Consolidação dos resultados com cálculo de variação percentual (MoM)
SELECT 
    mes_ano,
    regiao,
    submotivo_padrao,
    total_chamados,
    volume_mes_anterior,
    -- Calcula o crescimento ou queda percentual de chamados mês a mês
    CASE 
        WHEN volume_mes_anterior IS NULL THEN 0.00
        ELSE ROUND(((total_chamados - volume_mes_anterior)::NUMERIC / volume_mes_anterior) * 100, 2)
    END AS variacao_volume_mom_pct,
    taxa_estouro_sla_pct,
    media_dias_resolucao,
    -- Classificação de criticidade do submotivo baseado na volumetria
    DENSE_RANK() OVER(
        PARTITION BY mes_ano, regiao 
        ORDER BY total_chamados DESC
    ) AS ranking_criticidade_regioal
FROM AnaliseTendencia
ORDER BY regiao, submotivo_padrao, mes_ano;