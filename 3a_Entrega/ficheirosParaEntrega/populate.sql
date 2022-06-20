
--------------------------------------------------------------------------
--------------------------  Criação de tabelas  --------------------------
--------------------------------------------------------------------------

CREATE TABLE categoria (
    nome varchar(80),
    CONSTRAINT pk_categoria PRIMARY KEY(nome)
);

CREATE TABLE categoria_simples (
    nome varchar(80),
    CONSTRAINT pk_categoria_simples PRIMARY KEY(nome),
    CONSTRAINT fk_categoria_simples_categoria FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE super_categoria (
    nome varchar(80),
    CONSTRAINT pk_super_categoria PRIMARY KEY(nome),
    CONSTRAINT fk_super_categoria_categoria FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE tem_outra (
    super_categoria varchar(80),
    categoria varchar(80),
    CONSTRAINT pk_tem_outra PRIMARY KEY(categoria),
    CONSTRAINT fk_tem_outra_super_categoria FOREIGN KEY(super_categoria) REFERENCES super_categoria(nome),
    CONSTRAINT fk_tem_outra_categoria FOREIGN KEY(categoria) REFERENCES categoria(nome)
);

CREATE TABLE produto (
    ean numeric,
    descr varchar(420),
    cat varchar(80),
    CONSTRAINT pk_produto PRIMARY KEY(ean),
    CONSTRAINT fk_produto_categoria FOREIGN KEY(cat) REFERENCES categoria(nome)
);

CREATE TABLE tem_categoria (
    ean numeric,
    nome varchar(80),
    CONSTRAINT pk_tem_categoria PRIMARY KEY(ean, nome),
    CONSTRAINT fk_tem_categoria_produto FOREIGN KEY(ean) REFERENCES produto(ean),
    CONSTRAINT fk_tem_categoria_categoria FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE IVM (
    num_serie integer,
    fabricante varchar(80),
    CONSTRAINT pk_IVM PRIMARY KEY(num_serie, fabricante)
);

CREATE TABLE ponto_de_retalho (
    nome varchar(80),
    distrito varchar(80),
    concelho varchar(80),
    CONSTRAINT pk_ponto_de_retalho PRIMARY KEY(nome)
);

CREATE TABLE instalada_em (
    num_serie integer,
    fabricante varchar(80),
    local_ varchar(80),
    CONSTRAINT pk_instalada_em PRIMARY KEY(num_serie, fabricante),
    CONSTRAINT fk_instalada_em_ponto_de_retalho FOREIGN KEY(local_) REFERENCES ponto_de_retalho(nome)
);

CREATE TABLE prateleira (
    nro integer,
    num_serie integer,
    fabricante varchar(80),
    altura integer, -- assumimos que está em centímetros
    nome varchar(80), 
    CONSTRAINT pk_prateleira PRIMARY KEY(nro, num_serie, fabricante),
    CONSTRAINT fk_prateleira_categoria FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE planograma (
    ean numeric,
    nro integer,
    num_serie integer,
    fabricante varchar(80),
    faces integer,
    unidades integer,
    loc varchar(80), -- TODO sei lá o que é isto
    CONSTRAINT pk_planograma PRIMARY KEY(ean, nro, num_serie, fabricante),
    CONSTRAINT fk_planograma_produto FOREIGN KEY(ean) REFERENCES produto(ean),
    CONSTRAINT fk_planograma_prateleira FOREIGN KEY(nro, num_serie, fabricante) REFERENCES prateleira(nro, num_serie, fabricante)
);

CREATE TABLE retalhista (
    tin integer,
    nome varchar(80),
    CONSTRAINT pk_retalhista PRIMARY KEY(tin),
    UNIQUE(nome)
);

CREATE TABLE responsavel_por (
    nome_cat varchar(80),
    tin integer,
    num_serie integer,
    fabricante varchar(80),
    CONSTRAINT pk_responsavel_por PRIMARY KEY(num_serie, fabricante),
    CONSTRAINT fk_responsavel_por_IVM FOREIGN KEY(num_serie, fabricante) REFERENCES IVM(num_serie, fabricante),
    CONSTRAINT fk_responsavel_por_retalhista FOREIGN KEY(tin) REFERENCES retalhista(tin),
    CONSTRAINT fk_responsavel_por_categoria FOREIGN KEY(nome_cat) REFERENCES categoria(nome)
);

CREATE TABLE evento_reposicao(
    ean numeric,
    nro integer,
    num_serie integer,
    fabricante varchar(80),
    instante timestamp,
    unidades integer,
    tin integer,
    CONSTRAINT pk_evento_reposicao PRIMARY KEY(ean, nro, num_serie, fabricante, instante),
    CONSTRAINT fk_evento_reposicao_planograma FOREIGN KEY(ean, nro, num_serie, fabricante) REFERENCES planograma(ean, nro, num_serie, fabricante),
    CONSTRAINT fk_evento_reposicao_retalhista FOREIGN KEY(tin) REFERENCES retalhista(tin)
);

-------------------------------------------------------------------------
-------------------------  Inserção de valores  -------------------------
-------------------------------------------------------------------------

----------- categoria
--Lvl 1
INSERT INTO categoria VALUES('Material');
INSERT INTO categoria VALUES('Bebidas');
INSERT INTO categoria VALUES('Comida');
-- Lvl 2
INSERT INTO categoria VALUES('Material de escrita');
INSERT INTO categoria VALUES('Material de artes');
INSERT INTO categoria VALUES('Material diverso');
INSERT INTO categoria VALUES('Bebidas Quentes');
INSERT INTO categoria VALUES('Bebidas Frias');
INSERT INTO categoria VALUES('Comida Saudável');
INSERT INTO categoria VALUES('Comida - Chips');
INSERT INTO categoria VALUES('Comida - Diversa');
-- Lvl 3
INSERT INTO categoria VALUES('Bebidas Frias sem açucar');
INSERT INTO categoria VALUES('Bebidas Frias com açucar');
INSERT INTO categoria VALUES('Bebidas Quentes sem açucar');
INSERT INTO categoria VALUES('Bebidas Quentes com açucar');


----------- categoria simples
-- Lvl 2
INSERT INTO categoria_simples VALUES('Material de escrita');
INSERT INTO categoria_simples VALUES('Material de artes');
INSERT INTO categoria_simples VALUES('Material diverso');
INSERT INTO categoria_simples VALUES('Bebidas Quentes');
INSERT INTO categoria_simples VALUES('Bebidas Frias');
INSERT INTO categoria_simples VALUES('Comida Saudável');
INSERT INTO categoria_simples VALUES('Comida - Chips');
INSERT INTO categoria_simples VALUES('Comida - Diversa');
-- Lvl 3
INSERT INTO categoria_simples VALUES('Bebidas Frias sem açucar');
INSERT INTO categoria_simples VALUES('Bebidas Frias com açucar');
INSERT INTO categoria_simples VALUES('Bebidas Quentes sem açucar');
INSERT INTO categoria_simples VALUES('Bebidas Quentes com açucar');


----------- super_categoria
--Lvl 1
INSERT INTO super_categoria VALUES('Material');
INSERT INTO super_categoria VALUES('Bebidas');
INSERT INTO super_categoria VALUES('Comida');
-- Lvl 2
INSERT INTO super_categoria VALUES('Material de escrita');
INSERT INTO super_categoria VALUES('Material de artes');
INSERT INTO super_categoria VALUES('Material diverso');
INSERT INTO super_categoria VALUES('Bebidas Quentes');
INSERT INTO super_categoria VALUES('Bebidas Frias');
INSERT INTO super_categoria VALUES('Comida Saudável');
INSERT INTO super_categoria VALUES('Comida - Chips');
INSERT INTO super_categoria VALUES('Comida - Diversa');



----------- tem_outra
-- Lvl 1 => Lvl 2
INSERT INTO tem_outra VALUES('Material', 'Material de escrita');
INSERT INTO tem_outra VALUES('Material', 'Material de artes');
INSERT INTO tem_outra VALUES('Material', 'Material diverso');

INSERT INTO tem_outra VALUES('Bebidas', 'Bebidas Quentes');
INSERT INTO tem_outra VALUES('Bebidas', 'Bebidas Frias');

INSERT INTO tem_outra VALUES('Comida', 'Comida Saudável');
INSERT INTO tem_outra VALUES('Comida', 'Comida - Chips');
INSERT INTO tem_outra VALUES('Comida', 'Comida - Diversa');

-- Lvl 2 => Lvl 3
INSERT INTO tem_outra VALUES('Bebidas Quentes', 'Bebidas Quentes sem açucar');
INSERT INTO tem_outra VALUES('Bebidas Quentes', 'Bebidas Quentes com açucar');
INSERT INTO tem_outra VALUES('Bebidas Frias', 'Bebidas Frias sem açucar');
INSERT INTO tem_outra VALUES('Bebidas Frias', 'Bebidas Frias com açucar');


----------- produto
INSERT INTO produto VALUES('7666524286794', 'Doritos Banana', 'Comida - Chips');
INSERT INTO produto VALUES('9519839391742', 'Maçã Reineta', 'Comida Saudável');
INSERT INTO produto VALUES('8228319498508', 'Tofu', 'Comida Saudável');
INSERT INTO produto VALUES('7897560363456', 'Cola UHU batom', 'Material de artes');
INSERT INTO produto VALUES('8476179764055', 'Caneta BIC azul-clara', 'Material de escrita');
INSERT INTO produto VALUES('8608781717131', 'Tesoura sem pontas', 'Material de artes');
INSERT INTO produto VALUES('9745636370867', 'Pato de borracha amarelo', 'Material diverso');
INSERT INTO produto VALUES('1142135172864', 'Pastilha elástica sabor canela', 'Comida - Diversa');
INSERT INTO produto VALUES('3721299173738', 'Caramelos cremosos', 'Comida - Diversa');
INSERT INTO produto VALUES('2003201507481', 'Coca-Cola zero', 'Bebidas Frias sem açucar');
INSERT INTO produto VALUES('2003201507482', 'Pepsi Max', 'Bebidas Frias sem açucar');
INSERT INTO produto VALUES('9327697790291', 'Coca-Cola caramelo', 'Bebidas Frias com açucar');
INSERT INTO produto VALUES('4906557087560', 'Fanta limão', 'Bebidas Frias com açucar');
INSERT INTO produto VALUES('4885688144658', 'Iced Tea pêssego', 'Bebidas Frias com açucar');
INSERT INTO produto VALUES('1793985090306', 'Chá de limão', 'Bebidas Quentes com açucar');
INSERT INTO produto VALUES('8524357146284', 'Copo de leite', 'Bebidas Quentes sem açucar');
INSERT INTO produto VALUES('7988481049998', 'Cappuccino', 'Bebidas Quentes com açucar');
INSERT INTO produto VALUES('1839347963471', 'Starbuck coffee', 'Bebidas Frias com açucar');
INSERT INTO produto VALUES('6256453770703', 'Cones de milho', 'Comida - Diversa');
INSERT INTO produto VALUES('8973425695373', 'Pringles simples', 'Comida - Chips');
INSERT INTO produto VALUES('3584420578315', 'Pringles Cebola', 'Comida - Chips');


----------- tem_categoria
INSERT INTO tem_categoria VALUES('7666524286794', 'Comida - Chips');
INSERT INTO tem_categoria VALUES('9519839391742', 'Comida Saudável');
INSERT INTO tem_categoria VALUES('8228319498508', 'Comida Saudável');
INSERT INTO tem_categoria VALUES('7897560363456', 'Material de artes');
INSERT INTO tem_categoria VALUES('8476179764055', 'Material de escrita');
INSERT INTO tem_categoria VALUES('8608781717131', 'Material de artes');
INSERT INTO tem_categoria VALUES('9745636370867', 'Material diverso');
INSERT INTO tem_categoria VALUES('1142135172864', 'Comida - Diversa');
INSERT INTO tem_categoria VALUES('3721299173738', 'Comida - Diversa');
INSERT INTO tem_categoria VALUES('2003201507481', 'Bebidas Frias sem açucar');
INSERT INTO tem_categoria VALUES('2003201507482', 'Bebidas Frias sem açucar');
INSERT INTO tem_categoria VALUES('9327697790291', 'Bebidas Frias com açucar');
INSERT INTO tem_categoria VALUES('4906557087560', 'Bebidas Frias com açucar');
INSERT INTO tem_categoria VALUES('4885688144658', 'Bebidas Frias com açucar');
INSERT INTO tem_categoria VALUES('1793985090306', 'Bebidas Quentes com açucar');
INSERT INTO tem_categoria VALUES('8524357146284', 'Bebidas Quentes sem açucar');
INSERT INTO tem_categoria VALUES('7988481049998', 'Bebidas Quentes com açucar');
INSERT INTO tem_categoria VALUES('1839347963471', 'Bebidas Frias com açucar');
INSERT INTO tem_categoria VALUES('6256453770703', 'Comida - Diversa');
INSERT INTO tem_categoria VALUES('8973425695373', 'Comida - Chips');
INSERT INTO tem_categoria VALUES('3584420578315', 'Comida - Chips');


----------- IVM
INSERT INTO IVM VALUES('11345', 'Pedro Lda.');
INSERT INTO IVM VALUES('6789', 'Pedro Lda.');
INSERT INTO IVM VALUES('121212', 'Joao Lda.');
INSERT INTO IVM VALUES('343434', 'Joao Lda.');
INSERT INTO IVM VALUES('555555', 'Ricardo Lda.');
INSERT INTO IVM VALUES('666666', 'Ricardo Lda.');

----------- ponto_de_retalho
INSERT INTO ponto_de_retalho VALUES('IST - Alameda', 'Lisboa', 'Lisboa');
INSERT INTO ponto_de_retalho VALUES('IST - Taguspark', 'Lisboa', 'Oeiras');
INSERT INTO ponto_de_retalho VALUES('MCDonalds Sintra', 'Sintra', 'Sintra');
INSERT INTO ponto_de_retalho VALUES('Alverca FC', 'Lisboa', 'Vila Franca de Xira');
INSERT INTO ponto_de_retalho VALUES('Metro do Porto', 'Porto', 'Porto');
INSERT INTO ponto_de_retalho VALUES('Forum Algarve', 'Faro', 'Algarve');


----------- instalada_em
INSERT INTO instalada_em VALUES(11345, 'Pedro Lda.', 'IST - Alameda');
INSERT INTO instalada_em VALUES(6789, 'Pedro Lda.', 'MCDonalds Sintra');
INSERT INTO instalada_em VALUES(121212,  'Joao Lda.', 'IST - Taguspark');
INSERT INTO instalada_em VALUES(343434,  'Joao Lda.', 'Alverca FC');
INSERT INTO instalada_em VALUES(555555, 'Ricardo Lda.', 'Metro do Porto');
INSERT INTO instalada_em VALUES(666666, 'Ricardo Lda.', 'Forum Algarve');





/* 
INSERT INTO prateleira VALUES( );


INSERT INTO planograma VALUES( );


INSERT INTO retalhista VALUES( );


INSERT INTO responsavel_por VALUES( );


INSERT INTO evento_reposicao VALUES( ); 
*/