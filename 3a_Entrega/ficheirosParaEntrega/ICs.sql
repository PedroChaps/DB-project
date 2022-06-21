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

CREATE OR REPLACE FUNCTION get_sub_categs(name VARCHAR, dbConn, cursor)
RETURNS VARCHAR AS
$$
BEGIN
records = []
queue = [name]

while len(queue) != 0:
    currentName = queue.pop(0)
    querry = f"SELECT categoria FROM tem_outra WHERE super_categoria = {currentName}"   
    
    cursor.execute(querry) 
    for record in cursor: 
        queue.append(record[0])
        records.append(record[0])
        
    cursor.close()
    cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    
return records
END;
$$ LANGUAGE python;

-- 1º: Vamos buscar a categoria da prateleira 
-- 2º: A partir da categoria obtemos todas as suas sub_categorias
-- 3º: verificamos se alguma delas coincide com a categoria do produto
CREATE OR REPLACE FUNCTION check_product_can_be_replenished_on_shelf_proc() 
RETURNS TRIGGER AS
$$
DECLARE categoria_prat VARCHAR
DECLARE categoria_prod VARCHAR;
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

    IF categoria_prat != categoria_prod THEN
        RAISE EXCEPTION 'Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das Categorias desse produto';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_product_can_be_replenished_on_shelf_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE check_product_can_be_replenished_on_shelf_proc();