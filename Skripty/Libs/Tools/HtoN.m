function N = HtoN(p)
    N = zeros(size(p));
    N(p=='L') = 1;
    N(p=='R' | p=='P') = 2;
    
end