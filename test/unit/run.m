[~, results] = evalc('runtests()');

T = table(results);
T.Row = T.Name;
disp(T(:, {'Passed', 'Duration'}));
