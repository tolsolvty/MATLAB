function [tolmax,argmax,envs,ccode] = tolsolvty(infA,supA,infb,supb,varargin) 
%  
%   Вычисление максимума распознающего функционала допускового множества 
%   решений для интервальной системы линейных алгебраических уравнений. 
% 
%   TOLSOLVTY(infA, supA, infb, supb) выдаёт значение максимума распознающего 
%   функционала допускового множества решений для интервальной системы линейных 
%   уравнений Ax = b, у которой матрицы нижних и верхних концов элементов A  
%   равны infA и supA, а векторы нижних и верхних концов правой части b  равны 
%   infb  и  supb  соответственно. Дополнительно  процедура  выводит  аргумент 
%   максимума - допусковое решение или псевдорешение интервальной линейной 
%   системы Ax = b, имеющее наибольшую меру разрешимости, а также  заключение  
%   о пустоте/непустоте допускового множества решений и диагностику работы. 
%  
%   Синтаксис вызова:
%       [tolmax,argmax,envs,ccode] = tolsolvty(infA,supA,infb,supb, ... 
%                                           iprn,weight,epsf,epsx,epsg,maxitn) 
%  
%   Обязательные входные аргументы функции: 
%        infA, supA - матрицы левых и правых концов интервальных коэффициентов 
%                     при  неизвестных  для  интервальной  системы  линейных 
%                     алгебраических уравнений; они могут быть прямоугольными, 
%                     но должны иметь одинаковые размеры; 
%        infb, supb - векторы левых и правых концов интервалов  правой части 
%                     интервальной системы линейных алгебраических уравнений. 
%  
%   Необязательные входные аргументы функции:
%              iprn - выдача протокола работы; если iprn > 0 - информация 
%                     о ходе процесса печатается через каждые iprn-итераций;
%                     если iprn <= 0 (значение по умолчанию), печати нет;
%            weight - положительный вектор весовых коэффициентов для образующих 
%                     распознающего функционала, по умолчанию берётся равным 
%                     вектору со всеми единичными компонентами; 
%              epsf - допуск на точность по значению целевого функционала,
%                     по умолчанию устанавливается 1.e-6;
%              epsx - допуск на точность по аргументу целевого функционала,
%                     по умолчанию устанавливается 1.e-6;
%              epsg - допуск на малость нормы суперградиента функционала,
%                     по умолчанию устанавливается 1.e-6;
%            maxitn - ограничение на количество шагов алгоритма, 
%                     по умолчанию устанавливается 2000.
%  
%   Выходные аргументы функции: 
%            tolmax - значение максимума распознающего функционала;
%            argmax - доставляющий его вектор значений аргумента,который 
%                     лежит в допусковом множестве решений при tolmax>=0;
%              envs - значения образующих распознающего функционала в точке 
%                     его максимума, отсортированные по возрастанию; 
%             ccode - код завершения алгоритма (1 - по допуску epsf на 
%                     изменения значений функционала, 2 - по допуску epsg 
%                     на суперградиент, 3 - по допуску epsx на вариацию 
%                     аргумента, 4 - по числу итераций, 5 - не найден 
%                     максимум по направлению). 
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
%    Эта  программа  выполняет  исследование допускового множества решений 
%    для интервальной системы  линейных  алгебраических  уравнений  Ax = b 
%    с интервальной матрицей A = [infA, supA] и интервальным вектором правой 
%    части  b = [infb, supb] с помощью максимизации распознающего функционала 
%    допускового множества решений этой системы. См. подробности в 
%   
%       Шарый С.П. Конечномерный интервальный анализ. - Новосибирск: XYZ, 
%       2020. - Электронная книга, доступная на http://www.nsc.ru/interval/,
%       параграф 6.4;
%       Shary S.P. Solving the linear interval tolerance problem //
%       Mathematics and Computers in Simulation. - 1995. - Vol. 39.
%       - P. 53-85.
%   
%   Вектор весовых коэффициентов для образующих распознающего функционала 
%   (фактически, для отдельных уравнений системы) позволяет учитывать разную 
%   ценность отдельных уравнений, соответствующую неравноценным измерениям 
%   в задаче восстановления зависимостей и т.п. 
%
%   Для  максимизации  вогнутого  распознающего  функционала  используется 
%   вариант алгоритма суперградиентного подъёма с растяжением пространства 
%   в направлении  разности  последовательных суперградиентов, предложенный
%   (для случая минимизации) в работе 
%       Шор Н.З., Журбенко Н.Г. Метод минимизации, использующий операцию
%       растяжения пространства в направлении разности двух последовательных 
%       градинетов // Кибернетика. - 1971. - №3. - С. 51-59. 
%   
%   В качестве основы этой части программы использована процедура негладкой 
%   оптимизации ralgb5, разработанная и реализованная П.И.Стецюком (Институт 
%   кибернетики НАН Украины, Киев). Подробно этот алгоритм описан в статье 
% 
%       Стецюк П.И. Субградиентные методы ralgb5 и ralgb4 для минимизации 
%       овражных выпуклых функций // Вычислительные технологии. - 2017. - 
%       Т. 22, № 2. - С. 127-149. 
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%   С.П. Шарый, ФИЦ ИВТ, НГУ, 2007-2019 гг. 
%   М.Л. Смольский, СПбГПУ, 2019-2020 г. 
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
%   
%   проверка корректности входных данных 
%   
  
