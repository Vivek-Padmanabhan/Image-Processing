%% Object Tracker
%-----------------------------------------------------------------
% function Dim = track_objects(d,bw1,nr,nc,maxs)
%-----------------------------------------------------------------
function Dim = track_objects(d,bw1,nr,nc)
    [L count] = bwlabel(bw1);
    Dim = zeros(nr,nc);
    idx = 1;
    colors = {'r','g','b','y','c','m','k'};
    obid = [];
    obL = []; 
    for nn = 1:count
        ob = L ==nn;   
        [x y] = find(ob);
        [Dim levels] = cluster(d,bw1);
        for kk = 1:length(levels)
            % Find the same level in previosly detected objects
            if ~isempty(obid) % If not empty
                match = 0;
                for oo = 1:length(obid)
                    diff = abs(levels(kk)-obid(oo));
                    if diff<=4 % if diff less then one then same object
                        objectid = obL(oo);
                        match = 1;
                        obidtemp(kk) = obid(oo);
                        obLtemp(kk) = objectid;
                        break;
                    end    
                end
                if match~=1
                    obid = [obid levels(kk)];
                    % Take empty value
                    for ii1 = 1:7
                        if ~ismember(ii1,obL)
                            obL = [obL ii1];
                            break;
                        end
                    end
                    objectid = obL(end);
                    obidtemp(kk) = levels(kk);
                    obLtemp(kk) = objectid; 
                end    
            else
                obid = levels(kk);
                objectid = 1;
                obidtemp(kk) = levels(kk);
                obLtemp(kk) = objectid;   
            end
            ob1 = Dim ==levels(kk);
            ob1 = bwareaopen(ob1,200);
            [x1 y1] = find(ob1);
            co = [min(y1) min(x1) max(y1)-min(y1) max(x1)-min(x1)];
            rectangle('position',co,'edgecolor',colors{objectid})
            text(co(1), co(2),num2str(levels(kk)),'color','r')
            idx = idx+1; 
        end
        obid = obidtemp;
        obL = obLtemp;
    end
end