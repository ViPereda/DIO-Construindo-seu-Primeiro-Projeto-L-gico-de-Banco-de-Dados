# 🛒 Projeto de Banco de Dados: E-Commerce

Este repositório contém a modelagem, criação e manipulação de um banco de dados relacional para um cenário de E-commerce. O projeto foi desenvolvido como parte de um desafio prático de SQL, contemplando a criação do esquema (DDL), persistência de dados para testes (DML) e consultas complexas (DQL).

## 🎯 Objetivos e Refinamentos do Projeto

O modelo lógico inicial foi expandido e refinado para atender às seguintes regras de negócio:
* **Cliente PJ e PF:** Um cliente pode ser Pessoa Física (PF) ou Pessoa Jurídica (PJ), mas não ambos. O esquema garante essa exclusividade estrutural.
* **Múltiplos Pagamentos:** Um cliente pode cadastrar e utilizar mais de uma forma de pagamento (Cartão de Crédito, Pix, Boleto, etc.).
* **Gestão de Entrega:** Os pedidos possuem rastreamento detalhado, contendo status da entrega (Preparando, Em trânsito, Entregue) e código de rastreio.

## 🗄️ 1. Esquema do Banco de Dados (DDL)

O banco de dados, nomeado `ecomerce`, é composto pelas seguintes tabelas principais e seus relacionamentos:

* **Clientes (`client`, `client_pf`, `client_pj`):** Utiliza uma herança lógica onde a tabela base `client` armazena dados comuns, e as tabelas `client_pf` e `client_pj` armazenam dados específicos (CPF vs CNPJ).
* **Pagamentos (`payment`):** Relacionada 1:N com clientes, permitindo múltiplas formas de pagamento.
* **Produtos e Estoque (`product`, `productStorage`, `storageLocation`):** Catálogo de produtos com seus respectivos preços, categorias e localização/quantidade em estoque.
* **Pedidos e Entregas (`orders`, `delivery`, `productOrder`):** Gerencia o ciclo de vida da compra, itens do pedido (N:M) e o status logístico da entrega.
* **Fornecedores e Vendedores (`supplier`, `seller`, `productSupplier`, `productSeller`):** Gerencia quem fornece ou vende na plataforma, permitindo que uma mesma entidade seja tanto fornecedora quanto vendedora.

## 📥 2. Persistência de Dados (Inputs / DML)

Para garantir que as consultas (queries) refletissem cenários reais, o banco foi populado com um volume robusto de dados (+ de 10 registros de teste por fluxo completo), cobrindo diversas situações:
* **Cenários Positivos:** Clientes com múltiplas compras, pedidos de alto valor, produtos com múltiplos fornecedores.
* **Cenários de Exceção/Borda:** Pedidos cancelados (onde não há geração de entrega), clientes que se registraram mas não compraram, e clientes com mais de um método de pagamento registrado.

## 🔍 3. Consultas Complexas (Selects / DQL)

Foram elaboradas 5 consultas SQL para responder a perguntas de negócio estratégicas, utilizando junções, filtros, agrupamentos e atributos derivados.

### Pergunta 1: Quantos pedidos foram feitos por cada cliente e qual o status da entrega?
* **Cláusulas aplicadas:** `SELECT`, `LEFT JOIN`, `INNER JOIN`, `GROUP BY`, `ORDER BY`, Função `IFNULL()`.
* **Descrição:** Retorna a volumetria de pedidos por cliente. O uso do `LEFT JOIN` com a tabela `delivery` e a função `IFNULL()` garante que até mesmo pedidos cancelados (sem entrega) sejam exibidos de forma clara no relatório como "Sem Entrega".

### Pergunta 2: Algum vendedor também é fornecedor?
* **Cláusulas aplicadas:** `SELECT`, `INNER JOIN`.
* **Descrição:** Cruza os dados das tabelas `seller` e `supplier` utilizando o CNPJ como chave de ligação para encontrar parceiros comerciais com atuação dupla na plataforma.

### Pergunta 3: Qual é o ticket médio dos pedidos que estão "Confirmados"?
* **Cláusulas aplicadas:** `SELECT`, `JOIN`, `WHERE`, `GROUP BY`, `ORDER BY`, *Atributos Derivados*.
* **Descrição:** Calcula matematicamente o valor total de um pedido em tempo de execução `(quantidade * preço_produto) + frete`, filtrando apenas os pedidos cujo status é "Confirmado".

### Pergunta 4: Quais clientes gastaram, no total, mais de R$ 2.000,00 na plataforma?
* **Cláusulas aplicadas:** `SELECT`, `JOIN`, `GROUP BY`, `HAVING`, `ORDER BY`.
* **Descrição:** Agrupa todos os gastos de um cliente e utiliza a cláusula `HAVING` para filtrar *após* o agrupamento, mostrando apenas os clientes "VIPs" que ultrapassaram o teto de gastos estipulado.

### Pergunta 5: Qual a relação de produtos, quantidade disponível no estoque e seus respectivos fornecedores?
* **Cláusulas aplicadas:** `SELECT`, `INNER JOIN`, `LEFT JOIN`.
* **Descrição:** Uma query de visão logística geral que une as tabelas de produtos, fornecedores e galpões de estoque para monitoramento de abastecimento.

---
**Tecnologia Utilizada:** MySQL.
