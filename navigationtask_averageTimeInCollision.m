clc; clear;


subjectIDs = {'s1', 's2', 's3','s4','s5','s6', 's7', 's8','s9','s10', ...
                's11', 's12', 's13', 's14','s15','s16', 's17', 's18', 's19', 's20'};
subjectInitial = {'n','j','m'};
difficulty = {'L', 'M', 'S'};

avgTimess = nan(3,3,length(subjectIDs)); % < [nL nM nS; jL, jM....];
% row = mode; col = diffi; depth = subs 

% to put into for loop
for subs = 1:20
    
    if subs == 13 || subs == 19
        continue
    end
    
    % to put into for loop
    for mode = 1:3;
        
        for diffi = 1:3;
            
            subject = subjectIDs{subs};
            subIn = subjectInitial{mode};
            
            isLoad = true;
            
            if isLoad
                % detailed data
                [alldata, txt, ~] = xlsread([cd '\KeshRawData\' subject '\' 'navigation_detail_' subject '_' subIn '.csv']);
                
                if size(alldata,2) == 21 % error bc of way matlab interprets 0,1,2 vs L,M,S
                    keyboard
                end
            else
                disp('File Not Loaded')
            end
            
            %sort the easy data
            idxMode = strcmp(txt(:,2),difficulty{diffi});
            %note that the txt data has a header at the top so delete the first entry
            idxMode(1) = [];
            
            
            data = alldata(idxMode,:);
            isCollide = find(data(:,10) == 1 | data(:,10) == 2);
            
            if isempty(isCollide)
                disp('No Collisions')
                continue
            end
            
            
            % find the number of times collisions happen
            indColl = find(diff(isCollide) > 1);
            numColl = length(indColl) + 1;
            
            % total number of indexes collisions were occuring
            numIdxColl = length(isCollide);
            
            % frame rate;
            interval = mean(diff(data(:,1))); % 55Hz or 11Hz. Ie. 18ms or 90ms.
            
            % total time spend in collision
            timecoll = numIdxColl * interval; % time in ms
            
            avgTimess(mode, diffi, subs) = timecoll/numColl;
            
            
            fprintf('Subject %i, Mode %s, Difficulty %s \n', subs, subIn, difficulty{diffi})
        end % diffi
        
    end % mode
    
end % subs


%% Go through and plot out the bar graphs for all subjects and then average them all

for subs = 1:20
    
    if subs == 13 || subs == 19
        continue
    end

    figure(1), clf
    barweb(avgTimess(:,:,subs),zeros(3), 1, {'N', 'J', 'M'})
    title(['Subject ' num2str(subs)])
    legend('L','M','S')
%    saveas(gcf,num2str(subs), 'pdf')
end

figure(2)
barweb(nanmean(avgTimess,3), nanstd(avgTimess,1,3), 1, {'N', 'J', 'M'})
title('All Subjects: Average Time in Collision')
legend('L','M','S')
