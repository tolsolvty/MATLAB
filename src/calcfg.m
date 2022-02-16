function [f,g,tt] = calcfg(x,n,infA,supA,Ac,Ar,bc,br,weight)
% 
%   функция, которая вычисляет значение f максимизируемого распознающего 
%   функционала и его суперградиент g;  кроме того, она выдаёт вектор tt 
%   из значений образующих функционала в данной точке аргумента 
%
    %   для быстрого вычисления образующих распознающего функционала
    %   используются сокращённые формулы умножения интервальной матрицы
    %   на точечный вектор, через середину и радиус 
    Axc = Ac * x;
    Axr = Ar * abs(x);
    Axi = Axc - Axr;
    Axs = Axc + Axr;
    infs = bc - Axs;
    sups = bc - Axi;
    mags = max(-infs, sups);
    tt = weight .* (br - mags);
  
    %   сборка значения всего распознающего функционала 
    [f, mc] = min(tt);
  
    %   вычисление суперградиента той образующей распознающего функционала, 
    %   на которой достигается предыдущий минимум 
    isxnonnegative = x >= 0; 
    isxnegative = x < 0; 
    if -infs(mc) <= sups(mc) 
        ds = zeros(n,1); 
        ds(isxnonnegative) = infA(mc,isxnonnegative); 
        ds(isxnegative) = supA(mc,isxnegative); 
        g = weight(mc) * ds; 
    else 
        dl = zeros(n,1); 
        dl(isxnonnegative) = supA(mc,isxnonnegative); 
        dl(isxnegative) = infA(mc,isxnegative); 
        g = -weight(mc) * dl; 
    end 
end 
