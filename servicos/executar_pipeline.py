"""
Pipeline de automacao - Pata Amiga ELT
Executa os scripts SQL na ordem correta, com tratamento de erros.

Uso:
    python servicos/executar_pipeline.py
"""

import os
import sys
import psycopg2
from dotenv import load_dotenv
from pathlib import Path

# Carrega as variaveis do .env
load_dotenv()

# Caminho base do projeto
BASE_DIR = Path(__file__).resolve().parent.parent
SQL_DIR = BASE_DIR / 'scripts_sql'

# Ordem de execucao dos scripts
SCRIPTS = [
    ('01-carga-staging.sql', 'postgres'),
    ('02-dimensoes-prontas.sql', 'dw_pata_amiga'),
    ('03-diagnostico.sql', 'dw_pata_amiga'),
    ('04-dimensoes-customizadas.sql', 'dw_pata_amiga'),
    ('05-carga-fato.sql', 'dw_pata_amiga'),
    ('06-analises.sql', 'dw_pata_amiga'),
]


def conectar(banco):
    """Estabelece conexao com o PostgreSQL."""
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            port=os.getenv('DB_PORT'),
            dbname=banco,
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
        conn.autocommit = True
        print(f"[OK] Conectado ao banco '{banco}'")
        return conn
    except Exception as e:
        print(f"[ERRO] Falha ao conectar no banco '{banco}': {e}")
        sys.exit(1)


def executar_script(arquivo, banco):
    """Executa um arquivo SQL em um banco especifico."""
    caminho = SQL_DIR / arquivo

    if not caminho.exists():
        print(f"[AVISO] Arquivo nao encontrado: {caminho}")
        sys.exit(1)

    print(f"\n{'='*60}")
    print(f"Executando: {arquivo}")
    print(f"Banco: {banco}")
    print(f"{'='*60}")

    conn = None
    try:
        conn = conectar(banco)
        with conn.cursor() as cur:
            with open(caminho, 'r', encoding='utf-8') as f:
                sql = f.read()
            cur.execute(sql)

            # Se houver retorno, exibe
            if cur.description:
                resultados = cur.fetchall()
                for linha in resultados:
                    print(linha)

        print(f"[OK] Script {arquivo} executado com sucesso!")

    except Exception as e:
        print(f"[ERRO] Falha ao executar {arquivo}: {e}")
        sys.exit(1)
    finally:
        if conn:
            conn.close()


def main():
    """Funcao principal - orquestra a execucao."""
    print("\nIniciando pipeline ELT - Pata Amiga")
    print(f"Diretorio dos scripts: {SQL_DIR}")

    # Verifica se o .env foi configurado
    senha = os.getenv('DB_PASSWORD')
    if not senha or senha == 'SUA_SENHA_AQUI':
        print("[ERRO] Configure o arquivo .env com suas credenciais do PostgreSQL")
        sys.exit(1)

    for arquivo, banco in SCRIPTS:
        executar_script(arquivo, banco)

    print("\nPipeline concluido com sucesso!")
    print("Execute o 00-conferencia.sql para validar os resultados.")


if __name__ == '__main__':
    main()