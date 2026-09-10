## Diagnóstico da Origem

### Números gerais

| Tabela | Linhas |
|--------|--------|
| stg_pedido | 4.044 |
| stg_loja | 32 |
| stg_loja_praca | 48 |

### Os 5 itens solicitados pelo documento oficial

| Item | Quantidade |
|------|------------|
| Grafias distintas de loja | 128 |
| Grafias distintas de categoria | 37 |
| Pedidos sem código de loja | 1.575 |
| Pedidos sem nome de loja | 3 |

### Marcos de processo em branco (em aberto)

| Marco | Quantidade |
|-------|------------|
| Dt Separacao Estoque | 1.077 |
| DtNotaFiscal | 1.338 |
| Dt_Despacho_Transportadora | 1.665 |
| DtEntregaCliente | 1.953 |

### Interpretação

- **128 grafias de loja** para apenas 32 lojas reais: a mesma loja aparece escrita de dezenas de maneiras (acentos, caixa alta, erros de digitação, sufixos);
- **37 grafias de categoria** para 7 categorias reais: inclui variações como "Ração", "RACAO", "Rac." e a pegadinha "Ração Medicamentosa" (que é medicamento, não ração);
- **1.575 pedidos sem código de loja** (~39%): o código será recuperado pelo nome da loja;
- **3 pedidos sem nome de loja**: irão para a linha -1 na dimensão loja;
- **Marcos em branco**: representam processos ainda em aberto (não são erros), e serão tratados como NULL nos campos de dias.