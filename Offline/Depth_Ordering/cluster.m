function D = cluster(D1,bw1)


[a b] = hist(D1(:),1:2:30);

a(1:3) = 0;

a(a<max(a)*0.2)=0;


[L count] = bwlabel(a);

if count>0
    D = zeros(size(D1,1),size(D1,2),count);
    for ii = 1:count
        v(ii) = mean(b(L ==ii));

        D(:,:,ii) = abs(D1-v(ii));

    end

    [val ix] = min(D,[],3);

    D = v(ix).*bw1;
else
    D = D1;
end




