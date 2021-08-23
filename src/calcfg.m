function [f,g,tt] = calcfg(x,infA,supA,Ac,Ar,bc,br,weight)
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
    infs = bc - (Axc + Axr);
    sups = bc - (Axc - Axr);
    tt = weight .* (br - max(abs(infs), abs(sups)));
  
    %   сборка значения всего распознающего функционала 
    [f, mc] = min(tt);
  
    %   вычисление суперградиента той образующей распознающего функционала, 
    %   на которой достигается предыдущий минимум 
    isxnonnegative = x >= 0; 
    isxnegative = x < 0; 
    if -infs(mc) <= sups(mc) 
        ds(isxnonnegative,1) = infA(mc,isxnonnegative); 
        ds(isxnegative,1) = supA(mc,isxnegative); 
        g = weight(mc) * ds; 
    else 
        dl(isxnonnegative,1) = supA(mc,isxnonnegative); 
        dl(isxnegative,1) = infA(mc,isxnegative); 
        g = -weight(mc) * dl; 
    end 
end 
