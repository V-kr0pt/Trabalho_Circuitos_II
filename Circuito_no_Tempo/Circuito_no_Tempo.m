%Trabalho de circuitos Laplace
clear

%declarando s como vari�vel simb�lica
syms s;

%Receber arquivo csv e transformar a matriz de entrada para o formato sym
dados = csvread('tabela_de_entrada.csv',1,0);

% matriz dos n�s
nos= double(dados(:,2:3))

%o n�mero de n�s ser� dado pelo m�ximo valor de n� de 
%ambas as colunas
numero_de_nos = (max(max(nos))

%o n�mero de ramos ser� dado pelo n�mero de linhas 
%do arquivo
tamanho_do_arq = size(dados)
numero_de_ramos = tamanho_do_arq(1) 

%matriz de incid�ncia completa (n x b):
%incializando
matriz_inc_completa = zeros(numero_de_nos, numero_de_ramos)

%atribuindo orienta��o dos grafos
for ramo = 1:numero_de_ramos
    matriz_inc_completa(nos(ramo,1), ramo) = 1
    matriz_inc_completa(nos(ramo,2), ramo) = -1
end

%matriz reduzida

% como matriz_inc_completa � LD, podemos trabalhar com
% com uma matriz reduzida (A), retirando a �ltima linha
A = matriz_inc_completa(1:end-1,:)
%A transposta da matriz reduzida:
A_T = transpose(A) 

% Matriz de admit�ncia Yb:

%imped�ncia resultante para cada ramo:

%resistiva
R = double(dados(:, 4))
%indutiva
L = double(dados(:,5))
Xl = s * L
%capacitiva
Xc = 1/(s*double(dados(:,7)))
Xc = transpose(Xc)
Xc(Xc(:) == Inf)=0

%imped�ncia equivalente 
Zeq = R + Xl + Xc

%admit�ncia equivalente
Yeq = 1./Zeq(:)

%Criando a matriz admit�ncia de ramo: Yb (diagonal)
Yb = diag(Yeq)

%Admit�ncia de n�
Yn = A * Yb * A_T

% -- Fontes de Independentes --

%Fontes de tens�o
%coluna 9: Vind, coluna 8: V0
Vs = double(dados(:,9)) + double(dados(:,8))
%coluna 6: I0
Vs = Vs/s + L.*double(dados(:,6))

%Fonte de corrente
Js = double(dados(:,10))

%C�lculo do Is:
Is = A * Yb * Vs - A* Js

%C�lculo do Tens�o de n�
E = inv(Yn) * Is

%C�lculo da Tens�o de ramo
V = A_T * E

%Corrente nos Ramo:
J = Js + Yb*V - Yb*Vs

%Transformada Inversa de Laplace

%corrente nos ramo no tempo:
j = ilaplace(J)

%tens�o nos ramos no tempo:
v = ilaplace(V)

%tens�o nos n�s no tempo:
e = ilaplace(E)

%gr�ficos
t = 0:0.01:10
e_t = subs(e,t)
plot(t,e_t)



