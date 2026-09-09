-- =====================================================================================
--  DIAGNOSTICO-ORIGEM.SQL
-- =====================================================================================
--  Script de diagnóstico da origem.
--  Contém:
--    A. Números gerais (contagens das tabelas)
--    B. Os 5 itens solicitados no subitem 'Tarefa 1: Diagnóstico da Origem' (pág. 4)
--       1. Quantas grafias de loja existem?
--       2. Quantas de categoria?
--       3. Quantos pedidos vieram sem código de loja?
--       4. Quantos sem nome de loja?
--       5. Quantos marcos de processo estão em branco?
-- =====================================================================================

-- -----------------------------------------------------------------------------------
-- A. NÚMEROS GERAIS
-- -----------------------------------------------------------------------------------
SELECT 'stg_pedido' AS tabela, COUNT(*) AS linhas FROM stg_pedido
UNION ALL SELECT 'stg_loja', COUNT(*) FROM stg_loja
UNION ALL SELECT 'stg_loja_praca', COUNT(*) FROM stg_loja_praca;

-- -----------------------------------------------------------------------------------
-- B. DIAGNÓSTICO SOLICITADO PELO DOCUMENTO
-- -----------------------------------------------------------------------------------

-- 1. Quantas grafias de loja existem?
SELECT COUNT(DISTINCT "Loja-Nome") AS grafias_loja
FROM stg_pedido;

-- 2. Quantas grafias de categoria existem?
SELECT COUNT(DISTINCT "CategoriaProduto") AS grafias_categoria
FROM stg_pedido;

-- 3. Quantos pedidos vieram sem código de loja?
SELECT SUM(CASE WHEN "Cod Loja" = '' THEN 1 ELSE 0 END) AS sem_cod_loja
FROM stg_pedido;

-- 4. Quantos pedidos vieram sem nome de loja?
SELECT SUM(CASE WHEN "Loja-Nome" = '' THEN 1 ELSE 0 END) AS sem_nome_loja
FROM stg_pedido;

-- 5. Quantos marcos de processo estão em branco?
SELECT 
    SUM(CASE WHEN "Dt Separacao Estoque" = '' THEN 1 ELSE 0 END) AS sem_separacao,
    SUM(CASE WHEN "DtNotaFiscal" = '' THEN 1 ELSE 0 END) AS sem_nota,
    SUM(CASE WHEN "Dt_Despacho_Transportadora" = '' THEN 1 ELSE 0 END) AS sem_despacho,
    SUM(CASE WHEN "DtEntregaCliente" = '' THEN 1 ELSE 0 END) AS sem_entrega
FROM stg_pedido;