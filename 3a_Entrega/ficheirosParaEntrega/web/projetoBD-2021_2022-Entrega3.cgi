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
        
        
        # TODO mudar esta query de contas para super-categs e categs dos retalhistas
        query = "SELECT account_number, branch_name, balance FROM account;"
        
        cursor.execute(query)
        rowsSuperCategories = cursor.fetchall()
        
        # TODO mudar esta query de contas para super-categs e categs dos retalhistas
        query = "SELECT account_number, branch_name, balance FROM account;"
        
        cursor.execute(query)
        rowsSubCategories = cursor.fetchall()
        
        
        return render_template("updateCategories.html", rowsSuperCategories=rowsSuperCategories, rowsSubCategories=rowsSubCategories, FILENAME=FILENAME)
    except Exception as e:
        return str(e)
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
        
        

        # TODO mudar esta query
        #query = "UPDATE account SET balance=%s WHERE account_number = %s"
        #data = (manuf, serial_nr)
        #cursor.execute(query, data)
        return render_template("add_subCateg_to_superCateg-Success.html", FILENAME=FILENAME, superCategName=superCategName,simpleCategName=simpleCategName)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/remove_superCateg")
def remove_superCateg():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        superCategName = request.args["superCategName"]

        # TODO mudar esta query
        #query = "UPDATE account SET balance=%s WHERE account_number = %s"
        #data = (manuf, serial_nr)
        #cursor.execute(query, data)
        return render_template("removeSuperCateg-Success.html", cursor=cursor, FILENAME=FILENAME, superCategName=superCategName)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/add_superCateg", methods=["POST"])
def add_superCateg():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        name = request.form["name"]

        # TODO mudar esta query
        #query = "UPDATE account SET balance=%s WHERE account_number = %s"
        #data = (tin, name)
        #cursor.execute(query, data)
        return render_template("add_superCateg-Success.html", cursor=cursor, FILENAME=FILENAME)

    except Exception as e:
        return str(e)

    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/remove_subCateg")
def remove_subCateg():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        subCategName = request.args["subCategName"]

        # TODO mudar esta query
        #query = "UPDATE account SET balance=%s WHERE account_number = %s"
        #data = (manuf, serial_nr)
        #cursor.execute(query, data)
        return render_template("removeSubCateg-Success.html", cursor=cursor, FILENAME=FILENAME, subCategName=subCategName)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()



@app.route("/add_subCateg", methods=["POST"])
def add_subCateg():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        name = request.form["name"]
    
        # TODO mudar esta query
        #query = "UPDATE account SET balance=%s WHERE account_number = %s"
        #data = (tin, name)
        #cursor.execute(query, data)
        return render_template("add_subCateg-Success.html", FILENAME=FILENAME, name=name)

    except Exception as e:
        return str(e)

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
        # TODO mudar esta query de contas para TINs e nomes dos retalhistas
        query = "SELECT account_number, branch_name, balance FROM account;"
        cursor.execute(query)
        return render_template("updateRetailers.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/add_retailer")
def add_retailer():
    try:
        return render_template("addRetailer.html", FILENAME=FILENAME)
    except Exception as e:
        return str(e)


@app.route("/insert_retailer", methods=["POST"])
def insert_retailer():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        tin = request.form["TIN"]
        name = request.form["name"]

        # TODO perceber o .commit(), visto que não começa a transaction em lado nenhum
        # TODO mudar esta query de contas para inserir um novo retalhista com tin tin e nome name
        #query = "UPDATE account SET balance=%s WHERE account_number = %s"
        #data = (tin, name)
        #cursor.execute(query, data)
        return render_template("addRetailer-Success.html", FILENAME=FILENAME)

    except Exception as e:
        return str(e)

    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/remove_retailer")
def remove_retailer():
    # TODO implementar. Fazer query em SQL em que apago todos os produtos do retailhista, depois o retalhista. Parecido ao list_IVM_specific_event(). Tem que ser uma transação. De alguma forma, usar params=request.args para sacar o TIN do retalhista. Gerar HTML a dizer "o retalhista *nome* com o TIN *TIN* foi removido com sucesso, tais como os seus produtos."
    return render_template("removeRetailer-Success.html", FILENAME=FILENAME)
    

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
        # TODO mudar esta query de contas para nomes das IVMs
        query = "SELECT account_number, branch_name, balance FROM account;"
        cursor.execute(query)
        return render_template("listIVMevents.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return str(e)
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
        
        # TODO mudar esta query
        #query = "UPDATE account SET balance=%s WHERE account_number = %s"
        #data = (manuf, serial_nr)
        #cursor.execute(query, data)
        return render_template("listIVMSpecificEvent.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return str(e)
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
        # TODO mudar esta query de contas para nomes das IVMs
        query = "SELECT account_number FROM account;"
        cursor.execute(query)
        return render_template("listSub-categs.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return str(e)
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
        
        records = getSubCategs(name, dbConn, cursor)
        
        return render_template("listSub-categsFromSuper-categ.html", name=name, records=records, FILENAME=FILENAME)
        
    except Exception as e:
        return str(e)
        
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()



def getSubCategs(name, dbConn, cursor):
    
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
            
    
# ———————————————————————————————————————————————————————————————————————————————————————————————————————








# TODO Geral
# [ ] - "Adicionar sub-categoria"
# [ ] - meter h1 depois do Tecnico Lisboa a dizer "projeto BD - parte 3", com as mesmas cores dos relatórios
# [ ] - Quando insiro categoria, meter página de sucesso
# [ ] - Quando removo categoria, meter página de sucesso
# [ ] - Quando removo retalhista, meter página de sucesso
# [ ] - ver a cena da atomicidade, fazer commit no fim de todas as transações 






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
        return str(e)  # Renders a page with the error.
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
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/balance")
def change_balance():
    try:
        return render_template("balance.html", params=request.args)
    except Exception as e:
        return str(e)


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
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\


CGIHandler().run(app)
