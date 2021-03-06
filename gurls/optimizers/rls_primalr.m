function [cfr] = rls_primalr(X,y, opt)
% rls_primalr(X, y, opt)
% computes a classifier for the primal formulation of RLS.
% It uses a randomized method to solve the associated linear system.
% The regularization parameter is set to the one found in opt.paramsel.
% In case of multiclass problems, the regularizers need to be combined with the opt.singlelambda function.
%
% INPUTS:
% -OPT: struct of options with the following fields:
%   fields that need to be set through previous gurls tasks:
%		- paramsel.lambdas (set by the paramsel_* routines)
%   fields with default values set through the defopt function:
%		- singlelambda
% 
%   For more information on standard OPT fields
%   see also defopt
% 
% OUTPUT: structure with the following fields:
% -W: matrix of coefficient vectors of rls estimator for each class
% -C: empty matrix
% -X: empty matrix
% -dcomptime: time required for computing the singular value decomposition
% -rlseigtime: time required for computing the estimator given the SVD

lambda = opt.singlelambda(opt.paramsel.lambdas);

%fprintf('\tSolving primal RLS using Randomized SVD...\n');
[n,d] = size(X);


indices = 1:size(X,1);
if isprop(opt,'split_fixed_indices') && isprop(opt,'notTrainOnValidation') && opt.notTrainOnValidation
    indices = opt.split_fixed_indices;
end

n = numel(indices);

XtX = X(indices,:)'*X(indices,:); % n\lambda is added in rls_eigen;

% tic;
k = max(round(opt.eig_percentage*d/100),1);
[Q,L,U] = tygert_svd(XtX,k);
% cfr.dcomptime = toc;
Q = double(Q);
L = double(diag(L));

Xty = X(indices,:)'*y(indices,:);

if isprop(opt,'W0') 
	Xty = Xty + opt.W0;
end

% tic;

cfr.W = rls_eigen(Q, L, Q'*Xty, lambda,d);
% cfr.rlseigtime = toc;

cfr.C = [];
cfr.X = [];
