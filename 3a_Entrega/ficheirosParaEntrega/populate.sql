create table categoria (
    nome varchar(80),
    constraint pk_categoria primary key(nome)
);

create table categoria_simples (
    nome varchar(80),
    constraint pk_categoria_simples primary key(nome),
    constraint fk_categoria_simples_categoria foreign key(nome) references categoria(nome)
);

create table super_categoria (
    nome varchar(80),
    constraint pk_super_categoria primary key(nome),
    constraint fk_super_categoria_categoria foreign key(nome) references categoria(nome)
);

create table tem_outra (
    super_categoria varchar(80),
    categoria varchar(80),
    constraint pk_tem_outra primary key(categoria),
    constraint fk_tem_outra_super_categoria foreign key(super_categoria) references super_categoria(nome),
    constraint fk_tem_outra_categoria foreign key(categoria) references categoria(nome)
);

create table produto (
    ean integer,
    cat varchar(80),
    descr varchar(420),
    constraint pk_produto primary key(ean),
    constraint fk_produto_categoria foreign key(cat) references categoria(nome)
);

create table tem_categoria (
    ean integer,
    nome varchar(80),
    constraint pk_tem_categoria primary key(ean, nome),
    constraint fk_tem_categoria_produto foreign key(ean) references produto(ean),
    constraint fk_tem_categoria_categoria foreign key(nome) references categoria(nome)
);

create table IVM (
    num_serie integer,
    fabricante varchar(80),
    constraint pk_IVM primary key(num_serie, fabricante)
);

create table ponto_de_retalho (
    nome varchar(80),
    distrito varchar(80),
    concelho varchar(80),
    constraint pk_ponto_de_retalho primary key(nome)
);

create table instalada_em (
    num_erie integer, 
    fabricante varchar(80),
    local_ varchar(80),
    constraint pk_instalada_em primary key (num_serie, fabricante),
    constraint fk_instalada_em_IVM foreign key (num_serie, fabricante) references IVM(num_serie, fabricante)
);



-- TODO
-- [ ] verificar as RIs
-- [ ] verificar os UNIQUEs, NOT NULLs, etc.