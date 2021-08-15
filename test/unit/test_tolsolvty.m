TOL = 1e-6;

addpath(fullfile('..', '..', 'src'));

listing = dir('data');
for file = listing(~[listing.isdir])'
    
    load(fullfile(file.folder, file.name));
    
    [~, tolmax, argmax, ~, ccode] = evalc('tolsolvty(infA, supA, infb, supb)');
    
    assert(ccode == 1 || ccode == 3);
    assert(abs(gt_tolmax - tolmax) / max(1, abs(gt_tolmax)) < TOL);
    assert(norm(gt_argmax - argmax) / max(1, norm(gt_argmax)) < TOL);
end