mi = size(infA,1);  ni = size(infA,2);  
ms = size(supA,1);  ns = size(supA,2); 
if mi==ms   %   m - количество уравнений в системе 
    m = ms; 
else 
    error('Количество строк в матрицах левых и правых концов неодинаково')
end
if ni==ns 
    n = ns; %   n - количество неизвестных переменных в системе 
else 
    error('Количество столбцов в матрицах левых и правых концов неодинаково')
end 
  
ki = size(infb,1); 
ks = size(supb,1); 
if ki==ks 
    k = ks; 
else 
    error('Количество компонент у векторов левых и правых концов неодинаково')
end
if k~=m 
    error('Размеры матрицы системы не соответствуют размерам правой части') 
end
  
if ~all(all(infA <= supA)) 
    error('В матрице системы задан неправильный интервальный элемент') 
end 
  
if ~all(infb <= supb) 
    error('В векторе правой части задана неправильная интервальная компонента') 
end 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%   задание параметров алгоритма суперградиентного подъёма и прочих 
%
maxitn = 2000;          %   ограничение на количество шагов алгоритма
nsims  = 30;            %   допустимое количество одинаковых шагов
epsf = 1.e-6;           %   допуск на изменение значения функционала 
epsx = 1.e-6;           %   допуск на изменение аргумента функционала
epsg = 1.e-6;           %   допуск на норму суперградиента функционала
  
alpha = 2.3;            %   коэффициент растяжения пространства в алгоритме
hs = 1.;                %   начальная величина шага одномерного поиска
nh = 3;                 %   число одинаковых шагов одномерного поиска 
q1 = 0.9;               %   q1, q2 - параметры адаптивной регулировки
q2 = 1.1;               %       шагового множителя
  
iprn = 0;               %   печать о ходе процесса через каждые iprn-итераций
                        %   (если iprn < 0, то печать подавляется) 
weight = ones(m,1);     %   задание вектора весовых коэффициентов для образующих 
format short g;         %   формат вывода данных  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   формирование строковых констант для оформления протокола работы 
%
HorLine = '-------------------------------------------------------------';
TitLine = 'Протокол максимизации распознающего функционала Tol';
TabLine = 'Шаг        Tol(x)         Tol(xx)   ВычФун/шаг  ВычФун';
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   переназначение параметров алгоритма, заданных пользователем 
% 
if nargin >= 5 
    iprn = ceil(varargin{1}); 
    if nargin >= 6 
        weight = varargin{2}; 
        if size(weight,1)~=m 
            error('Размер вектора весовых коэффициентов задан некорректно') 
        end 
        if any( weight <= 0 ) 
            error(' Вектор весовых коэффициентов должен быть положительным') 
        end 
        if nargin >= 7 
            epsf = varargin{3}; 
            if nargin >= 8 
                epsx = varargin{4}; 
                if nargin >= 9 
                    epsg = varargin{5}; 
                    if nargin >= 10 
                        maxitn = varargin{6}; 
                    end
                end
            end
        end 
    end 
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
function [f,g,tt] = calcfg(x)
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
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   формируем начальное приближение x как решение либо псевдорешение 
%   'средней' точечной системы, если она не слишком плохо обусловлена,
%   иначе берём начальным приближением нулевой вектор 
% 
Ac = 0.5*(infA + supA);
Ar = 0.5*(supA - infA);
bc = 0.5*(infb + supb);
br = 0.5*(supb - infb);
sv = svd(Ac);
minsv = min(sv);
maxsv = max(sv);
  
if ( minsv~=0 && maxsv/minsv < 1.e+12 ) 
    x = Ac\bc; 
else
    x = zeros(n,1);
end 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Рабочие массивы:
%       B - матрица обратного преобразования пространства
%       vf - вектор приращений функционала на последних шагах алгоритма
%       g, g0, g1 - используются для хранения вспомогательных векторов,
%           суперградиента минимизируемого функционала и др.
  
