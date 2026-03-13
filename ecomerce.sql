-- Criação do Banco de Dados para o desafio de E-Commerce
DROP DATABASE ecomerce;
CREATE DATABASE ecomerce;
USE ecomerce;

-- Tabela Cliente (Tabela Base)
CREATE TABLE client (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    Address VARCHAR(255),
    clientType ENUM('PF', 'PJ') NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela Cliente PF (Pessoa Física)
CREATE TABLE client_pf (
    idClient INT PRIMARY KEY,
    Fname VARCHAR(20) NOT NULL,
    Minit CHAR(3),
    Lname VARCHAR(20) NOT NULL,
    CPF CHAR(11) NOT NULL UNIQUE,
    CONSTRAINT fk_client_pf FOREIGN KEY (idClient) REFERENCES client(idClient) ON DELETE CASCADE
);

-- Tabela Cliente PJ (Pessoa Jurídica)
CREATE TABLE client_pj (
    idClient INT PRIMARY KEY,
    socialName VARCHAR(100) NOT NULL,
    tradeName VARCHAR(100),
    CNPJ CHAR(14) NOT NULL UNIQUE,
    CONSTRAINT fk_client_pj FOREIGN KEY (idClient) REFERENCES client(idClient) ON DELETE CASCADE
);

-- Tabela Pagamento (Permite múltiplas formas por cliente)
CREATE TABLE payment (
    idPayment INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT NOT NULL,
    typePayment ENUM('Boleto', 'Cartão de Crédito', 'Cartão de Débito', 'Pix') NOT NULL,
    limitAvailable FLOAT,
    dueDate DATE,
    CONSTRAINT fk_payment_client FOREIGN KEY (idClient) REFERENCES client(idClient) ON DELETE CASCADE
);

-- Tabela Produto
-- Adicionado o campo "price" para permitir cálculos de valores derivados
CREATE TABLE product (
    idProduct INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    classification_kids BOOL DEFAULT FALSE,
    category ENUM('Eletrônico', 'Vestimenta', 'Brinquedos', 'Alimentos', 'Moveis') NOT NULL,
    rating FLOAT DEFAULT 0,
    size VARCHAR(10),
    price FLOAT NOT NULL
);

-- Tabela Pedido
CREATE TABLE orders (
    idOrder INT AUTO_INCREMENT PRIMARY KEY,
    idOrderClient INT NOT NULL,
    orderStatus ENUM('Cancelado', 'Confirmado', 'Em Processamento') DEFAULT 'Em Processamento',
    orderDescription VARCHAR(255),
    sendValue FLOAT DEFAULT 10,
    paymentCash BOOL DEFAULT FALSE,
    CONSTRAINT fk_orders_client FOREIGN KEY (idOrderClient) REFERENCES client(idClient)
);

-- Tabela Entrega (Status e código de rastreio)
CREATE TABLE delivery (
    idDelivery INT AUTO_INCREMENT PRIMARY KEY,
    idOrder INT NOT NULL UNIQUE,
    deliveryStatus ENUM('Preparando', 'Em trânsito', 'Entregue') DEFAULT 'Preparando',
    trackingCode VARCHAR(50) UNIQUE,
    CONSTRAINT fk_delivery_order FOREIGN KEY (idOrder) REFERENCES orders(idOrder) ON DELETE CASCADE
);

-- Tabela Estoque
CREATE TABLE productStorage (
    idProdStorage INT AUTO_INCREMENT PRIMARY KEY,
    storageLocation VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 0
);

-- Tabela Fornecedor
CREATE TABLE supplier (
    idSupplier INT AUTO_INCREMENT PRIMARY KEY,
    socialName VARCHAR(255) NOT NULL,
    CNPJ CHAR(14) NOT NULL UNIQUE,
    contact CHAR(11) NOT NULL
);

-- Tabela Vendedor
CREATE TABLE seller (
    idSeller INT AUTO_INCREMENT PRIMARY KEY,
    socialName VARCHAR(255) NOT NULL,
    AbstName VARCHAR(255),
    CNPJ CHAR(14),
    CPF CHAR(11),
    location VARCHAR(255),
    contact CHAR(11) NOT NULL,
    CONSTRAINT unique_cnpj_seller UNIQUE (CNPJ),
    CONSTRAINT unique_cpf_seller UNIQUE (CPF)
);

-- Tabelas de Relacionamento (N:M)
CREATE TABLE productSeller (
    idPSeller INT,
    idPProduct INT,
    productQuantity INT DEFAULT 1,
    PRIMARY KEY (idPSeller, idPProduct),
    CONSTRAINT fk_product_seller FOREIGN KEY (idPSeller) REFERENCES seller(idSeller),
    CONSTRAINT fk_product_product FOREIGN KEY (idPProduct) REFERENCES product(idProduct)
);

CREATE TABLE productOrder (
    idPOproduct INT,
    idPOorder INT,
    poQuantity INT DEFAULT 1,
    poStatus ENUM('Disponível', 'Sem Estoque') DEFAULT 'Disponível',
    PRIMARY KEY (idPOproduct, idPOorder),
    CONSTRAINT fk_productorder_product FOREIGN KEY (idPOproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_productorder_order FOREIGN KEY (idPOorder) REFERENCES orders(idOrder)
);

CREATE TABLE storageLocation (
    idLproduct INT,
    idLstorage INT,
    location VARCHAR(255) NOT NULL,
    PRIMARY KEY (idLproduct, idLstorage),
    CONSTRAINT fk_storage_location_product FOREIGN KEY (idLproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_storage_location_storage FOREIGN KEY (idLstorage) REFERENCES productStorage(idProdStorage)
);

CREATE TABLE productSupplier (
    idPsSupplier INT,
    idPsProduct INT,
    quantity INT NOT NULL,
    PRIMARY KEY (idPsSupplier, idPsProduct),
    CONSTRAINT fk_product_supplier_supplier FOREIGN KEY (idPsSupplier) REFERENCES supplier(idSupplier),
    CONSTRAINT fk_product_supplier_product FOREIGN KEY (idPsProduct) REFERENCES product(idProduct)
);


-- Inserindo Clientes (Tabela Base)
INSERT INTO client (Address, clientType) VALUES 
('Rua das Flores, 123', 'PF'),
('Av. Paulista, 1000', 'PJ'),
('Rua das Arvores, 45', 'PF'),
('Rua Augusta, 100', 'PF'),
('Av Brasil, 500', 'PJ'),
('Rua Direita, 10', 'PF'),
('Praça da Sé, 1', 'PJ'),
('Av Amazonas, 300', 'PF');

-- Inserindo Clientes PF
INSERT INTO client_pf (idClient, Fname, Minit, Lname, CPF) VALUES 
(1, 'João', 'S', 'Silva', '12345678901'),
(3, 'Maria', 'A', 'Souza', '98765432100'),
(4, 'Pedro', 'H', 'Alves', '11122233344'),
(6, 'Ana', 'B', 'Costa', '55566677788'),
(8, 'Lucas', 'T', 'Mendes', '99988877766');

-- Inserindo Clientes PJ
INSERT INTO client_pj (idClient, socialName, tradeName, CNPJ) VALUES 
(2, 'Tech Solutions SA', 'Tech Store', '12345678000199'),
(5, 'Mega Varejo Ltda', 'Mega Varejo', '11222333000199'),
(7, 'Atacadão BR SA', 'Atacadão BR', '99888777000233');

-- Inserindo Formas de Pagamento
INSERT INTO payment (idClient, typePayment, limitAvailable) VALUES 
(1, 'Cartão de Crédito', 5000.00),
(1, 'Pix', NULL),
(2, 'Boleto', NULL),
(3, 'Cartão de Crédito', 1500.00),
(4, 'Pix', NULL),
(5, 'Boleto', NULL),
(6, 'Cartão de Crédito', 2500.00),
(7, 'Cartão de Débito', NULL),
(8, 'Pix', NULL),
(4, 'Cartão de Crédito', 1000.00);

-- Inserindo Produtos
INSERT INTO product (Pname, classification_kids, category, rating, size, price) VALUES 
('Smartphone', false, 'Eletrônico', 4.8, NULL, 2500.00),
('Camiseta', false, 'Vestimenta', 4.5, 'M', 50.00),
('Carrinho', true, 'Brinquedos', 4.9, NULL, 120.00),
('Notebook', false, 'Eletrônico', 4.7, NULL, 4500.00),
('Calça Jeans', false, 'Vestimenta', 4.2, '40', 120.00),
('Sofá 3 Lugares', false, 'Moveis', 4.5, NULL, 1800.00),
('Mesa de Jantar', false, 'Moveis', 4.8, NULL, 2200.00),
('Chocolate', false, 'Alimentos', 4.9, NULL, 15.00),
('Quebra-cabeça', true, 'Brinquedos', 4.6, NULL, 60.00),
('Fone de Ouvido', false, 'Eletrônico', 4.4, NULL, 150.00);

-- Inserindo Pedidos
INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue) VALUES 
(1, 'Confirmado', 'Compra pelo App', 15.00),
(2, 'Em Processamento', 'Compra pelo Site', 50.00),
(1, 'Confirmado', 'Compra pelo App', 20.00),
(4, 'Confirmado', 'Compra Web', 0.00),
(5, 'Em Processamento', 'Compra Atacado', 150.00),
(6, 'Cancelado', 'Desistência', 20.00),
(7, 'Confirmado', 'Compra Atacado', 80.00),
(8, 'Confirmado', 'Compra App', 10.00),
(1, 'Confirmado', 'Compra Web', 0.00),
(2, 'Em Processamento', 'Compra App', 35.00);

-- Inserindo Entregas (Nenhuma para o pedido 6 pois foi cancelado)
INSERT INTO delivery (idOrder, deliveryStatus, trackingCode) VALUES 
(1, 'Em trânsito', 'BR1234567890'),
(2, 'Preparando', NULL),
(3, 'Entregue', 'BR0987654321'),
(4, 'Entregue', 'BR111222333'),
(5, 'Preparando', NULL),
(7, 'Em trânsito', 'BR444555666'),
(8, 'Entregue', 'BR777888999'),
(9, 'Em trânsito', 'BR000111222'),
(10, 'Preparando', NULL);

-- Inserindo Relação Pedido x Produto
INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity) VALUES 
(1, 1, 1),
(2, 1, 3),
(1, 2, 5),
(3, 3, 2),
(4, 4, 1),
(10, 4, 2),
(6, 5, 10),
(7, 5, 5),
(2, 6, 1),
(4, 7, 5),
(8, 8, 10),
(9, 8, 1),
(1, 9, 1),
(2, 10, 50);

-- Inserindo Fornecedores
INSERT INTO supplier (socialName, CNPJ, contact) VALUES 
('Fornecedor Eletrônicos BR', '99888777000122', '11999999999'),
('Malharia Sul', '11222333000144', '41888888888'),
('Móveis Design', '33444555000166', '31999999999'),
('Alimentos Doces Cia', '66777888000199', '11888888888');

-- Inserindo Vendedores
INSERT INTO seller (socialName, AbstName, CNPJ, CPF, location, contact) VALUES 
('Vendedor João', NULL, '55666777000188', '21777777777', 'RJ', '21777777777'),
('Fornecedor Eletrônicos BR', 'Eletro BR', '99888777000122', NULL, 'SP', '11999999999'),
('Maria Modas', 'Modas Maria', NULL, '33344455566', 'SP', '11777777777'),
('Móveis Design', 'Design Interiores', '33444555000166', NULL, 'MG', '31999999999');

-- Inserindo Relação Produto x Fornecedor
INSERT INTO productSupplier (idPsSupplier, idPsProduct, quantity) VALUES 
(1, 1, 100),
(2, 2, 500),
(3, 6, 50),
(3, 7, 30),
(4, 8, 1000);

-- Inserindo Estoque e Localizações
INSERT INTO productStorage (storageLocation, quantity) VALUES 
('Galpão SP', 1000),
('Galpão RJ', 500),
('Galpão MG', 300);

INSERT INTO storageLocation (idLproduct, idLstorage, location) VALUES 
(1, 1, 'Corredor A'),
(2, 2, 'Corredor B'),
(6, 3, 'Setor Móveis'),
(7, 3, 'Setor Móveis'),
(8, 1, 'Setor Alimentos');

use ecomerce;
-- Pergunta 1: Quantos pedidos foram feitos por cada cliente e qual o status da entrega?
-- Cláusulas utilizadas: SELECT, JOIN, GROUP BY, ORDER BY.
SELECT 
    c.idClient,
    IFNULL(cpf.Fname, cpj.tradeName) AS NomeCliente,
    IFNULL(d.deliveryStatus, 'Sem Entrega (Cancelado/Pendente)') AS StatusEntrega,
    COUNT(o.idOrder) AS TotalPedidos
FROM client c
LEFT JOIN client_pf cpf ON c.idClient = cpf.idClient
LEFT JOIN client_pj cpj ON c.idClient = cpj.idClient
INNER JOIN orders o ON c.idClient = o.idOrderClient
LEFT JOIN delivery d ON o.idOrder = d.idOrder
GROUP BY c.idClient, NomeCliente, d.deliveryStatus
ORDER BY NomeCliente, TotalPedidos DESC;

-- Pergunta 2: Algum vendedor também é fornecedor?
-- Cláusulas utilizadas: SELECT, WHERE (implicito no JOIN).
SELECT 
    se.socialName AS NomeVendedor, 
    su.socialName AS NomeFornecedor, 
    se.CNPJ
FROM seller se
INNER JOIN supplier su ON se.CNPJ = su.CNPJ;

-- Pergunta 3: Qual é o ticket médio (valor total do pedido com frete) dos pedidos que estão "Confirmados"?
-- Cláusulas utilizadas: SELECT, JOIN, WHERE, Atributos Derivados (Expressões matemáticas), ORDER BY.
SELECT 
    o.idOrder, 
    o.orderStatus,
    o.sendValue AS Frete,
    SUM(po.poQuantity * p.price) AS ValorProdutos,
    (SUM(po.poQuantity * p.price) + o.sendValue) AS ValorTotalPedido
FROM orders o
INNER JOIN productOrder po ON o.idOrder = po.idPOorder
INNER JOIN product p ON po.idPOproduct = p.idProduct
WHERE o.orderStatus = 'Confirmado'
GROUP BY o.idOrder, o.orderStatus, o.sendValue
ORDER BY ValorTotalPedido DESC;

-- Pergunta 4: Quais clientes gastaram, no total, mais de R$ 2.000,00 na plataforma?
-- Cláusulas utilizadas: SELECT, JOIN, HAVING, Atributo Derivado.
SELECT 
    c.idClient,
    IFNULL(cpf.Fname, cpj.tradeName) AS ClientName,
    SUM((po.poQuantity * p.price) + o.sendValue) AS GastoTotal
FROM client c
LEFT JOIN client_pf cpf ON c.idClient = cpf.idClient
LEFT JOIN client_pj cpj ON c.idClient = cpj.idClient
INNER JOIN orders o ON c.idClient = o.idOrderClient
INNER JOIN productOrder po ON o.idOrder = po.idPOorder
INNER JOIN product p ON po.idPOproduct = p.idProduct
GROUP BY c.idClient, ClientName
HAVING GastoTotal > 2000.00
ORDER BY GastoTotal DESC;

-- Pergunta 5: Relação de produtos, quantidade disponível no estoque e seus respectivos fornecedores.
-- Cláusulas utilizadas: SELECT, JOIN múltiplos.
SELECT 
    p.Pname AS Produto,
    p.category AS Categoria,
    ps.quantity AS QtdeFornecida,
    su.socialName AS Fornecedor,
    st.quantity AS EstoqueAtual,
    st.storageLocation AS Galpao
FROM product p
INNER JOIN productSupplier ps ON p.idProduct = ps.idPsProduct
INNER JOIN supplier su ON ps.idPsSupplier = su.idSupplier
LEFT JOIN storageLocation sl ON p.idProduct = sl.idLproduct
LEFT JOIN productStorage st ON sl.idLstorage = st.idProdStorage
ORDER BY p.category, p.Pname;

