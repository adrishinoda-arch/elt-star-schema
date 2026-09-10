--=========================================================================================
--P1: Onde está o gargalo da entrega?
--=========================================================================================

-- P1: Tempo médio total e por intervalo
SELECT 
    ROUND(AVG(dias_integracao_separacao), 2) AS media_integracao_separacao,
    ROUND(AVG(dias_separacao_nota), 2) AS media_separacao_nota,
    ROUND(AVG(dias_nota_despacho), 2) AS media_nota_despacho,
    ROUND(AVG(dias_despacho_entrega), 2) AS media_despacho_entrega,
    ROUND(AVG(dias_total_ate_entrega), 2) AS media_total
FROM fato_pedido;

-- P1: Gargalo por porte de loja
SELECT 
    l.porte,
    ROUND(AVG(f.dias_integracao_separacao), 2) AS media_integracao_separacao,
    ROUND(AVG(f.dias_separacao_nota), 2) AS media_separacao_nota,
    ROUND(AVG(f.dias_nota_despacho), 2) AS media_nota_despacho,
    ROUND(AVG(f.dias_despacho_entrega), 2) AS media_despacho_entrega,
    ROUND(AVG(f.dias_total_ate_entrega), 2) AS media_total
FROM fato_pedido f
JOIN dim_loja l ON l.sk_loja = f.sk_loja
WHERE l.sk_loja <> -1
GROUP BY l.porte
ORDER BY l.porte;

--=========================================================================================
--P2: Qual categoria concentra o faturamento?
--=========================================================================================

-- P2: Faturamento por categoria padronizada
SELECT 
    c.nome_categoria,
    c.grupo_categoria,
    ROUND(SUM(f.vl_liquido), 2) AS faturamento,
    ROUND(100.0 * SUM(f.vl_liquido) / (SELECT SUM(vl_liquido) FROM fato_pedido), 2) AS percentual
FROM fato_pedido f
JOIN dim_categoria c ON c.sk_categoria = f.sk_categoria
WHERE c.sk_categoria <> -1
GROUP BY c.nome_categoria, c.grupo_categoria
ORDER BY faturamento DESC;

-- P2: Categoria campeã por porte de loja
SELECT 
    l.porte,
    c.nome_categoria,
    ROUND(SUM(f.vl_liquido), 2) AS faturamento,
    ROUND(100.0 * SUM(f.vl_liquido) / 
        (SELECT SUM(f2.vl_liquido) 
         FROM fato_pedido f2 
         JOIN dim_loja l2 ON l2.sk_loja = f2.sk_loja 
         WHERE l2.porte = l.porte), 2) AS percentual_do_porte
FROM fato_pedido f
JOIN dim_categoria c ON c.sk_categoria = f.sk_categoria
JOIN dim_loja l ON l.sk_loja = f.sk_loja
WHERE c.sk_categoria <> -1 AND l.sk_loja <> -1
GROUP BY l.porte, c.nome_categoria
ORDER BY l.porte, faturamento DESC;

--=========================================================================================
--P3: O desconto funciona igual em todo canal?
--=========================================================================================

-- P3: Ticket médio com e sem desconto por canal
SELECT 
    canal_pedido,
    ROUND(AVG(CASE WHEN houve_desconto = 'Sim' THEN vl_liquido END), 2) AS ticket_com_desconto,
    ROUND(AVG(CASE WHEN houve_desconto = 'Nao' THEN vl_liquido END), 2) AS ticket_sem_desconto,
    COUNT(CASE WHEN houve_desconto = 'Sim' THEN 1 END) AS pedidos_com_desconto,
    COUNT(CASE WHEN houve_desconto = 'Nao' THEN 1 END) AS pedidos_sem_desconto
FROM fato_pedido
WHERE canal_pedido <> 'Nao Informado'
  AND houve_desconto IN ('Sim', 'Nao')
GROUP BY canal_pedido
ORDER BY canal_pedido;

-- P3: Faturamento por canal
SELECT 
    canal_pedido,
    ROUND(SUM(vl_liquido), 2) AS faturamento,
    ROUND(100.0 * SUM(vl_liquido) / (SELECT SUM(vl_liquido) FROM fato_pedido), 2) AS percentual
FROM fato_pedido
GROUP BY canal_pedido
ORDER BY faturamento DESC;

--=========================================================================================
--P4: Qual praça de atendimento concentra o faturamento?
--=========================================================================================

