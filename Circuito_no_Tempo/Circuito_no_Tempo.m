%Trabalho de circuitos Laplace
clear

%declarando s como vari�vel simb�lica
syms s;
syms t;

%Receber arquivo csv e transformar a matriz de entrada para o formato sym
dados = csvread('tabela_de_entrada _senoidal.csv',1,0);

% matriz dos n�s
nos = double(dados(:,2:3))

%o n�mero de n�s ser� dado pelo m�ximo valor de n� de 
%ambas as colunas
numero_de_nos = max(max(nos))

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

% ----------Mauricio-------

%matriz de incid�ncia reduzida

% como matriz_inc_completa � LD, podemos trabalhar com
% com uma matriz reduzida (A), retirando a �ltima linha
A = matriz_inc_completa(1:end-1,:)

%A transposta da matriz reduzida:
A_T = transpose(A) 

% Matriz de admit�ncia de ramo Yb:

%imped�ncia resultante para cada ramo:

%resistiva
R = double(dados(:, 4))
%indutiva
L = double(dados(:,5))
Xl = s * L
%capacitiva
C = double(dados(:,7))
Xc = 1./(s*C)
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

%coluna 9: Tipos de fontes de tens�o
for ramo = 1:numero_de_ramos
    if dados(ramo,9) == 1
        %Fontes Cont�nuas
        %Fontes de tens�o 
        %coluna 10: Vind, coluna 8: V0
        Vs = dados(:,10) + dados(:,8);
        %coluna 6: I0
        Vs = laplace(sym(Vs)) + L.*double(dados(:,6))

        %Matrix das fontes de corrente, coluna 12: Iind
        Js = dados(:,12)
        Js = laplace(sym(Js))
        
    end
    if dados(ramo,9) == 2
        %Fontes Senoidais
        
        w = dados(:,14)
        %Fontes de tens�o, coluna 10: Vind 
        mod_Vs = dados(:,10)
        fase_Vs = dados(:,11)
        
        Vs = mod_Vs .* cos(w*t + fase_Vs) 
        Vs = laplace(sym(Vs)) + L.*double(dados(:,6))
         
        %Fontes de corrente, coluna 12: Iind
        mod_Js = dados(:,12)
        fase_Js = dados(:,13)
        Js = mod_Js .* cos(w*t + fase_Js) 
        Js = laplace(sym(Js))
    end
end



%-------Vitor

%C�lculo do Is:
Is =( A * Yb * Vs) - (A* Js)

%C�lculo do Tens�o de n�
E = inv(Yn) * Is

%C�lculo da Tens�o de ramo
V = A_T * E

%Corrente nos Ramo:
J = Js + Yb*V - Yb*Vs

%Transformada Inversa de Laplace

%corrente nos ramos no tempo:
j = ilaplace(J)

%tens�o nos ramos no tempo:
v = ilaplace(V)

%tens�o nos n�s no tempo:
e = ilaplace(E)

%gr�ficos
tmax = 40e-3
passo = 1e-4 
t = 0:passo:tmax 
%e_t = subs(e,t)
%v_t = subs(v,t)
%j_t = subs(j,t)

%tens�o no resistor de 10 ohms
v0 = 10*j(3)
v0_t = subs(v0, t)

%gr�fico da tens�o no resistor de 10 ohm, desejado
figure
plot(t,v0_t)
axis([0 tmax -60 60])
set(gca,'FontSize',16)
xlabel('tempo (s)','Interpreter','LaTex','FontSize',18)
ylabel('Tens�o (V)','Interpreter','LaTex','FontSize',18)
grid()
title ('Tens�o no resistor de 10 ohms')


%gr�fico das tens�es de n�
% figure
% plot(t,e_t)
% axis([0 2e-4 0 6])
% set(gca,'FontSize',16)
% xlabel('tempo (s)','Interpreter','LaTex','FontSize',18)
% ylabel('Tens�o (V)','Interpreter','LaTex','FontSize',18)
% title ('Tens�es nos n�s')
% T1={}
% for i=1:numero_de_ramos
% T1(i)={strcat('E',num2str(i))};
% end
% grid()
% legend(T1)
% 
% 
% %gr�fico das tens�es nos ramos
% figure
% plot(t,v_t)
% axis([0 2e-4 0 6])
% set(gca,'FontSize',16)
% xlabel('tempo (s)','Interpreter','LaTex','FontSize',18)
% ylabel('Tens�o (V)','Interpreter','LaTex','FontSize',18)
% title ('Tens�o nos ramos')
% T2={}
% for i=1:numero_de_ramos
% T2(i)={strcat('V',num2str(i))};
% end
% grid()
% legend(T2)
% 
% 
% %gr�fico das correntes nos ramos
% figure
% plot(t,j_t)
% axis([0 2e-4 0 6])
% set(gca,'FontSize',16)
% xlabel('tempo (s)','Interpreter','LaTex','FontSize',18)
% ylabel('Corrente (A)','Interpreter','LaTex','FontSize',18)
% title ('Corrente nos ramos')
% T3={}
% for i=1:numero_de_ramos
% T3(i)={strcat('J',num2str(i))};
% end
% legend(T3)
% 
% %-----Tiago
% 
