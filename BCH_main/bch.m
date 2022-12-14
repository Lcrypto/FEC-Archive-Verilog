function [genpoly, t] = bchgenpoly(N,K,varargin); 
%BCHGENPOLY  Generator polynomial of BCH code. 
%   GENPOLY = BCHGENPOLY(N,K) returns the narrow-sense generator polynomial of a  
%   BCH code with codeword length N and message length K.  The codeword  
%   length N must have the form 2^m-1 for some integer m between 3 and 16.  The  
%   output GENPOLY is a Galois row vector that represents the coefficients of  
%   the generator polynomial in order of descending powers.  The narrow-sense  
%   generator polynomial is (X-alpha)*(X-alpha^2)*...*(X-alpha^(N-K)), where  
%   alpha is a root of the default primitive polynomial for the field GF(N+1). 
%    
%   GENPOLY = BCHGENPOLY(N,K,PRIM_POLY) is the same as the syntax above, except  
%   that PRIM_POLY specifies the primitive polynomial for GF(N+1) that has alpha  
%   as a root.  PRIM_POLY is an integer whose binary representation indicates  
%   the coefficients of the primitive polynomial in order of descending powers.  
%   To use the default primitive polynomial, set PRIM_POLY to []. 
% 
%   [GENPOLY,T] = BCHGENPOLY(...) returns T, the error-correction capability of  
%   the code. 
% 
%   See also BCHENC, BCHDEC.  
 
% Copyright 1996-2003 The MathWorks, Inc. 
% $Revision: 1.1.6.4 $  $ $  
 
 
% Initial checks 
 N= 4095;
 K = 4059;
t = 3; 
t2 = 2*t; 
 varargin =4249;
prim_poly = 1; 
 
m = log2(N+1); 
 prim_poly = varargin;  
    

 
% Alpha is the primitive element of this GF(2^m) field 
if prim_poly == 1 
    alpha = gf(2,m); 
else 
    alpha = gf(2,m,prim_poly); 
end 
 
% genpoly = LCM([1 alpha.^k])... for  k = 1 : 2t-1) 
 
% Find all the minimun polynomials, add them to list of minimum 
% polynomials, if they're not there yet. Then convolve all the minimum 
% polynomials to make the generator polynomial. 
 
minpol_list = minpol(alpha); 
 
for k=[1:t2-1] 
    minpoly = minpol(alpha.^k); 
     
    [len,w] = size(minpol_list);  
    minpol_mat = repmat(minpoly, [len 1]); 
     
    eq = (minpol_mat == minpol_list); 
    if(~any(sum(eq') == w)) 
        minpol_list = [minpol_list;minpoly];     
    end 
end 
 
% convolve all the rows of the minpol_list with each other. 
len = size(minpol_list,1); 
genpoly  = 1; 
for(i = 1:len) 
    genpoly = conv(genpoly,minpol_list(i,:)); 
end 
 
% strip any leading zeros 
% the size of the generator polynomial should be N-K+1 
genpoly = genpoly( end-(N-K) :end); 
 
% EOF 