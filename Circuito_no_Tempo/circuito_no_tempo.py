from sympy.abc import s
import numpy as np
import pandas as pd

#tornando o arquivo csv um dataframe
circuito = pd.read_csv('circuito.csv', sep=',')

# - Quantos nós e quantos ramos existem no circuito?

#criando um dataframe que possui somente os nós
nos = circuito[['nó saída', 'nó chegada']]

#sabemos que a quantidade de nós vai ser dada pelo máximo número encontrado na tabela "nos" criada
quantidade_de_nos = nos.values.max()

#a quantidade de ramos é dada pela quantidade de linhas que possuimos na tabela.
quantidade_de_ramos = circuito.shape[0] 

#a matriz de incidencia completa terá dimensões quantidade_de_nos x quantidade_de_ramos
incidencia_completa = np.zeros((quantidade_de_nos, quantidade_de_ramos))

#Além disso terá 1 quando a corrente tiver saindo do nó e -1 quando estiver chegando
for ramo in range(quantidade_de_ramos): 
    #contando o nó a partir do zero
    no_de_saida = nos['nó saída'][ramo] - 1 
    no_de_chegada =  nos['nó chegada'][ramo] - 1

    incidencia_completa[no_de_saida,ramo] = 1
    incidencia_completa[no_de_chegada, ramo] = -1

#incidencia_reduzida será a matriz de incidência reduzida. Iremos retirar a última linha da incidencia_completa
incidencia_reduzida = incidencia_completa[:-1,:]

#Cálculo das impedâncias
#Resistivas:
circuito['impedancias'] = circuito['R(Ohm)']  

#indutivas
circuito['impedancias'] = circuito['impedancias'] + s * circuito['L(H)'] - circuito['I0(A)']  

#capacitivas
imp_capacitiva = 1/(s * circuito['C(F)']) + circuito['V0(V)']

#zerando a transformada de laplace para os ramos com capacitância nula
imp_capacitiva .loc[circuito['C(F)'] == 0] = 0
circuito['impedancias'] = circuito['impedancias'] + imp_capacitiva 


