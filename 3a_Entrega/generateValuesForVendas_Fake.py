out = ""
"""
CREATE TABLE Vendas_2_fake(ean NUMERIC, 
						   cat VARCHAR(40), 
						   ano INTEGER, 
						   trimestre INTEGER, 
                           mes INTEGER,
						   dia_mes INTEGER, 
						   dia_semana INTEGER, 
						   distrito INTEGER, 
						   concelho INTEGER, 
						   unidades INTEGER);
"""
categories = ['Material','Bebidas','Comida','Material de escrita','Material de artes','Material diverso','Bebidas Quentes','Bebidas Frias','Comida Saudável','Comida - Chips','Comida - Diversa','Bebidas Frias sem açúcar','Bebidas Frias com açúcar','Bebidas Quentes sem açúcar','Bebidas Quentes com açúcar']
districts = ["Lisboa", "Faro", "Porto", "Vila Real"]        
concelhos = ["Vila Franca", "Alverca", "Algarve", "Areeiro", "Santos"]
            
            
from random import randint             
              
for i in range(6969):
    out += "(" \
        + str(randint(1000000000000, 9999999999999)) + "," \
        + "'" + categories[randint(0, len(categories)-1)]  + "'" + "," \
        + str(randint(2000, 2022)) + "," \
        + str(randint(1, 4)) + "," \
        + str(randint(1, 12)) + "," \
        + str(randint(1, 26)) + "," \
        + str(randint(1, 7)) + "," \
        +"'" + districts[randint(0, len(districts)-1)] +"'" + "," \
        +"'" + concelhos[randint(0, len(concelhos)-1)] +"'" + "," \
        + str(randint(1, 69)) + "),\n"
        
print(out)