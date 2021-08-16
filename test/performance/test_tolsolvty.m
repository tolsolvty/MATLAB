addpath(fullfile('..', '..', 'src'));

load(fullfile('data', '1000.mat'));

%%
evalc('tolsolvty(infA, supA, infb, supb)');
