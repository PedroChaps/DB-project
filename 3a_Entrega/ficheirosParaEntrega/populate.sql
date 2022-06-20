DROP TABLE categoria CASCADE;
DROP TABLE categoria_simples CASCADE;
DROP TABLE super_categoria CASCADE;
DROP TABLE tem_outra CASCADE;
DROP TABLE produto CASCADE;
DROP TABLE tem_categoria CASCADE;
DROP TABLE IVM CASCADE;
DROP TABLE ponto_de_retalho CASCADE;
DROP TABLE instalada_em CASCADE;
DROP TABLE prateleira CASCADE;
DROP TABLE planograma CASCADE;
DROP TABLE retalhista CASCADE;
DROP TABLE responsavel_por CASCADE;
DROP TABLE evento_reposicao CASCADE;

--------------------------------------------------------------------------
--------------------------  Criacao de tabelas  --------------------------
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
-------------------------  Insercao de valores  -------------------------
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
INSERT INTO categoria VALUES('Bebidas Frias sem açúcar');
INSERT INTO categoria VALUES('Bebidas Frias com açúcar');
INSERT INTO categoria VALUES('Bebidas Quentes sem açúcar');
INSERT INTO categoria VALUES('Bebidas Quentes com açúcar');


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
INSERT INTO categoria_simples VALUES('Bebidas Frias sem açúcar');
INSERT INTO categoria_simples VALUES('Bebidas Frias com açúcar');
INSERT INTO categoria_simples VALUES('Bebidas Quentes sem açúcar');
INSERT INTO categoria_simples VALUES('Bebidas Quentes com açúcar');


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
INSERT INTO tem_outra VALUES('Bebidas Quentes', 'Bebidas Quentes sem açúcar');
INSERT INTO tem_outra VALUES('Bebidas Quentes', 'Bebidas Quentes com açúcar');
INSERT INTO tem_outra VALUES('Bebidas Frias', 'Bebidas Frias sem açúcar');
INSERT INTO tem_outra VALUES('Bebidas Frias', 'Bebidas Frias com açúcar');


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
INSERT INTO produto VALUES('2003201507481', 'Coca-Cola zero', 'Bebidas Frias sem açúcar');
INSERT INTO produto VALUES('2003201507482', 'Pepsi Max', 'Bebidas Frias sem açúcar');
INSERT INTO produto VALUES('9327697790291', 'Coca-Cola caramelo', 'Bebidas Frias com açúcar');
INSERT INTO produto VALUES('4906557087560', 'Fanta limão', 'Bebidas Frias com açúcar');
INSERT INTO produto VALUES('4885688144658', 'Iced Tea pêssego', 'Bebidas Frias com açúcar');
INSERT INTO produto VALUES('1793985090306', 'Chá de limao', 'Bebidas Quentes com açúcar');
INSERT INTO produto VALUES('8524357146284', 'Copo de leite', 'Bebidas Quentes sem açúcar');
INSERT INTO produto VALUES('7988481049998', 'Cappuccino', 'Bebidas Quentes com açúcar');
INSERT INTO produto VALUES('1839347963471', 'Starbuck coffee', 'Bebidas Frias com açúcar');
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
INSERT INTO tem_categoria VALUES('2003201507481', 'Bebidas Frias sem açúcar');
INSERT INTO tem_categoria VALUES('2003201507482', 'Bebidas Frias sem açúcar');
INSERT INTO tem_categoria VALUES('9327697790291', 'Bebidas Frias com açúcar');
INSERT INTO tem_categoria VALUES('4906557087560', 'Bebidas Frias com açúcar');
INSERT INTO tem_categoria VALUES('4885688144658', 'Bebidas Frias com açúcar');
INSERT INTO tem_categoria VALUES('1793985090306', 'Bebidas Quentes com açúcar');
INSERT INTO tem_categoria VALUES('8524357146284', 'Bebidas Quentes sem açúcar');
INSERT INTO tem_categoria VALUES('7988481049998', 'Bebidas Quentes com açúcar');
INSERT INTO tem_categoria VALUES('1839347963471', 'Bebidas Frias com açúcar');
INSERT INTO tem_categoria VALUES('6256453770703', 'Comida - Diversa');
INSERT INTO tem_categoria VALUES('8973425695373', 'Comida - Chips');
INSERT INTO tem_categoria VALUES('3584420578315', 'Comida - Chips');


----------- IVM
INSERT INTO IVM VALUES('11345', 'Pedro Lda.');
INSERT INTO IVM VALUES('6789', 'Pedro Lda.');
INSERT INTO IVM VALUES('121212', 'João Lda.');
INSERT INTO IVM VALUES('343434', 'João Lda.');
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
INSERT INTO instalada_em VALUES(121212,  'João Lda.', 'IST - Taguspark');
INSERT INTO instalada_em VALUES(343434,  'João Lda.', 'Alverca FC');
INSERT INTO instalada_em VALUES(555555, 'Ricardo Lda.', 'Metro do Porto');
INSERT INTO instalada_em VALUES(666666, 'Ricardo Lda.', 'Forum Algarve');


----------- prateleira
INSERT INTO prateleira VALUES(1, '11345', 'Pedro Lda.', 30, 'Comida - Chips');
INSERT INTO prateleira VALUES(2, '11345', 'Pedro Lda.', 70, 'Comida Saudável');
INSERT INTO prateleira VALUES(3, '11345', 'Pedro Lda.', 50, 'Comida - Diversa');

INSERT INTO prateleira VALUES(1, '6789', 'Pedro Lda.', 50, 'Material de artes');
INSERT INTO prateleira VALUES(2, '6789', 'Pedro Lda.', 30, 'Material de escrita');
INSERT INTO prateleira VALUES(3, '6789', 'Pedro Lda.', 50, 'Material diverso');

