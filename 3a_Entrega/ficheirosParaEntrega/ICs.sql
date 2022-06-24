DROP TRIGGER IF EXISTS check_category_not_contains_itself_trigger
ON tem_outra;

DROP TRIGGER IF EXISTS check_number_units_not_superior_planogram_trigger
ON evento_reposicao;

DROP TRIGGER IF EXISTS check_product_can_be_replenished_on_shelf_trigger
ON evento_reposicao;


-- (RI-1) Uma Categoria não pode estar contida em si própria --

CREATE OR REPLACE FUNCTION check_category_not_contains_itself_proc() 
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.super_categoria = NEW.categoria THEN
        RAISE EXCEPTION 'Uma Categoria não pode estar contida em si própria';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_category_not_contains_itself_trigger
BEFORE UPDATE OR INSERT ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE check_category_not_contains_itself_proc();

-- (RI-4) O número de unidades repostas num Evento de Reposição não pode exceder o número de
-- unidades especificado no Planograma --

CREATE OR REPLACE FUNCTION check_number_units_not_superior_planogram_proc() 
RETURNS TRIGGER AS
$$
DECLARE unidades_planograma INTEGER;
BEGIN
    SELECT unidades INTO unidades_planograma
    FROM planograma as p
    WHERE p.ean = NEW.ean
        AND p.nro = NEW.nro
        AND p.num_serie = NEW.num_serie
        AND p.fabricante = NEW.fabricante;

    IF NEW.unidades > unidades_planograma THEN
        RAISE EXCEPTION 'O número de unidades repostas num Evento de Reposição não pode exceder o número de unidades especificado no Planograma';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_number_units_not_superior_planogram_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE check_number_units_not_superior_planogram_proc();

-- (RI-5) Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das
-- Categorias desse produto --

CREATE OR REPLACE FUNCTION check_product_can_be_replenished_on_shelf_proc() 
RETURNS TRIGGER AS
$$
DECLARE categoria_prat VARCHAR;
DECLARE categoria_prod VARCHAR;
DECLARE contem_cat_prod BOOLEAN;
BEGIN

     -- vai buscar a categoria da prateleira 
    SELECT nome INTO categoria_prat  
    FROM prateleira as p
    WHERE p.nro = NEW.nro
        AND p.num_serie = NEW.num_serie
        AND p.fabricante = NEW.fabricante;

    -- vai buscar a categoria do produto
    SELECT cat INTO categoria_prod
    FROM produto as p
    WHERE p.ean = NEW.ean;
    
    IF categoria_prod = categoria_prat THEN
        RETURN NEW;
    END IF;

    WITH RECURSIVE sub_categorias AS (
        SELECT categoria
        FROM tem_outra
        WHERE super_categoria = categoria_prat
    UNION
        SELECT te_o.categoria
        FROM tem_outra as te_o, sub_categorias as sc
        WHERE te_o.categoria = sc.categoria
    )
    SELECT EXISTS(SELECT 1 FROM sub_categorias as sc WHERE sc.categoria = categoria_prod) INTO contem_cat_prod;

    IF contem_cat_prod THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das Categorias desse produto';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_product_can_be_replenished_on_shelf_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE check_product_can_be_replenished_on_shelf_proc();