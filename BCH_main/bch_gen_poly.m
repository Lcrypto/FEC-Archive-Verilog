 
%n = 255; k = 171; 
% n = 255; k = 179; 
%n = 255; k = 131; 
%n = 255; k = 223; 
%n = 255; k = 231; 
n = 255; k = 239; 
prim_poly = 369;
%n = 511; k = 457; prim_poly = 529; 
%n = 127; k = 50; prim_poly = 131;
r = bchgenpoly(n,k,prim_poly);

%n = 15; k = 5; 
%r = bchgenpoly(n,k);

arr = zeros(1, length(r));
str = '';
for i=1:length(r)
    %t = r(length(r) + 1 - i);
    t = r(i);
    if (t.x == 1)
        arr(i) = 1; 
        str = [str '1'];
    else 
        str = [str '0'];
    end
end

arr;
str 
