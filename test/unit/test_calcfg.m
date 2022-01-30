N = 1000;
EPS = 1e-8;
TOL = 1e-6;

addpath(fullfile('..', '..', 'src'));

rng('default');

listing = dir('data');
for file = listing(~[listing.isdir])'
    
    load(fullfile(file.folder, file.name));
    
    Ac = (infA + supA) / 2;
    Ar = (supA - infA) / 2;
    
    bc = (infb + supb) / 2;
    br = (supb - infb) / 2;
    
    weight = ones([m, 1]);
    
    for i = 1 : N
        
        x = 2 * (rand([n, 1]) - 0.5) * 10 ^ randi([0, ceil(log10(max(1, norm(gt_argmax)))) + 1]);
        [~, g, ~] = calcfg(x, n, infA, supA, Ac, Ar, bc, br, weight);
        
        numerical_g = zeros([n, 1]);
        for j = 1 : n
            
            h = EPS * max(1, abs(x(j)));
            e = double((1 : n)' == j);
            step = h * e;
            
            x_plus_step = x + step;
            f_x_plus_step = calcfg(x_plus_step, n, infA, supA, Ac, Ar, bc, br, weight);
            
            x_minus_step = x - step;
            f_x_minus_step = calcfg(x_minus_step, n, infA, supA, Ac, Ar, bc, br, weight);
            
            numerical_g(j) = (f_x_plus_step - f_x_minus_step) / (2 * h);
        end
        
        assert(norm(g - numerical_g) / max([1, norm(g), norm(numerical_g)]) < TOL);
    end
end
