function D = GH(L,R,M)

    D = L;
    D(M==2,:) = R(M==2,:);    

end