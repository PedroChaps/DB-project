#!/usr/bin/python3

from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

# Libs postgres
import psycopg2
import psycopg2.extras

app = Flask(__name__, static_url_path='/static')

# SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist199298"
DB_DATABASE = DB_USER
DB_PASSWORD = "vgod7787"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)

FILENAME = "projetoBD-2021_2022-Entrega3.cgi"
# ———————————————————————————————————————————————————————————————————————————————————————————————————————



@app.route("/")
def index():
    return render_template("index.html", FILENAME=FILENAME)





#                               Routes related to updates of categories
# ———————————————————————————————————————————————————————————————————————————————————————————————————————


@app.route("/update_categories")
def update_categories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        # TODO TODO TODO 
        # Há muita coisa para mudar aqui ainda
        
        query = "SELECT nome FROM categoria;"
        cursor.execute(query)
        
        return render_template("updateCategories.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/add_subCateg_to_superCateg", methods=["POST"])
def add_subCateg_to_superCateg():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        simpleCategName = request.form["simpleCategName"]
        superCategName = request.form["superCategName"]
        
        # Verifies if the sub-category is already registred in the database (the super-category is guaranteed to be registred)
        query = "SELECT DISTINCT nome FROM categoria WHERE nome=%s"
        cursor.execute(query, (simpleCategName,))
        
        # If there are no rows, then the sub-category isn't present in the database.
        # So, adds it to the category and sub-category tables. 
        if cursor.rowcount == 0:
            query = "INSERT INTO categoria VALUES(%s)"
            cursor.execute(query, (simpleCategName,))
            
            query = "INSERT INTO categoria_simples VALUES(%s)"
            cursor.execute(query, (simpleCategName,))
            
        # Also verifies if the super-category is already registredin the super_categoria table
        query = "SELECT DISTINCT nome FROM super_categoria WHERE nome=%s"
        cursor.execute(query, (superCategName,))
        
        if cursor.rowcount == 0:
            query = "INSERT INTO super_categoria VALUES(%s)"
            cursor.execute(query, (superCategName,))
        
        # Adds the sub-category -> super-category relation
        query = "INSERT INTO tem_outra VALUES(%s, %s)"
        cursor.execute(query, (superCategName, simpleCategName))
        
        # If the now super-category was a simple category, removes it from the categoria_simples table
        query = "DELETE FROM categoria_simples WHERE nome=%s"
        cursor.execute(query, (superCategName,))
        
        return render_template("add_subCateg_to_superCateg-Success.html", FILENAME=FILENAME, superCategName=superCategName,simpleCategName=simpleCategName)
        
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/remove_categ")
def remove_categ():
    dbConn = None
    cursor = None
    
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        categName = request.args["categName"]
        
        # Deletes the category from every place it can possibly be (DELETE works even if there is no entry with
        # the name).
        # Follows an order such that no dependecies are broken (Since categoria -> categoria_simples, super_categoria -> tem_outra)
        query = "DELETE FROM tem_outra WHERE super_categoria=%s"
        cursor.execute(query, (categName,))
        query = "DELETE FROM tem_outra WHERE categoria=%s"
        cursor.execute(query, (categName,))
        query = "DELETE FROM tem_categoria WHERE nome=%s"
        cursor.execute(query, (categName,))
        # Deletes the product first from planograma, then from the table produto
        # Finds the products first
        query = "SELECT ean FROM produto WHERE cat=%s"
        cursor.execute(query, (categName,))
        rows_product_ean = cursor.fetchall()
        
        # For a given product (that is about to be deleted), deletes it's entries from the
        # tables evento_reposicao and planograma
        for row in rows_product_ean:
            query = "DELETE FROM evento_reposicao WHERE ean=%s"
            cursor.execute(query, (row[0],))
        
            query = "DELETE FROM planograma WHERE ean=%s"
            cursor.execute(query, (row[0],))
        
        # Only then deletes the product
        query = "DELETE FROM produto WHERE cat=%s"
        cursor.execute(query, (categName,))
        
        # Prepares to delete the entries from prateleira
        query = "SELECT nro, num_serie, fabricante FROM prateleira WHERE nome=%s"
        cursor.execute(query, (categName,))
        rows_prateleira_nroNumserieFabricante = cursor.fetchall()
        
        # Before deleting the entries, finds all dependencies and deletes them first
        for row in rows_prateleira_nroNumserieFabricante:
            query = "DELETE FROM evento_reposicao WHERE nro=%s AND num_serie=%s AND fabricante=%s"
            cursor.execute(query, (row[0], row[1], row[2]))  
            query = "DELETE FROM planograma WHERE nro=%s AND num_serie=%s AND fabricante=%s"
            cursor.execute(query, (row[0], row[1], row[2]))     
        
        # Only then deletes the entries from prateleira
        query = "DELETE FROM prateleira WHERE nome=%s"
        cursor.execute(query, (categName,))
        
        # Also deletes from the table responsavel_por
        query = "DELETE FROM responsavel_por WHERE nome_cat=%s"
        cursor.execute(query, (categName,))
        
        # Deletes the final entries from the main tables
        query = "DELETE FROM categoria_simples WHERE nome=%s"
        cursor.execute(query, (categName,))
        query = "DELETE FROM super_categoria WHERE nome=%s"
        cursor.execute(query, (categName,))
        query = "DELETE FROM categoria WHERE nome=%s"
        cursor.execute(query, (categName,))

        return render_template("removeCateg-Success.html", cursor=cursor, FILENAME=FILENAME, categName=categName)
        
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
        
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/add_categ", methods=["POST"])
def add_categ():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        name = request.form["name"]
        
        # Since this is an independent query, adds it to the sub-category table as well as the category table.
        query = "INSERT INTO categoria VALUES(%s)"
        cursor.execute(query, (name,))
        query = "INSERT INTO categoria_simples VALUES(%s)"
        cursor.execute(query, (name,))
        
        
        return render_template("add_superCateg-Success.html", cursor=cursor, FILENAME=FILENAME)

    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)

    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()