B = eye(n,n);                   %   инициализируем единичной матрицей 
vf = realmax*ones(nsims,1);     %   инициализируем самыми большими числами 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%   установка начальных параметров
  
w = 1./alpha - 1.;
lp = iprn; 
  
[f, g0, tt] = calcfg(x); 
ff = f ;  xx = x;
cal = 1;  ncals = 1; 
  
if iprn > 0 
    fprintf('\n\t%52s\n',TitLine); 
    fprintf('%65s\n',HorLine); 
    fprintf('\t%50s\n',TabLine); 
    fprintf('%65s\n',HorLine); 
    fprintf('\t%d\t%f\t%f\t%d\t%d\n',0,f,ff,cal,ncals); 
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   основной цикл алгоритма: 
%       itn - счётчик числа итераций
%       xx  - приближение к аргументу максимума функционала
%       ff  - приближение к максимуму функционала 
%       cal - количество вычислений функционала на текущем шаге 
%     ncals - общее количество вычислений целевого функционала
%  
for itn = 1:maxitn;
    vf(nsims) = ff;
    %   критерий останова по норме суперградиента
    if  norm(g0) < epsg
        ccode = 2;  
        break
    end
    %   вычисляем суперградиент в преобразованном пространстве,
    %   определяем направление подъёма 
    g1 = B' * g0;
    g = B * g1/norm(g1); 
    normg = norm(g);
    %   одномерный подъём по направлению g:
    %       cal - счётчик шагов одномерного поиска,
    %       deltax - вариация аргумента в процессе поиска
    r = 1; 
    cal = 0; 
    deltax = 0;
    while ( r > 0. && cal <= 500 )
        cal = cal + 1; 
        x = x + hs*g; 
        deltax = deltax + hs*normg; 
        [f, g1, tt] = calcfg(x); 
        if f > ff 
            ff = f; 
            xx = x; 
        end 
        %   если прошло nh шагов одномерного подъёма, 
        %   то увеличиваем величину шага hs 
        if mod(cal,nh) == 0  
            hs = hs*q2; 
        end 
        r = g'*g1; 
    end 
    %   если превышен лимит числа шагов одномерного подъёма, то выход
    if cal > 500 
        ccode = 5; 
        break; 
    end 
    %   если одномерный подъём занял один шаг, 
    %   то уменьшаем величину шага hs 
    if cal == 1
        hs = hs*q1;
    end 
    %   уточняем статистику и при необходимости выводим её
    ncals = ncals + cal;
    if itn==lp
        fprintf('\t%d\t%f\t%f\t%d\t%d\n',itn,f,ff,cal,ncals); 
        lp = lp + iprn;
    end
    %   если вариация аргумента в одномерном поиске мала, то выход
    if deltax < epsx 
        ccode = 3;  
        break; 
    end
    %   пересчитываем матрицу преобразования пространства 
    dg = B' * (g1 - g0);
    xi = dg / norm(dg);
    B = B + w*(B*xi).*xi';
    g0 = g1;
    %   проверка изменения значения функционала, относительного 
    %   либо абсолютного, на последних nsims шагах алгоритма
    vf = circshift(vf,1);
    vf(1) = abs(ff - vf(1)); 
    if abs(ff) > 1
        deltaf = sum(vf)/abs(ff);
    else 
        deltaf = sum(vf);
    end
    if deltaf < epsf 
        ccode = 1;  
        break
    end 
    ccode = 4; 
end
  
tolmax = ff;
argmax = xx; 
  
%   сортируем образующие распознающего функционала по возрастанию 
tt = [(1:m)', tt];
[z,ind] = sort(tt(:,2));
envs = tt(ind,:);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   вывод результатов работы 
   
if iprn > 0
    if rem(itn,iprn)~=0
        fprintf('\t%d\t%f\t%f\t%d\t%d\n',itn,f,ff,cal,ncals); 
    end
    fprintf('%65s\n',HorLine); 
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
disp(' ');
if tolmax >= 0
    disp(' Допусковое множество решений интервальной линейной системы непусто ')
else 
    disp(' Допусковое множество решений интервальной линейной системы пусто ')
end 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
disp(' ');
if ( tolmax < 0. && abs(tolmax/epsx) < 10 ) 
    disp(' Абсолютное значение вычисленного максимума');
    disp('                          находится в пределах заданной точности'); 
    disp(' Перезапустите программу  с меньшими значениями  epsf и/или epsx');
    disp(' для получения большей информации о разрешимости рассматриваемой'); 
    disp(' задачи о допусках');
    disp(' ');
end 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
