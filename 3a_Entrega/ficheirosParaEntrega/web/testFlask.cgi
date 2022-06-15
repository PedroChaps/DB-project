#!/usr/bin/python3

from wsgiref.handlers import CGIHandler
from flask import Flask

## Libs postgres
import psycopg2
import psycopg2.extras

app = Flask(__name__)

## SGBD configs
DB_HOST="db.tecnico.ulisboa.pt"
DB_USER="ist199298" 
DB_DATABASE=DB_USER
DB_PASSWORD="vgod7787"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)


## Runs the function once the root page is requested.
## The request comes with the folder structure setting ~/web as the root
@app.route('/')
def list_accounts():
  dbConn=None
  cursor=None
  try:
    dbConn = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
    query = "SELECT * FROM account;"
    cursor.execute(query)

    rowcount=cursor.rowcount
    
    #String interpolation method called f-strings added to Python 3.6
    #We will use it to build the html string that is going to be used to build the page
    html=f'''      
    <!DOCTYPE html>
    <html>
      <head>
        <title>List accounts - Python</title>
      </head>
      <body style="padding:20px">
        <table border="3">
          <thead>
            <tr>
              <th>account_number</th>
              <th>branch_name</th>
              <th>balance</th>
            </tr>
          </thead>
          <tbody>
    '''
    for record in cursor:
      html+=f'''
                <tr>
                  <td>{record[0]}</td>
                  <td>{record[1]}</td>
                  <td>{record[2]}</td>
              </tr>
      '''
        
    html+='''
              <tbody
            </table>
      </body>
    </html>
    '''
    
    return html #Renders the html string
  except Exception as e:
    return e #Renders a page with the error.
  finally:
    cursor.close()
    dbConn.close()

CGIHandler().run(app)    