# ———————————————————————————————————————————————————————————————————————————————————————————————————————



#                                   Routes related to updates of retailers
# ———————————————————————————————————————————————————————————————————————————————————————————————————————

@app.route("/update_retailers")
def update_retailers():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        query = "SELECT tin, nome FROM retalhista ORDER BY nome;"
        cursor.execute(query)
        return render_template("updateRetailers.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/add_retailer")
def add_retailer():
    try:
        return render_template("addRetailer.html", FILENAME=FILENAME)
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)


@app.route("/insert_retailer", methods=["POST"])
def insert_retailer():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        tin = request.form["TIN"]
        name = request.form["name"]
        
        query = "INSERT INTO retalhista VALUES(%s, %s)"
        cursor.execute(query, (tin, name))

        return render_template("addRetailer-Success.html", FILENAME=FILENAME)

    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)

    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/remove_retailer")
def remove_retailer():

    dbConn = None
    cursor = None
    
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        tin = request.args["TIN"]
        
        # Gets the products EANs that the retailer is responsible for
        query = "SELECT ean \
                 FROM retalhista r JOIN responsavel_por r_p ON r.tin = r_p.tin \
                 JOIN tem_categoria t_c ON t_c.nome = r_p.nome_cat \
                 WHERE r.tin = %s;"
        cursor.execute(query, (tin,))
        eans = cursor.fetchall()
        
        # Deletes the retailer from every place it can possibly be (DELETE works even if there is no entry with
        # the name).
        # Follows an order such that no dependecies are broken.
        query = "DELETE FROM responsavel_por WHERE tin=%s"
        cursor.execute(query, (tin,))
        query = "DELETE FROM evento_reposicao WHERE tin=%s"
        cursor.execute(query, (tin,))
        query = "DELETE FROM retalhista WHERE tin=%s"
        cursor.execute(query, (tin,))
        
        # Deletes the products that have the associated EAN from every table they participate
        for ean in eans:
            query = "DELETE FROM evento_reposicao WHERE ean=%s"
            cursor.execute(query, (ean[0],))
            query = "DELETE FROM planograma WHERE ean=%s"
            cursor.execute(query, (ean[0],))
            query = "DELETE FROM tem_categoria WHERE ean=%s"
            cursor.execute(query, (ean[0],))
            query = "DELETE FROM produto WHERE ean=%s"
            cursor.execute(query, (ean[0],))
            
        return render_template("removeRetailer-Success.html", cursor=cursor, FILENAME=FILENAME, tin=tin)
        
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
        
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()
# ———————————————————————————————————————————————————————————————————————————————————————————————————————




