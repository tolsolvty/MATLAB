N = 1000;
EPS = 1e-8;
TOL = 1e-6;

addpath(fullfile('..', '..', 'src'));

rng('default');

listing = dir('data');
for file = listing(~[listing.isdir])'
    
    load(fullfile(file.folder, file.name));
    weight = ones([m, 1]);
    
    for i = 1 : N
        
        x = 2 * (rand([n, 1]) - 0.5) * 10 ^ randi([0, ceil(log10(max(1, norm(gt_argmax)))) + 1]);
        [~, g, ~] = calcfg(x, m, n, infA, supA, infb, supb, weight);
        
        numerical_g = zeros([n, 1]);
        for j = 1 : n
            
            h = EPS * max(1, abs(x(j)));
            step = h * double((1 : n)' == j);
            
            x_plus_step = x + step;
            f_x_plus_step = calcfg(x_plus_step, m, n, infA, supA, infb, supb, weight);
            
            x_minus_step = x - step;
            f_x_minus_step = calcfg(x_minus_step, m, n, infA, supA, infb, supb, weight);
            
            numerical_g(j) = (f_x_plus_step - f_x_minus_step) / (2 * h);
        end
        
        assert(norm(g - numerical_g) / max(1, max(norm(g), norm(numerical_g))) < TOL);
    end
end
