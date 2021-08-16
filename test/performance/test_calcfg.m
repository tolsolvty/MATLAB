addpath(fullfile('..', '..', 'src'));

load(fullfile('data', '1000.mat'));
weight = ones([m, 1]);

mid_A = (infA + supA) / 2;
mid_b = (infb + supb) / 2;
x = mid_A \ mid_b;

%%
calcfg(x, m, n, infA, supA, infb, supb, weight);
