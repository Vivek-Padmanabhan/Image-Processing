function [D level]= cluster(D1,bw1)

D1(~bw1)=31;
[a b] = hist(D1(:),1:2:31);

D1(~bw1)=0;
a(end) = 0;

a(a<max(a)*0.05)=0;


[L count] = bwlabel(a);
count

if count>0
    D = zeros(size(D1,1),size(D1,2),count);
    for ii = 1:count
        v(ii) = mean(b(L ==ii));

        D(:,:,ii) = abs(D1-v(ii));
    end

    [val ix] = min(D,[],3);

    D = v(ix).*bw1;
    level = v;
else
    D1(bw1) = mean2(D1(bw1));
    D = D1;
    level = mean2(D1(bw1));
end