INSERT INTO prateleira VALUES(1, '121212', 'João Lda.', 70, 'Comida Saudável');
INSERT INTO prateleira VALUES(2, '121212', 'João Lda.', 85, 'Bebidas Frias sem açúcar');
INSERT INTO prateleira VALUES(3, '121212', 'João Lda.', 50, 'Bebidas Quentes sem açúcar');

INSERT INTO prateleira VALUES(1, '343434', 'João Lda.', 30,  'Comida - Chips');
INSERT INTO prateleira VALUES(2, '343434', 'João Lda.', 30, 'Bebidas Frias com açúcar');
INSERT INTO prateleira VALUES(3, '343434', 'João Lda.', 40, 'Bebidas Quentes com açúcar');

INSERT INTO prateleira VALUES(1, '555555', 'Ricardo Lda.', 50, 'Material de escrita');
INSERT INTO prateleira VALUES(2, '555555', 'Ricardo Lda.', 40, 'Comida - Diversa');
INSERT INTO prateleira VALUES(3, '555555', 'Ricardo Lda.', 30, 'Bebidas Frias sem açúcar');

INSERT INTO prateleira VALUES(1, '666666', 'Ricardo Lda.', 85, 'Comida - Chips');
INSERT INTO prateleira VALUES(2, '666666', 'Ricardo Lda.', 40, 'Bebidas Quentes com açúcar');
INSERT INTO prateleira VALUES(3, '666666', 'Ricardo Lda.', 70,  'Material de artes');


----------- planograma
INSERT INTO planograma VALUES(7666524286794, 1, '11345', 'Pedro Lda.', 4, 20, ' ');
INSERT INTO planograma VALUES(9519839391742, 2, '11345', 'Pedro Lda.', 5, 30, ' ');

INSERT INTO planograma VALUES(8228319498508, 1, '6789', 'Pedro Lda.', 6, 40, ' ');

INSERT INTO planograma VALUES(7897560363456, 1, '121212', 'João Lda.', 3, 20, ' ');
INSERT INTO planograma VALUES(8476179764055, 2, '121212', 'João Lda.', 7, 20, ' ');
INSERT INTO planograma VALUES(8608781717131, 3, '121212', 'João Lda.', 8, 30, ' ');

INSERT INTO planograma VALUES(9745636370867, 1, '343434', 'João Lda.', 4, 10, ' ');

INSERT INTO planograma VALUES(1142135172864, 1, '555555', 'Ricardo Lda.', 9, 20, ' ');
INSERT INTO planograma VALUES(2003201507481, 2, '555555', 'Ricardo Lda.', 5, 20, ' ');

INSERT INTO planograma VALUES(9327697790291, 1, '666666', 'Ricardo Lda.', 6, 30, ' ');


----------- retalhista
INSERT INTO retalhista VALUES(111111111, 'Jorge');
INSERT INTO retalhista VALUES(222222222, 'Fátima');
INSERT INTO retalhista VALUES(333333333, 'Raul');
INSERT INTO retalhista VALUES(444444444, 'Rui');
INSERT INTO retalhista VALUES(555555555, 'Alfredo');
INSERT INTO retalhista VALUES(666666666, 'José');



----------- responsavel_por
INSERT INTO responsavel_por VALUES('Comida Saudável', 111111111, '11345', 'Pedro Lda.');
INSERT INTO responsavel_por VALUES('Comida - Chips', 222222222, '121212', 'João Lda.');
INSERT INTO responsavel_por VALUES('Bebidas Frias com açúcar', 333333333, '555555', 'Ricardo Lda.');
INSERT INTO responsavel_por VALUES('Bebidas Quentes com açúcar', 444444444, '666666', 'Ricardo Lda.');
INSERT INTO responsavel_por VALUES('Material de artes', 555555555, '343434', 'João Lda.');
INSERT INTO responsavel_por VALUES('Material diverso', 666666666, '6789', 'Pedro Lda.');


----------- evento_reposicao
INSERT INTO evento_reposicao VALUES(7666524286794, 1, '11345', 'Pedro Lda.', '2022-01-02 10:34:15.123', 4, 111111111);
INSERT INTO evento_reposicao VALUES(9519839391742, 2, '11345', 'Pedro Lda.', '2022-01-03 11:34:15.145', 5, 111111111);

INSERT INTO evento_reposicao VALUES(2003201507481, 2, '555555', 'Ricardo Lda.', '2022-06-02 21:14:15.653', 6, 222222222);

INSERT INTO evento_reposicao VALUES(7897560363456, 1, '121212', 'João Lda.', '2022-01-02 22:54:17.889', 7, 333333333);
INSERT INTO evento_reposicao VALUES(8476179764055, 2, '121212', 'João Lda.', '2022-04-04 14:14:15.113', 8, 333333333);

INSERT INTO evento_reposicao VALUES(9327697790291, 1, '666666', 'Ricardo Lda.', '2022-11-11 11:11:11.111', 1, 444444444);

INSERT INTO evento_reposicao VALUES(9745636370867, 1, '343434', 'João Lda.', '2022-12-21 12:21:12.212', 2, 555555555);
INSERT INTO evento_reposicao VALUES(9745636370867, 1, '343434', 'João Lda.', '2022-01-01 01:01:01.123', 3, 555555555);
INSERT INTO evento_reposicao VALUES(9745636370867, 1, '343434', 'João Lda.', '2022-01-04 10:44:44.123', 4, 555555555);

INSERT INTO evento_reposicao VALUES(8228319498508, 1, '6789', 'Pedro Lda.', '2022-01-03 10:34:16.123', 5, 666666666);
