function d = pitts(uf, ul)
    L = 7.622;
    arb = 3.04878;
    k = 0.35;
    b = 0;
    if ul > uf
        b = 0.1;
    end

    d = L + arb + k*uf + b*k*(ul-uf)^2;
end