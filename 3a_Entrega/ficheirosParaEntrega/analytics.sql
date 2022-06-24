----------- 1

-- o número total de artigos vendidos num dado período (i.e. entre duas datas), por dia da semana, por concelho e no total;

SELECT v.dia_semana, v.concelho, SUM(v.unidades) AS unidades_totais
FROM Vendas v
WHERE make_date(v.ano, v.mes, v.dia_mes) BETWEEN make_date(2020, 07, 09) AND make_date(2022, 08, 14)
GROUP BY 
  GROUPING SETS((v.dia_semana), (v.concelho), ())
  ORDER BY v.concelho, v.dia_semana;
  
  
----------- 2

-- o número total de artigos vendidos num dado distrito (i.e. “Lisboa”), por concelho, categoria, dia da semana e no total


SELECT v.concelho, v.cat, v.dia_semana, SUM(v.unidades) AS unidades_totais
FROM Vendas v
WHERE v.distrito = "Lisboa"
GROUP BY 
  CUBE(v.concelho, v.cat, v.dia_semana);
