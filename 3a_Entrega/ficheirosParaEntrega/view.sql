CREATE VIEW vendas(ean, cat, ano, trimeste, mes, dia_mes, dia_semana, distrito, concelho, unidades)
AS
SELECT er.ean, p.cat, EXTRACT(YEAR FROM er.instante)::INTEGER, EXTRACT(QUARTER FROM er.instante)::INTEGER,
    EXTRACT(MONTH FROM er.instante)::INTEGER, EXTRACT(DAY FROM er.instante)::INTEGER,
    EXTRACT(DOW FROM er.instante)::INTEGER, pr.distrito, pr.concelho, er.unidades
FROM evento_reposicao as er, produto as p, instalada_em as ie, ponto_de_retalho as pr
WHERE er.ean = p.ean
    AND er.num_serie = ie.num_serie
    AND ie.local_ = pr.nome;