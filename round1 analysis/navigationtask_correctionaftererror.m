
subjectIDs = {'s3', 's4', 's7','s10','s11'};
subjectInitial = {'n','j','m'};
difficulty = {'L', 'M', 'S'};

figure(1), clf
figure(2), clf
subpnum = 1;

% to put into for loop
subs = 1;

% to put into for loop
for mode = 1:3;
    
    for diffi = 1:3;
        
        subject = subjectIDs{subs};
        subIn = subjectInitial{mode};
        
        isLoad = true;
        
        if isLoad
            % logfile
            log = xlsread([cd '\' subject '\' 'navigation_summary_' subject '_' subIn '.csv']);
            % detailed data
            [alldata, txt, ~] = xlsread([cd '\' subject '\' 'navigation_detail_' subject '_' subIn '.csv']);
            
            if size(alldata,2) == 21 % error bc of way matlab interprets 0,1,2 vs L,M,S
                alldata(:,1:2) = [];
            end
        else
            disp('File Not Loaded')
        end
        
        
        %sort the easy data
        idxMode = strcmp(txt(:,2),difficulty{diffi});
        %note that the txt data has a header at the top so delete the first entry
        idxMode(1) = [];
        
        for LorR = 1:2
            
            data = alldata(idxMode,:);
            isCollide = find(data(:,10) == LorR);
            
            if isempty(isCollide)
                disp('No Collisions')
                break 
            end
            
            % find the number of times collisions happen
            indColl = find(diff(isCollide) > 1);
            idxCollstart = [isCollide(1); isCollide(indColl+1)];
            idxCollend = [isCollide(indColl); isCollide(end)];
            
            % add a little to the front and back of the collision
            interval = mean(diff(data(:,1))); % 55Hz or 11Hz. Ie. 18ms or 90ms.
            idxCollstartMore = idxCollstart - round(0/interval);
            idxCollendMore = idxCollend + round(1000/interval);
            
            % plot path and colliding positions
            %figure(1), clf, hold on
            %plot(data(:,2), data(:,3),'b', data(isCollide,2), data(isCollide,3), 'ro') ...
                            %data(isCollideR,2), data(isCollideR,3), 'go')
            
            % find the head of each collision
            for iC = 1:length(idxCollstart)
                %plot(data(idxCollRstartMore(iC):idxCollRendMore(iC),2),data(idxCollRstartMore(iC):idxCollRendMore(iC),3),'kx')
                xRStart = data(idxCollstart(iC)+1,2) - data(idxCollstart(iC),2); %#ok<*SAGROW>
                yRStart = data(idxCollstart(iC)+1,3) - data(idxCollstart(iC),3);
                dirR(iC) = atan2d(yRStart, xRStart);
                
                if idxCollendMore(iC) > size(data,1)
                    idxCollendMore(iC) = size(data,1);
                end
                
                thisVecX = data(idxCollstartMore(iC):idxCollendMore(iC),2);
                thisVecY = data(idxCollstartMore(iC):idxCollendMore(iC),3);
                thisVecX = thisVecX - thisVecX(1);
                thisVecY = thisVecY - thisVecY(1);
                
                vecR = [cosd(-dirR(iC)) -sind(-dirR(iC)); sind(-dirR(iC)) cosd(-dirR(iC))]*[thisVecX, thisVecY]';
                
                figure(LorR)
                subplot(3,3,subpnum), hold on
                plot(vecR(1,:), vecR(2,:), 'b')
                title([subIn ': ' difficulty{diffi}])
                ylim([-10 10])
                drawnow
            end
            
        end %LorR
        
        subpnum = subpnum + 1;
    end % diffi
    
end % mode

% example of rotation matrix
% x = 1:10; y = 1:10;
% xyR = [cosd(-45) -sind(-45); sind(-45) cosd(-45)]*[x; y]
% plot(xyR(1,:), xyR(2,:))