-- P4: Faturamento rateado por praça
SELECT 
    p.nome_praca,
    p.regional,
    p.domicilios_com_pet,
    ROUND(SUM(f.vl_liquido * b.fator_publico), 2) AS faturamento_rateado,
    ROUND(100.0 * SUM(f.vl_liquido * b.fator_publico) / 
        (SELECT SUM(f2.vl_liquido * b2.fator_publico)
         FROM fato_pedido f2
         JOIN dim_loja l2 ON l2.sk_loja = f2.sk_loja
         JOIN bridge_loja_praca b2 ON b2.cod_loja = l2.cod_loja), 2) AS percentual
FROM fato_pedido f
JOIN dim_loja l ON l.sk_loja = f.sk_loja
JOIN bridge_loja_praca b ON b.cod_loja = l.cod_loja
JOIN dim_praca p ON p.sk_praca = b.sk_praca
GROUP BY p.nome_praca, p.regional, p.domicilios_com_pet
ORDER BY faturamento_rateado DESC;

-- P4: Faturamento por domicílio com pet
SELECT 
    p.nome_praca,
    p.domicilios_com_pet,
    ROUND(SUM(f.vl_liquido * b.fator_publico), 2) AS faturamento_rateado,
    ROUND(SUM(f.vl_liquido * b.fator_publico) / NULLIF(p.domicilios_com_pet, 0), 2) AS faturamento_por_domicilio
FROM fato_pedido f
JOIN dim_loja l ON l.sk_loja = f.sk_loja
JOIN bridge_loja_praca b ON b.cod_loja = l.cod_loja
JOIN dim_praca p ON p.sk_praca = b.sk_praca
WHERE p.domicilios_com_pet IS NOT NULL
GROUP BY p.nome_praca, p.domicilios_com_pet
ORDER BY faturamento_por_domicilio DESC;

--=========================================================================================
--P5: Onde abrir a próxima loja, e o que os dados não permitem afirmar?
--=========================================================================================

-- P5a: Itens vendidos por mil habitantes por loja
SELECT 
    l.nome_loja,
    l.cidade,
    l.populacao_cidade,
    SUM(f.qt_itens) AS total_itens,
    ROUND((SUM(f.qt_itens)::numeric / l.populacao_cidade) * 1000, 2) AS itens_por_mil_habitantes
FROM fato_pedido f
JOIN dim_loja l ON l.sk_loja = f.sk_loja
WHERE l.sk_loja <> -1
  AND f.qt_itens IS NOT NULL
GROUP BY l.nome_loja, l.cidade, l.populacao_cidade
ORDER BY itens_por_mil_habitantes DESC;

-- P5a: Itens por mil habitantes + tempo médio de entrega
SELECT 
    l.nome_loja,
    l.cidade,
    ROUND((SUM(f.qt_itens)::numeric / l.populacao_cidade) * 1000, 2) AS itens_por_mil_habitantes,
    ROUND(AVG(f.dias_total_ate_entrega), 2) AS tempo_medio_entrega
FROM fato_pedido f
JOIN dim_loja l ON l.sk_loja = f.sk_loja
WHERE l.sk_loja <> -1
  AND f.qt_itens IS NOT NULL
  AND f.dias_total_ate_entrega IS NOT NULL
GROUP BY l.nome_loja, l.cidade, l.populacao_cidade
ORDER BY itens_por_mil_habitantes DESC;

-- P5b: Faturamento por faixa de franquia atual
SELECT 
    l.faixa_franquia,
    ROUND(SUM(f.vl_liquido), 2) AS faturamento,
    ROUND(100.0 * SUM(f.vl_liquido) / (SELECT SUM(vl_liquido) FROM fato_pedido), 2) AS percentual
FROM fato_pedido f
JOIN dim_loja l ON l.sk_loja = f.sk_loja
WHERE l.sk_loja <> -1
GROUP BY l.faixa_franquia
ORDER BY faturamento DESC;

-- P5c: Medir o que ficou de fora
SELECT 
    'Pedidos sem loja identificada' AS item,
    COUNT(*) AS total
FROM fato_pedido
WHERE sk_loja = -1
UNION ALL
SELECT 
    'Entregas ainda nao concluidas',
    COUNT(*)
FROM fato_pedido
WHERE sk_tempo_entrega = -1
UNION ALL
SELECT 
    'Pedidos com itens em branco',
    COUNT(*)
FROM fato_pedido
WHERE qt_itens IS NULL
UNION ALL
SELECT 
    'Pedidos com valor em branco',
    COUNT(*)
FROM fato_pedido
WHERE vl_liquido IS NULL;