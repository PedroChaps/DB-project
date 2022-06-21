-- Qual o nome do retalhista (ou retalhistas) responsáveis pela reposição do maior número de categorias?

SELECT s.nome
FROM (
    SELECT r.nome, COUNT(DISTINCT rp.nome_cat)
    FROM retalhista as r, responsavel_por as rp
    WHERE r.tin = rp.tin
    GROUP BY r.nome, rp.tin
) as s
WHERE s.count >= ALL (
    SELECT MAX(s.count)
    FROM (
    SELECT r.nome, COUNT(DISTINCT rp.nome_cat)
    FROM retalhista as r, responsavel_por as rp
    WHERE r.tin = rp.tin
    GROUP BY r.nome, rp.tin
) as s);

-- Qual o nome do ou dos retalhistas que são responsáveis por todas as categorias simples?

SELECT s.nome
FROM (
    SELECT r.nome, COUNT(DISTINCT rp.nome_cat)
    FROM retalhista as r, responsavel_por as rp, categoria_simples as c
    WHERE r.tin = rp.tin
        AND rp.nome_cat = c.nome
    GROUP BY r.nome, rp.tin
) as s
WHERE s.count >= ALL (
    SELECT COUNT (*)
    FROM categoria_simples
)

-- Quais os produtos (ean) que nunca foram repostos?

SELECT ean
FROM produto
WHERE ean NOT IN (
    SELECT ean
    FROM evento_reposicao
);

-- Quais os produtos (ean) que foram repostos sempre pelo mesmo retalhista?

SELECT ean
FROM (SELECT er.ean, COUNT(DISTINCT er.tin)
    FROM evento_reposicao as er
    GROUP BY er.ean
) as s
WHERE s.count = 1;