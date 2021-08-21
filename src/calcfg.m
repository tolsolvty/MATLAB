function [f,g,tt] = calcfg(x,m,n,infA,supA,infb,supb,weight)
% 
%   функция, которая вычисляет значение f максимизируемого распознающего 
%   функционала и его суперградиент g;  кроме того, она выдаёт вектор tt 
%   из значений образующих функционала в данной точке аргумента 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   предварительное размещение рабочих массивов 
  
infs = zeros(m,1); 
sups = zeros(m,1); 
tt = zeros(m,1); 
dl = zeros(n,1); 
ds = zeros(n,1); 
dd = zeros(n,m); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   вычисляем значение распознающего функционала и матрицу dd, 
    %   составленную из суперградиентов его образующих 
    
    for i = 1:m 
        los = 0.5*(infb(i)+supb(i));
        sus = los; 
        for j = 1:n
            if x(j) >= 0  
                los = los - supA(i,j)*x(j); 
                sus = sus - infA(i,j)*x(j); 
            else 
                los = los - infA(i,j)*x(j); 
                sus = sus - supA(i,j)*x(j); 
            end 
        end 
        %   нижний и верхний концы интервала, который получается  
        %   под модулем в выражении для i-ой образующей 
        infs(i) = los; 
        sups(i) = sus; 
    end 
    
    %   вычисление значения i-ой образующей распознающего 
    %   функционала и её суперградиента 
    for i = 1:m 
        alos = abs(infs(i));  asus = abs(sups(i)); 
        %   вычисление суперградиента dl нижнего конца
        for j = 1:n 
            dm = infA(i,j);
            dp = supA(i,j);
            if x(j) < 0
                dl(j) = dm;
            else 
                dl(j) = dp;
            end
        end
        %   вычисление суперградиента ds верхнего конца 
        for j = 1:n 
            dm = supA(i,j);
            dp = infA(i,j);
            if x(j) < 0 
                ds(j) = dm;
            else
                ds(j) = dp;
            end
        end
        %   сборка полного суперградиента i-ой образующей
        if alos ~= asus
            if alos < asus 
                mags = asus;  dd(:,i) = weight(i)*ds; 
            else 
                mags = alos;  dd(:,i) = -weight(i)*dl; 
            end 
        else
            mags = alos; 
            if sups(i) > 0 
                dd(:,i) = weight(i)*ds; 
            else 
                dd(:,i) = -weight(i)*dl; 
            end
        end 
        %   нахождение и запоминание значения i-ой образующей 
        tt(i) = weight(i)*(0.5*(supb(i) - infb(i)) - mags);
    end  
   
    %   выбираем минимальную по значению образующую
    %   и конструируем общий суперградиент 
    [f,mc] = min(tt);
    g = dd(:,mc);
  
end 