#                                   Routes related to listing IVM events
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
@app.route("/list_IVM_events")
def list_IVM_events():
    dbConn = None
    cursor = None
    
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        query = "SELECT fabricante, num_serie FROM IVM ORDER BY fabricante;"
        cursor.execute(query)
        
        return render_template("listIVMevents.html", cursor=cursor, FILENAME=FILENAME)
        
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
        
    finally:
        cursor.close()
        dbConn.close()


@app.route("/list_IVM_specific_event")
def list_IVM_specific_event():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        manuf = request.args["manuf"]
        serial_nr = request.args["serial_nr"]
        
        query = "SELECT cat, SUM(unidades)                                                \
                 FROM evento_reposicao JOIN produto ON evento_reposicao.ean = produto.ean \
                 GROUP BY cat, fabricante, num_serie                                      \
                 HAVING fabricante=%s AND num_serie=%s;"
        cursor.execute(query, (manuf, serial_nr))
        
        
        return render_template("listIVMSpecificEvent.html", cursor=cursor, FILENAME=FILENAME)
        
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
        
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()
# ———————————————————————————————————————————————————————————————————————————————————————————————————————




#                          Routes related to listing sub-categories of a super-categorie
# ———————————————————————————————————————————————————————————————————————————————————————————————————————

@app.route("/list_sub-categs")
def list_subcategs():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        query = "SELECT DISTINCT super_categoria FROM tem_outra;"
        cursor.execute(query)
        return render_template("listSub-categs.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/list_sub-categs_from_super-categ")
def list_subCategs_from_superCategs():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        name = request.args["name"]
        
        records = getSubCategs(name, cursor)
        
        return render_template("listSub-categsFromSuper-categ.html", name=name, records=records, FILENAME=FILENAME)
        
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
        
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


def getSubCategs(name, cursor):
    
    records = []
    queue = [name]
    
    while len(queue) != 0:
        currentName = queue.pop(0)
        querry = "SELECT categoria FROM tem_outra WHERE super_categoria=%s"   
        cursor.execute(querry, (currentName,)) 
        
        for record in cursor: 
            queue.append(record[0])
            records.append(record[0])
        
    return records
            
    
# ———————————————————————————————————————————————————————————————————————————————————————————————————————













# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

@app.route("/list_accounts")
def list_accounts():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM account;"
        cursor.execute(query)
        return render_template("index.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route("/accounts")
def list_accounts_edit():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT account_number, branch_name, balance FROM account;"
        cursor.execute(query)
        return render_template("accounts.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/balance")
def change_balance():
    try:
        return render_template("balance.html", params=request.args)
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)


@app.route("/update", methods=["POST"])
def update_balance():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        balance = request.form["balance"]
        account_number = request.form["account_number"]
        query = "UPDATE account SET balance=%s WHERE account_number = %s"
        data = (balance, account_number)
        cursor.execute(query, data)
        return query
    except Exception as e:
        return render_template("errors.html", error=str(e), FILENAME=FILENAME)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\


CGIHandler().run(app)
