-- Query otimizada para análise no Excel
WITH Atracacoes AS (
    SELECT 
        CASE 
            WHEN SGUF = 'CE' THEN 'Ceará'
            WHEN [Região Geográfica] = 'Nordeste' THEN 'Nordeste'
            ELSE 'Brasil' 
        END AS Localidade,
        [Ano da data de início da operação] AS Ano,
        [Mês da data de início da operação] AS Mes,
        COUNT(DISTINCT IDAtracacao) AS Numero_Atracoes,
        AVG(TEsperaAtracacao) AS Tempo_Espera_Medio,
        AVG(TAtracado) AS Tempo_Atracado_Medio
    FROM atracacao_fato
    WHERE [Ano da data de início da operação] IN (2021, 2023)
    GROUP BY 
        CASE 
            WHEN SGUF = 'CE' THEN 'Ceará'
            WHEN [Região Geográfica] = 'Nordeste' THEN 'Nordeste'
            ELSE 'Brasil' 
        END, 
        [Ano da data de início da operação], 
        [Mês da data de início da operação]
),
Variação AS (
    SELECT 
        a.Localidade,
        a.Ano,
        a.Mes,
        a.Numero_Atracoes,
        ((a.Numero_Atracoes - COALESCE(b.Numero_Atracoes, 0)) * 100.0 / NULLIF(b.Numero_Atracoes, 0)) AS Variacao_Atracoes,
        a.Tempo_Espera_Medio,
        a.Tempo_Atracado_Medio
    FROM Atracacoes a
    LEFT JOIN Atracacoes b 
        ON a.Localidade = b.Localidade 
        AND a.Mes = b.Mes 
        AND b.Ano = 2021 
        AND a.Ano = 2023
)
SELECT 
    Localidade,
    Ano,
    Mes,
    Numero_Atracoes,
    COALESCE(Variacao_Atracoes, 0) AS '(%) Variacao_Atracoes_AA',
    Tempo_Espera_Medio,
    Tempo_Atracado_Medio
FROM Variação
ORDER BY Ano, Mes;