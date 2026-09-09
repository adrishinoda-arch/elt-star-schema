# ELT + Star Schema — Pata Amiga

Pipeline ELT em PostgreSQL para construção de um modelo dimensional estrela a partir de dados sujos da rede de pet shops Pata Amiga.

---

## Diagnóstico da Origem

### Contagens gerais

| Tabela | Linhas |
|--------|--------|
| stg_pedido | 4.044 |
| stg_loja | 32 |
| stg_loja_praca | 48 |

### Grafias distintas

| Campo | Quantidade |
|-------|------------|
| Loja-Nome | 128 |
| CategoriaProduto | 37 |
| HouveDesconto | 17 |
| CanalPedido | 20 |

### Pedidos com identificação ausente

| Item | Quantidade |
|------|------------|
| Sem Cod Loja | 1.575 |
| Sem nome de loja | 3 |

### Marcos em branco (processo em aberto)

| Marco | Quantidade |
|-------|------------|
| Dt Separacao Estoque | 1.077 |
| DtNotaFiscal | 1.338 |
| Dt_Despacho_Transportadora | 1.665 |
| DtEntregaCliente | 1.953 |

---

## O que está errado com cada tabela

### stg_pedido
- Todas as colunas em texto (VARCHAR);
- Datas em formatos diferentes (MM/DD/YYYY e YYYY-MM-DD);
- Valores monetários em formatos mistos (R$ 1.850,00, 1850.00, 1.200);
- 37 grafias para 7 categorias;
- Dezenas de grafias de loja;
- 1.575 pedidos sem código de loja;
- 3 pedidos sem nome de loja;
- Marcos em branco = processo em aberto.

### stg_loja
- Nomes de loja com grafias variadas (acentos, caixa alta, erros);
- Faixa de franquia é a foto atual (passado sobrescrito).

### stg_loja_praca
- Relação N:N entre loja e praça;
- Fator de público em texto com ponto de milhar.