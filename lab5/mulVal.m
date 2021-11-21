function m = mulVal( vec )
    r=size(vec);
    m=1;
    for i=1:r(2)
        m=m*vec(i);
    end
end

