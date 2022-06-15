#!/usr/bin/python3

from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

## Libs postgres
import psycopg2
import psycopg2.extras

app = Flask(__name__, static_url_path='/static')

## SGBD configs
DB_HOST="db.tecnico.ulisboa.pt"
DB_USER="ist199298" 
DB_DATABASE=DB_USER
DB_PASSWORD="vgod7787"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)

FILENAME = "projetoBD-2021_2022-Entrega3.cgi"


@app.route("/")
def index():
    return render_template("index.html", FILENAME=FILENAME)


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
        
        manuf = request.form["manuf"]
        serial_nr = request.form["serial_nr"]
        
        # TODO mudar esta query
        query = "UPDATE account SET balance=%s WHERE account_number = %s"
        data = (manuf, serial_nr)
        cursor.execute(query, data)
        return render_template("listIVMSpecificEvent.html", cursor=cursor, FILENAME=FILENAME)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


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




@app.route("/remove_retailer")
def remove_retailer():
    # TODO implementar. Fazer query em SQL em que apago todos os produtos do retailhista, depois o retalhista. Tem que ser uma transação. De alguma forma, usar params=request.args para sacar o TIN do retalhista. Gerar HTML a dizer "o retalhista *nome* com o TIN *TIN* foi removido com sucesso, tais como os seus produtos."
    pass


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
  



